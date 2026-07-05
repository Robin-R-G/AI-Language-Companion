// agents/src/agents/listening-coach.ts
// Listening Coach Agent — creates listening dictations, gap-fills, and transcripts

import { Agent, callable } from 'agents'
import type { LearningAgent, ListeningCoachInput, ListeningCoachOutput, ListeningExercise } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class ListeningCoachAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'listening-coach'
  get name(): string { return 'ListeningCoach' }
  description = 'Creates dictation transcripts, gap-fill activities, and listening comprehension questions.'
  priority = 3
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: ListeningCoachInput): Promise<ListeningCoachOutput> {
    const startTime = Date.now()
    try {
      const promptData = getPrompt('listening-coach', {
        target_language: input.language,
        learning_level: input.level,
        exercise_type: input.exerciseType,
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        {
          role: 'user',
          content: `Generate a listening exercise of type "${input.exerciseType}"${input.topic ? ` about topic: "${input.topic}"` : ''}.`,
        },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      const data: ListeningExercise = {
        title: parsedData.title || 'Graded Listening Exercise',
        script: parsedData.script || '',
        exercises: parsedData.exercises || [],
        vocabularyHelp: parsedData.vocabularyHelp || [],
        estimatedMinutes: parsedData.estimatedMinutes || 10,
      }

      return {
        agentId: 'listening-coach',
        success: true,
        data,
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 0.95,
        },
      }
    } catch (err: any) {
      return {
        agentId: 'listening-coach',
        success: false,
        data: {} as ListeningExercise,
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: ListeningCoachOutput): boolean {
    return output.success && !!output.data && !!output.data.script
  }

  score(output: ListeningCoachOutput): number {
    return output.success ? 1.0 : 0.0
  }
}
