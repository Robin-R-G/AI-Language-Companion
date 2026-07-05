// supabase/functions/shared/learning-engine/context-builder.ts
import { UserProfile, LearningProgress, CEFRLevel } from './types.ts'
import { SupabaseClient } from 'https://deno.land/x/supabase@2.3.0/mod.ts'

export interface LearningContext {
  profile: UserProfile | null
  progress: LearningProgress | null
  recentActivity: ActivityRecord[]
  vocabularyStats: VocabularyStats
  goalsProgress: GoalsProgress
  timeOfDay: string
  sessionDuration: number
}

export interface ActivityRecord {
  type: string
  date: string
  score?: number
  duration?: number
}

export interface VocabularyStats {
  totalLearned: number
  dueForReview: number
  masteredCount: number
  strugglingWords: string[]
}

export interface GoalsProgress {
  dailyMinutesToday: number
  dailyMinutesGoal: number
  weeklyLessonsCompleted: number
  weeklyGoal: number
  xpEarnedToday: number
  xpGoalToday: number
}

export class ContextBuilder {
  private supabase: SupabaseClient

  constructor(supabase: SupabaseClient) {
    this.supabase = supabase
  }

  async buildContext(userId: string): Promise<LearningContext> {
    const [profile, progress, recentActivity, vocabularyStats, goalsProgress] = await Promise.all([
      this.loadProfile(userId),
      this.loadProgress(userId),
      this.loadRecentActivity(userId),
      this.loadVocabularyStats(userId),
      this.loadGoalsProgress(userId),
    ])

    return {
      profile,
      progress,
      recentActivity,
      vocabularyStats,
      goalsProgress,
      timeOfDay: this.getTimeOfDay(),
      sessionDuration: await this.getSessionDuration(userId),
    }
  }

  private async loadProfile(userId: string): Promise<UserProfile | null> {
    const { data } = await this.supabase
      .from('user_profiles')
      .select('*')
      .eq('auth_user_id', userId)
      .single()
    return data
  }

  private async loadProgress(userId: string): Promise<LearningProgress | null> {
    const { data } = await this.supabase
      .from('user_progress')
      .select('*')
      .eq('user_id', userId)
      .single()
    return data
  }

  private async loadRecentActivity(userId: string): Promise<ActivityRecord[]> {
    const { data } = await this.supabase
      .from('analytics_events')
      .select('event_name, created_at')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(10)

    return (data || []).map((item: any) => ({
      type: item.event_name,
      date: item.created_at,
    }))
  }

  private async loadVocabularyStats(userId: string): Promise<VocabularyStats> {
    const { data: vocabHistory } = await this.supabase
      .from('vocabulary_history')
      .select('mastery_level, review_count, next_review, vocabulary(word)')
      .eq('user_id', userId)

    const { data: dueForReview } = await this.supabase
      .from('vocabulary_history')
      .select('id')
      .eq('user_id', userId)
      .lte('next_review', new Date().toISOString())

    const cards = vocabHistory || []

    return {
      totalLearned: cards.length,
      dueForReview: (dueForReview || []).length,
      masteredCount: cards.filter((c: any) => c.mastery_level >= 80 && c.review_count >= 5).length,
      strugglingWords: cards
        .filter((c: any) => c.mastery_level < 30)
        .map((c: any) => c.vocabulary?.word || 'unknown')
        .slice(0, 5),
    }
  }

  private async loadGoalsProgress(userId: string): Promise<GoalsProgress> {
    const today = new Date().toISOString().split('T')[0]
    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()

    const { data: todaySessions } = await this.supabase
      .from('voice_sessions')
      .select('duration')
      .eq('user_id', userId)
      .gte('created_at', today)

    const { data: weekLessons } = await this.supabase
      .from('lesson_progress')
      .select('id')
      .eq('user_id', userId)
      .not('completed_at', 'is', null)
      .gte('completed_at', weekAgo)

    const { data: goals } = await this.supabase
      .from('user_goals')
      .select('daily_goal_minutes')
      .eq('user_id', userId)
      .single()

    const { data: profile } = await this.supabase
      .from('user_profiles')
      .select('id')
      .eq('auth_user_id', userId)
      .single()

    const { data: analyticsToday } = await this.supabase
      .from('analytics_events')
      .select('properties')
      .eq('user_id', profile?.id || userId)
      .gte('created_at', today)
      .eq('event_name', 'lesson_completed')

    const dailyMinutes = (todaySessions || []).reduce(
      (sum: number, s: any) => sum + (s.duration || 0),
      0
    )

    return {
      dailyMinutesToday: dailyMinutes,
      dailyMinutesGoal: goals?.daily_goal_minutes || 15,
      weeklyLessonsCompleted: (weekLessons || []).length,
      weeklyGoal: 10,
      xpEarnedToday: (analyticsToday || []).reduce(
        (sum: number, e: any) => sum + (e.properties?.xp_earned || 0),
        0
      ),
      xpGoalToday: 50,
    }
  }

  private getTimeOfDay(): string {
    const hour = new Date().getHours()
    if (hour < 12) return 'morning'
    if (hour < 17) return 'afternoon'
    return 'evening'
  }

  private async getSessionDuration(userId: string): Promise<number> {
    const { data } = await this.supabase
      .from('analytics_events')
      .select('created_at')
      .eq('user_id', userId)
      .eq('event_name', 'session_start')
      .order('created_at', { ascending: false })
      .limit(1)
      .single()

    if (!data) return 0

    const start = new Date(data.created_at)
    return Math.round((Date.now() - start.getTime()) / 60000)
  }
}

export function formatContextForPrompt(context: LearningContext): string {
  const parts: string[] = []

  if (context.profile) {
    parts.push(`User: ${context.profile.fullName}`)
    parts.push(`Level: ${context.profile.proficiencyLevel}`)
    parts.push(`Native Language: ${context.profile.nativeLanguage}`)
    parts.push(`Learning: ${context.profile.targetLanguage}`)
    if (context.profile.targetExam) {
      parts.push(`Target Exam: ${context.profile.targetExam}`)
    }
  }

  if (context.progress) {
    parts.push(`XP: ${context.progress.xp}, Level: ${context.progress.level}`)
    parts.push(`Streak: ${context.progress.streak} days`)
  }

  parts.push(`Time of day: ${context.timeOfDay}`)
  parts.push(`Session duration: ${context.sessionDuration} minutes`)

  parts.push(`Vocabulary: ${context.vocabularyStats.totalLearned} learned, ${context.vocabularyStats.dueForReview} due for review`)

  if (context.vocabularyStats.strugglingWords.length > 0) {
    parts.push(`Struggling with: ${context.vocabularyStats.strugglingWords.join(', ')}`)
  }

  parts.push(`Daily goal: ${context.goalsProgress.dailyMinutesToday}/${context.goalsProgress.dailyMinutesGoal} minutes`)

  return parts.join('\n')
}
