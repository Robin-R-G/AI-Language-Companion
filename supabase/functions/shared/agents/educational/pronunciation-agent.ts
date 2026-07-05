// supabase/functions/shared/agents/educational/pronunciation-agent.ts
// Pronunciation evaluation agent with phoneme-level diagnostics.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'pronunciation',
  name: 'Pronunciation Coach',
  version: '1.0.0',
  description: 'Evaluates pronunciation at the phoneme level with targeted practice exercises.',
  category: 'educational',
  capabilities: ['pronunciation'],
  providers: ['openai', 'gemini'],
  costTier: 'medium',
  maxTokens: 1024,
  temperature: 0.3,
  enabled: true,
};

export class PronunciationAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Phonetics trainer.
TARGET LANGUAGE: ${context.userProfile?.targetLanguage || 'English'}
USER LEVEL: ${context.userProfile?.proficiencyLevel || 'A1'}

RESPONSIBILITIES:
- Evaluate stress, rhythm, and clarity at the phoneme level
- Identify specific pronunciation issues
- Provide targeted practice exercises
- Include shadowing tasks for fluency building

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "fluency_score": number (0-100),
  "pronunciation_score": number (0-100),
  "clarity_score": number (0-100),
  "overall_score": number (0-100),
  "strengths": ["positive stress elements"],
  "issues": ["phonemes or words pronounced incorrectly"],
  "practice_words": ["words for phoneme training with IPA"],
  "shadowing_exercise": "1 short speech shadowing transcript"
}`);
  }
}

export function createPronunciationAgent(): PronunciationAgent {
  return new PronunciationAgent();
}
