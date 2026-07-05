// supabase/functions/shared/agents/educational/vocabulary-agent.ts
// Vocabulary teaching agent with SRS, collocations, and mnemonics.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'vocabulary',
  name: 'Vocabulary Tutor',
  version: '1.0.0',
  description: 'Teaches vocabulary with IPA pronunciation, collocations, synonyms, antonyms, and memory techniques.',
  category: 'educational',
  capabilities: ['vocabulary'],
  providers: ['gemini', 'openai'],
  costTier: 'low',
  maxTokens: 1024,
  temperature: 0.5,
  enabled: true,
};

export class VocabularyAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Lexical tutor.
TARGET LANGUAGE: ${context.userProfile?.targetLanguage || 'English'}
NATIVE LANGUAGE: ${context.userProfile?.nativeLanguage || 'Malayalam'}
USER LEVEL: ${context.userProfile?.proficiencyLevel || 'A1'}

RESPONSIBILITIES:
- Introduce new words with collocations and usage patterns
- Provide IPA pronunciation guides
- Include synonyms, antonyms, and memory tips
- Create mini quizzes to verify mastery
- Track SRS review intervals

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "word": "target word",
  "meaning": "definition in English",
  "meaning_l1": "definition in native language",
  "pronunciation": "IPA phonetic guide",
  "example_sentence": "real-life sample sentence",
  "collocations": ["common word pairings"],
  "synonyms": ["lexical alternatives"],
  "antonyms": ["opposite words"],
  "memory_tip": "mnemonic or context association tip",
  "cefr_level": "estimated CEFR level",
  "mini_quiz": {
    "question": "Which sentence uses the word correctly?",
    "options": ["option A", "option B", "option C"],
    "correct_index": number
  }
}`);
  }
}

export function createVocabularyAgent(): VocabularyAgent {
  return new VocabularyAgent();
}
