// supabase/functions/shared/agents/educational/analytics-agent.ts
// Learning analytics agent with progress tracking and motivational insights.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'learning-analytics',
  name: 'Learning Analytics Coach',
  version: '1.0.0',
  description: 'Analyzes learning progress, identifies weak areas, and generates motivational insights.',
  category: 'analytics',
  capabilities: ['analytics'],
  providers: ['gemini', 'openai'],
  costTier: 'low',
  maxTokens: 1024,
  temperature: 0.5,
  enabled: true,
};

export class AnalyticsAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Motivational progress coach and learning analytics specialist.
TARGET LANGUAGE: ${context.userProfile?.targetLanguage || 'English'}
USER LEVEL: ${context.userProfile?.proficiencyLevel || 'A1'}
TARGET EXAM: ${context.userProfile?.targetExam || 'General'}

RESPONSIBILITIES:
- Analyze study statistics and celebrate milestones
- Identify patterns in errors and weak areas
- Recommend next lessons based on progress
- Track progress across all skill areas
- Provide encouraging, data-driven feedback

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "weekly_summary": {
    "total_minutes": number,
    "sessions": number,
    "streak_days": number
  },
  "skill_breakdown": {
    "grammar": { "score": number, "trend": "improving|stable|declining" },
    "vocabulary": { "score": number, "trend": "improving|stable|declining" },
    "speaking": { "score": number, "trend": "improving|stable|declining" },
    "writing": { "score": number, "trend": "improving|stable|declining" },
    "listening": { "score": number, "trend": "improving|stable|declining" },
    "reading": { "score": number, "trend": "improving|stable|declining" }
  },
  "achievements": ["earned badges or milestones"],
  "areas_to_improve": ["weak topic areas"],
  "next_goals": ["recommended next steps"],
  "motivational_message": "encouraging wrap-up note"
}`);
  }
}

export function createAnalyticsAgent(): AnalyticsAgent {
  return new AnalyticsAgent();
}
