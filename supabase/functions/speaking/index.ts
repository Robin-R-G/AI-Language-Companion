// supabase/functions/speaking/index.ts
// Section 15: Speaking APIs
// POST /speaking/start, POST /speaking/stop, POST /speaking/evaluate, GET /speaking/history
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { getAIProvider, ChatMessage } from '../shared/ai.ts'
import { buildPrompt, PromptContext } from '../shared/prompts.ts'
import { ConversationMemory } from '../shared/memory.ts'
import {
  successResponse,
  createdResponse,
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

    // POST /speaking/start - Start a speaking session
    if (req.method === 'POST' && lastPart === 'start') {
      const body = await req.json()
      const { topic, mode } = body

      const { data: profile } = await supabase
        .from('user_profiles')
        .select('id, native_language, target_language, proficiency_level')
        .eq('auth_user_id', userId)
        .single()

      if (!profile) {
        return notFound('User profile not found')
      }

      // Create voice session
      const { data: session, error: sessionError } = await supabase
        .from('voice_sessions')
        .insert({
          user_id: profile.id,
          provider: 'livekit',
          room_id: `speaking-${Date.now()}`,
          transcript: '',
        })
        .select('id')
        .single()

      if (sessionError) {
        console.error('Failed to create speaking session:', sessionError)
        return serverError('Failed to start speaking session')
      }

      // Generate speaking prompt using AI
      const memory = new ConversationMemory(supabase)
      const context = await memory.loadContext('', userId)

      const promptContext: PromptContext = {
        userName: context.userProfile?.fullName,
        nativeLanguage: profile.native_language,
        targetLanguage: profile.target_language,
        learningLevel: profile.proficiency_level,
      }

      const systemPrompt = buildPrompt('speaking', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Generate a speaking practice prompt for topic: ${topic || 'general conversation'}. Return JSON: { "prompt": "", "suggested_response": "", "tips": [""] }` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.7,
        maxTokens: 1024,
      })

      let speakingPrompt
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        if (jsonMatch) {
          speakingPrompt = JSON.parse(jsonMatch[0])
        } else {
          speakingPrompt = {
            prompt: response.content,
            suggested_response: '',
            tips: [],
          }
        }
      } catch {
        speakingPrompt = {
          prompt: response.content,
          suggested_response: '',
          tips: [],
        }
      }

      return createdResponse({
        session_id: session.id,
        ...speakingPrompt,
      }, 'Speaking session started.')
    }

    // POST /speaking/stop - Stop speaking session
    if (req.method === 'POST' && lastPart === 'stop') {
      const body = await req.json()
      const { session_id, transcript } = body

      const validation = validateRequired({ session_id })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      const { error } = await supabase
        .from('voice_sessions')
        .update({
          transcript: transcript || '',
          duration: 0,
        })
        .eq('id', session_id)
        .eq('user_id', userId)

      if (error) {
        console.error('Failed to stop session:', error)
        return serverError('Failed to stop speaking session')
      }

      return successResponse({ session_id }, 'Speaking session stopped.')
    }

    // POST /speaking/evaluate - Evaluate speaking performance
    if (req.method === 'POST' && lastPart === 'evaluate') {
      const body = await req.json()
      const { session_id, transcript } = body

      const validation = validateRequired({ transcript })
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
      }

      const systemPrompt = buildPrompt('speaking', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Evaluate this speaking transcript for pronunciation, fluency, grammar, and vocabulary. Return JSON: { "overall_score": 0-100, "pronunciation_score": 0-100, "fluency_score": 0-100, "grammar_score": 0-100, "vocabulary_score": 0-100, "feedback": "", "strengths": [""], "improvements": [""] }\n\nTranscript: "${transcript}"` },
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
            overall_score: 70,
            pronunciation_score: 70,
            fluency_score: 70,
            grammar_score: 70,
            vocabulary_score: 70,
            feedback: response.content,
            strengths: [],
            improvements: [],
          }
        }
      } catch {
        evaluation = {
          overall_score: 70,
          pronunciation_score: 70,
          fluency_score: 70,
          grammar_score: 70,
          vocabulary_score: 70,
          feedback: response.content,
          strengths: [],
          improvements: [],
        }
      }

      // Update session with scores
      if (session_id) {
        await supabase
          .from('voice_sessions')
          .update({
            pronunciation_score: evaluation.pronunciation_score,
            fluency_score: evaluation.fluency_score,
            overall_score: evaluation.overall_score,
            transcript,
          })
          .eq('id', session_id)
      }

      return successResponse({
        session_id,
        ...evaluation,
        tokens_used: response.tokensUsed,
        latency_ms: response.latencyMs,
      }, 'Speaking performance evaluated.')
    }

    // GET /speaking/history - Get speaking session history
    if (req.method === 'GET' && lastPart === 'history') {
      const page = parseInt(url.searchParams.get('page') || '1')
      const limit = parseInt(url.searchParams.get('limit') || '10')

      const { data: sessions, error, count } = await supabase
        .from('voice_sessions')
        .select('*', { count: 'exact' })
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .range((page - 1) * limit, page * limit - 1)

      if (error) {
        console.error('Failed to fetch speaking history:', error)
        return serverError('Failed to fetch speaking history')
      }

      const total = count || 0
      return successResponse({
        sessions: sessions || [],
        pagination: {
          page,
          limit,
          total,
          total_pages: Math.ceil(total / limit),
        },
      }, 'Speaking history retrieved.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Speaking error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
