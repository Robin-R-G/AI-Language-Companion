// supabase/functions/shared/agents/orchestrator.ts
// AI Orchestrator: routes requests to agents, manages pipelines, and enforces post-processing.

import type {
  LearningAgent,
  AgentRequest,
  AgentContext,
  AgentResult,
  AgentRequestOptions,
  AgentCapability,
  Pipeline,
  PipelineStage,
  OrchestratorConfig,
  AgentMetrics,
  PostProcessingResult,
} from './types.ts';
import {
  getAgent,
  findAgentForCapability,
  recordUsage,
  getAgentsByCapability,
} from './registry.ts';
import {
  getContainer,
  Tokens,
  getDefaultOrchestratorConfig,
} from './container.ts';
import { getAIProvider } from '../ai.ts';
import { recordMetrics, estimateCost, emitEvent } from './metrics.ts';

// ─── Request ID Generation ───────────────────────────────────────────────────

let requestCounter = 0;
function generateRequestId(): string {
  requestCounter++;
  return `req_${Date.now()}_${requestCounter}`;
}

// ─── Orchestrator ────────────────────────────────────────────────────────────

export class Orchestrator {
  private config: OrchestratorConfig;

  constructor(config?: Partial<OrchestratorConfig>) {
    this.config = { ...getDefaultOrchestratorConfig(), ...config };
  }

  /**
   * Route a request to the best agent for the given capability.
   */
  async route(
    capability: AgentCapability,
    input: string,
    context: AgentContext,
    options?: AgentRequestOptions
  ): Promise<AgentResult> {
    const requestId = generateRequestId();
    const agent = findAgentForCapability(capability, options?.preferredProvider);

    if (!agent) {
      throw new Error(`No agent found for capability: ${capability}`);
    }

    emitEvent({
      type: 'orchestrator:routed',
      requestId,
      agentId: agent.metadata.id,
      reason: `capability=${capability}, provider=${options?.preferredProvider ?? 'any'}`,
    });

    return this.executeAgent(agent, input, context, options, requestId);
  }

  /**
   * Execute a specific agent by ID.
   */
  async execute(
    agentId: string,
    input: string,
    context: AgentContext,
    options?: AgentRequestOptions
  ): Promise<AgentResult> {
    const requestId = generateRequestId();
    const agent = getAgent(agentId);

    if (!agent) {
      throw new Error(`Agent not found: ${agentId}`);
    }

    return this.executeAgent(agent, input, context, options, requestId);
  }

  /**
   * Execute multiple agents in parallel for independent capabilities.
   */
  async routeParallel(
    capabilities: AgentCapability[],
    input: string,
    context: AgentContext,
    options?: AgentRequestOptions
  ): Promise<Map<AgentCapability, AgentResult>> {
    const results = new Map<AgentCapability, AgentResult>();

    const tasks = capabilities.map(async (cap) => {
      try {
        const result = await this.route(cap, input, context, options);
        results.set(cap, result);
      } catch (error) {
        console.error(`Parallel agent failed for ${cap}:`, error);
      }
    });

    await Promise.allSettled(tasks);
    return results;
  }

  /**
   * Execute a pipeline of agents sequentially, with optional parallel stages.
   */
  async executePipeline(
    pipeline: Pipeline,
    initialInput: string,
    context: AgentContext,
    options?: AgentRequestOptions
  ): Promise<Map<string, AgentResult>> {
    const requestId = generateRequestId();
    const results = new Map<string, AgentResult>();

    emitEvent({
      type: 'orchestrator:pipeline-started',
      requestId,
      pipelineId: pipeline.id,
    });

    const startTime = Date.now();

    for (const stage of pipeline.stages) {
      const agent = getAgent(stage.agentId);
      if (!agent) {
        console.warn(`Pipeline stage agent not found: ${stage.agentId}`);
        continue;
      }

      // Check condition if defined
      if (stage.condition && !stage.condition(context)) {
        continue;
      }

      const input = stage.inputMapping(results);
      const result = await this.executeAgent(agent, input, context, options, requestId);
      results.set(stage.agentId, result);
    }

    // Execute parallel stages if defined
    if (pipeline.parallelStages) {
      for (const parallelGroup of pipeline.parallelStages) {
        const parallelTasks = parallelGroup.map(async (stage) => {
          const agent = getAgent(stage.agentId);
          if (!agent) return;

          if (stage.condition && !stage.condition(context)) return;

          const input = stage.inputMapping(results);
          const result = await this.executeAgent(agent, input, context, options, requestId);
          results.set(stage.agentId, result);
        });

        await Promise.allSettled(parallelTasks);
      }
    }

    emitEvent({
      type: 'orchestrator:pipeline-completed',
      requestId,
      pipelineId: pipeline.id,
      durationMs: Date.now() - startTime,
    });

    return results;
  }

  /**
   * Run mandatory post-processing agents on an agent result.
   */
  async runPostProcessing(
    result: AgentResult,
    context: AgentContext
  ): Promise<PostProcessingResult[]> {
    if (!this.config.enablePostProcessing) return [];

    const postProcessorIds = this.config.mandatoryPostProcessors;
    const postResults: PostProcessingResult[] = [];

    for (const agentId of postProcessorIds) {
      const agent = getAgent(agentId);
      if (!agent) continue;

      try {
        const output = JSON.stringify(result.output);
        const postResult = await this.executeAgent(
          agent,
          output,
          context,
          { skipPostProcessing: true },
          generateRequestId()
        );

        postResults.push({
          agentId,
          passed: (postResult.output as any)?.passed ?? true,
          issues: (postResult.output as any)?.issues ?? [],
          suggestions: (postResult.output as any)?.recommendations ?? [],
        });
      } catch (error) {
        console.error(`Post-processing agent ${agentId} failed:`, error);
        postResults.push({
          agentId,
          passed: false,
          issues: [`Post-processor ${agentId} failed: ${(error as Error).message}`],
          suggestions: [],
        });
      }
    }

    return postResults;
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  private async executeAgent(
    agent: LearningAgent,
    input: string,
    context: AgentContext,
    options?: AgentRequestOptions,
    requestId?: string
  ): Promise<AgentResult> {
    const reqId = requestId || generateRequestId();
    const startTime = Date.now();

    emitEvent({ type: 'agent:started', agentId: agent.metadata.id, requestId: reqId });

    try {
      const result = await agent.execute(input, context, {
        ...options,
        timeout: options?.timeout ?? this.config.globalTimeout,
      });

      recordUsage(agent.metadata.id);

      emitEvent({
        type: 'agent:completed',
        agentId: agent.metadata.id,
        requestId: reqId,
        metrics: result.metrics,
      });

      // Run post-processing unless skipped
      if (!options?.skipPostProcessing && this.config.enablePostProcessing) {
        const postResults = await this.runPostProcessing(result, context);
        result.postProcessingResults = postResults;

        emitEvent({
          type: 'agent:post-processed',
          agentId: agent.metadata.id,
          requestId: reqId,
          results: postResults,
        });
      }

      return result;
    } catch (error) {
      emitEvent({
        type: 'agent:failed',
        agentId: agent.metadata.id,
        requestId: reqId,
        error: (error as Error).message,
      });
      throw error;
    }
  }
}

// ─── Convenience: Create Orchestrator with Default Config ────────────────────

export function createOrchestrator(config?: Partial<OrchestratorConfig>): Orchestrator {
  return new Orchestrator(config);
}
