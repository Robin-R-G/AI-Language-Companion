// supabase/functions/shared/agents/educational/listening-agent.ts
// Listening comprehension agent with dictation and gap-fill exercises.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'listening',
  name: 'Listening Comprehension Specialist',
  version: '1.0.0',
  description: 'Generates listening exercises with dictation scripts, gap-fill tasks, and comprehension questions.',
  category: 'educational',
  capabilities: ['listening'],
  providers: ['gemini', 'openai'],
  costTier: 'low',
  maxTokens: 2048,
  temperature: 0.5,
  enabled: true,
};

export class ListeningAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Listening comprehension specialist.
TARGET LANGUAGE: ${context.userProfile?.targetLanguage || 'English'}
USER LEVEL: ${context.userProfile?.proficiencyLevel || 'A1'}
TARGET EXAM: ${context.userProfile?.targetExam || 'General'}

RESPONSIBILITIES:
- Generate dictation and gap-fill exercises
- Create audio scripts suitable for TTS playback
- Design progressive difficulty exercises
- Include comprehension questions
- NEVER reproduce copyrighted audio scripts

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "script": "original audio script for TTS",
  "title": "exercise title",
  "cefr_level": "target level",
  "gap_fill": [
    { "sentence": "The cat ___ on the mat", "answer": "sat", "hint": "past tense of sit" }
  ],
  "comprehension_questions": [
    { "question": "question", "options": ["A","B","C"], "correct_index": number, "explanation": "why" }
  ],
  "speed_notes": "recommended speech speed (slow|normal|fast)"
}`);
  }
}

export function createListeningAgent(): ListeningAgent {
  return new ListeningAgent();
}
