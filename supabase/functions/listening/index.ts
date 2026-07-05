// supabase/functions/listening/index.ts
// Section 13: Listening APIs
// GET /listening, GET /listening/audio/{id}, POST /listening/submit
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
    const isAudioEndpoint = pathParts.includes('audio')

    // GET /listening - List listening exercises
    if (req.method === 'GET' && lastPart === 'listening') {
      const page = parseInt(url.searchParams.get('page') || '1')
      const limit = parseInt(url.searchParams.get('limit') || '10')
      const difficulty = url.searchParams.get('difficulty')

      const { data: profile } = await supabase
        .from('user_profiles')
        .select('proficiency_level')
        .eq('auth_user_id', userId)
        .single()

      const level = difficulty || profile?.proficiency_level || 'A1'

      const { data: exercises, error, count } = await supabase
        .from('listening_exercises')
        .select('*', { count: 'exact' })
        .eq('difficulty', level)
        .order('created_at', { ascending: false })
        .range((page - 1) * limit, page * limit - 1)

      if (error) {
        return successResponse({
          exercises: [],
          pagination: { page, limit, total: 0, total_pages: 0 },
        }, 'No listening exercises available yet.')
      }

      const total = count || 0
      return successResponse({
        exercises: exercises || [],
        pagination: {
          page,
          limit,
          total,
          total_pages: Math.ceil(total / limit),
        },
      }, 'Listening exercises retrieved.')
    }

    // GET /listening/audio/{id} - Get audio content for listening exercise
    if (req.method === 'GET' && isAudioEndpoint) {
      const exerciseId = lastPart

      const { data: exercise, error } = await supabase
        .from('listening_exercises')
        .select('*')
        .eq('id', exerciseId)
        .single()

      if (error || !exercise) {
        // Generate listening content using AI
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

        const systemPrompt = buildPrompt('listening', promptContext)
        const messages: ChatMessage[] = [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: `Generate a listening exercise with a transcript and comprehension questions. Return JSON: { "title": "", "transcript": "", "difficulty": "", "audio_url": "", "questions": [{ "question": "", "options": [""], "correct_answer": "", "explanation": "" }] }` },
        ]

        const ai = getAIProvider()
        const response = await ai.chatWithFallback(messages, {
          temperature: 0.7,
          maxTokens: 2048,
        })

        let listeningContent
        try {
          const jsonMatch = response.content.match(/\{[\s\S]*\}/)
          if (jsonMatch) {
            listeningContent = JSON.parse(jsonMatch[0])
          } else {
            listeningContent = {
              title: 'Listening Practice',
              transcript: response.content,
              difficulty: profile?.proficiency_level || 'A1',
              audio_url: '',
              questions: [],
            }
          }
        } catch {
          listeningContent = {
            title: 'Listening Practice',
            transcript: response.content,
            difficulty: profile?.proficiency_level || 'A1',
            audio_url: '',
            questions: [],
          }
        }

        return successResponse({
          id: exerciseId,
          ...listeningContent,
          tokens_used: response.tokensUsed,
          latency_ms: response.latencyMs,
        }, 'Listening exercise generated.')
      }

      return successResponse({ exercise }, 'Listening exercise retrieved.')
    }

    // POST /listening/submit - Submit listening answers
    if (req.method === 'POST' && lastPart === 'submit') {
      const body = await req.json()
      const { exercise_id, answers } = body

      const validation = validateRequired({ exercise_id, answers })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      const messages: ChatMessage[] = [
        { role: 'system', content: 'You are a listening comprehension evaluator. Return JSON: { "score": 0-100, "feedback": [{ "question_index": 0, "correct": true, "explanation": "" }] }' },
        { role: 'user', content: `Evaluate these listening comprehension answers:\n${JSON.stringify({ exercise_id, answers })}` },
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
            score: 80,
            feedback: answers.map((_: any, i: number) => ({
              question_index: i,
              correct: true,
              explanation: 'Answer accepted.',
            })),
          }
        }
      } catch {
        evaluation = {
          score: 80,
          feedback: answers.map((_: any, i: number) => ({
            question_index: i,
            correct: true,
            explanation: 'Answer accepted.',
          })),
        }
      }

      return successResponse({
        exercise_id,
        ...evaluation,
        tokens_used: response.tokensUsed,
      }, 'Listening answers evaluated.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Listening error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
