// supabase/functions/vocabulary-api/index.ts
// Vocabulary SRS Management with SM-2 Algorithm
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, notFound, serverError } from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequired, parsePagination } from '../shared/validator.ts'

interface VocabularyRecord {
  id: string
  user_id: string
  word_id: string
  ease_factor: number
  interval: number
  repetitions: number
  next_review: string
  last_reviewed: string | null
  status: string
  created_at: string
}

interface SM2Result {
  ease_factor: number
  interval: number
  repetitions: number
  next_review: Date
}

function sm2Algorithm(
  quality: number,
  currentEaseFactor: number = 2.5,
  currentInterval: number = 0,
  currentRepetitions: number = 0,
): SM2Result {
  let easeFactor = currentEaseFactor
  let interval = currentInterval
  let repetitions = currentRepetitions

  if (quality < 0 || quality > 5) {
    throw new Error('Quality must be between 0 and 5')
  }

  if (quality >= 3) {
    if (repetitions === 0) {
      interval = 1
    } else if (repetitions === 1) {
      interval = 6
    } else {
      interval = Math.round(currentInterval * easeFactor)
    }
    repetitions += 1
  } else {
    repetitions = 0
    interval = 1
  }

  easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))

  if (easeFactor < 1.3) {
    easeFactor = 1.3
  }

  const now = new Date()
  const nextReview = new Date(now.getTime() + interval * 24 * 60 * 60 * 1000)

  return {
    ease_factor: Math.round(easeFactor * 100) / 100,
    interval,
    repetitions,
    next_review: nextReview,
  }
}

async function getProfileId(supabase: any, userId: string): Promise<string | null> {
  const { data: profile, error } = await supabase
    .from('user_profiles')
    .select('id')
    .eq('auth_user_id', userId)
    .single()

  if (error || !profile) return null
  return profile.id
}

async function handleListVocabulary(
  supabase: any,
  userId: string,
  url: URL,
): Promise<Response> {
  const profileId = await getProfileId(supabase, userId)
  if (!profileId) {
    return badRequest('User profile not found')
  }

  const status = url.searchParams.get('status')
  const { limit, offset } = parsePagination(url.searchParams)

  let query = supabase
    .from('vocabulary')
    .select('*', { count: 'exact' })
    .eq('user_id', profileId)

  if (status) {
    query = query.eq('status', status)
  }

  const { data, error, count } = await query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) {
    console.error('Failed to fetch vocabulary:', error)
    return serverError('Failed to fetch vocabulary')
  }

  return successResponse(
    { items: data || [], total: count || 0, limit, offset },
    'Vocabulary retrieved successfully',
  )
}

async function handleReview(
  supabase: any,
  userId: string,
  req: Request,
): Promise<Response> {
  const body = await req.json()
  const { word_id, quality } = body

  const validation = validateRequired({ word_id, quality })
  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '))
  }

  if (typeof quality !== 'number' || quality < 0 || quality > 5 || !Number.isInteger(quality)) {
    return badRequest('quality must be an integer between 0 and 5')
  }

  const profileId = await getProfileId(supabase, userId)
  if (!profileId) {
    return badRequest('User profile not found')
  }

  const { data: existing, error: fetchError } = await supabase
    .from('vocabulary')
    .select('*')
    .eq('user_id', profileId)
    .eq('word_id', word_id)
    .single()

  if (fetchError || !existing) {
    return notFound('Vocabulary word not found for this user')
  }

  const sm2 = sm2Algorithm(
    quality,
    existing.ease_factor || 2.5,
    existing.interval || 0,
    existing.repetitions || 0,
  )

  const newStatus = sm2.ease_factor >= 2.5 && sm2.interval >= 21
    ? 'mastered'
    : quality >= 3
      ? 'learning'
      : 'new'

  const { error: updateError } = await supabase
    .from('vocabulary')
    .update({
      ease_factor: sm2.ease_factor,
      interval: sm2.interval,
      repetitions: sm2.repetitions,
      next_review: sm2.next_review.toISOString(),
      last_reviewed: new Date().toISOString(),
      status: newStatus,
    })
    .eq('id', existing.id)

  if (updateError) {
    console.error('Failed to update vocabulary:', updateError)
    return serverError('Failed to update vocabulary review')
  }

  return successResponse(
    {
      word_id,
      quality,
      ease_factor: sm2.ease_factor,
      interval: sm2.interval,
      repetitions: sm2.repetitions,
      next_review: sm2.next_review.toISOString(),
      status: newStatus,
    },
    'Vocabulary review recorded',
  )
}

