// agents/src/agents/motivation.ts
// Motivation Agent — streaks, encouragement, burnout prevention, XP awards

import { Agent, callable } from 'agents'
import type { LearningAgent, MotivationInput, MotivationOutput } from '../types/contracts'
import type { Env } from '../types/declarations'
import { getPrompt } from '../shared/prompt-manager'
import { AIClient } from '../shared/ai'

export class MotivationAgent extends Agent<Env, { streaks: Record<string, { current: number; best: number; lastActive: string }>; achievements: Record<string, string[]>; xp: Record<string, number> }> implements LearningAgent {
  initialState = {
    streaks: {} as Record<string, { current: number; best: number; lastActive: string }>,
    achievements: {} as Record<string, string[]>,
    xp: {} as Record<string, number>,
  }

  id = 'motivation'
  get name(): string { return 'MotivationAgent' }
  description = 'Streaks, encouragement, and burnout prevention'
  priority = 1
  supportedLanguages = ['English', 'German', 'French', 'Spanish', 'Japanese', 'Korean', 'Chinese']
  supportedExams = ['IELTS', 'TOEFL', 'PTE', 'OET', 'Goethe', 'Cambridge', 'CEFR', 'General']

  @callable()
  async execute(input: MotivationInput): Promise<MotivationOutput> {
    return this.generateMotivation(input)
  }

  validate(output: MotivationOutput): boolean {
    return output.success && !!output.data
  }

  score(output: MotivationOutput): number {
    return output.success ? 1.0 : 0.0
  }

  @callable()
  async generateMotivation(input: MotivationInput): Promise<MotivationOutput> {
    const startTime = Date.now()
    const streakData = this.state.streaks[input.userId] || { current: 0, best: 0, lastActive: '' }
    const userAchievements = this.state.achievements[input.userId] || []
    const currentXp = this.state.xp[input.userId] || 0

    const today = new Date().toISOString().split('T')[0]
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0]

    // 1. Update study streaks
    let newStreak = streakData.current
    if (streakData.lastActive === yesterday || streakData.lastActive === today) {
      if (input.dailyGoalMet && streakData.lastActive !== today) {
        newStreak = streakData.current + 1
      }
    } else if (streakData.lastActive !== today) {
      newStreak = input.dailyGoalMet ? 1 : 0
    }

    const newBest = Math.max(newStreak, streakData.best)

    // 2. Award XP
    let xpEarned = 0
    if (input.dailyGoalMet) xpEarned += 100
    if (input.recentAchievements && input.recentAchievements.length > 0) {
      xpEarned += input.recentAchievements.length * 50
    }
    const totalXp = currentXp + xpEarned

    // 3. Query dynamic motivation prompt via AI client
    try {
      const promptData = getPrompt('motivation', {
        target_language: input.language,
        learning_level: input.level,
        streak: newStreak.toString(),
        daily_goal_met: input.dailyGoalMet ? 'true' : 'false',
        recent_achievements: input.recentAchievements?.join(', ') || 'none',
      })

      const ai = new AIClient(this.env)
      const response = await ai.chatWithFallback([
        { role: 'system', content: promptData.prompt },
        { role: 'user', content: `Generate motivation data. Streak is ${newStreak} days.` },
      ])

      const cleanedContent = response.content.replace(/```json|```/g, '').trim()
      const parsedData = JSON.parse(cleanedContent)

      // Update state
      this.setState({
        ...this.state,
        streaks: {
          ...this.state.streaks,
          [input.userId]: { current: newStreak, best: newBest, lastActive: today },
        },
        achievements: {
          ...this.state.achievements,
          [input.userId]: [...userAchievements, ...input.recentAchievements],
        },
        xp: {
          ...this.state.xp,
          [input.userId]: totalXp,
        },
      })

      return {
        agentId: 'motivation',
        success: true,
        data: {
          message: parsedData.message || 'Consistency is key. Keep up the good work!',
          celebration: parsedData.celebration || undefined,
          challenge: parsedData.challenge || undefined,
          streakInfo: {
            current: newStreak,
            best: newBest,
            reminder: newStreak === 0
              ? 'Start a new streak today! Even 5 minutes counts.'
              : `Keep your ${newStreak}-day streak going!`,
          },
          xpEarned,
          totalXp,
        },
        metadata: {
          tokensUsed: response.tokensUsed,
          latencyMs: Date.now() - startTime,
          confidence: 1.0,
        },
      }
    } catch (err: any) {
      // Fallback response if API fails or parsing errors out
      this.setState({
        ...this.state,
        streaks: {
          ...this.state.streaks,
          [input.userId]: { current: newStreak, best: newBest, lastActive: today },
        },
        achievements: {
          ...this.state.achievements,
          [input.userId]: [...userAchievements, ...input.recentAchievements],
        },
        xp: {
          ...this.state.xp,
          [input.userId]: totalXp,
        },
      })

      return {
        agentId: 'motivation',
        success: true,
        data: {
          message: input.dailyGoalMet
            ? 'Great job completing your study goals today! Consistency is the path to fluency.'
            : 'No worries! Take a break, recharge, and return stronger tomorrow.',
          streakInfo: {
            current: newStreak,
            best: newBest,
            reminder: newStreak === 0
              ? 'Start a new streak today! Even 5 minutes counts.'
              : `Keep your ${newStreak}-day streak going!`,
          },
          xpEarned,
          totalXp,
        },
        metadata: {
          latencyMs: Date.now() - startTime,
          confidence: 0.5,
        },
      }
    }
  }
}
