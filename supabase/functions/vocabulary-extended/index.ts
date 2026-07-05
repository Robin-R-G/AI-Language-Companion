// supabase/functions/vocabulary-extended/index.ts
// Section 10: Extended Vocabulary APIs
// GET /vocabulary, POST /vocabulary/review, POST /vocabulary/mastered, GET /vocabulary/recommendations
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
import { validateRequired, validateNumber } from '../shared/validator.ts'
import { corsHeaders } from '../shared/cors.ts'

function calculateNextReview(masteryScore: number): Date {
  const now = new Date()
  let daysToAdd: number

  switch (masteryScore) {
    case 1: daysToAdd = 1; break
    case 2: daysToAdd = 3; break
    case 3: daysToAdd = 7; break
    case 4: daysToAdd = 14; break
    case 5: daysToAdd = 30; break
    default: daysToAdd = 1
  }

  return new Date(now.getTime() + daysToAdd * 24 * 60 * 60 * 1000)
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
    const pathParts = url.pathname.split('/').filter(Boolean)
    const action = pathParts[pathParts.length - 1]

    // GET /vocabulary - List vocabulary with pagination
    if (req.method === 'GET' && action === 'vocabulary') {
      const page = parseInt(url.searchParams.get('page') || '1')
      const limit = parseInt(url.searchParams.get('limit') || '20')
      const cefr_level = url.searchParams.get('cefr_level')
      const search = url.searchParams.get('search')

      let query = supabase
        .from('vocabulary')
        .select('*', { count: 'exact' })

      if (cefr_level) query = query.eq('cefr_level', cefr_level)
      if (search) query = query.ilike('word', `%${search}%`)

      const offset = (page - 1) * limit
      query = query
        .order('word', { ascending: true })
        .range(offset, offset + limit - 1)

      const { data: words, error, count } = await query

      if (error) {
        console.error('Failed to fetch vocabulary:', error)
        return serverError('Failed to fetch vocabulary')
      }

      const total = count || 0
      const totalPages = Math.ceil(total / limit)

      return successResponse({
        vocabulary: words || [],
        pagination: {
          page,
          limit,
          total,
          total_pages: totalPages,
        },
      }, 'Vocabulary retrieved successfully.')
    }

    // GET /vocabulary/recommendations - Get AI-recommended vocabulary
    if (req.method === 'GET' && action === 'recommendations') {
      const { data: profile } = await supabase
        .from('user_profiles')
        .select('id, native_language, target_language, proficiency_level, target_exam')
        .eq('auth_user_id', userId)
        .single()

      if (!profile) {
        return notFound('User profile not found')
      }

      // Get user's vocabulary history to avoid recommending known words
      const { data: knownWords } = await supabase
        .from('vocabulary_history')
        .select('vocabulary_id')
        .eq('user_id', profile.id)

      const knownWordIds = knownWords?.map((w: any) => w.vocabulary_id) || []

      // Get words the user needs to review (due for SRS)
      const { data: dueWords } = await supabase
        .from('vocabulary_history')
        .select('*, vocabulary(*)')
        .eq('user_id', profile.id)
        .lte('next_review', new Date().toISOString())
        .order('next_review', { ascending: true })
        .limit(10)

      // Get new words at user's level
      let newWordsQuery = supabase
        .from('vocabulary')
        .select('*')
        .eq('cefr_level', profile.proficiency_level || 'A1')
        .limit(10)

      if (knownWordIds.length > 0) {
        newWordsQuery = newWordsQuery.not('id', 'in', `(${knownWordIds.join(',')})`)
      }

      const { data: newWords } = await newWordsQuery

      // Get AI recommendations based on learning context
      const memory = new ConversationMemory(supabase)
      const context = await memory.loadContext('', userId)

      const promptContext: PromptContext = {
        userName: context.userProfile?.fullName,
        nativeLanguage: profile.native_language,
        targetLanguage: profile.target_language,
        learningLevel: profile.proficiency_level,
        targetExam: profile.target_exam,
      }

      const systemPrompt = buildPrompt('vocabulary', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Recommend 5 vocabulary words for a ${profile.proficiency_level} level learner preparing for ${profile.target_exam || 'general proficiency'}. Return JSON: { "recommendations": [{ "word": "", "meaning": "", "example": "", "cefr_level": "" }] }` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.7,
        maxTokens: 1024,
      })

      let aiRecommendations: any[] = []
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        if (jsonMatch) {
          const parsed = JSON.parse(jsonMatch[0])
          aiRecommendations = parsed.recommendations || []
        }
      } catch {
        // AI recommendations are optional
      }

      return successResponse({
        due_for_review: dueWords || [],
        new_words: newWords || [],
        ai_recommendations: aiRecommendations,
      }, 'Vocabulary recommendations retrieved.')
    }

    // POST /vocabulary/review - Review vocabulary (SRS update)
    if (req.method === 'POST' && action === 'review') {
      const body = await req.json()
      const { word_id, mastery_score } = body

      const validation = validateRequired({ word_id, mastery_score })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      const masteryValidation = validateNumber(mastery_score, 'mastery_score', { min: 1, max: 5, integer: true })
      if (!masteryValidation.isValid) {
        return validationError('Invalid mastery_score', masteryValidation.errors)
      }

      const { data: profile } = await supabase
        .from('user_profiles')
        .select('id')
        .eq('auth_user_id', userId)
        .single()

      if (!profile) {
        return notFound('User profile not found')
      }

      // Check existing record
      const { data: existingRecord } = await supabase
        .from('vocabulary_history')
        .select('id, current_interval, review_count')
        .eq('user_id', profile.id)
        .eq('vocabulary_id', word_id)
        .single()

      const nextReview = calculateNextReview(mastery_score)
      const newInterval = mastery_score >= 3
        ? Math.min((existingRecord?.current_interval || 1) * 2, 30)
        : 1

      if (existingRecord) {
        const { error: updateError } = await supabase
          .from('vocabulary_history')
          .update({
            mastery_level: mastery_score,
            next_review: nextReview.toISOString(),
            current_interval: newInterval,
            review_count: (existingRecord.review_count || 0) + 1,
            updated_at: new Date().toISOString(),
          })
          .eq('id', existingRecord.id)

        if (updateError) {
          console.error('Failed to update vocabulary:', updateError)
          return serverError('Failed to update vocabulary progress')
        }
      } else {
        const { error: insertError } = await supabase
          .from('vocabulary_history')
          .insert({
            user_id: profile.id,
            vocabulary_id: word_id,
            mastery_level: mastery_score,
            next_review: nextReview.toISOString(),
            current_interval: newInterval,
            review_count: 1,
          })

        if (insertError) {
          console.error('Failed to insert vocabulary:', insertError)
          return serverError('Failed to save vocabulary progress')
        }
      }

      return successResponse({
        word_id,
        mastery_score,
        next_review: nextReview.toISOString(),
        current_interval: newInterval,
      }, 'Vocabulary review recorded.')
    }

    // POST /vocabulary/mastered - Mark word as mastered
    if (req.method === 'POST' && action === 'mastered') {
      const body = await req.json()
      const { word_id } = body

      const validation = validateRequired({ word_id })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      const { data: profile } = await supabase
        .from('user_profiles')
        .select('id')
        .eq('auth_user_id', userId)
        .single()

      if (!profile) {
        return notFound('User profile not found')
      }

      // Upsert with mastery score 5
      const { error } = await supabase
        .from('vocabulary_history')
        .upsert({
          user_id: profile.id,
          vocabulary_id: word_id,
          mastery_level: 5,
          review_count: 5,
          current_interval: 30,
          next_review: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString(),
          updated_at: new Date().toISOString(),
        }, { onConflict: 'user_id,vocabulary_id' })

      if (error) {
        console.error('Failed to mark as mastered:', error)
        return serverError('Failed to mark word as mastered')
      }

      return successResponse({
        word_id,
        mastery_level: 5,
        status: 'mastered',
      }, 'Word marked as mastered.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Vocabulary extended error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
