// supabase/functions/analytics/index.ts
// Section 20: Analytics APIs
// GET /analytics/dashboard, GET /analytics/progress, GET /analytics/streak, GET /analytics/recommendations
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { getAIProvider, ChatMessage } from '../shared/ai.ts'
import { buildPrompt, PromptContext } from '../shared/prompts.ts'
import { ConversationMemory } from '../shared/memory.ts'
import {
  successResponse,
  notFound,
  serverError,
} from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'

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
    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(Boolean)
    const action = pathParts[pathParts.length - 1]

    const { data: profile } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('auth_user_id', userId)
      .single()

    if (!profile) {
      return notFound('User profile not found')
    }

    // GET /analytics/dashboard - Get dashboard data
    if (action === 'dashboard') {
      const [progressResult, streaksResult, vocabResult, voiceResult, lessonsResult] = await Promise.all([
        supabase.from('user_progress').select('*').eq('user_id', userId).single(),
        supabase.from('streaks').select('*').eq('user_id', userId).single(),
        supabase.from('vocabulary_history').select('mastery_level, next_review').eq('user_id', profile.id),
        supabase.from('voice_sessions').select('overall_score, fluency_score, pronunciation_score, created_at').eq('user_id', profile.id),
        supabase.from('lesson_progress').select('*').eq('user_id', profile.id),
      ])

      const progress = progressResult.data
      const streaks = streaksResult.data
      const vocabHistory = vocabResult.data || []
      const voiceSessions = voiceResult.data || []
      const lessons = lessonsResult.data || []

      const oneWeekAgo = new Date()
      oneWeekAgo.setDate(oneWeekAgo.getDate() - 7)
      const weeklyLessons = lessons.filter((l: any) => new Date(l.completed_at) >= oneWeekAgo)

      const vocabMastery = vocabHistory.length > 0
        ? Math.round(vocabHistory.reduce((sum: number, v: any) => sum + (v.mastery_level || 0), 0) / vocabHistory.length)
        : 0

      const dueVocabCount = vocabHistory.filter((v: any) => new Date(v.next_review) <= new Date()).length

      return successResponse({
        user: {
          name: profile.full_name || 'Learner',
          native_language: profile.native_language,
          target_language: profile.target_language,
          proficiency_level: profile.proficiency_level,
          target_exam: profile.target_exam,
        },
        progress: {
          total_xp: progress?.xp || 0,
          level: progress?.level || 1,
          lessons_completed: lessons.length,
        },
        streak: {
          current: streaks?.current_streak || 0,
          longest: streaks?.longest_streak || 0,
        },
        study: {
          weekly_minutes: weeklyLessons.length * 15,
          weekly_lessons: weeklyLessons.length,
        },
        skills: {
          grammar: progress?.grammar_score || 0,
          speaking: progress?.speaking_score || 0,
          writing: progress?.writing_score || 0,
          vocabulary: vocabMastery,
          reading: progress?.reading_score || 0,
          listening: progress?.listening_score || 0,
        },
        vocabulary: {
          total_words: vocabHistory.length,
          due_for_review: dueVocabCount,
          average_mastery: vocabMastery,
        },
      }, 'Dashboard data retrieved.')
    }

    // GET /analytics/progress - Get detailed progress
    if (action === 'progress') {
      const { data: progress } = await supabase
        .from('user_progress')
        .select('*')
        .eq('user_id', userId)
        .single()

      const { data: lessons } = await supabase
        .from('lesson_progress')
        .select('*, lessons(title, category, difficulty)')
        .eq('user_id', profile.id)
        .order('completed_at', { ascending: false })

      const { data: writingEvals } = await supabase
        .from('writing_evaluations')
        .select('estimated_band, grammar_score, vocabulary_score, created_at')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(10)

      const { data: voiceSessions } = await supabase
        .from('voice_sessions')
        .select('overall_score, pronunciation_score, fluency_score, created_at')
        .eq('user_id', profile.id)
        .order('created_at', { ascending: false })
        .limit(10)

      return successResponse({
        progress: progress || {
          xp: 0, level: 1,
          grammar_score: 0, speaking_score: 0, writing_score: 0,
          vocabulary_score: 0, reading_score: 0, listening_score: 0,
        },
        recent_lessons: (lessons || []).slice(0, 10),
        writing_trend: writingEvals || [],
        speaking_trend: voiceSessions || [],
      }, 'Progress data retrieved.')
    }

    // GET /analytics/streak - Get streak data
    if (action === 'streak') {
      const { data: streaks } = await supabase
        .from('streaks')
        .select('*')
        .eq('user_id', userId)
        .single()

      const { data: lessons } = await supabase
        .from('lesson_progress')
        .select('completed_at')
        .eq('user_id', profile.id)
        .order('completed_at', { ascending: false })
        .limit(30)

      // Calculate active days in last 30 days
      const activeDays = new Set(
        (lessons || []).map((l: any) => new Date(l.completed_at).toISOString().split('T')[0])
      )

      return successResponse({
        current_streak: streaks?.current_streak || 0,
        longest_streak: streaks?.longest_streak || 0,
        freeze_count: streaks?.freeze_count || 0,
        last_active_date: streaks?.last_active_date,
        active_days_last_30: activeDays.size,
        calendar: Array.from(activeDays),
      }, 'Streak data retrieved.')
    }

    // GET /analytics/recommendations - Get AI recommendations
    if (action === 'recommendations') {
      const memory = new ConversationMemory(supabase)
      const context = await memory.loadContext('', userId)

      const promptContext: PromptContext = {
        userName: context.userProfile?.fullName,
        nativeLanguage: profile.native_language,
        targetLanguage: profile.target_language,
        learningLevel: profile.proficiency_level,
        targetExam: profile.target_exam,
      }

      const { data: progress } = await supabase
        .from('user_progress')
        .select('*')
        .eq('user_id', userId)
        .single()

      const { data: streaks } = await supabase
        .from('streaks')
        .select('*')
        .eq('user_id', userId)
        .single()

      const systemPrompt = buildPrompt('tutor', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Based on this user profile, provide personalized learning recommendations:\n\nProficiency: ${profile.proficiency_level}\nTarget Exam: ${profile.target_exam}\nXP: ${progress?.xp || 0}\nLevel: ${progress?.level || 1}\nStreak: ${streaks?.current_streak || 0}\n\nReturn JSON: { "recommendations": [{ "type": "", "title": "", "description": "", "priority": "high|medium|low" }], "focus_areas": [""], "daily_goal_suggestion": "" }` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.7,
        maxTokens: 1024,
      })

      let recommendations
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        recommendations = jsonMatch ? JSON.parse(jsonMatch[0]) : { recommendations: [] }
      } catch {
        recommendations = { recommendations: [] }
      }

      return successResponse({
        ...recommendations,
        tokens_used: response.tokensUsed,
      }, 'Recommendations generated.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Analytics error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
