// supabase/functions/shared/learning-engine/spaced-repetition.ts
import { Flashcard, SRSResponse } from './types.ts'

/**
 * SM-2 Algorithm implementation for spaced repetition
 * Based on SuperMemo 2 algorithm with modifications
 */

export function calculateNextReview(
  flashcard: Flashcard,
  quality: number
): SRSResponse {
  // quality: 0-5 (0=complete blackout, 5=perfect response)
  if (quality < 0 || quality > 5) {
    throw new Error('Quality must be between 0 and 5')
  }

  let { easeFactor, interval, repetitions } = flashcard

  if (quality >= 3) {
    // Correct response
    if (repetitions === 0) {
      interval = 1
    } else if (repetitions === 1) {
      interval = 6
    } else {
      interval = Math.round(interval * easeFactor)
    }
    repetitions += 1
  } else {
    // Incorrect response - reset
    repetitions = 0
    interval = 1
  }

  // Update ease factor
  easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))

  // Minimum ease factor of 1.3
  if (easeFactor < 1.3) {
    easeFactor = 1.3
  }

  // Calculate next review date
  const now = new Date()
  const nextReview = new Date(now.getTime() + interval * 24 * 60 * 60 * 1000)

  return {
    flashcardId: flashcard.id,
    quality,
    easeFactor: Math.round(easeFactor * 100) / 100,
    interval,
    nextReview: nextReview.toISOString(),
  }
}

export function getCardsDueForReview(cards: Flashcard[]): Flashcard[] {
  const now = new Date()
  return cards.filter((card) => {
    const nextReview = new Date(card.nextReview)
    return nextReview <= now
  })
}

export function sortCardsByPriority(cards: Flashcard[]): Flashcard[] {
  return [...cards].sort((a, b) => {
    // Priority: overdue cards first, then by ease factor (harder first)
    const now = new Date()
    const aOverdue = now.getTime() - new Date(a.nextReview).getTime()
    const bOverdue = now.getTime() - new Date(b.nextReview).getTime()

    if (aOverdue > 0 && bOverdue <= 0) return -1
    if (aOverdue <= 0 && bOverdue > 0) return 1
    if (aOverdue > 0 && bOverdue > 0) {
      return bOverdue - aOverdue // More overdue first
    }

    return a.easeFactor - b.easeFactor // Harder cards first
  })
}

export function getReviewStats(cards: Flashcard[]): {
  newCards: number
  learning: number
  review: number
  mastered: number
  dueToday: number
} {
  const now = new Date()
  const todayStr = now.toISOString().split('T')[0]

  return {
    newCards: cards.filter((c) => c.repetitions === 0).length,
    learning: cards.filter((c) => c.repetitions > 0 && c.repetitions < 5).length,
    review: cards.filter((c) => c.repetitions >= 5 && c.easeFactor >= 2.0).length,
    mastered: cards.filter((c) => c.easeFactor >= 2.5 && c.interval >= 21).length,
    dueToday: cards.filter((c) => {
      const nextReview = new Date(c.nextReview).toISOString().split('T')[0]
      return nextReview <= todayStr
    }).length,
  }
}
