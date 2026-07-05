// agents/src/agents/speaking-coach.ts
// Speaking Coach Agent — evaluates conversational speech scripts and mock interviews

import { Agent, callable } from 'agents'
import type { LearningAgent, SpeakingCoachInput, SpeakingCoachOutput, SpeakingEvaluation } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class SpeakingCoachAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'speaking-coach'
  get name(): string { return 'SpeakingCoach' }
  description = 'Evaluates spoken transcript text responses against speaking performance metrics.'
  priority = 3
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: SpeakingCoachInput): Promise<SpeakingCoachOutput> {
    const startTime = Date.now()
    try {
      const promptData = getPrompt('speaking-coach', {
        target_language: input.language,
        learning_level: input.level,
        target_exam: input.examType || 'General',
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        {
          role: 'user',
          content: `Evaluate this speaking transcript: "${input.transcript}"${input.prompt ? ` in response to topic/prompt: "${input.prompt}"` : ''}.`,
        },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      const data: SpeakingEvaluation = {
        scores: {
          fluency: parsedData.fluency_score || 0,
          grammar: parsedData.grammar_score || 0,
          vocabulary: parsedData.vocabulary_score || 0,
          pronunciation: parsedData.pronunciation_score || 0,
          intonation: parsedData.intonation_score || 0,
          clarity: parsedData.clarity_score || 0,
          overall: parsedData.overall_score || 0,
        },
        estimatedProficiency: parsedData.estimated_proficiency || input.level,
        strengths: parsedData.strengths || [],
        improvements: parsedData.issues || parsedData.improvements || [],
        practiceWords: parsedData.practice_words || [],
        shadowingExercise: parsedData.shadowing_exercise || '',
      }

      return {
        agentId: 'speaking-coach',
        success: true,
        data,
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 0.90,
        },
      }
    } catch (err: any) {
      return {
        agentId: 'speaking-coach',
        success: false,
        data: {} as SpeakingEvaluation,
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: SpeakingCoachOutput): boolean {
    return output.success && !!output.data && typeof output.data.scores.overall === 'number'
  }

  score(output: SpeakingCoachOutput): number {
    return output.success ? (output.data.scores.overall / 100) : 0.0
  }
}
