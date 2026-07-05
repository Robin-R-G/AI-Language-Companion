// supabase/functions/analytics-api/index.ts
// Analytics APIs
// GET /analytics/dashboard - Get analytics dashboard data
// GET /analytics/progress - Get progress over time (query param: period=week|month|quarter|year)
// GET /analytics/streak - Get streak data
// GET /analytics/recommendations - Get AI-powered recommendations
import { validateRequest } from '../shared/auth.ts'
import { getAIProvider, ChatMessage } from '../shared/ai.ts'
import { buildPrompt, PromptContext } from '../shared/prompts.ts'
import { ConversationMemory } from '../shared/memory.ts'
import {
  successResponse,
  badRequest,
  notFound,
  serverError,
} from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'

// ─── Period Helpers ───────────────────────────────────────────────────────────

function getPeriodRange(period: string): { start: Date; label: string } {
  const now = new Date()
  const start = new Date(now)

  switch (period) {
    case 'week':
      start.setDate(now.getDate() - 7)
      return { start, label: 'Last 7 days' }
    case 'month':
      start.setMonth(now.getMonth() - 1)
      return { start, label: 'Last 30 days' }
    case 'quarter':
      start.setMonth(now.getMonth() - 3)
      return { start, label: 'Last 3 months' }
    case 'year':
      start.setFullYear(now.getFullYear() - 1)
      return { start, label: 'Last 12 months' }
    default:
      start.setDate(now.getDate() - 30)
      return { start, label: 'Last 30 days' }
  }
}

function getDateBuckets(period: string): { date: string; label: string }[] {
  const now = new Date()
  const buckets: { date: string; label: string }[] = []

  if (period === 'week') {
    for (let i = 6; i >= 0; i--) {
      const d = new Date(now)
      d.setDate(now.getDate() - i)
      buckets.push({
        date: d.toISOString().split('T')[0],
        label: d.toLocaleDateString('en-US', { weekday: 'short' }),
      })
    }
  } else if (period === 'month') {
    for (let i = 29; i >= 0; i--) {
      const d = new Date(now)
      d.setDate(now.getDate() - i)
      buckets.push({
        date: d.toISOString().split('T')[0],
        label: `${d.getMonth() + 1}/${d.getDate()}`,
      })
    }
  } else if (period === 'quarter') {
    for (let i = 11; i >= 0; i--) {
      const d = new Date(now)
      d.setDate(now.getDate() - i * 7)
      buckets.push({
        date: d.toISOString().split('T')[0],
        label: `W${12 - i}`,
      })
    }
  } else {
    for (let i = 11; i >= 0; i--) {
      const d = new Date(now)
      d.setMonth(now.getMonth() - i)
      buckets.push({
        date: d.toISOString().split('T')[0],
        label: d.toLocaleDateString('en-US', { month: 'short' }),
      })
    }
  }

  return buckets
}

// ─── Handler: Dashboard ──────────────────────────────────────────────────────

