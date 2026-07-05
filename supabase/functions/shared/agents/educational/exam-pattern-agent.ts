// supabase/functions/shared/agents/educational/exam-pattern-agent.ts
// Exam pattern agent for simulating exam scenarios and scoring against rubrics.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'exam-pattern',
  name: 'Exam Pattern Specialist',
  version: '1.0.0',
  description: 'Simulates exam scenarios and scores responses against official rubrics. Generates original practice materials.',
  category: 'educational',
  capabilities: ['exam-pattern'],
  providers: ['openai', 'gemini'],
  costTier: 'medium',
  maxTokens: 2048,
  temperature: 0.3,
  enabled: true,
};

export class ExamPatternAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Certified exam preparation specialist for ${context.userProfile?.targetExam || 'IELTS'}.
TARGET LANGUAGE: ${context.userProfile?.targetLanguage || 'English'}
USER LEVEL: ${context.userProfile?.proficiencyLevel || 'A1'}
TARGET EXAM: ${context.userProfile?.targetExam || 'IELTS'}

RESPONSIBILITIES:
- Simulate exam scenarios based on official exam structures
- Score responses against official rubrics
- Provide targeted improvement plans
- Generate ORIGINAL practice materials (NEVER reproduce copyrighted exam content)
- Label all scores as advisory estimates, not official results

CRITICAL RULES:
- NEVER reproduce actual exam questions, passages, or audio from official tests
- ALWAYS generate original practice material inspired by official specifications
- Clearly distinguish between official information and AI-generated content

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "exam_type": "IELTS|PTE|TOEFL|Goethe|JLPT|TOPIK",
  "section": "exam section name",
  "estimated_band": "advisory score (e.g., Band 7.0)",
  "rubric_scores": {
    "task_achievement": number,
    "coherence": number,
    "lexical_resource": number,
    "grammar_range": number
  },
  "strengths": ["positive aspects"],
  "weaknesses": ["areas for improvement"],
  "corrections": [{ "original": "text", "corrected": "text", "rule": "explanation" }],
  "improvement_plan": ["step-by-step plan"],
  "disclaimer": "This is an AI-generated advisory score, not an official exam result."
}`);
  }
}

export function createExamPatternAgent(): ExamPatternAgent {
  return new ExamPatternAgent();
}
