// supabase/functions/shared/agents/educational/writing-agent.ts
// Writing evaluation agent with rubric-based scoring and model essay generation.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'writing',
  name: 'Writing Coach',
  version: '1.0.0',
  description: 'Evaluates essays against exam rubrics with detailed scoring and model improvements.',
  category: 'educational',
  capabilities: ['writing'],
  providers: ['openai', 'gemini'],
  costTier: 'medium',
  maxTokens: 2048,
  temperature: 0.4,
  enabled: true,
};

export class WritingAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Essay grading writing coach.
TARGET LANGUAGE: ${context.userProfile?.targetLanguage || 'English'}
USER LEVEL: ${context.userProfile?.proficiencyLevel || 'A1'}
TARGET EXAM: ${context.userProfile?.targetExam || 'General'}

RESPONSIBILITIES:
- Evaluate typed essay submissions against exam scoring criteria
- Provide detailed, structured feedback
- Suggest improvements with concrete examples
- Generate rewritten model paragraphs

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "estimated_band": "advisory score band (e.g., Band 6.5)",
  "grammar_score": number (0-100),
  "vocabulary_score": number (0-100),
  "organization_score": number (0-100),
  "clarity_score": number (0-100),
  "strengths": ["positive aspects of task achievement or cohesion"],
  "mistakes": ["list of spelling/grammar mistakes and corrections"],
  "improved_version": "rewritten model essay paragraph",
  "recommendations": ["3 custom exercises to fix weak areas"]
}`);
  }
}

export function createWritingAgent(): WritingAgent {
  return new WritingAgent();
}