async function handleDashboard(supabase: any, userId: string, profileId: string): Promise<Response> {
  const [
    progressResult,
    streaksResult,
    vocabResult,
    voiceResult,
    lessonsResult,
  ] = await Promise.all([
    supabase.from('user_progress').select('*').eq('user_id', userId).single(),
    supabase.from('streaks').select('*').eq('user_id', userId).single(),
    supabase
      .from('vocabulary')
      .select('mastery_level, next_review')
      .eq('user_id', profileId),
    supabase
      .from('voice_sessions')
      .select('fluency_score, pronunciation_score, created_at')
      .eq('user_id', profileId),
    supabase
      .from('lesson_progress')
      .select('*')
      .eq('user_id', profileId),
  ])

  const progress = progressResult.data
  const streaks = streaksResult.data
  const vocabHistory = vocabResult.data || []
  const voiceSessions = voiceResult.data || []
  const lessons = lessonsResult.data || []

  const oneWeekAgo = new Date()
  oneWeekAgo.setDate(oneWeekAgo.getDate() - 7)
  const weeklyLessons = lessons.filter(
    (l: any) => new Date(l.completed_at) >= oneWeekAgo,
  )

  const vocabMastery =
    vocabHistory.length > 0
      ? Math.round(
          vocabHistory.reduce(
            (sum: number, v: any) => sum + (v.mastery_level || 0),
            0,
          ) / vocabHistory.length,
        )
      : 0

  const dueVocabCount = vocabHistory.filter(
    (v: any) => new Date(v.next_review) <= new Date(),
  ).length

  return successResponse(
    {
      user: {
        name: profileId ? (progress?.full_name || 'Learner') : 'Learner',
        native_language: progress?.native_language,
        target_language: progress?.target_language,
        proficiency_level: progress?.proficiency_level,
        target_exam: progress?.target_exam,
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
    },
    'Dashboard data retrieved.',
  )
}

// ─── Handler: Progress ───────────────────────────────────────────────────────

async function handleProgress(
  supabase: any,
  userId: string,
  profileId: string,
  period: string,
): Promise<Response> {
  const { start, label } = getPeriodRange(period)
  const startISO = start.toISOString()

  const [progressResult, lessonsResult, writingResult, voiceResult, vocabResult] =
    await Promise.all([
      supabase
        .from('user_progress')
        .select('*')
        .eq('user_id', userId)
        .single(),
      supabase
        .from('lesson_progress')
        .select('*, lessons(title, category, difficulty)')
        .eq('user_id', profileId)
        .gte('completed_at', startISO)
        .order('completed_at', { ascending: false }),
      supabase
        .from('writing_evaluations')
        .select('estimated_band, grammar_score, vocabulary_score, created_at')
        .eq('user_id', userId)
        .gte('created_at', startISO)
        .order('created_at', { ascending: false }),
      supabase
        .from('voice_sessions')
        .select('pronunciation_score, fluency_score, created_at')
        .eq('user_id', profileId)
        .gte('created_at', startISO)
        .order('created_at', { ascending: false }),
      supabase
        .from('vocabulary')
        .select('mastery_level, created_at')
        .eq('user_id', profileId)
        .gte('created_at', startISO),
    ])

  const lessons = lessonsResult.data || []
  const writingEvals = writingResult.data || []
  const voiceSessions = voiceResult.data || []
  const vocabWords = vocabResult.data || []

  const buckets = getDateBuckets(period)

  const lessonsPerDay = buckets.map((b) => ({
    date: b.date,
    label: b.label,
    count: lessons.filter(
      (l: any) =>
        new Date(l.completed_at).toISOString().split('T')[0] === b.date,
    ).length,
  }))

  const xpPerDay = buckets.map((b) => ({
    date: b.date,
    label: b.label,
    xp: lessons
      .filter(
        (l: any) =>
          new Date(l.completed_at).toISOString().split('T')[0] === b.date,
      )
      .reduce((sum: number, l: any) => sum + (l.xp_earned || 10), 0),
  }))

  return successResponse(
    {
      period: { key: period, label },
      summary: {
        lessons_completed: lessons.length,
        writing_evaluations: writingEvals.length,
        speaking_sessions: voiceSessions.length,
        words_learned: vocabWords.length,
      },
      progress: progressResult.data || {
        xp: 0,
        level: 1,
        grammar_score: 0,
        speaking_score: 0,
        writing_score: 0,
        vocabulary_score: 0,
        reading_score: 0,
        listening_score: 0,
      },
      timeseries: {
        lessons_per_day: lessonsPerDay,
        xp_per_day: xpPerDay,
      },
      recent_lessons: lessons.slice(0, 10),
      writing_trend: writingEvals,
      speaking_trend: voiceSessions,
    },
    'Progress data retrieved.',
  )
}

// ─── Handler: Streak ─────────────────────────────────────────────────────────

async function handleStreak(
  supabase: any,
  userId: string,
  profileId: string,
): Promise<Response> {
  const [streaksResult, lessonsResult] = await Promise.all([
    supabase
      .from('streaks')
      .select('*')
      .eq('user_id', userId)
      .single(),
    supabase
      .from('lesson_progress')
      .select('completed_at')
      .eq('user_id', profileId)
      .order('completed_at', { ascending: false })
      .limit(90),
  ])

  const streaks = streaksResult.data
  const lessons = lessonsResult.data || []

  const activeDays = new Set(
    lessons.map((l: any) =>
      new Date(l.completed_at).toISOString().split('T')[0],
    ),
  )

  const today = new Date()
  const calendar: { date: string; active: boolean }[] = []
  for (let i = 29; i >= 0; i--) {
    const d = new Date(today)
    d.setDate(today.getDate() - i)
    const dateStr = d.toISOString().split('T')[0]
    calendar.push({ date: dateStr, active: activeDays.has(dateStr) })
  }

  return successResponse(
    {
      current_streak: streaks?.current_streak || 0,
      longest_streak: streaks?.longest_streak || 0,
      freeze_count: streaks?.freeze_count || 0,
      last_active_date: streaks?.last_active_date,
      active_days_last_90: activeDays.size,
      active_days_last_30: calendar.filter((c) => c.active).length,
      calendar,
    },
    'Streak data retrieved.',
  )
}

// ─── Handler: Recommendations ────────────────────────────────────────────────

async function handleRecommendations(
  supabase: any,
  userId: string,
): Promise<Response> {
  const memory = new ConversationMemory(supabase)
  const context = await memory.loadContext('', userId)

  const { data: profile } = await supabase
    .from('user_profiles')
    .select('*')
    .eq('auth_user_id', userId)
    .single()

  if (!profile) {
    return notFound('User profile not found.')
  }

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
    {
      role: 'user',
      content: `Based on this user profile, provide personalized learning recommendations:

Proficiency: ${profile.proficiency_level}
Target Exam: ${profile.target_exam || 'General'}
XP: ${progress?.xp || 0}
Level: ${progress?.level || 1}
Current Streak: ${streaks?.current_streak || 0}
Grammar Score: ${progress?.grammar_score || 0}
Speaking Score: ${progress?.speaking_score || 0}
Writing Score: ${progress?.writing_score || 0}
Vocabulary Score: ${progress?.vocabulary_score || 0}
Reading Score: ${progress?.reading_score || 0}
Listening Score: ${progress?.listening_score || 0}

Return ONLY valid JSON with this structure:
{
  "recommendations": [
    {
      "type": "grammar|vocabulary|speaking|writing|reading|listening",
      "title": "short title",
      "description": "actionable recommendation with specific steps",
      "priority": "high|medium|low"
    }
  ],
  "focus_areas": ["area1", "area2"],
  "daily_goal_suggestion": "suggested daily study plan"
}`,
    },
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

  return successResponse(
    {
      ...recommendations,
      tokens_used: response.tokensUsed,
      provider: response.provider,
      model: response.model,
    },
    'Recommendations generated.',
  )
}

// ─── Entry Point ─────────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
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
      .select('id')
      .eq('auth_user_id', userId)
      .single()

    if (!profile) {
      return notFound('User profile not found.')
    }

    const profileId = profile.id

    switch (action) {
      case 'dashboard':
        return await handleDashboard(supabase, userId, profileId)
      case 'progress': {
        const period = url.searchParams.get('period') || 'month'
        const validPeriods = ['week', 'month', 'quarter', 'year']
        if (!validPeriods.includes(period)) {
          return badRequest(
            `Invalid period. Must be one of: ${validPeriods.join(', ')}`,
          )
        }
        return await handleProgress(supabase, userId, profileId, period)
      }
      case 'streak':
        return await handleStreak(supabase, userId, profileId)
      case 'recommendations':
        return await handleRecommendations(supabase, userId)
      default:
        return badRequest(`Unknown endpoint: ${action}`)
    }
  } catch (error) {
    console.error('Analytics API error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
