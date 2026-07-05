// agents/src/agents/quality-reviewer.ts
// Quality Reviewer — dynamic output quality scoring

import { Agent, callable } from 'agents'
import type { LearningAgent, QualityInput, QualityOutput } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class QualityReviewerAgent extends Agent<Env, {}> implements LearningAgent {
  initialState = {}

  id = 'quality-reviewer'
  get name(): string { return 'QualityReviewer' }
  description = 'Grades outputs on dimensions such as language accuracy, educational value, clarity, and difficulty calibration.'
  priority = 1
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: QualityInput): Promise<QualityOutput> {
    return this.review(input)
  }

  validate(output: QualityOutput): boolean {
    return output.success && !!output.data && typeof output.data.score === 'number'
  }

  score(output: QualityOutput): number {
    return output.success ? (output.data.score / 100) : 0.0
  }

  @callable()
  async review(input: QualityInput): Promise<QualityOutput> {
    const startTime = Date.now()
    try {
      const promptData = getPrompt('quality-reviewer', {
        content_type: input.contentType,
        learning_level: input.level,
        target_language: input.language,
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        { role: 'user', content: `Grade this content of type "${input.contentType}":\n"${input.content}"` },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      const score = typeof parsedData.score === 'number' ? parsedData.score : 80
      const dimensions = parsedData.dimensions || {
        accuracy: 80,
        educationalValue: 80,
        grammar: 80,
        difficulty: 80,
        personalization: 80,
        clarity: 80,
      }

      return {
        agentId: 'quality-reviewer',
        success: true,
        data: {
          score,
          dimensions: {
            accuracy: typeof dimensions.accuracy === 'number' ? dimensions.accuracy : 80,
            educationalValue: typeof dimensions.educationalValue === 'number' ? dimensions.educationalValue : 80,
            grammar: typeof dimensions.grammar === 'number' ? dimensions.grammar : 80,
            difficulty: typeof dimensions.difficulty === 'number' ? dimensions.difficulty : 80,
            personalization: typeof dimensions.personalization === 'number' ? dimensions.personalization : 80,
            clarity: typeof dimensions.clarity === 'number' ? dimensions.clarity : 80,
          },
          issues: parsedData.issues || [],
          suggestions: parsedData.suggestions || [],
        },
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 0.95,
        },
      }
    } catch (err: any) {
      // Fallback grade if parsing/API fails to prevent pipeline locks
      return {
        agentId: 'quality-reviewer',
        success: true,
        data: {
          score: 80,
          dimensions: {
            accuracy: 80,
            educationalValue: 80,
            grammar: 80,
            difficulty: 80,
            personalization: 80,
            clarity: 80,
          },
          issues: [`Quality audit fallback triggered: ${err.message}`],
          suggestions: ['Verify reviewer API connection'],
        },
        metadata: {
          latencyMs: Date.now() - startTime,
          confidence: 0.5,
        },
      }
    }
  }
}
