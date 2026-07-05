// supabase/functions/assessment/index.ts
// Section 19: Assessment APIs
// POST /assessment/start, POST /assessment/submit, GET /assessment/results, GET /assessment/history
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
    const action = pathParts[pathParts.length - 1]

    const { data: profile } = await supabase
      .from('user_profiles')
      .select('id, native_language, target_language, proficiency_level')
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

    // POST /assessment/start - Start assessment
    if (req.method === 'POST' && action === 'start') {
      const body = await req.json()
      const { type, skills } = body

      const systemPrompt = buildPrompt('tutor', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Generate a ${type || 'placement'} assessment covering ${skills || 'all skills'}. Include questions for grammar, vocabulary, reading, listening, writing, and speaking. Return JSON: { "assessment_id": "", "type": "", "total_questions": 0, "sections": [{ "skill": "", "questions": [{ "question": "", "options": [""], "correct_answer": "" }], "time_limit_minutes": 0 }] }` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.7,
        maxTokens: 4096,
      })

      let assessment
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        assessment = jsonMatch ? JSON.parse(jsonMatch[0]) : { type: 'placement', sections: [] }
      } catch {
        assessment = { type: 'placement', sections: [] }
      }

      // Save assessment record
      const { data: savedAssessment } = await supabase
        .from('mock_exams')
        .insert({
          user_id: profile?.id,
          exam_type: 'assessment',
          section: type || 'placement',
        })
        .select('id')
        .single()

      return createdResponse({
        assessment_id: savedAssessment?.id,
        ...assessment,
        tokens_used: response.tokensUsed,
      }, 'Assessment started.')
    }

    // POST /assessment/submit - Submit assessment answers
    if (req.method === 'POST' && action === 'submit') {
      const body = await req.json()
      const { assessment_id, answers } = body

      const validation = validateRequired({ answers })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      const messages: ChatMessage[] = [
        { role: 'system', content: 'You are a language assessment evaluator. Evaluate answers and determine proficiency level. Return JSON: { "overall_score": 0-100, "proficiency_level": "A1-C2", "skill_scores": { "grammar": 0, "vocabulary": 0, "reading": 0, "listening": 0, "writing": 0, "speaking": 0 }, "feedback": "", "strengths": [""], "weaknesses": [""] }' },
        { role: 'user', content: `Evaluate these assessment answers:\n${JSON.stringify(answers)}` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.3,
        maxTokens: 2048,
      })

      let evaluation
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        evaluation = jsonMatch ? JSON.parse(jsonMatch[0]) : {
          overall_score: 70,
          proficiency_level: profile?.proficiency_level || 'B1',
          skill_scores: { grammar: 70, vocabulary: 70, reading: 70, listening: 70, writing: 70, speaking: 70 },
        }
      } catch {
        evaluation = {
          overall_score: 70,
          proficiency_level: profile?.proficiency_level || 'B1',
          skill_scores: { grammar: 70, vocabulary: 70, reading: 70, listening: 70, writing: 70, speaking: 70 },
        }
      }

      // Update user's proficiency level if assessment suggests a different one
      if (evaluation.proficiency_level && profile) {
        await supabase
          .from('user_profiles')
          .update({ proficiency_level: evaluation.proficiency_level })
          .eq('auth_user_id', userId)
      }

      // Update mock exam record
      if (assessment_id) {
        await supabase
          .from('mock_exams')
          .update({
            estimated_score: evaluation.overall_score,
            feedback: evaluation,
          })
          .eq('id', assessment_id)
      }

      return successResponse({
        assessment_id,
        ...evaluation,
        tokens_used: response.tokensUsed,
      }, 'Assessment evaluated.')
    }

    // GET /assessment/results - Get latest assessment results
    if (req.method === 'GET' && action === 'results') {
      if (!profile) {
        return notFound('User profile not found')
      }

      const { data: latest, error } = await supabase
        .from('mock_exams')
        .select('*')
        .eq('user_id', profile.id)
        .eq('exam_type', 'assessment')
        .order('created_at', { ascending: false })
        .limit(1)
        .single()

      if (error || !latest) {
        return notFound('No assessment results found')
      }

      return successResponse({
        assessment: latest,
      }, 'Assessment results retrieved.')
    }

    // GET /assessment/history - Get assessment history
    if (req.method === 'GET' && action === 'history') {
      if (!profile) {
        return notFound('User profile not found')
      }

      const page = parseInt(url.searchParams.get('page') || '1')
      const limit = parseInt(url.searchParams.get('limit') || '10')

      const { data: history, error, count } = await supabase
        .from('mock_exams')
        .select('*', { count: 'exact' })
        .eq('user_id', profile.id)
        .eq('exam_type', 'assessment')
        .order('created_at', { ascending: false })
        .range((page - 1) * limit, page * limit - 1)

      if (error) {
        console.error('Failed to fetch assessment history:', error)
        return serverError('Failed to fetch assessment history')
      }

      const total = count || 0
      return successResponse({
        assessments: history || [],
        pagination: {
          page,
          limit,
          total,
          total_pages: Math.ceil(total / limit),
        },
      }, 'Assessment history retrieved.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Assessment error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
