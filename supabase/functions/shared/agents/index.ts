// supabase/functions/shared/agents/index.ts
// Multi-Agent Framework for AI Language Coach
// Central export point for all agent framework components.
//
// Adapted from Agency Agents repository (MIT License).
// Original: https://github.com/msitarzewski/agency-agents
// Copyright (c) 2025 AgentLand Contributors

// ─── Core Framework ──────────────────────────────────────────────────────────

export type {
  LearningAgent,
  AgentMetadata,
  AgentCategory,
  AgentCapability,
  AgentRequest,
  AgentContext,
  AgentRequestOptions,
  AgentResult,
  AgentMetrics,
  PostProcessingResult,
  Pipeline,
  PipelineStage,
  OrchestratorConfig,
  AgentEvent,
  AgentEventListener,
  UserProfile,
  PromptTemplate,
} from './types.ts';

// ─── Registry ────────────────────────────────────────────────────────────────

export {
  registerAgent,
  unregisterAgent,
  getAgent,
  getAgentMetadata,
  getAllAgents,
  getEnabledAgents,
  getAgentsByCategory,
  getAgentsByCapability,
  findAgentForCapability,
  getRegistryStats,
  clearRegistry,
} from './registry.ts';

// ─── Orchestrator ────────────────────────────────────────────────────────────

export { Orchestrator, createOrchestrator } from './orchestrator.ts';

// ─── Container ───────────────────────────────────────────────────────────────

export {
  Container,
  getContainer,
  resetContainer,
  Tokens,
  registerProviders,
  registerOrchestratorConfig,
  getDefaultOrchestratorConfig,
} from './container.ts';

// ─── Prompt Loader ───────────────────────────────────────────────────────────

export {
  loadPromptTemplate,
  getPromptTemplate,
  compilePrompt,
  buildSystemPrompt,
  resolveVariables,
  registerBuiltinTemplates,
  GLOBAL_RULES,
} from './prompt-loader.ts';

// ─── Metrics ─────────────────────────────────────────────────────────────────

export {
  recordMetrics,
  estimateCost,
  getAggregateMetrics,
  getAllAggregateMetrics,
  getHealthStatus,
  resetMetrics,
  onAgentEvent,
  emitEvent,
} from './metrics.ts';

// ─── Base Agent ──────────────────────────────────────────────────────────────

export { BaseLearningAgent, createAgent } from './base-agent.ts';

// ─── Engineering Agents ──────────────────────────────────────────────────────

export { CodeReviewAgent, createCodeReviewAgent } from './engineering/code-review-agent.ts';
export { SecurityAuditAgent, createSecurityAuditAgent } from './engineering/security-audit-agent.ts';

// ─── Educational Agents ──────────────────────────────────────────────────────

export { GrammarAgent, createGrammarAgent } from './educational/grammar-agent.ts';
export { VocabularyAgent, createVocabularyAgent } from './educational/vocabulary-agent.ts';
export { SpeakingAgent, createSpeakingAgent } from './educational/speaking-agent.ts';
export { WritingAgent, createWritingAgent } from './educational/writing-agent.ts';
export { ReadingAgent, createReadingAgent } from './educational/reading-agent.ts';
export { ListeningAgent, createListeningAgent } from './educational/listening-agent.ts';
export { PronunciationAgent, createPronunciationAgent } from './educational/pronunciation-agent.ts';
export { TranslationAgent, createTranslationAgent } from './educational/translation-agent.ts';
export { CurriculumAgent, createCurriculumAgent } from './educational/curriculum-agent.ts';
export { AnalyticsAgent, createAnalyticsAgent } from './educational/analytics-agent.ts';
export { ExamPatternAgent, createExamPatternAgent } from './educational/exam-pattern-agent.ts';

// ─── Safety & Quality Agents ─────────────────────────────────────────────────

export { SafetyReviewAgent, createSafetyReviewAgent } from './safety/safety-review-agent.ts';
export { CopyrightReviewAgent, createCopyrightReviewAgent } from './safety/copyright-review-agent.ts';
export { QualityReviewAgent, createQualityReviewAgent } from './safety/quality-review-agent.ts';
export { PromptOptimizerAgent, createPromptOptimizerAgent } from './safety/prompt-optimizer-agent.ts';

// ─── Bootstrap: Register All Agents ──────────────────────────────────────────

import { registerAgent } from './registry.ts';
import { registerBuiltinTemplates } from './prompt-loader.ts';
import { createCodeReviewAgent } from './engineering/code-review-agent.ts';
import { createSecurityAuditAgent } from './engineering/security-audit-agent.ts';
import { createGrammarAgent } from './educational/grammar-agent.ts';
import { createVocabularyAgent } from './educational/vocabulary-agent.ts';
import { createSpeakingAgent } from './educational/speaking-agent.ts';
import { createWritingAgent } from './educational/writing-agent.ts';
import { createReadingAgent } from './educational/reading-agent.ts';
import { createListeningAgent } from './educational/listening-agent.ts';
import { createPronunciationAgent } from './educational/pronunciation-agent.ts';
import { createTranslationAgent } from './educational/translation-agent.ts';
import { createCurriculumAgent } from './educational/curriculum-agent.ts';
import { createAnalyticsAgent } from './educational/analytics-agent.ts';
import { createExamPatternAgent } from './educational/exam-pattern-agent.ts';
import { createSafetyReviewAgent } from './safety/safety-review-agent.ts';
import { createCopyrightReviewAgent } from './safety/copyright-review-agent.ts';
import { createQualityReviewAgent } from './safety/quality-review-agent.ts';
import { createPromptOptimizerAgent } from './safety/prompt-optimizer-agent.ts';

/**
 * Initialize the multi-agent framework.
 * Call this once at application startup to register all agents and templates.
 */
export function initializeAgentFramework(): void {
  // Register built-in prompt templates
  registerBuiltinTemplates();

  // Register engineering agents
  registerAgent(createCodeReviewAgent());
  registerAgent(createSecurityAuditAgent());

  // Register educational agents
  registerAgent(createGrammarAgent());
  registerAgent(createVocabularyAgent());
  registerAgent(createSpeakingAgent());
  registerAgent(createWritingAgent());
  registerAgent(createReadingAgent());
  registerAgent(createListeningAgent());
  registerAgent(createPronunciationAgent());
  registerAgent(createTranslationAgent());
  registerAgent(createCurriculumAgent());
  registerAgent(createAnalyticsAgent());
  registerAgent(createExamPatternAgent());

  // Register safety & quality agents (mandatory post-processors)
  registerAgent(createSafetyReviewAgent());
  registerAgent(createCopyrightReviewAgent());
  registerAgent(createQualityReviewAgent());
  registerAgent(createPromptOptimizerAgent());

  console.log('[AgentFramework] Initialized with 17 agents');
}
