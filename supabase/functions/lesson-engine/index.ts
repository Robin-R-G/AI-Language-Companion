// supabase/functions/lesson-engine/index.ts
// Lesson Engine Edge Function with AI-powered Lesson Generation
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { getAIProvider, ChatMessage } from '../shared/ai.ts'
import { buildPrompt, PromptContext } from '../shared/prompts.ts'
import { ConversationMemory } from '../shared/memory.ts'
import { successResponse, badRequest, serverError } from '../shared/errors.ts'
import { validateRequired } from '../shared/validator.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE',
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
    const memory = new ConversationMemory(supabase)
    const url = new URL(req.url)

    if (req.method === 'GET') {
      const lessonId = url.searchParams.get('lesson_id')

      if (lessonId) {
        // Get lesson details
        const { data: lesson, error } = await supabase
          .from('lessons')
          .select('*')
          .eq('id', lessonId)
          .single()

        if (error || !lesson) {
          return badRequest('Lesson not found')
        }

        // Get user progress for this lesson
        const { data: progress } = await supabase
          .from('user_progress')
          .select('*')
          .eq('user_id', userId)
          .eq('lesson_id', lessonId)
          .single()

        return successResponse({
          lesson,
          progress: progress || null,
        }, 'Lesson details retrieved')
      }

      // Get lessons list
      const context = await memory.loadContext('', userId)
      const level = context.userProfile?.proficiencyLevel || 'A1'

      const { data: lessons, error } = await supabase
        .from('lessons')
        .select('*')
        .eq('difficulty', level)
        .order('created_at', { ascending: false })
        .limit(20)

      if (error) {
        console.error('Failed to fetch lessons:', error)
        return serverError('Failed to fetch lessons')
      }

      return successResponse({
        lessons: lessons || [],
        level,
      }, 'Lessons retrieved')
    }

    if (req.method === 'POST') {
      const body = await req.json()
      const { lesson_id, score, generate } = body

      // Generate a new lesson if requested
      if (generate) {
        const context = await memory.loadContext('', userId)

        const promptContext: PromptContext = {
          userName: context.userProfile?.fullName,
          nativeLanguage: context.userProfile?.nativeLanguage || 'Malayalam',
          targetLanguage: context.userProfile?.targetLanguage || 'English',
          learningLevel: context.userProfile?.proficiencyLevel || 'A1',
          targetExam: context.userProfile?.targetExam || 'IELTS',
        }

        const systemPrompt = buildPrompt('lesson', promptContext)

        const messages: ChatMessage[] = [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: 'Generate a new lesson. Return ONLY the JSON response.' },
        ]

        const ai = getAIProvider()
        const response = await ai.chatWithFallback(messages, {
          temperature: 0.7,
          maxTokens: 2048,
        })

        let lessonData
        try {
          const jsonMatch = response.content.match(/\{[\s\S]*\}/)
          if (jsonMatch) {
            lessonData = JSON.parse(jsonMatch[0])
          } else {
            lessonData = {
              title: 'Generated Lesson',
              category: 'general',
              difficulty: context.userProfile?.proficiencyLevel || 'A1',
              estimated_minutes: 15,
              content: response.content,
              vocabulary: [],
              quizzes: [],
            }
          }
        } catch {
          lessonData = {
            title: 'Generated Lesson',
            category: 'general',
            difficulty: context.userProfile?.proficiencyLevel || 'A1',
            estimated_minutes: 15,
            content: response.content,
            vocabulary: [],
            quizzes: [],
          }
        }

        // Save generated lesson
        const { data: newLesson, error: insertError } = await supabase
          .from('lessons')
          .insert({
            title: lessonData.title,
            category: lessonData.category,
            difficulty: lessonData.difficulty,
            estimated_minutes: lessonData.estimated_minutes,
            content: lessonData.content,
            vocabulary: lessonData.vocabulary,
            quizzes: lessonData.quizzes,
            is_ai_generated: true,
          })
          .select('id')
          .single()

        if (insertError) {
          console.error('Failed to save lesson:', insertError)
          return serverError('Failed to save generated lesson')
        }

        return successResponse({
          lesson_id: newLesson.id,
          ...lessonData,
        }, 'Lesson generated successfully')
      }

      // Complete a lesson
      const validation = validateRequired({ lesson_id, score })
      if (!validation.isValid) {
        return badRequest(validation.errors.join(', '))
      }

      const scoreValidation = validateNumber(score, 'score', { min: 0, max: 100 })
      if (!scoreValidation.isValid) {
        return badRequest(scoreValidation.errors.join(', '))
      }

      // Calculate XP earned: base 50 + (score * 0.5 bonus)
      const baseXP = 50
      const bonusXP = Math.round(score * 0.5)
      const totalXP = baseXP + bonusXP

      // Get current user progress
      const { data: currentProgress } = await supabase
        .from('user_progress')
        .select('xp, level')
        .eq('user_id', userId)
        .single()

      const currentXP = currentProgress?.xp || 0
      const currentLevel = currentProgress?.level || 1
      const newXP = currentXP + totalXP
      const newLevel = Math.floor(newXP / 500) + 1 // Level up every 500 XP

      // Update or insert user progress
      const { error: progressError } = await supabase
        .from('user_progress')
        .upsert({
          user_id: userId,
          lesson_id,
          score,
          xp: newXP,
          level: newLevel,
          completed_at: new Date().toISOString(),
        }, { onConflict: 'user_id,lesson_id' })

      if (progressError) {
        console.error('Failed to update progress:', progressError)
        return serverError('Failed to save lesson progress')
      }

      return successResponse({
        lesson_id,
        score,
        xp_earned: totalXP,
        base_xp: baseXP,
        bonus_xp: bonusXP,
        total_xp: newXP,
        level: newLevel,
        leveled_up: newLevel > currentLevel,
      }, 'Lesson completed successfully')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Lesson engine error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
