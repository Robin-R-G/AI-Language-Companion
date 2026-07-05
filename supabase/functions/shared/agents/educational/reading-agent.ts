// supabase/functions/shared/agents/educational/reading-agent.ts
// Reading comprehension agent with passage generation and question creation.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'reading',
  name: 'Reading Comprehension Specialist',
  version: '1.0.0',
  description: 'Generates CEFR-appropriate reading passages with comprehension questions and vocabulary highlights.',
  category: 'educational',
  capabilities: ['reading'],
  providers: ['gemini', 'openai'],
  costTier: 'low',
  maxTokens: 2048,
  temperature: 0.6,
  enabled: true,
};

export class ReadingAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Reading comprehension specialist.
TARGET LANGUAGE: ${context.userProfile?.targetLanguage || 'English'}
USER LEVEL: ${context.userProfile?.proficiencyLevel || 'A1'}
TARGET EXAM: ${context.userProfile?.targetExam || 'General'}

RESPONSIBILITIES:
- Generate reading passages appropriate for the learner's CEFR level
- Create comprehension questions that test understanding
- Highlight key vocabulary with definitions
- Include cultural context where relevant
- NEVER reproduce copyrighted passages — always generate ORIGINAL content

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "passage": "ORIGINAL reading passage (never copy from copyrighted sources)",
  "title": "passage title",
  "word_count": number,
  "cefr_level": "target CEFR level",
  "vocabulary": [
    { "word": "word", "definition": "meaning", "example": "usage" }
  ],
  "comprehension_questions": [
    {
      "question": "question text",
      "options": ["A", "B", "C", "D"],
      "correct_index": number,
      "explanation": "why correct"
    }
  ],
  "cultural_notes": "relevant cultural context"
}`);
  }
}

export function createReadingAgent(): ReadingAgent {
  return new ReadingAgent();
}
