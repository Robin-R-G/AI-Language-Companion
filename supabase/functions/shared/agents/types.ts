// supabase/functions/shared/agents/types.ts
// Core types and interfaces for the AI Language Coach multi-agent framework.

import type { ChatMessage, AIResponse } from '../ai.ts';

// ─── Agent Identity ──────────────────────────────────────────────────────────

export type AgentCategory =
  | 'educational'
  | 'engineering'
  | 'safety'
  | 'quality'
  | 'analytics'
  | 'orchestration';

export type AgentCapability =
  | 'grammar'
  | 'vocabulary'
  | 'speaking'
  | 'writing'
  | 'reading'
  | 'listening'
  | 'pronunciation'
  | 'translation'
  | 'curriculum'
  | 'analytics'
  | 'exam-pattern'
  | 'safety-review'
  | 'copyright-review'
  | 'quality-review'
  | 'prompt-optimization'
  | 'code-review'
  | 'security-audit';

export interface AgentMetadata {
  id: string;
  name: string;
  version: string;
  description: string;
  category: AgentCategory;
  capabilities: AgentCapability[];
  providers: string[];
  costTier: 'low' | 'medium' | 'high';
  maxTokens: number;
  temperature: number;
  enabled: boolean;
}

// ─── Agent Request/Response ──────────────────────────────────────────────────

export interface AgentRequest {
  agentId: string;
  input: string;
  context: AgentContext;
  options?: AgentRequestOptions;
}

export interface AgentContext {
  userId: string;
  conversationId?: string;
  userProfile?: UserProfile;
  recentErrors?: string[];
  learningMemory?: string[];
  conversationHistory?: ChatMessage[];
  metadata?: Record<string, unknown>;
}

export interface UserProfile {
  id: string;
  fullName: string;
  nativeLanguage: string;
  targetLanguage: string;
  proficiencyLevel: string;
  targetExam: string;
  subscriptionPlan: string;
}

export interface AgentRequestOptions {
  temperature?: number;
  maxTokens?: number;
  preferredProvider?: string;
  stream?: boolean;
  timeout?: number;
  skipPostProcessing?: boolean;
}

export interface AgentResult {
  agentId: string;
  output: unknown;
  raw: AIResponse;
  metrics: AgentMetrics;
  postProcessingResults?: PostProcessingResult[];
}

export interface AgentMetrics {
  latencyMs: number;
  tokensUsed: number;
  costEstimate: number;
  provider: string;
  model: string;
  confidenceScore?: number;
  qualityScore?: number;
}

export interface PostProcessingResult {
  agentId: string;
  passed: boolean;
  issues: string[];
  suggestions: string[];
}

// ─── Agent Interface ─────────────────────────────────────────────────────────

export interface LearningAgent {
  readonly metadata: AgentMetadata;

  /** Build the system prompt for this agent given the context. */
  buildPrompt(context: AgentContext): string;

  /** Execute the agent and return a structured result. */
  execute(
    input: string,
    context: AgentContext,
    options?: AgentRequestOptions
  ): Promise<AgentResult>;

  /** Validate that the AI output conforms to the expected schema. */
  validateOutput(output: string): { valid: boolean; parsed?: unknown; errors?: string[] };
}

// ─── Orchestrator Types ──────────────────────────────────────────────────────

export interface RoutingRule {
  capability: AgentCapability;
  agentIds: string[];
  priority: number;
}

export interface PipelineStage {
  agentId: string;
  inputMapping: (results: Map<string, AgentResult>) => string;
  condition?: (context: AgentContext) => boolean;
}

export interface Pipeline {
  id: string;
  name: string;
  stages: PipelineStage[];
  parallelStages?: PipelineStage[][];
}

export interface OrchestratorConfig {
  defaultProvider: string;
  fallbackProvider: string;
  maxParallelAgents: number;
  globalTimeout: number;
  enablePostProcessing: boolean;
  mandatoryPostProcessors: string[];
}

// ─── Registry Types ──────────────────────────────────────────────────────────

export interface RegistryEntry {
  agent: LearningAgent;
  metadata: AgentMetadata;
  registeredAt: number;
  lastUsed?: number;
  usageCount: number;
}

// ─── Prompt Template Types ───────────────────────────────────────────────────

export interface PromptTemplate {
  id: string;
  version: string;
  system: string;
  userTemplate: string;
  outputSchema?: Record<string, unknown>;
  variables: Record<string, string>;
}

// ─── Event Types ─────────────────────────────────────────────────────────────

export type AgentEvent =
  | { type: 'agent:started'; agentId: string; requestId: string }
  | { type: 'agent:completed'; agentId: string; requestId: string; metrics: AgentMetrics }
  | { type: 'agent:failed'; agentId: string; requestId: string; error: string }
  | { type: 'agent:post-processed'; agentId: string; requestId: string; results: PostProcessingResult[] }
  | { type: 'orchestrator:routed'; requestId: string; agentId: string; reason: string }
  | { type: 'orchestrator:pipeline-started'; requestId: string; pipelineId: string }
  | { type: 'orchestrator:pipeline-completed'; requestId: string; pipelineId: string; durationMs: number };

export type AgentEventListener = (event: AgentEvent) => void;
