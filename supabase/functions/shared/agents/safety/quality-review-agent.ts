// supabase/functions/shared/agents/safety/quality-review-agent.ts
// Quality review agent — mandatory post-processor for educational accuracy.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'quality-review',
  name: 'Educational Quality Reviewer',
  version: '1.0.0',
  description: 'Mandatory post-processor that verifies educational accuracy, CEFR appropriateness, and pedagogical quality.',
  category: 'quality',
  capabilities: ['quality-review'],
  providers: ['gemini', 'openai'],
  costTier: 'low',
  maxTokens: 1024,
  temperature: 0.2,
  enabled: true,
};

export class QualityReviewAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Educational content quality reviewer for language learning.
Your job is to verify that AI-generated educational content is accurate and pedagogically sound.

CHECK FOR:
1. Grammar explanation accuracy
2. Translation correctness
3. CEFR level appropriateness (content should match stated level)
4. Explanation clarity for non-native speakers
5. Cultural sensitivity and inclusivity
6. Engagement quality (is the content motivating?)
7. Factual accuracy of any cultural or linguistic information
8. Consistency of scoring rubrics

QUALITY METRICS:
- Grammar correction accuracy should be >97%
- Translation preservation score should be >95%
- Content should be pedagogically progressive
- Explanations should be clear and actionable

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "quality_score": number (0-100),
  "accuracy_issues": ["list of factual errors if any"],
  "pedagogy_issues": ["teaching quality concerns"],
  "cefr_appropriate": boolean,
  "engagement_score": number (0-100),
  "clarity_score": number (0-100),
  "recommendations": ["improvement suggestions"]
}`);
  }
}

export function createQualityReviewAgent(): QualityReviewAgent {
  return new QualityReviewAgent();
}
