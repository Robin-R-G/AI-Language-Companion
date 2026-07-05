// supabase/functions/shared/agents/base-agent.ts
// Base class for all LearningAgents. Provides common execution logic,
// prompt compilation, AI provider calls, output validation, and metrics.

import type {
  LearningAgent,
  AgentMetadata,
  AgentContext,
  AgentResult,
  AgentRequestOptions,
  AgentMetrics,
} from './types.ts';
import { getContainer, Tokens } from './container.ts';
import { buildSystemPrompt, compilePrompt } from './prompt-loader.ts';
import { getAIProvider } from '../ai.ts';
import { estimateCost, recordMetrics } from './metrics.ts';

// ─── Base Agent ──────────────────────────────────────────────────────────────

export abstract class BaseLearningAgent implements LearningAgent {
  abstract readonly metadata: AgentMetadata;

  /**
   * Build the system prompt for this agent.
   * Override in subclasses for agent-specific prompt logic.
   */
  abstract buildPrompt(context: AgentContext): string;

  /**
   * Execute the agent: build prompt → call AI → parse output → record metrics.
   */
  async execute(
    input: string,
    context: AgentContext,
    options?: AgentRequestOptions
  ): Promise<AgentResult> {
    const startTime = Date.now();

    // Build messages
    const systemPrompt = this.buildPrompt(context);
    const messages = [
      { role: 'system' as const, content: systemPrompt },
      { role: 'user' as const, content: input },
    ];

    // Get AI provider
    const container = getContainer();
    let aiFactory: any;
    try {
      aiFactory = container.resolve(Tokens.AI_PROVIDER_FACTORY);
    } catch {
      aiFactory = getAIProvider();
    }

    // Call AI
    const aiResponse = await aiFactory.chatWithFallback(messages, {
      temperature: options?.temperature ?? this.metadata.temperature,
      maxTokens: options?.maxTokens ?? this.metadata.maxTokens,
      preferredProvider: options?.preferredProvider ?? this.metadata.providers[0],
    });

    // Parse output
    const { valid, parsed, errors } = this.validateOutput(aiResponse.content);

    // Build metrics
    const metrics: AgentMetrics = {
      latencyMs: Date.now() - startTime,
      tokensUsed: aiResponse.tokensUsed,
      costEstimate: estimateCost(aiResponse.provider, aiResponse.model, aiResponse.tokensUsed),
      provider: aiResponse.provider,
      model: aiResponse.model,
      qualityScore: valid ? 1.0 : 0.5,
    };

    // Record metrics
    recordMetrics({
      agentId: this.metadata.id,
      requestId: `auto_${Date.now()}`,
      latencyMs: metrics.latencyMs,
      tokensUsed: metrics.tokensUsed,
      costEstimate: metrics.costEstimate,
      provider: metrics.provider,
      model: metrics.model,
      success: true,
      qualityScore: metrics.qualityScore,
    });

    return {
      agentId: this.metadata.id,
      output: parsed ?? aiResponse.content,
      raw: aiResponse,
      metrics,
    };
  }

  /**
   * Default JSON output validation. Override for custom schemas.
   */
  validateOutput(output: string): { valid: boolean; parsed?: unknown; errors?: string[] } {
    try {
      const jsonMatch = output.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        return { valid: true, parsed };
      }
      return { valid: false, errors: ['No JSON found in output'] };
    } catch (e) {
      return { valid: false, errors: [`JSON parse error: ${(e as Error).message}`] };
    }
  }
}

// ─── Utility: Create Agent from Config ───────────────────────────────────────

export interface AgentConfig {
  metadata: AgentMetadata;
  promptBuilder: (context: AgentContext) => string;
  outputValidator?: (output: string) => { valid: boolean; parsed?: unknown; errors?: string[] };
}

export function createAgent(config: AgentConfig): LearningAgent {
  return {
    metadata: config.metadata,

    buildPrompt(context: AgentContext): string {
      return config.promptBuilder(context);
    },

    async execute(
      input: string,
      context: AgentContext,
      options?: AgentRequestOptions
    ): Promise<AgentResult> {
      const startTime = Date.now();
      const systemPrompt = config.promptBuilder(context);

      const messages = [
        { role: 'system' as const, content: systemPrompt },
        { role: 'user' as const, content: input },
      ];

      const container = getContainer();
      let aiFactory: any;
      try {
        aiFactory = container.resolve(Tokens.AI_PROVIDER_FACTORY);
      } catch {
        aiFactory = getAIProvider();
      }

      const aiResponse = await aiFactory.chatWithFallback(messages, {
        temperature: options?.temperature ?? config.metadata.temperature,
        maxTokens: options?.maxTokens ?? config.metadata.maxTokens,
        preferredProvider: options?.preferredProvider ?? config.metadata.providers[0],
      });

      const validator = config.outputValidator ?? ((o: string) => {
        try {
          const m = o.match(/\{[\s\S]*\}/);
          if (m) return { valid: true, parsed: JSON.parse(m[0]) };
          return { valid: false, errors: ['No JSON'] };
        } catch (e) {
          return { valid: false, errors: [(e as Error).message] };
        }
      });

      const { valid, parsed, errors } = validator(aiResponse.content);

      const metrics: AgentMetrics = {
        latencyMs: Date.now() - startTime,
        tokensUsed: aiResponse.tokensUsed,
        costEstimate: estimateCost(aiResponse.provider, aiResponse.model, aiResponse.tokensUsed),
        provider: aiResponse.provider,
        model: aiResponse.model,
        qualityScore: valid ? 1.0 : 0.5,
      };

      recordMetrics({
        agentId: config.metadata.id,
        requestId: `auto_${Date.now()}`,
        latencyMs: metrics.latencyMs,
        tokensUsed: metrics.tokensUsed,
        costEstimate: metrics.costEstimate,
        provider: metrics.provider,
        model: metrics.model,
        success: true,
        qualityScore: metrics.qualityScore,
      });

      return {
        agentId: config.metadata.id,
        output: parsed ?? aiResponse.content,
        raw: aiResponse,
        metrics,
      };
    },

    validateOutput: config.outputValidator ?? ((output: string) => {
      try {
        const m = output.match(/\{[\s\S]*\}/);
        if (m) return { valid: true, parsed: JSON.parse(m[0]) };
        return { valid: false, errors: ['No JSON'] };
      } catch (e) {
        return { valid: false, errors: [(e as Error).message] };
      }
    }),
  };
}
