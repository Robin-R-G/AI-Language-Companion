// agents/src/agents/pronunciation.ts
// Pronunciation Agent — evaluates phonetic clarity, intonation, and stress patterns

import { Agent, callable } from 'agents'
import type { LearningAgent, PronunciationInput, PronunciationOutput, PronunciationEvaluation } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class PronunciationAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'pronunciation'
  get name(): string { return 'PronunciationAgent' }
  description = 'Evaluates transcript speech stress, intonation, fluency, and individual phonemes.'
  priority = 3
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: PronunciationInput): Promise<PronunciationOutput> {
    const startTime = Date.now()
    try {
      const promptData = getPrompt('pronunciation', {
        target_language: input.language,
        learning_level: input.level,
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        { role: 'user', content: `Evaluate this spoken transcript text: "${input.audioText}". Target phonemes if any: ${input.targetPhonemes?.join(', ') || 'none'}.` },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData: PronunciationEvaluation = JSON.parse(cleanedContent)

      return {
        agentId: 'pronunciation',
        success: true,
        data: parsedData,
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 0.90,
        },
      }
    } catch (err: any) {
      return {
        agentId: 'pronunciation',
        success: false,
        data: {} as PronunciationEvaluation,
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: PronunciationOutput): boolean {
    return output.success && !!output.data && typeof output.data.overallScore === 'number'
  }

  score(output: PronunciationOutput): number {
    return output.success ? output.data.overallScore / 100 : 0.0
  }
}
