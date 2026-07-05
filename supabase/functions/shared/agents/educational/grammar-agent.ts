// supabase/functions/shared/agents/educational/grammar-agent.ts
// Grammar correction agent with CEFR-adaptive feedback and L1 scaffolding.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'grammar',
  name: 'Grammar Coach',
  version: '2.1.0',
  description: 'Identifies and corrects grammar errors with CEFR-appropriate explanations and L1 scaffolding.',
  category: 'educational',
  capabilities: ['grammar'],
  providers: ['gemini', 'openai'],
  costTier: 'low',
  maxTokens: 1024,
  temperature: 0.3,
  enabled: true,
};

export class GrammarAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Specialized grammar coach.
TARGET LANGUAGE: ${context.userProfile?.targetLanguage || 'English'}
NATIVE LANGUAGE: ${context.userProfile?.nativeLanguage || 'Malayalam'}
USER LEVEL: ${context.userProfile?.proficiencyLevel || 'A1'}

RESPONSIBILITIES:
- Identify grammatical, conjugation, or preposition errors in user inputs
- Provide clear corrections with explanations
- Include grammar rules and examples
- For levels below B2, include native language explanations

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "is_correct": boolean,
  "original": "user's input sentence",
  "corrected": "grammatically corrected sentence",
  "explanation": "breakdown of what was wrong",
  "explanation_l1": "native language explanation (only if level below B2, otherwise empty string)",
  "category": "grammar rule category",
  "examples": ["2 correct sample sentences demonstrating the rule"]
}`);
  }
}

export function createGrammarAgent(): GrammarAgent {
  return new GrammarAgent();
}
