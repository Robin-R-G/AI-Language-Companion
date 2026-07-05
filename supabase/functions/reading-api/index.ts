// supabase/functions/reading-api/index.ts
// Reading API endpoints
// GET /reading - List reading exercises (query params: level, topic)
// GET /reading/{id} - Get reading exercise with passage and questions
// POST /reading/submit - Submit reading answers
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
import { validateRequired, parsePagination } from '../shared/validator.ts'
import { corsHeaders } from '../shared/cors.ts'

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
    const lastPart = pathParts[pathParts.length - 1]
    const isSubmitEndpoint = lastPart === 'submit'
    const isReadingRoot = lastPart === 'reading'

    // GET /reading - List reading exercises
    if (req.method === 'GET' && isReadingRoot) {
      const { limit, offset } = parsePagination(url.searchParams)
      const level = url.searchParams.get('level')
      const topic = url.searchParams.get('topic')

      const { data: profile } = await supabase
        .from('user_profiles')
        .select('proficiency_level')
        .eq('auth_user_id', userId)
        .single()

      const filterLevel = level || profile?.proficiency_level || 'A1'

      let query = supabase
        .from('reading_lessons')
        .select('*', { count: 'exact' })
        .eq('difficulty', filterLevel)

      if (topic) {
        query = query.eq('topic', topic)
      }

      const { data: readings, error, count } = await query
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1)

      if (error) {
        return successResponse({
          readings: [],
          pagination: { limit, offset, total: 0, total_pages: 0 },
        }, 'No reading exercises available yet.')
      }

      const total = count || 0
      return successResponse({
        readings: readings || [],
        pagination: {
          limit,
          offset,
          total,
          total_pages: Math.ceil(total / limit),
        },
      }, 'Reading exercises retrieved.')
    }

    // GET /reading/{id} - Get reading exercise with passage and questions
    if (req.method === 'GET' && !isReadingRoot && !isSubmitEndpoint) {
      const passageId = lastPart

      const { data: passage, error } = await supabase
        .from('reading_lessons')
        .select('*')
        .eq('id', passageId)
        .single()

      if (error || !passage) {
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

        const systemPrompt = buildPrompt('reading', promptContext)
        const messages: ChatMessage[] = [
          { role: 'system', content: systemPrompt },
          {
            role: 'user',
            content: `Generate a reading passage with comprehension questions. Return JSON: { "title": "", "passage": "", "difficulty": "", "questions": [{ "question": "", "options": [""], "correct_answer": "", "explanation": "" }] }`,
          },
        ]

        const ai = getAIProvider()
        const response = await ai.chatWithFallback(messages, {
          temperature: 0.7,
          maxTokens: 2048,
        })

        let readingContent
        try {
          const jsonMatch = response.content.match(/\{[\s\S]*\}/)
          if (jsonMatch) {
            readingContent = JSON.parse(jsonMatch[0])
          } else {
            readingContent = {
              title: 'Reading Practice',
              passage: response.content,
              difficulty: profile?.proficiency_level || 'A1',
              questions: [],
            }
          }
        } catch {
          readingContent = {
            title: 'Reading Practice',
            passage: response.content,
            difficulty: profile?.proficiency_level || 'A1',
            questions: [],
          }
        }

        return successResponse(
          {
            id: passageId,
            ...readingContent,
            tokens_used: response.tokensUsed,
            latency_ms: response.latencyMs,
          },
          'Reading passage generated.'
        )
      }

      return successResponse({ passage }, 'Reading passage retrieved.')
    }

    // POST /reading/submit - Submit reading answers
    if (req.method === 'POST' && isSubmitEndpoint) {
      const body = await req.json()
      const { passage_id, answers } = body

      const validation = validateRequired({ passage_id, answers })
      if (!validation.isValid) {
        return badRequest('Validation failed', validation.errors)
      }

      const messages: ChatMessage[] = [
        {
          role: 'system',
          content:
            'You are a reading comprehension evaluator. Return JSON: { "score": 0-100, "feedback": [{ "question_index": 0, "correct": true, "explanation": "" }] }',
        },
        {
          role: 'user',
          content: `Evaluate these reading comprehension answers:\n${JSON.stringify({ passage_id, answers })}`,
        },
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
            feedback: answers.map((_: unknown, i: number) => ({
              question_index: i,
              correct: true,
              explanation: 'Answer accepted.',
            })),
          }
        }
      } catch {
        evaluation = {
          score: 80,
          feedback: answers.map((_: unknown, i: number) => ({
            question_index: i,
            correct: true,
            explanation: 'Answer accepted.',
          })),
        }
      }

      return successResponse(
        {
          passage_id,
          ...evaluation,
          tokens_used: response.tokensUsed,
        },
        'Reading answers evaluated.'
      )
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Reading API error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
