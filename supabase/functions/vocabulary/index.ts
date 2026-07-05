// supabase/functions/vocabulary/index.ts
// Vocabulary SRS Management with SM-2 Algorithm
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, serverError } from '../shared/errors.ts'
import { validateRequired, validateNumber } from '../shared/validator.ts'
import { corsHeaders } from '../shared/cors.ts'

function calculateNextReview(masteryScore: number, currentInterval: number = 0): Date {
  const now = new Date()
  let daysToAdd: number

  switch (masteryScore) {
    case 1:
      daysToAdd = 1
      break
    case 2:
      daysToAdd = 3
      break
    case 3:
      daysToAdd = 7
      break
    case 4:
      daysToAdd = 14
      break
    case 5:
      daysToAdd = 30
      break
    default:
      daysToAdd = 1
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

    if (req.method === 'GET') {
      // Get due vocabulary reviews
      const { data: profile, error: profileError } = await supabase
        .from('user_profiles')
        .select('id')
        .eq('auth_user_id', userId)
        .single()

      if (profileError || !profile) {
        return badRequest('User profile not found')
      }

      const { data: dueCards, error } = await supabase
        .from('vocabulary_history')
        .select(`
          *,
          vocabulary (*)
        `)
        .eq('user_id', profile.id)
        .lte('next_review', new Date().toISOString())
        .order('next_review', { ascending: true })
        .limit(20)

      if (error) {
        console.error('Failed to fetch vocabulary:', error)
        return serverError('Failed to fetch vocabulary reviews')
      }

      return successResponse({
        due_cards: dueCards || [],
        total_due: dueCards?.length || 0,
      }, 'Due vocabulary cards retrieved')
    }

    if (req.method === 'POST') {
      const body = await req.json()
      const { word_id, mastery_score } = body

      const validation = validateRequired({ word_id, mastery_score })
      if (!validation.isValid) {
        return badRequest(validation.errors.join(', '))
      }

      const masteryValidation = validateNumber(mastery_score, 'mastery_score', { min: 1, max: 5, integer: true })
      if (!masteryValidation.isValid) {
        return badRequest(masteryValidation.errors.join(', '))
      }

      const { data: profile, error: profileError } = await supabase
        .from('user_profiles')
        .select('id')
        .eq('auth_user_id', userId)
        .single()

      if (profileError || !profile) {
        return badRequest('User profile not found')
      }

      // Get current vocabulary history record
      const { data: existingRecord, error: recordError } = await supabase
        .from('vocabulary_history')
        .select('id, current_interval, review_count')
        .eq('user_id', profile.id)
        .eq('word_id', word_id)
        .single()

      const nextReview = calculateNextReview(mastery_score, existingRecord?.current_interval || 0)
      const newInterval = mastery_score >= 3
        ? Math.min((existingRecord?.current_interval || 1) * 2, 30)
        : 1

      if (existingRecord) {
        // Update existing record
        const { error: updateError } = await supabase
          .from('vocabulary_history')
          .update({
            mastery_score,
            next_review: nextReview.toISOString(),
            current_interval: newInterval,
            review_count: (existingRecord.review_count || 0) + 1,
            last_reviewed: new Date().toISOString(),
          })
          .eq('id', existingRecord.id)

        if (updateError) {
          console.error('Failed to update vocabulary:', updateError)
          return serverError('Failed to update vocabulary progress')
        }
      } else {
        // Create new record
        const { error: insertError } = await supabase
          .from('vocabulary_history')
          .insert({
            user_id: profile.id,
            word_id,
            mastery_score,
            next_review: nextReview.toISOString(),
            current_interval: newInterval,
            review_count: 1,
            last_reviewed: new Date().toISOString(),
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
      }, 'Vocabulary progress updated')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Vocabulary error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
