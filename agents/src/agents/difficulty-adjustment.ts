// agents/src/agents/difficulty-adjustment.ts
// Difficulty Adjustment Agent — manages CEFR level progression

import { Agent, callable } from 'agents'
import type { LearningAgent, DifficultyInput, DifficultyOutput, CEFRLanguage } from '../types/contracts'

const CEFR_LEVELS: CEFRLanguage[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']

export class DifficultyAdjustmentAgent extends Agent<Env, { history: Record<string, { level: CEFRLanguage; confidence: number }[]> }> implements LearningAgent {
  initialState = { history: {} as Record<string, { level: CEFRLanguage; confidence: number }[]> }

  id = 'difficulty-adjustment'
  get name(): string { return 'DifficultyAdjustment' }
  description = 'Manages CEFR level progression'
  priority = 1
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: DifficultyInput): Promise<DifficultyOutput> {
    return this.evaluate(input)
  }

  validate(output: DifficultyOutput): boolean {
    return output.success && !!output.data
  }

  score(output: DifficultyOutput): number {
    return output.success ? (output.data.confidence || 1.0) : 0.0
  }

  @callable()
  async evaluate(input: DifficultyInput): Promise<DifficultyOutput> {
    const userHistory = this.state.history[input.userId] || []
    const currentLevelIndex = CEFR_LEVELS.indexOf(input.currentLevel)

    let adjustment: 'increase' | 'decrease' | 'maintain' = 'maintain'
    let recommendedLevel = input.performance.correctRate > 0.85 && input.performance.averageResponseTime < 3000
      ? 'increase'
      : input.performance.correctRate < 0.5
        ? 'decrease'
        : 'maintain'

    if (recommendedLevel === 'increase' && currentLevelIndex < CEFR_LEVELS.length - 1) {
      adjustment = 'increase'
    } else if (recommendedLevel === 'decrease' && currentLevelIndex > 0) {
      adjustment = 'decrease'
    }

    const newLevelIndex = adjustment === 'increase'
      ? currentLevelIndex + 1
      : adjustment === 'decrease'
        ? currentLevelIndex - 1
        : currentLevelIndex

    const recommendedLevelFinal = CEFR_LEVELS[newLevelIndex]

    const reason = adjustment === 'increase'
      ? `Excellent performance! Correct rate ${(input.performance.correctRate * 100).toFixed(0)}% with fast response times. Ready for more challenge. [Pedagogical Action: Increase complexity, introduce richer vocabulary, reduce hints.]`
      : adjustment === 'decrease'
        ? `Correct rate ${(input.performance.correctRate * 100).toFixed(0)}% suggests the current level may be too challenging. Let's review fundamentals. [Pedagogical Action: Reduce complexity, provide additional examples, increase review frequency.]`
        : `Good performance at current level. Continue building confidence before progressing.`

    // Update history
    this.setState({
      ...this.state,
      history: {
        ...this.state.history,
        [input.userId]: [
          ...userHistory,
          { level: recommendedLevelFinal, confidence: input.performance.correctRate },
        ].slice(-30), // Keep last 30 entries
      },
    })

    return {
      agentId: 'difficulty-adjustment',
      success: true,
      data: {
        recommendedLevel: recommendedLevelFinal,
        adjustment,
        reason,
        confidence: input.performance.correctRate,
      },
    }
  }
}
