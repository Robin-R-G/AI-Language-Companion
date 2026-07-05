// supabase/functions/shared/agents/educational/speaking-agent.ts
// Speaking evaluation agent with fluency, grammar, vocabulary, and pronunciation scoring.

import type { AgentMetadata, AgentContext } from '../types.ts';
import { BaseLearningAgent } from '../base-agent.ts';
import { buildSystemPrompt } from '../prompt-loader.ts';

const metadata: AgentMetadata = {
  id: 'speaking',
  name: 'Speaking Coach',
  version: '1.0.0',
  description: 'Evaluates speaking performance with multi-dimensional scoring and actionable feedback.',
  category: 'educational',
  capabilities: ['speaking'],
  providers: ['openai', 'gemini'],
  costTier: 'medium',
  maxTokens: 2048,
  temperature: 0.4,
  enabled: true,
};

export class SpeakingAgent extends BaseLearningAgent {
  readonly metadata = metadata;

  buildPrompt(context: AgentContext): string {
    return buildSystemPrompt(context, `ROLE: Conversational speaking partner preparing users for oral exams.
TARGET LANGUAGE: ${context.userProfile?.targetLanguage || 'English'}
USER LEVEL: ${context.userProfile?.proficiencyLevel || 'A1'}
TARGET EXAM: ${context.userProfile?.targetExam || 'General'}

RESPONSIBILITIES:
- Maintain natural conversation flows without excessive interruptions
- Grade speech performance on fluency, grammar, vocabulary, and pronunciation
- Provide actionable improvement suggestions
- Include practice exercises and shadowing tasks

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "fluency_score": number (0-100),
  "grammar_score": number (0-100),
  "vocabulary_score": number (0-100),
  "pronunciation_score": number (0-100),
  "overall_score": number (0-100),
  "feedback": "overall feedback message",
  "strengths": ["positive aspects"],
  "issues": ["areas needing improvement"],
  "practice_words": ["words for pronunciation practice"],
  "shadowing_exercise": "1 short speech shadowing transcript",
  "estimated_proficiency": "estimated band/level"
}`);
  }
}

export function createSpeakingAgent(): SpeakingAgent {
  return new SpeakingAgent();
}
