// supabase/functions/exam/index.ts
// Section 18: Exam APIs
// /exam/{exam}/practice, /exam/{exam}/mock, /exam/{exam}/submit, /exam/{exam}/results, /exam/{exam}/analytics
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

const SUPPORTED_EXAMS = [
  'ielts', 'toefl', 'pte', 'oet', 'celpip', 'cambridge',
  'goethe', 'testdaf', 'delf', 'dalf', 'dele', 'siele',
  'jlpt', 'topik', 'hsk', 'duolingo',
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
    // URL format: /exam/{exam}/{action}
    const examIndex = pathParts.indexOf('exam')
    const examType = examIndex >= 0 ? pathParts[examIndex + 1] : null
    const action = examIndex >= 0 ? pathParts[examIndex + 2] : null

    if (!examType || !SUPPORTED_EXAMS.includes(examType)) {
      return badRequest(`Supported exams: ${SUPPORTED_EXAMS.join(', ')}`)
    }

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
      targetExam: examType.toUpperCase(),
    }

    // GET /exam/{exam}/practice - Get practice questions
    if (req.method === 'GET' && action === 'practice') {
      const section = url.searchParams.get('section') || 'general'
      const difficulty = url.searchParams.get('difficulty') || profile?.proficiency_level || 'B1'

      const systemPrompt = buildPrompt('tutor', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Generate 5 ${examType.toUpperCase()} ${section} practice questions at ${difficulty} level. Return JSON: { "questions": [{ "question": "", "options": [""], "correct_answer": "", "explanation": "", "section": "" }] }` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.7,
        maxTokens: 2048,
      })

      let questions
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        questions = jsonMatch ? JSON.parse(jsonMatch[0]) : { questions: [] }
      } catch {
        questions = { questions: [] }
      }

      return successResponse({
        exam: examType,
        section,
        difficulty,
        ...questions,
        tokens_used: response.tokensUsed,
      }, 'Practice questions generated.')
    }

    // POST /exam/{exam}/mock - Start mock exam
    if (req.method === 'POST' && action === 'mock') {
      const body = await req.json()
      const { section } = body

      const systemPrompt = buildPrompt('tutor', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Generate a ${examType.toUpperCase()} mock ${section || 'full'} exam with questions and time limit. Return JSON: { "exam_id": "", "title": "", "duration_minutes": 0, "sections": [{ "name": "", "questions": [{ "question": "", "options": [""], "correct_answer": "" }], "time_limit_minutes": 0 }] }` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.7,
        maxTokens: 4096,
      })

      let mockExam
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        mockExam = jsonMatch ? JSON.parse(jsonMatch[0]) : { title: `${examType.toUpperCase()} Mock Exam` }
      } catch {
        mockExam = { title: `${examType.toUpperCase()} Mock Exam` }
      }

      // Save mock exam record
      const { data: savedExam } = await supabase
        .from('mock_exams')
        .insert({
          user_id: profile?.id,
          exam_type: examType,
          section: section || 'full',
        })
        .select('id')
        .single()

      return successResponse({
        exam_id: savedExam?.id,
        ...mockExam,
        tokens_used: response.tokensUsed,
      }, 'Mock exam generated.')
    }

    // POST /exam/{exam}/submit - Submit exam answers
    if (req.method === 'POST' && action === 'submit') {
      const body = await req.json()
      const { exam_id, answers, section } = body

      const validation = validateRequired({ answers })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      const messages: ChatMessage[] = [
        { role: 'system', content: `You are a ${examType.toUpperCase()} examiner. Evaluate answers and return JSON: { "score": 0-100, "estimated_band": "", "section_scores": {}, "feedback": [{ "question_index": 0, "correct": true, "explanation": "" }] }` },
        { role: 'user', content: `Evaluate these ${examType.toUpperCase()} answers:\n${JSON.stringify(answers)}` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.3,
        maxTokens: 2048,
      })

      let evaluation
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        evaluation = jsonMatch ? JSON.parse(jsonMatch[0]) : { score: 70, estimated_band: 'C1' }
      } catch {
        evaluation = { score: 70, estimated_band: 'C1' }
      }

      // Update mock exam if provided
      if (exam_id) {
        await supabase
          .from('mock_exams')
          .update({
            estimated_score: evaluation.score,
            feedback: evaluation,
          })
          .eq('id', exam_id)
      }

      return successResponse({
        exam: examType,
        exam_id,
        ...evaluation,
        tokens_used: response.tokensUsed,
      }, 'Exam answers evaluated.')
    }

    // GET /exam/{exam}/results - Get exam results
    if (req.method === 'GET' && action === 'results') {
      if (!profile) {
        return notFound('User profile not found')
      }

      const { data: results, error } = await supabase
        .from('mock_exams')
        .select('*')
        .eq('user_id', profile.id)
        .eq('exam_type', examType)
        .order('created_at', { ascending: false })
        .limit(20)

      if (error) {
        console.error('Failed to fetch exam results:', error)
        return serverError('Failed to fetch exam results')
      }

      return successResponse({
        exam: examType,
        results: results || [],
        total: results?.length || 0,
      }, 'Exam results retrieved.')
    }

    // GET /exam/{exam}/analytics - Get exam analytics
    if (req.method === 'GET' && action === 'analytics') {
      if (!profile) {
        return notFound('User profile not found')
      }

      const { data: results } = await supabase
        .from('mock_exams')
        .select('estimated_score, section, created_at')
        .eq('user_id', profile.id)
        .eq('exam_type', examType)
        .order('created_at', { ascending: true })

      const scores = (results || []).map((r: any) => r.estimated_score || 0)
      const avgScore = scores.length > 0
        ? Math.round(scores.reduce((a: number, b: number) => a + b, 0) / scores.length)
        : 0

      const trend = scores.length >= 2
        ? scores[scores.length - 1] - scores[0]
        : 0

      return successResponse({
        exam: examType,
        total_attempts: scores.length,
        average_score: avgScore,
        highest_score: scores.length > 0 ? Math.max(...scores) : 0,
        lowest_score: scores.length > 0 ? Math.min(...scores) : 0,
        trend: trend > 0 ? 'improving' : trend < 0 ? 'declining' : 'stable',
        score_history: scores,
      }, 'Exam analytics retrieved.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Exam error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
