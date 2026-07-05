// supabase/functions/lessons/index.ts
// Lesson endpoints: list, get by id, start, complete
import { validateRequest } from '../shared/auth.ts'
import {
  successResponse,
  createdResponse,
  badRequest,
  notFound,
  serverError,
} from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequired, parsePagination } from '../shared/validator.ts'

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
    const segment = pathParts[pathParts.length - 1]
    const isAction = ['start', 'complete'].includes(segment || '')

    // GET /lessons - List available lessons
    if (req.method === 'GET' && !isAction) {
      const { limit, offset } = parsePagination(url.searchParams)
      const type = url.searchParams.get('type')
      const level = url.searchParams.get('level')

      let query = supabase
        .from('lessons')
        .select('*', { count: 'exact' })

      if (type) query = query.eq('type', type)
      if (level) query = query.eq('level', level)

      query = query
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1)

      const { data: lessons, error, count } = await query

      if (error) {
        console.error('Failed to fetch lessons:', error)
        return serverError('Failed to fetch lessons')
      }

      const total = count || 0

      return successResponse(lessons || [], 'Lessons retrieved successfully.', {
        total,
        limit,
        offset,
      })
    }

    // GET /lessons/{id} - Get lesson by ID
    if (req.method === 'GET' && segment && !isAction) {
      const { data: lesson, error } = await supabase
        .from('lessons')
        .select('*')
        .eq('id', segment)
        .single()

      if (error || !lesson) {
        return notFound('Lesson not found')
      }

      const { data: profile } = await supabase
        .from('user_profiles')
        .select('id')
        .eq('auth_user_id', userId)
        .single()

      let progress = null
      if (profile) {
        const { data: progressData } = await supabase
          .from('lesson_progress')
          .select('*')
          .eq('user_id', profile.id)
          .eq('lesson_id', segment)
          .single()

        progress = progressData || null
      }

      return successResponse({ lesson, progress }, 'Lesson retrieved successfully.')
    }

    // POST /lessons/start - Start a lesson
    if (req.method === 'POST' && segment === 'start') {
      const body = await req.json()
      const { lesson_id } = body

      const validation = validateRequired({ lesson_id })
      if (!validation.isValid) {
        return badRequest('Validation failed', validation.errors)
      }

      const { data: lesson, error: lessonError } = await supabase
        .from('lessons')
        .select('id')
        .eq('id', lesson_id)
        .single()

      if (lessonError || !lesson) {
        return notFound('Lesson not found')
      }

      const { data: profile, error: profileError } = await supabase
        .from('user_profiles')
        .select('id')
        .eq('auth_user_id', userId)
        .single()

      if (profileError || !profile) {
        return notFound('User profile not found')
      }

      const { data: existingProgress } = await supabase
        .from('lesson_progress')
        .select('id, completion_percentage')
        .eq('user_id', profile.id)
        .eq('lesson_id', lesson_id)
        .single()

      if (existingProgress && existingProgress.completion_percentage === 100) {
        return badRequest('Lesson already completed')
      }

      let progressResult
      if (existingProgress) {
        progressResult = await supabase
          .from('lesson_progress')
          .update({ started_at: new Date().toISOString() })
          .eq('id', existingProgress.id)
          .select('*')
          .single()
      } else {
        progressResult = await supabase
          .from('lesson_progress')
          .insert({
            user_id: profile.id,
            lesson_id,
            completion_percentage: 0,
            started_at: new Date().toISOString(),
          })
          .select('*')
          .single()
      }

      if (progressResult.error) {
        console.error('Failed to start lesson:', progressResult.error)
        return serverError('Failed to start lesson')
      }

      return createdResponse(
        { lesson_id, progress: progressResult.data },
        'Lesson started successfully.',
      )
    }

    // POST /lessons/complete - Complete a lesson with score
    if (req.method === 'POST' && segment === 'complete') {
      const body = await req.json()
      const { lesson_id, score, mistakes } = body

      const validation = validateRequired({ lesson_id, score })
      if (!validation.isValid) {
        return badRequest('Validation failed', validation.errors)
      }

      if (typeof score !== 'number' || score < 0 || score > 100 || !Number.isInteger(score)) {
        return badRequest('Score must be an integer between 0 and 100.')
      }

      const { data: profile, error: profileError } = await supabase
        .from('user_profiles')
        .select('id')
        .eq('auth_user_id', userId)
        .single()

      if (profileError || !profile) {
        return notFound('User profile not found')
      }

      const { data: lesson, error: lessonError } = await supabase
        .from('lessons')
        .select('id, xp_reward')
        .eq('id', lesson_id)
        .single()

      if (lessonError || !lesson) {
        return notFound('Lesson not found')
      }

      const baseXP = lesson.xp_reward || 50
      const bonusMultiplier = score >= 90 ? 1.5 : score >= 70 ? 1.2 : 1.0
      const earnedXP = Math.round(baseXP * bonusMultiplier)

      const { error: progressError } = await supabase
        .from('lesson_progress')
        .upsert({
          user_id: profile.id,
          lesson_id,
          completion_percentage: 100,
          earned_xp: earnedXP,
          mistakes: mistakes || 0,
          completed_at: new Date().toISOString(),
        }, { onConflict: 'user_id,lesson_id' })

      if (progressError) {
        console.error('Failed to complete lesson:', progressError)
        return serverError('Failed to save lesson completion')
      }

      const { data: currentProgress } = await supabase
        .from('user_progress')
        .select('xp, level')
        .eq('user_id', userId)
        .single()

      const currentXP = currentProgress?.xp || 0
      const currentLevel = currentProgress?.level || 1
      const newXP = currentXP + earnedXP
      const newLevel = Math.floor(newXP / 500) + 1

      await supabase
        .from('user_progress')
        .upsert({
          user_id: userId,
          xp: newXP,
          level: newLevel,
          last_study_date: new Date().toISOString().split('T')[0],
        }, { onConflict: 'user_id' })

      const today = new Date().toISOString().split('T')[0]
      const { data: streakData } = await supabase
        .from('streaks')
        .select('current_streak, longest_streak, last_active_date')
        .eq('user_id', userId)
        .single()

      let newStreak = 1
      if (streakData) {
        const lastActive = streakData.last_active_date
        const yesterday = new Date()
        yesterday.setDate(yesterday.getDate() - 1)
        const yesterdayStr = yesterday.toISOString().split('T')[0]

        if (lastActive === today) {
          newStreak = streakData.current_streak
        } else if (lastActive === yesterdayStr) {
          newStreak = streakData.current_streak + 1
        }
      }

      const longestStreak = Math.max(newStreak, streakData?.longest_streak || 0)

      await supabase
        .from('streaks')
        .upsert({
          user_id: userId,
          current_streak: newStreak,
          longest_streak: longestStreak,
          last_active_date: today,
        }, { onConflict: 'user_id' })

      return successResponse({
        lesson_id,
        score,
        earned_xp: earnedXP,
        total_xp: newXP,
        level: newLevel,
        leveled_up: newLevel > currentLevel,
        streak: newStreak,
      }, 'Lesson completed successfully.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Lessons error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
