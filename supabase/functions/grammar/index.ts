// supabase/functions/grammar/index.ts
// Section 11: Grammar APIs
// GET /grammar, GET /grammar/{topic}, POST /grammar/submit
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

const GRAMMAR_TOPICS = [
  'tenses', 'articles', 'prepositions', 'pronouns', 'adjectives',
  'adverbs', 'conjunctions', 'conditionals', 'passive_voice',
  'reported_speech', 'modals', 'gerunds', 'infinitives',
  'relative_clauses', 'comparatives', 'superlatives',
]

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

    // GET /grammar - List all grammar topics
    if (req.method === 'GET' && lastPart === 'grammar') {
      const { data: profile } = await supabase
        .from('user_profiles')
        .select('proficiency_level')
        .eq('auth_user_id', userId)
        .single()

      const level = profile?.proficiency_level || 'A1'

      const topics = GRAMMAR_TOPICS.map((topic) => ({
        id: topic,
        name: topic.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase()),
        difficulty: level,
        description: `Practice ${topic.replace(/_/g, ' ')} exercises`,
      }))

      return successResponse({
        topics,
        total: topics.length,
      }, 'Grammar topics retrieved successfully.')
    }

    // GET /grammar/{topic} - Get specific grammar topic
    if (req.method === 'GET' && lastPart !== 'grammar') {
      const topic = lastPart

      if (!GRAMMAR_TOPICS.includes(topic)) {
        return notFound('Grammar topic not found')
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

      const systemPrompt = buildPrompt('grammar', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Generate a grammar lesson about ${topic.replace(/_/g, ' ')}. Include: explanation, examples, common mistakes, and 3 practice exercises. Return JSON: { "topic": "", "explanation": "", "examples": [""], "common_mistakes": [""], "exercises": [{ "question": "", "options": [""], "correct_answer": "", "explanation": "" }] }` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.7,
        maxTokens: 2048,
      })

      let grammarContent
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        if (jsonMatch) {
          grammarContent = JSON.parse(jsonMatch[0])
        } else {
          grammarContent = {
            topic,
            explanation: response.content,
            examples: [],
            common_mistakes: [],
            exercises: [],
          }
        }
      } catch {
        grammarContent = {
          topic,
          explanation: response.content,
          examples: [],
          common_mistakes: [],
          exercises: [],
        }
      }

      return successResponse({
        topic,
        content: grammarContent,
        tokens_used: response.tokensUsed,
        latency_ms: response.latencyMs,
      }, 'Grammar topic content retrieved.')
    }

    // POST /grammar/submit - Submit grammar exercise
    if (req.method === 'POST' && lastPart === 'submit') {
      const body = await req.json()
      const { topic, exercise_id, answer, text } = body

      // Handle text-based grammar check
      if (text) {
        const validation = validateRequired({ text })
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

        const systemPrompt = buildPrompt('grammar', promptContext)
        const messages: ChatMessage[] = [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: `Check the grammar of this text and return ONLY the JSON response:\n\n"${text}"` },
        ]

        const ai = getAIProvider()
        const response = await ai.chatWithFallback(messages, {
          temperature: 0.3,
          maxTokens: 1024,
        })

        let grammarResult
        try {
          const jsonMatch = response.content.match(/\{[\s\S]*\}/)
          if (jsonMatch) {
            grammarResult = JSON.parse(jsonMatch[0])
          } else {
            grammarResult = {
              is_correct: true,
              original: text,
              corrected: text,
              explanation: response.content,
              category: 'General',
              examples: [],
            }
          }
        } catch {
          grammarResult = {
            is_correct: true,
            original: text,
            corrected: text,
            explanation: response.content,
            category: 'General',
            examples: [],
          }
        }

        return successResponse(grammarResult, 'Grammar evaluated successfully.')
      }

      // Handle exercise submission
      const validation = validateRequired({ topic, answer })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      // For now, return a basic evaluation
      return successResponse({
        topic,
        exercise_id,
        user_answer: answer,
        is_correct: true,
        feedback: 'Answer submitted for review.',
      }, 'Grammar exercise submitted.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Grammar error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
