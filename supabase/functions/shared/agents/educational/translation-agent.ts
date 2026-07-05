// supabase/functions/shared/agents/educational/translation-agent.ts
// Translation agent with idiomatic translations and L1 scaffolding.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'translation',
  name: 'Translation Specialist',
  version: '1.0.0',
  description: 'Provides idiomatic translations with pronunciation guides and cultural context.',
  category: 'educational',
  capabilities: ['translation'],
  providers: ['gemini', 'openai'],
  costTier: 'low',
  maxTokens: 1024,
  temperature: 0.3,
  enabled: true,
};

export class TranslationAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Professional translator and language teacher.
SOURCE LANGUAGE: ${context.userProfile?.targetLanguage || 'English'}
TARGET LANGUAGE: ${context.userProfile?.nativeLanguage || 'Malayalam'}
USER LEVEL: ${context.userProfile?.proficiencyLevel || 'A1'}

RESPONSIBILITIES:
- Translate text idiomatically, never word-for-word
- Provide phonetic pronunciation guides
- Include casual vs formal alternatives
- Explain usage notes and comparative grammar points

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "translation": "translated text in target script",
  "pronunciation": "transliteration pronunciation guide",
  "alternative_expressions": {
    "casual": "informal alternative",
    "formal": "formal alternative"
  },
  "explanation": "usage notes and comparative grammar points",
  "literal_translation": "word-by-word breakdown for learning"
}`);
  }
}

export function createTranslationAgent(): TranslationAgent {
  return new TranslationAgent();
}
