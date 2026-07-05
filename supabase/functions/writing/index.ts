// supabase/functions/writing/index.ts
// Section 14: Writing APIs
// POST /writing/evaluate, GET /writing/history, GET /writing/feedback/{id}
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { getAIProvider, ChatMessage } from '../shared/ai.ts'
import { buildPrompt, PromptContext } from '../shared/prompts.ts'
import { ConversationMemory } from '../shared/memory.ts'
import {
  successResponse,
  badRequest,
  validationError,
  notFound,
  serverError,
} from '../shared/errors.ts'
import { validateRequired } from '../shared/validator.ts'
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
    const lastPart = pathParts[pathParts.length - 1]

    // POST /writing/evaluate - Evaluate writing
    if (req.method === 'POST' && lastPart === 'evaluate') {
      const body = await req.json()
      const { essay_text, prompt_id, exam_type } = body

      const validation = validateRequired({ essay_text })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
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
        nativeLanguage: profile?.native_language || 'Malayalam',
        targetLanguage: profile?.target_language || 'English',
        learningLevel: profile?.proficiency_level || 'A1',
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

      // Save evaluation
      const { data: savedEvaluation, error: saveError } = await supabase
        .from('writing_tasks')
        .insert({
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
        })
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

    // GET /writing/history - Get writing evaluation history
    if (req.method === 'GET' && lastPart === 'history') {
      const page = parseInt(url.searchParams.get('page') || '1')
      const limit = parseInt(url.searchParams.get('limit') || '10')

      const { data: evaluations, error, count } = await supabase
        .from('writing_tasks')
        .select('*', { count: 'exact' })
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .range((page - 1) * limit, page * limit - 1)

      if (error) {
        console.error('Failed to fetch writing history:', error)
        return serverError('Failed to fetch writing history')
      }

      const total = count || 0
      return successResponse({
        evaluations: evaluations || [],
        pagination: {
          page,
          limit,
          total,
          total_pages: Math.ceil(total / limit),
        },
      }, 'Writing history retrieved.')
    }

    // GET /writing/feedback/{id} - Get specific writing feedback
    if (req.method === 'GET' && lastPart !== 'writing' && lastPart !== 'history' && lastPart !== 'evaluate') {
      const evaluationId = lastPart

      const { data: evaluation, error } = await supabase
        .from('writing_tasks')
        .select('*')
        .eq('id', evaluationId)
        .eq('user_id', userId)
        .single()

      if (error || !evaluation) {
        return notFound('Writing evaluation not found')
      }

      return successResponse({ evaluation }, 'Writing feedback retrieved.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Writing error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