async function handleMarkMastered(
  supabase: any,
  userId: string,
  req: Request,
): Promise<Response> {
  const body = await req.json()
  const { word_id } = body

  const validation = validateRequired({ word_id })
  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '))
  }

  const profileId = await getProfileId(supabase, userId)
  if (!profileId) {
    return badRequest('User profile not found')
  }

  const { data: existing, error: fetchError } = await supabase
    .from('vocabulary')
    .select('*')
    .eq('user_id', profileId)
    .eq('word_id', word_id)
    .single()

  if (fetchError || !existing) {
    return notFound('Vocabulary word not found for this user')
  }

  const { error: updateError } = await supabase
    .from('vocabulary')
    .update({
      status: 'mastered',
      ease_factor: Math.max(existing.ease_factor || 2.5, 2.5),
      interval: Math.max(existing.interval || 0, 21),
      last_reviewed: new Date().toISOString(),
    })
    .eq('id', existing.id)

  if (updateError) {
    console.error('Failed to mark as mastered:', updateError)
    return serverError('Failed to mark vocabulary as mastered')
  }

  return successResponse(
    { word_id, status: 'mastered' },
    'Vocabulary marked as mastered',
  )
}

async function handleRecommendations(
  supabase: any,
  userId: string,
): Promise<Response> {
  const profileId = await getProfileId(supabase, userId)
  if (!profileId) {
    return badRequest('User profile not found')
  }

  const { data: profile, error: profileError } = await supabase
    .from('user_profiles')
    .select('current_level')
    .eq('id', profileId)
    .single()

  if (profileError || !profile) {
    return serverError('Failed to fetch user profile')
  }

  const userLevel = profile.current_level || 'A1'

  const { data: learnedWords } = await supabase
    .from('vocabulary')
    .select('word_id')
    .eq('user_id', profileId)

  const learnedWordIds = (learnedWords || []).map((w: any) => w.word_id)

  let query = supabase
    .from('vocabulary')
    .select('*')
    .eq('user_id', profileId)
    .is('status', null)

  if (learnedWordIds.length > 0) {
    query = query.not('word_id', 'in', `(${learnedWordIds.join(',')})`)
  }

  query = query.eq('difficulty_level', userLevel)

  const { data: recommendations, error: recError } = await query
    .order('created_at', { ascending: true })
    .limit(20)

  if (recError) {
    console.error('Failed to fetch recommendations:', recError)
    return serverError('Failed to fetch vocabulary recommendations')
  }

  return successResponse(
    {
      recommendations: recommendations || [],
      level: userLevel,
      total: recommendations?.length || 0,
    },
    'Vocabulary recommendations retrieved',
  )
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
    const url = new URL(req.url)
    const path = url.pathname

    const basePath = '/vocabulary-api'

    if (path === `${basePath}/vocabulary` && req.method === 'GET') {
      return await handleListVocabulary(supabase, userId, url)
    }

    if (path === `${basePath}/vocabulary/review` && req.method === 'POST') {
      return await handleReview(supabase, userId, req)
    }

    if (path === `${basePath}/vocabulary/mastered` && req.method === 'POST') {
      return await handleMarkMastered(supabase, userId, req)
    }

    if (path === `${basePath}/vocabulary/recommendations` && req.method === 'GET') {
      return await handleRecommendations(supabase, userId)
    }

    return badRequest('Route not found')
  } catch (error) {
    console.error('Vocabulary API error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
