// supabase/functions/exam-api/index.ts
// Exam API endpoints
// GET /exam/{exam}/practice - Get practice questions
// POST /exam/{exam}/mock - Start mock exam
// POST /exam/{exam}/submit - Submit exam answers
// GET /exam/{exam}/results - Get exam results
// GET /exam/{exam}/analytics - Get exam analytics
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

const SUPPORTED_EXAMS = [
  'ielts', 'toefl', 'pte', 'oet', 'celpip', 'toeic', 'duolingo',
  'gre', 'gmat', 'sat', 'act',
  'goethe', 'telc', 'testdaf', 'dsh',
  'delf_dalf', 'tcf', 'tef',
  'dele', 'siele',
  'jlpt', 'topek', 'hsk', 'cambridge',
]

const EXAM_CONFIGS: Record<string, { maxScore: number; bandLabels?: string[]; sections: string[] }> = {
  ielts: { maxScore: 9, bandLabels: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], sections: ['reading', 'listening', 'writing', 'speaking'] },
  toefl: { maxScore: 120, sections: ['reading', 'listening', 'writing', 'speaking'] },
  pte: { maxScore: 90, sections: ['speaking', 'writing', 'reading', 'listening'] },
  oet: { maxScore: 500, sections: ['listening', 'reading', 'writing', 'speaking'] },
  celpip: { maxScore: 12, sections: ['listening', 'reading', 'writing', 'speaking'] },
  toeic: { maxScore: 990, sections: ['listening', 'reading'] },
  duolingo: { maxScore: 160, sections: ['literacy', 'comprehension', 'conversation', 'production'] },
  gre: { maxScore: 340, sections: ['verbal', 'quantitative', 'analytical_writing'] },
  gmat: { maxScore: 800, sections: ['verbal', 'quantitative', 'analytical_writing', 'integrated_reasoning'] },
  sat: { maxScore: 1600, sections: ['reading_writing', 'math'] },
  act: { maxScore: 36, sections: ['english', 'math', 'reading', 'science'] },
  goethe: { maxScore: 100, sections: ['lesen', 'hoeren', 'schreiben', 'sprechen'] },
  telc: { maxScore: 100, sections: ['lesen', 'hoeren', 'schreiben', 'sprechen'] },
  testdaf: { maxScore: 5, bandLabels: ['3', '4', '5'], sections: ['lesen', 'hoeren', 'schreiben', 'sprechen'] },
  dsh: { maxScore: 3, bandLabels: ['1', '2', '3'], sections: ['lesen', 'hoeren', 'schreiben', 'sprechen'] },
  delf_dalf: { maxScore: 100, bandLabels: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'], sections: ['comprehension_orale', 'comprehension_ecrite', 'production_orale', 'production_ecrite'] },
  tcf: { maxScore: 100, bandLabels: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'], sections: ['comprehension_orale', 'comprehension_ecrite', 'expression_orale', 'expression_ecrite'] },
  tef: { maxScore: 100, bandLabels: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'], sections: ['comprehension_orale', 'comprehension_ecrite', 'expression_orale', 'expression_ecrite'] },
  dele: { maxScore: 100, bandLabels: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'], sections: ['comprension_lectura', 'comprension_auditiva', 'expresion_escrita', 'expresion_oral'] },
  siele: { maxScore: 100, bandLabels: ['A1', 'A2', 'B1', 'B2', 'C1'], sections: ['comprension_lectura', 'comprension_auditiva', 'expresion_escrita', 'expresion_oral'] },
  jlpt: { maxScore: 180, bandLabels: ['N1', 'N2', 'N3', 'N4', 'N5'], sections: ['kanji_vocabulary', 'grammar_reading', 'listening'] },
  topek: { maxScore: 300, bandLabels: ['1', '2', '3', '4', '5', '6'], sections: ['writing', 'listening', 'reading', 'speaking'] },
  hsk: { maxScore: 300, bandLabels: ['1', '2', '3', '4', '5', '6'], sections: ['listening', 'reading', 'writing'] },
  cambridge: { maxScore: 230, bandLabels: ['A2', 'B1', 'B2', 'C1', 'C2'], sections: ['reading', 'writing', 'use_of_english', 'listening', 'speaking'] },
}

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

    const examIndex = pathParts.indexOf('exam')
    if (examIndex < 0 || !pathParts[examIndex + 1]) {
      return badRequest('Invalid exam path format. Use /exam/{exam}/{action}')
    }

    const examType = pathParts[examIndex + 1]
    const action = pathParts[examIndex + 2] || null

    if (!SUPPORTED_EXAMS.includes(examType)) {
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
      nativeLanguage: profile?.native_language || 'English',
      targetLanguage: profile?.target_language || 'English',
      learningLevel: profile?.proficiency_level || 'B1',
      targetExam: examType.toUpperCase(),
    }

    const examConfig = EXAM_CONFIGS[examType]
    const sectionList = examConfig?.sections || []

    // GET /exam/{exam}/practice - Get practice questions
    if (req.method === 'GET' && action === 'practice') {
      const section = url.searchParams.get('section') || 'general'
      const difficulty = url.searchParams.get('difficulty') || profile?.proficiency_level || 'B1'
      const count = Math.min(Math.max(parseInt(url.searchParams.get('count') || '5'), 1), 20)

      const systemPrompt = buildPrompt('tutor', promptContext)
      const sectionInfo = sectionList.length > 0 ? ` Sections: ${sectionList.join(', ')}.` : ''
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        {
          role: 'user',
          content: `Generate ${count} ${examType.toUpperCase()} practice questions${section !== 'general' ? ` for ${section}` : ''} at ${difficulty} difficulty level.${sectionInfo} Return JSON only: { "questions": [{ "id": "q1", "question": "", "type": "mcq|essay|speaking|fill_blank|true_false", "options": [""], "correct_answer": "", "explanation": "", "section": "", "difficulty": "" }] }`,
        },
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

      return successResponse(
        {
          exam: examType,
          section,
          difficulty,
          sections_available: sectionList,
          ...questions,
          tokens_used: response.tokensUsed,
        },
        'Practice questions generated.'
      )
    }

    // POST /exam/{exam}/mock - Start mock exam
    if (req.method === 'POST' && action === 'mock') {
      const body = await req.json().catch(() => ({}))
      const { section, custom_time_limit } = body

      const systemPrompt = buildPrompt('tutor', promptContext)
      const sectionLabel = section || 'full'
      const timeLimit = custom_time_limit || 60
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        {
          role: 'user',
          content: `Generate a complete ${examType.toUpperCase()} mock exam${section !== 'all_sections' ? ` focused on ${sectionLabel}` : ''}. Return JSON: { "title": "", "description": "", "duration_minutes": ${timeLimit}, "total_questions": 0, "sections": [{ "name": "", "time_limit_minutes": 0, "questions": [{ "id": "", "question": "", "type": "mcq|essay|speaking|fill_blank|true_false", "options": [""], "correct_answer": "", "points": 0 }] }] }`,
        },
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

      const { data: savedExam, error: saveError } = await supabase
        .from('exam_attempts')
        .insert({
          user_id: profile?.id,
          auth_user_id: userId,
          exam_type: examType,
          section: sectionLabel,
          title: mockExam.title,
          total_questions: mockExam.total_questions || 0,
          duration_minutes: mockExam.duration_minutes || timeLimit,
          questions_data: mockExam,
          status: 'in_progress',
          started_at: new Date().toISOString(),
        })
        .select('id')
        .single()

      if (saveError) {
        console.error('Failed to save mock exam:', saveError)
      }

      const session = {
        ...mockExam,
        exam_id: savedExam?.id,
        status: 'in_progress',
        started_at: new Date().toISOString(),
        expires_at: new Date(Date.now() + timeLimit * 60 * 1000).toISOString(),
        tokens_used: response.tokensUsed,
      }

      return successResponse(session, 'Mock exam created. Timer has started.')
    }

    // POST /exam/{exam}/submit - Submit exam answers
    if (req.method === 'POST' && action === 'submit') {
      const body = await req.json()
      const { exam_id, answers, time_taken_seconds } = body

      const validation = validateRequired({ answers })
      if (!validation.isValid) {
        return badRequest('Validation failed', validation.errors)
      }

      let mockExamData = null
      if (exam_id) {
        const { data } = await supabase
          .from('exam_attempts')
          .select('*')
          .eq('id', exam_id)
          .eq('auth_user_id', userId)
          .single()
        mockExamData = data
      }

      const evalMessages: ChatMessage[] = [
        {
          role: 'system',
          content: `You are an expert ${examType.toUpperCase()} examiner. Evaluate the user's answers accurately and fairly. The scoring range is 0-${examConfig?.maxScore || 100}.${examConfig?.bandLabels ? ` Valid bands/levels: ${examConfig.bandLabels.join(', ')}.` : ''} Return JSON: { "score": <number>, "band_or_level": "<string>", "max_score": ${examConfig?.maxScore || 100}, "section_scores": [{ "section": "", "score": 0, "max_score": 0, "percentage": 0 }], "feedback": [{ "question_id": "", "correct": true, "user_answer": "", "correct_answer": "", "explanation": "" }], "strengths": [""], "weaknesses": [""], "recommendations": [""] }`,
        },
        {
          role: 'user',
          content: `Evaluate these ${examType.toUpperCase()} exam answers:\n${JSON.stringify({ answers, exam_type: examType, sections: sectionList })}`,
        },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(evalMessages, {
        temperature: 0.3,
        maxTokens: 2048,
      })

      let evaluation
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        evaluation = jsonMatch ? JSON.parse(jsonMatch[0]) : { score: 0, band_or_level: '' }
      } catch {
        evaluation = { score: 0, band_or_level: '' }
      }

      const completedAt = new Date().toISOString()

      if (exam_id) {
        await supabase
          .from('exam_attempts')
          .update({
            estimated_score: evaluation.score,
            band_or_level: evaluation.band_or_level,
            section_scores: evaluation.section_scores,
            feedback: evaluation,
            answers_data: answers,
            time_taken_seconds: time_taken_seconds || null,
            status: 'completed',
            completed_at: completedAt,
          })
          .eq('id', exam_id)
      }

      const { data: resultRecord } = await supabase
        .from('exam_results')
        .insert({
          user_id: profile?.id,
          auth_user_id: userId,
          exam_type: examType,
          exam_id: exam_id || null,
          score: evaluation.score,
          band_or_level: evaluation.band_or_level,
          max_score: evaluation.max_score || examConfig?.maxScore || 100,
          section_scores: evaluation.section_scores,
          feedback: evaluation,
          answers: answers,
          time_taken_seconds: time_taken_seconds || null,
          completed_at: completedAt,
        })
        .select('id')
        .single()

      return successResponse(
        {
          result_id: resultRecord?.id,
          exam: examType,
          exam_id,
          score: evaluation.score,
          band_or_level: evaluation.band_or_level,
          max_score: evaluation.max_score,
          section_scores: evaluation.section_scores,
          feedback: evaluation.feedback,
          strengths: evaluation.strengths,
          weaknesses: evaluation.weaknesses,
          recommendations: evaluation.recommendations,
          tokens_used: response.tokensUsed,
        },
        'Exam answers evaluated successfully.'
      )
    }

    // GET /exam/{exam}/results - Get exam results
    if (req.method === 'GET' && action === 'results') {
      if (!profile) {
        return notFound('User profile not found')
      }

      const { limit, offset } = parsePagination(url.searchParams)
      const dateFrom = url.searchParams.get('from')
      const dateTo = url.searchParams.get('to')
      const sectionFilter = url.searchParams.get('section')

      let query = supabase
        .from('exam_attempts')
        .select('*', { count: 'exact' })
        .eq('auth_user_id', userId)
        .eq('exam_type', examType)

      if (dateFrom) {
        query = query.gte('created_at', dateFrom)
      }
      if (dateTo) {
        query = query.lte('created_at', dateTo)
      }
      if (sectionFilter) {
        query = query.eq('section', sectionFilter)
      }

      const { data: mockResults, error: mockError, count: mockCount } = await query
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1)

      if (mockError) {
        console.error('Failed to fetch mock exam results:', mockError)
        return serverError('Failed to fetch exam results')
      }

      let examResultsQuery = supabase
        .from('exam_results')
        .select('*', { count: 'exact' })
        .eq('auth_user_id', userId)
        .eq('exam_type', examType)

      if (dateFrom) {
        examResultsQuery = examResultsQuery.gte('completed_at', dateFrom)
      }
      if (dateTo) {
        examResultsQuery = examResultsQuery.lte('completed_at', dateTo)
      }

      const { data: examResults, error: examError, count: examCount } = await examResultsQuery
        .order('completed_at', { ascending: false })
        .range(offset, offset + limit - 1)

      if (examError) {
        console.error('Failed to fetch exam results:', examError)
      }

      const total = (mockCount || 0) + (examCount || 0)

      return successResponse(
        {
          exam: examType,
          exam_attempts: mockResults || [],
          exam_results: examResults || [],
          pagination: {
            limit,
            offset,
            total,
            total_pages: Math.ceil(total / limit),
          },
        },
        'Exam results retrieved.'
      )
    }

    // GET /exam/{exam}/analytics - Get exam analytics
    if (req.method === 'GET' && action === 'analytics') {
      if (!profile) {
        return notFound('User profile not found')
      }

      const { data: mockHistory } = await supabase
        .from('exam_attempts')
        .select('estimated_score, band_or_level, section, section_scores, started_at, completed_at, time_taken_seconds')
        .eq('auth_user_id', userId)
        .eq('exam_type', examType)
        .not('status', 'eq', 'in_progress')
        .order('completed_at', { ascending: true })

      const { data: examHistory } = await supabase
        .from('exam_results')
        .select('score, band_or_level, section_scores, completed_at, time_taken_seconds')
        .eq('auth_user_id', userId)
        .eq('exam_type', examType)
        .order('completed_at', { ascending: true })

      const allScores = [
        ...(mockHistory || []).map((r: any) => ({
          score: r.estimated_score || 0,
          band: r.band_or_level,
          completed_at: r.completed_at,
          time_taken: r.time_taken_seconds,
        })),
        ...(examHistory || []).map((r: any) => ({
          score: r.score || 0,
          band: r.band_or_level,
          completed_at: r.completed_at,
          time_taken: r.time_taken_seconds,
        })),
      ].sort((a, b) => new Date(a.completed_at).getTime() - new Date(b.completed_at).getTime())

      const scores = allScores.map((s) => s.score)
      const totalAttempts = scores.length
      const avgScore = totalAttempts > 0
        ? Math.round(scores.reduce((a: number, b: number) => a + b, 0) / totalAttempts)
        : 0
      const highestScore = totalAttempts > 0 ? Math.max(...scores) : 0
      const lowestScore = totalAttempts > 0 ? Math.min(...scores) : 0

      let trend = 'stable'
      if (totalAttempts >= 3) {
        const mid = Math.floor(totalAttempts / 2)
        const firstHalfAvg = scores.slice(0, mid).reduce((a, b) => a + b, 0) / mid
        const secondHalfAvg = scores.slice(mid).reduce((a, b) => a + b, 0) / (totalAttempts - mid)
        const diffPercent = ((secondHalfAvg - firstHalfAvg) / (firstHalfAvg || 1)) * 100
        if (diffPercent > 5) trend = 'improving'
        else if (diffPercent < -5) trend = 'declining'
      }

      const avgTimeTaken = allScores.length > 0
        ? Math.round(
            allScores
              .filter((s) => s.time_taken)
              .reduce((sum, s) => sum + (s.time_taken || 0), 0) /
              Math.max(allScores.filter((s) => s.time_taken).length, 1)
          )
        : 0

      const sectionPerformance: Record<string, { totalScore: number; count: number; avg: number }> = {}
      for (const result of mockHistory || []) {
        if (result.section_scores && Array.isArray(result.section_scores)) {
          for (const sec of result.section_scores) {
            if (!sectionPerformance[sec.section]) {
              sectionPerformance[sec.section] = { totalScore: 0, count: 0, avg: 0 }
            }
            sectionPerformance[sec.section].totalScore += sec.score || 0
            sectionPerformance[sec.section].count += 1
          }
        }
      }
      for (const sec of Object.keys(sectionPerformance)) {
        sectionPerformance[sec].avg = Math.round(
          sectionPerformance[sec].totalScore / sectionPerformance[sec].count
        )
      }

      const bandDistribution: Record<string, number> = {}
      for (const s of allScores) {
        if (s.band) {
          bandDistribution[s.band] = (bandDistribution[s.band] || 0) + 1
        }
      }

      return successResponse(
        {
          exam: examType,
          exam_config: examConfig,
          summary: {
            total_attempts: totalAttempts,
            average_score: avgScore,
            highest_score: highestScore,
            lowest_score: lowestScore,
            trend,
            average_time_seconds: avgTimeTaken,
            latest_band_or_level: allScores.length > 0 ? allScores[allScores.length - 1].band : null,
          },
          section_performance: Object.entries(sectionPerformance).map(([section, data]) => ({
            section,
            average_score: data.avg,
            attempts: data.count,
          })),
          band_distribution: bandDistribution,
          score_history: allScores.map((s) => ({
            score: s.score,
            band: s.band,
            completed_at: s.completed_at,
          })),
        },
        'Exam analytics retrieved.'
      )
    }

    // GET /exam - List all supported exams with user progress
    if (req.method === 'GET' && !action) {
      if (!profile) {
        return notFound('User profile not found')
      }

      const examSummaries = []
      for (const exam of SUPPORTED_EXAMS) {
        const { data: latestResult } = await supabase
          .from('exam_results')
          .select('score, band_or_level, completed_at')
          .eq('auth_user_id', userId)
          .eq('exam_type', exam)
          .order('completed_at', { ascending: false })
          .limit(1)
          .single()

        const { count: totalAttempts } = await supabase
          .from('exam_results')
          .select('*', { count: 'exact', head: true })
          .eq('auth_user_id', userId)
          .eq('exam_type', exam)

        const config = EXAM_CONFIGS[exam]
        examSummaries.push({
          exam,
          max_score: config?.maxScore || 100,
          sections: config?.sections || [],
          latest_score: latestResult?.score || null,
          latest_band_or_level: latestResult?.band_or_level || null,
          total_attempts: totalAttempts || 0,
          last_practiced: latestResult?.completed_at || null,
        })
      }

      return successResponse(
        { exams: examSummaries, total: SUPPORTED_EXAMS.length },
        'Supported exams retrieved.'
      )
    }

    // GET /exam/{exam} - Get exam info
    if (req.method === 'GET' && !action) {
      const config = EXAM_CONFIGS[examType]
      return successResponse(
        {
          exam: examType,
          ...config,
        },
        `Information for ${examType.toUpperCase()} exam retrieved.`
      )
    }

    return badRequest('Invalid endpoint. Use /exam/{exam}/{action} where action is practice, mock, submit, results, or analytics.')
  } catch (error) {
    console.error('Exam API error:', error)
    return serverError(error instanceof Error ? error.message : 'Internal server error')
  }
})
