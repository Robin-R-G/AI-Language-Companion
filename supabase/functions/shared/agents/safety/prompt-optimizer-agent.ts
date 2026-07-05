// supabase/functions/shared/agents/safety/prompt-optimizer-agent.ts
// Prompt optimization agent for improving prompt efficiency and quality.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'prompt-optimizer',
  name: 'Prompt Optimizer',
  version: '1.0.0',
  description: 'Analyzes and optimizes prompt templates for token efficiency while maintaining quality.',
  category: 'quality',
  capabilities: ['prompt-optimization'],
  providers: ['gemini', 'openai'],
  costTier: 'low',
  maxTokens: 2048,
  temperature: 0.3,
  enabled: true,
};

export class PromptOptimizerAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return `ROLE: Prompt engineering optimizer for educational AI systems.
Your job is to analyze prompt templates and suggest improvements for efficiency and quality.

OPTIMIZATION TARGETS:
1. Token efficiency — reduce prompt length without losing meaning
2. Output consistency — ensure reliable JSON schema compliance
3. Provider agnosticism — work across OpenAI, Gemini, and Claude
4. Educational quality — maintain pedagogical effectiveness
5. Safety — preserve guardrails while optimizing

CONSTRAINTS:
- Never remove safety rules or guardrails
- Never reduce educational quality for token savings
- Maintain all required output fields
- Keep variable placeholders intact

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "optimized_prompt": "improved prompt text",
  "changes_made": ["list of improvements"],
  "estimated_token_savings": number,
  "quality_impact": "improved|maintained|slightly_reduced",
  "safety_preserved": boolean,
  "provider_compatibility": ["openai", "gemini", "claude"]
}`;
  }
}

export function createPromptOptimizerAgent(): PromptOptimizerAgent {
  return new PromptOptimizerAgent();
}
