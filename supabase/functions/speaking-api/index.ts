// supabase/functions/speaking-api/index.ts
// Speaking API - Sessions, Evaluation, and History
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, notFound, serverError } from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequired, parsePagination } from '../shared/validator.ts'
import { getAIProvider, ChatMessage } from '../shared/ai.ts'
import { buildPrompt, PromptContext } from '../shared/prompts.ts'
import { ConversationMemory } from '../shared/memory.ts'

interface VoiceTranscript {
  id: string
  session_id: string
  speaker: string
  text: string
  start_time: number
  end_time: number
  created_at: string
}

const BASE_PATH = '/speaking-api'

async function getProfileId(supabase: any, userId: string): Promise<string | null> {
  const { data: profile, error } = await supabase
    .from('user_profiles')
    .select('id')
    .eq('auth_user_id', userId)
    .single()

  if (error || !profile) return null
  return profile.id
}

async function getProfileLevel(supabase: any, userId: string): Promise<string> {
  const { data: profile } = await supabase
    .from('user_profiles')
    .select('proficiency_level')
    .eq('auth_user_id', userId)
    .single()

  return profile?.proficiency_level || 'A1'
}

async function handleStartSession(
  supabase: any,
  userId: string,
  req: Request,
): Promise<Response> {
  const body = await req.json()
  const { topic, target_language, session_type } = body

  const validation = validateRequired({ topic })
  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '))
  }

  const profileId = await getProfileId(supabase, userId)
  if (!profileId) {
    return notFound('User profile not found')
  }

  const level = await getProfileLevel(supabase, userId)

  const { data: session, error: insertError } = await supabase
    .from('voice_sessions')
    .insert({
      user_id: profileId,
      topic,
      target_language: target_language || 'English',
      session_type: session_type || 'free_speech',
      status: 'active',
      proficiency_level: level,
      started_at: new Date().toISOString(),
    })
    .select('id')
    .single()

  if (insertError) {
    console.error('Failed to create voice session:', insertError)
    return serverError('Failed to create speaking session')
  }

  return successResponse(
    {
      session_id: session.id,
      topic,
      target_language: target_language || 'English',
      session_type: session_type || 'free_speech',
      status: 'active',
      started_at: new Date().toISOString(),
    },
    'Speaking session started successfully',
  )
}

async function handleStopSession(
  supabase: any,
  userId: string,
  req: Request,
): Promise<Response> {
  const body = await req.json()
  const { session_id } = body

  const validation = validateRequired({ session_id })
  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '))
  }

  const profileId = await getProfileId(supabase, userId)
  if (!profileId) {
    return notFound('User profile not found')
  }

  const { data: session, error: fetchError } = await supabase
    .from('voice_sessions')
    .select('id, status, started_at')
    .eq('id', session_id)
    .eq('user_id', profileId)
    .single()

  if (fetchError || !session) {
    return notFound('Speaking session not found')
  }

  if (session.status === 'completed') {
    return badRequest('Session is already completed')
  }

  const durationMs = Date.now() - new Date(session.started_at).getTime()

  const { error: updateError } = await supabase
    .from('voice_sessions')
    .update({
      status: 'completed',
      completed_at: new Date().toISOString(),
      duration_ms: durationMs,
    })
    .eq('id', session_id)

  if (updateError) {
    console.error('Failed to stop voice session:', updateError)
    return serverError('Failed to stop speaking session')
  }

  return successResponse(
    {
      session_id,
      status: 'completed',
      duration_ms: durationMs,
      completed_at: new Date().toISOString(),
    },
    'Speaking session stopped successfully',
  )
}

