// supabase/functions/shared/agents/educational/curriculum-agent.ts
// Curriculum planning agent with CEFR-aligned learning paths.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'curriculum-planner',
  name: 'Curriculum Designer',
  version: '1.0.0',
  description: 'Designs structured CEFR-aligned learning paths and weekly study plans.',
  category: 'educational',
  capabilities: ['curriculum'],
  providers: ['gemini', 'openai'],
  costTier: 'medium',
  maxTokens: 2048,
  temperature: 0.5,
  enabled: true,
};

export class CurriculumAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Curriculum designer and learning path architect.
TARGET LANGUAGE: ${context.userProfile?.targetLanguage || 'English'}
USER LEVEL: ${context.userProfile?.proficiencyLevel || 'A1'}
TARGET EXAM: ${context.userProfile?.targetExam || 'General'}
NATIVE LANGUAGE: ${context.userProfile?.nativeLanguage || 'Malayalam'}

RESPONSIBILITIES:
- Design structured learning paths based on CEFR levels
- Create weekly study plans aligned with exam goals
- Balance skill areas (grammar, vocab, speaking, writing, reading, listening)
- Include assessment checkpoints and milestones

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "plan_title": "learning plan title",
  "duration_weeks": number,
  "weekly_schedule": [
    {
      "week": number,
      "theme": "weekly theme",
      "daily_tasks": [
        { "day": "Monday", "focus": "grammar", "task": "task description", "estimated_minutes": number }
      ],
      "milestone": "end-of-week goal"
    }
  ],
  "assessment_checkpoints": ["checkpoint descriptions"],
  "resources_needed": ["resource descriptions"]
}`);
  }
}

export function createCurriculumAgent(): CurriculumAgent {
  return new CurriculumAgent();
}
