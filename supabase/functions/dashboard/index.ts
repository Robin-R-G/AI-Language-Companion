// supabase/functions/dashboard/index.ts
// Dashboard Aggregation Edge Function
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, serverError } from '../shared/errors.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE',
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const authResult = await validateRequest(req)
  if (authResult.error) return authResult.error
  if (authResult.isPreflight) return authResult.response!

  try {
    const supabase = authResult.supabaseClient
    const userId = authResult.user.id

    // Fetch all required data in parallel
    const [profileResult, progressResult, streaksResult, vocabResult, voiceResult] = await Promise.all([
      supabase
        .from('user_profiles')
        .select('full_name, native_language, target_language, proficiency_level, target_exam')
        .eq('auth_user_id', userId)
        .single(),
      supabase
        .from('user_progress')
        .select('xp, level, score, completed_at')
        .eq('user_id', userId),
      supabase
        .from('streaks')
        .select('current_streak, longest_streak, last_active_date')
        .eq('user_id', userId)
        .single(),
      supabase
        .from('vocabulary_history')
        .select('mastery_score, next_review, last_reviewed')
        .eq('user_id', userId),
      supabase
        .from('voice_sessions')
        .select('overall_score, fluency_score, pronunciation_score, created_at')
        .eq('user_id', userId),
    ])

    const profile = profileResult.data
    const progress = progressResult.data || []
    const streaks = streaksResult.data
    const vocabHistory = vocabResult.data || []
    const voiceSessions = voiceResult.data || []

    // Calculate total XP and level
    const totalXP = progress.reduce((sum: number, p: any) => sum + (p.xp || 0), 0)
    const level = progress.length > 0
      ? Math.max(...progress.map((p: any) => p.level || 1))
      : 1

    // Calculate streak
    const currentStreak = streaks?.current_streak || 0
    const longestStreak = streaks?.longest_streak || 0

    // Calculate weekly study minutes (from completed lessons)
    const oneWeekAgo = new Date()
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7)
    const weeklyLessons = progress.filter((p: any) => {
      const completedAt = new Date(p.completed_at)
      return completedAt >= oneWeekAgo
    })
    const weeklyStudyMinutes = weeklyLessons.length * 15 // Assuming 15 min per lesson

    // Calculate skill scores
    const avgWritingScore = progress.length > 0
      ? Math.round(progress.reduce((sum: number, p: any) => sum + (p.score || 0), 0) / progress.length)
      : 0

    const avgSpeakingScore = voiceSessions.length > 0
      ? Math.round(voiceSessions.reduce((sum: number, s: any) => sum + (s.overall_score || 0), 0) / voiceSessions.length)
      : 0

    const avgFluencyScore = voiceSessions.length > 0
      ? Math.round(voiceSessions.reduce((sum: number, s: any) => sum + (s.fluency_score || 0), 0) / voiceSessions.length)
      : 0

    const avgPronunciationScore = voiceSessions.length > 0
      ? Math.round(voiceSessions.reduce((sum: number, s: any) => sum + (s.pronunciation_score || 0), 0) / voiceSessions.length)
      : 0

    // Calculate vocabulary mastery
    const vocabMastery = vocabHistory.length > 0
      ? Math.round(vocabHistory.reduce((sum: number, v: any) => sum + (v.mastery_score || 0), 0) / vocabHistory.length)
      : 0

    const dueVocabCount = vocabHistory.filter((v: any) => {
      return new Date(v.next_review) <= new Date()
    }).length

    const dashboardData = {
      user: {
        name: profile?.full_name || 'Learner',
        native_language: profile?.native_language || 'Malayalam',
        target_language: profile?.target_language || 'English',
        proficiency_level: profile?.proficiency_level || 'A1',
        target_exam: profile?.target_exam || 'IELTS',
      },
      progress: {
        total_xp: totalXP,
        level,
        lessons_completed: progress.length,
      },
      streak: {
        current: currentStreak,
        longest: longestStreak,
      },
      study: {
        weekly_minutes: weeklyStudyMinutes,
        weekly_lessons: weeklyLessons.length,
      },
      skills: {
        grammar: avgWritingScore,
        speaking: avgSpeakingScore,
        writing: avgWritingScore,
        vocabulary: vocabMastery,
        fluency: avgFluencyScore,
        pronunciation: avgPronunciationScore,
      },
      vocabulary: {
        total_words: vocabHistory.length,
        due_for_review: dueVocabCount,
        average_mastery: vocabMastery,
      },
      recent_activity: {
        total_voice_sessions: voiceSessions.length,
        recent_sessions: voiceSessions.slice(0, 5),
      },
    }

    return successResponse(dashboardData, 'Dashboard data retrieved')
  } catch (error) {
    console.error('Dashboard error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
