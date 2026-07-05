// agents/src/agents/translation.ts
// Translation Agent — translates target language content with contextual L1 grammar notes

import { Agent, callable } from 'agents'
import type { LearningAgent, TranslationInput, TranslationOutput } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class TranslationAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'translation'
  get name(): string { return 'TranslationAgent' }
  description = 'Provides contextual translation mappings between target and native languages.'
  priority = 2
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: TranslationInput): Promise<TranslationOutput> {
    const startTime = Date.now()
    try {
      const promptData = getPrompt('translation', {
        target_language: input.sourceLanguage,
        native_language: input.targetLanguage,
        learning_level: input.level,
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        {
          role: 'user',
          content: `Translate the following text: "${input.text}". Context: "${input.context || 'none'}"`,
        },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      return {
        agentId: 'translation',
        success: true,
        data: {
          translation: parsedData.translation || '',
          pronunciation: parsedData.pronunciation || '',
          alternatives: {
            formal: parsedData.alternatives?.formal || '',
            informal: parsedData.alternatives?.informal || '',
          },
          explanation: parsedData.explanation || '',
        },
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 0.95,
        },
      }
    } catch (err: any) {
      return {
        agentId: 'translation',
        success: false,
        data: {
          translation: '',
          pronunciation: '',
          alternatives: { formal: '', informal: '' },
          explanation: '',
        },
        errors: [err.message],
        metadata: {
          latencyMs: Date.now() - startTime,
        },
      }
    }
  }

  validate(output: TranslationOutput): boolean {
    return output.success && !!output.data && typeof output.data.translation === 'string'
  }

  score(output: TranslationOutput): number {
    return output.success ? 1.0 : 0.0
  }
}
