// supabase/functions/writing-api/index.ts
// Writing API Edge Function - Evaluate, History, Feedback
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
import { validateRequired, parsePagination } from '../shared/validator.ts'

const BASE_PATH = '/writing-api'

function extractIdFromPath(pathname: string): string | null {
  const prefix = `${BASE_PATH}/writing/feedback/`
  if (pathname.startsWith(prefix)) {
    return pathname.slice(prefix.length) || null
  }
  return null
}

async function handleEvaluate(
  supabase: any,
  userId: string,
  req: Request,
): Promise<Response> {
  const body = await req.json()
  const { essay_text, prompt_id, exam_type } = body

  const validation = validateRequired({ essay_text })
  if (!validation.isValid) {
    return badRequest('Validation failed', validation.errors)
  }

  if (typeof essay_text !== 'string' || essay_text.trim().length === 0) {
    return badRequest('essay_text must be a non-empty string')
  }

  const { data: profile } = await supabase
    .from('user_profiles')
    .select('native_language, target_language, proficiency_level')
    .eq('auth_user_id', userId)
    .single()

  const memory = new ConversationMemory(supabase)
  const context = await memory.loadContext('', userId)

  const promptContext: PromptContext = {
    userName: context.userProfile?.fullName,
    nativeLanguage: profile?.native_language || context.userProfile?.nativeLanguage || 'Malayalam',
    targetLanguage: profile?.target_language || context.userProfile?.targetLanguage || 'English',
    learningLevel: profile?.proficiency_level || context.userProfile?.proficiencyLevel || 'A1',
    targetExam: exam_type || context.userProfile?.targetExam || 'IELTS',
  }

  const systemPrompt = buildPrompt('writing', promptContext)
  const messages: ChatMessage[] = [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: `Evaluate this essay and return ONLY the JSON response:\n\n"${essay_text}"` },
  ]

  const ai = getAIProvider()
  const response = await ai.chatWithFallback(messages, {
    temperature: 0.3,
    maxTokens: 2048,
  })

  let evaluation
  try {
    const jsonMatch = response.content.match(/\{[\s\S]*\}/)
    if (jsonMatch) {
      evaluation = JSON.parse(jsonMatch[0])
    } else {
      evaluation = {
        estimated_band: 'N/A',
        grammar_score: 0,
        vocabulary_score: 0,
        organization_score: 0,
        clarity_score: 0,
        strengths: [],
        mistakes: [],
        improved_version: response.content,
        recommendations: [],
      }
    }
  } catch {
    evaluation = {
      estimated_band: 'N/A',
      grammar_score: 0,
      vocabulary_score: 0,
      organization_score: 0,
      clarity_score: 0,
      strengths: [],
      mistakes: [],
      improved_version: response.content,
      recommendations: [],
    }
  }

  const insertData: Record<string, unknown> = {
    user_id: userId,
    essay_text,
    estimated_band: evaluation.estimated_band,
    grammar_score: evaluation.grammar_score,
    vocabulary_score: evaluation.vocabulary_score,
    organization_score: evaluation.organization_score,
    clarity_score: evaluation.clarity_score,
    strengths: evaluation.strengths,
    mistakes: evaluation.mistakes,
    improved_version: evaluation.improved_version,
    recommendations: evaluation.recommendations,
  }

  if (prompt_id) {
    insertData.prompt_id = prompt_id
  }

  const { data: savedEvaluation, error: saveError } = await supabase
    .from('writing_tasks')
    .insert(insertData)
    .select('id')
    .single()

  if (saveError) {
    console.error('Failed to save evaluation:', saveError)
  }

  return successResponse({
    id: savedEvaluation?.id,
    ...evaluation,
    tokens_used: response.tokensUsed,
    latency_ms: response.latencyMs,
    provider: response.provider,
  }, 'Writing evaluated successfully.')
}

async function handleHistory(
  supabase: any,
  userId: string,
  url: URL,
): Promise<Response> {
  const { limit, offset } = parsePagination(url.searchParams)

  const { data: evaluations, error, count } = await supabase
    .from('writing_tasks')
    .select('*', { count: 'exact' })
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) {
    console.error('Failed to fetch writing history:', error)
    return serverError('Failed to fetch writing history')
  }

  const total = count || 0
  return successResponse(
    {
      items: evaluations || [],
      total,
      limit,
      offset,
    },
    'Writing history retrieved successfully.',
  )
}

async function handleFeedback(
  supabase: any,
  userId: string,
  evaluationId: string,
): Promise<Response> {
  const { data: evaluation, error } = await supabase
    .from('writing_tasks')
    .select('*')
    .eq('id', evaluationId)
    .eq('user_id', userId)
    .single()

  if (error || !evaluation) {
    return notFound('Writing evaluation not found')
  }

  return successResponse({ evaluation }, 'Writing feedback retrieved successfully.')
}

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
    const path = url.pathname

    // POST /writing-api/writing/evaluate
    if (req.method === 'POST' && path === `${BASE_PATH}/writing/evaluate`) {
      return await handleEvaluate(supabase, userId, req)
    }

    // GET /writing-api/writing/history
    if (req.method === 'GET' && path === `${BASE_PATH}/writing/history`) {
      return await handleHistory(supabase, userId, url)
    }

    // GET /writing-api/writing/feedback/{id}
    if (req.method === 'GET' && path.startsWith(`${BASE_PATH}/writing/feedback/`)) {
      const evaluationId = extractIdFromPath(path)
      if (!evaluationId) {
        return badRequest('Invalid feedback ID')
      }
      return await handleFeedback(supabase, userId, evaluationId)
    }

    return badRequest('Route not found')
  } catch (error) {
    console.error('Writing API error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