async function handleEvaluate(
  supabase: any,
  userId: string,
  req: Request,
): Promise<Response> {
  const body = await req.json()
  const { session_id, transcript_text, target_language } = body

  const validation = validateRequired({ transcript_text })
  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '))
  }

  const profileId = await getProfileId(supabase, userId)
  if (!profileId) {
    return notFound('User profile not found')
  }

  const memory = new ConversationMemory(supabase)
  const context = await memory.loadContext('', userId)

  const promptContext: PromptContext = {
    userName: context.userProfile?.fullName,
    nativeLanguage: context.userProfile?.nativeLanguage || 'Malayalam',
    targetLanguage: target_language || context.userProfile?.targetLanguage || 'English',
    learningLevel: context.userProfile?.proficiencyLevel || 'A1',
    targetExam: context.userProfile?.targetExam,
  }

  const systemPrompt = buildPrompt('speaking', promptContext)

  const messages: ChatMessage[] = [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: `Evaluate this speech transcript and return ONLY the JSON response:\n\n"${transcript_text}"` },
  ]

  const ai = getAIProvider()
  const response = await ai.chatWithFallback(messages, {
    temperature: 0.3,
    maxTokens: 1024,
  })

  let evaluation
  try {
    const jsonMatch = response.content.match(/\{[\s\S]*\}/)
    if (jsonMatch) {
      evaluation = JSON.parse(jsonMatch[0])
    } else {
      evaluation = {
        fluency_score: 0,
        grammar_score: 0,
        vocabulary_score: 0,
        pronunciation_score: 0,
        overall_score: 0,
        feedback: response.content,
        strengths: [],
        issues: [],
        practice_words: [],
        shadowing_exercise: '',
        estimated_proficiency: 'N/A',
      }
    }
  } catch {
    evaluation = {
      fluency_score: 0,
      grammar_score: 0,
      vocabulary_score: 0,
      pronunciation_score: 0,
      overall_score: 0,
      feedback: response.content,
      strengths: [],
      issues: [],
      practice_words: [],
      shadowing_exercise: '',
      estimated_proficiency: 'N/A',
    }
  }

  if (session_id) {
    await supabase
      .from('voice_sessions')
      .update({
        fluency_score: evaluation.fluency_score,
        grammar_score: evaluation.grammar_score,
        vocabulary_score: evaluation.vocabulary_score,
        pronunciation_score: evaluation.pronunciation_score,
        overall_score: evaluation.overall_score,
        feedback: evaluation,
        estimated_proficiency: evaluation.estimated_proficiency,
        status: 'completed',
        completed_at: new Date().toISOString(),
      })
      .eq('id', session_id)
      .eq('user_id', profileId)
  } else {
    const { data: session } = await supabase
      .from('voice_sessions')
      .insert({
        user_id: profileId,
        transcript: transcript_text,
        target_language: target_language || context.userProfile?.targetLanguage || 'English',
        fluency_score: evaluation.fluency_score,
        grammar_score: evaluation.grammar_score,
        vocabulary_score: evaluation.vocabulary_score,
        pronunciation_score: evaluation.pronunciation_score,
        overall_score: evaluation.overall_score,
        feedback: evaluation,
        estimated_proficiency: evaluation.estimated_proficiency,
        status: 'completed',
      })
      .select('id')
      .single()

    if (session) {
      evaluation.session_id = session.id
    }
  }

  await supabase.from('voice_transcripts').insert({
    session_id: session_id || evaluation.session_id || null,
    user_id: profileId,
    speaker: 'user',
    text: transcript_text,
    created_at: new Date().toISOString(),
  })

  return successResponse(
    {
      ...evaluation,
      session_id: session_id || evaluation.session_id || null,
      tokens_used: response.tokensUsed,
      latency_ms: response.latencyMs,
      provider: response.provider,
    },
    'Speaking performance evaluated successfully',
  )
}

async function handleHistory(
  supabase: any,
  userId: string,
  url: URL,
): Promise<Response> {
  const { limit, offset } = parsePagination(url.searchParams)
  const status = url.searchParams.get('status')
  const language = url.searchParams.get('language')

  const profileId = await getProfileId(supabase, userId)
  if (!profileId) {
    return notFound('User profile not found')
  }

  let query = supabase
    .from('voice_sessions')
    .select('*', { count: 'exact' })
    .eq('user_id', profileId)

  if (status) {
    query = query.eq('status', status)
  }
  if (language) {
    query = query.eq('target_language', language)
  }

  const { data: sessions, error, count } = await query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) {
    console.error('Failed to fetch speaking history:', error)
    return serverError('Failed to fetch speaking history')
  }

  const items = (sessions || []).map((s: any) => ({
    id: s.id,
    topic: s.topic,
    target_language: s.target_language,
    session_type: s.session_type,
    status: s.status,
    fluency_score: s.fluency_score,
    grammar_score: s.grammar_score,
    vocabulary_score: s.vocabulary_score,
    pronunciation_score: s.pronunciation_score,
    overall_score: s.overall_score,
    estimated_proficiency: s.estimated_proficiency,
    duration_ms: s.duration_ms,
    started_at: s.started_at,
    completed_at: s.completed_at,
    created_at: s.created_at,
  }))

  return successResponse(
    {
      sessions: items,
    },
    'Speaking history retrieved successfully',
    {
      limit,
      offset,
      total: count || 0,
      total_pages: Math.ceil((count || 0) / limit),
    },
  )
}

Deno.serve(async (req: Request): Promise<Response> => {
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

    // POST /speaking-api/start
    if (path === `${BASE_PATH}/start` && req.method === 'POST') {
      return await handleStartSession(supabase, userId, req)
    }

    // POST /speaking-api/stop
    if (path === `${BASE_PATH}/stop` && req.method === 'POST') {
      return await handleStopSession(supabase, userId, req)
    }

    // POST /speaking-api/evaluate
    if (path === `${BASE_PATH}/evaluate` && req.method === 'POST') {
      return await handleEvaluate(supabase, userId, req)
    }

    // GET /speaking-api/history
    if (path === `${BASE_PATH}/history` && req.method === 'GET') {
      return await handleHistory(supabase, userId, url)
    }

    return badRequest('Route not found')
  } catch (error) {
    console.error('Speaking API error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
