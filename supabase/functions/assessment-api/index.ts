// supabase/functions/assessment-api/index.ts
// Assessment APIs - Placement, Progress, and Diagnostic Assessments
// POST /assessment-api/start, POST /assessment-api/submit
// GET  /assessment-api/results, GET /assessment-api/history
import { validateRequest } from '../shared/auth.ts'
import { getAIProvider, ChatMessage } from '../shared/ai.ts'
import { buildPrompt, PromptContext } from '../shared/prompts.ts'
import { ConversationMemory } from '../shared/memory.ts'
import {
  successResponse,
  createdResponse,
  badRequest,
  notFound,
  serverError,
} from '../shared/errors.ts'
import { validateRequired, parsePagination } from '../shared/validator.ts'
import { corsHeaders } from '../shared/cors.ts'

// ─── Types ───────────────────────────────────────────────────────────────────

interface AssessmentQuestion {
  question: string
  options: string[]
  correct_answer: string
  skill: string
  difficulty: string
  explanation: string
}

interface AssessmentSection {
  skill: string
  questions: AssessmentQuestion[]
  time_limit_minutes: number
}

interface AssessmentData {
  type: string
  total_questions: number
  sections: AssessmentSection[]
}

interface EvaluationResult {
  overall_score: number
  proficiency_level: string
  skill_scores: Record<string, number>
  feedback: string
  strengths: string[]
  weaknesses: string[]
  recommendations: string[]
}

// ─── CEFR Level Calculation ──────────────────────────────────────────────────

function calculateCEFRLevel(score: number): string {
  if (score >= 95) return 'C2'
  if (score >= 85) return 'C1'
  if (score >= 70) return 'B2'
  if (score >= 55) return 'B1'
  if (score >= 40) return 'A2'
  if (score >= 20) return 'A1'
  return 'A1'
}

// ─── Handlers ────────────────────────────────────────────────────────────────

async function handleStart(
  supabase: any,
  userId: string,
  req: Request,
): Promise<Response> {
  const body = await req.json()
  const { type, skills, language_pair } = body

  const assessmentType = type || 'placement'
  const validTypes = ['placement', 'progress', 'diagnostic']
  if (!validTypes.includes(assessmentType)) {
    return badRequest(`Invalid assessment type. Must be one of: ${validTypes.join(', ')}`)
  }

  const { data: profile } = await supabase
    .from('user_profiles')
    .select('id, native_language, target_language, proficiency_level')
    .eq('auth_user_id', userId)
    .single()

  if (!profile) {
    return notFound('User profile not found')
  }

  const memory = new ConversationMemory(supabase)
  const context = await memory.loadContext('', userId)

  const promptContext: PromptContext = {
    userName: context.userProfile?.fullName,
    nativeLanguage: profile?.native_language || 'Malayalam',
    targetLanguage: profile?.target_language || 'English',
    learningLevel: profile?.proficiency_level || 'A1',
  }

  const systemPrompt = buildPrompt('tutor', promptContext)
  const skillList = skills || 'grammar, vocabulary, reading, listening, writing, speaking'

  const messages: ChatMessage[] = [
    {
      role: 'system',
      content: systemPrompt,
    },
    {
      role: 'user',
      content: `Generate a ${assessmentType} assessment for language proficiency testing.
Target language: ${promptContext.targetLanguage}
Native language: ${promptContext.nativeLanguage}
Current level: ${promptContext.learningLevel}
Skills to assess: ${skillList}

Include 5-8 questions per skill section. Mix difficulty levels (A1-C2) to accurately gauge proficiency.
For each question provide: question text, 4 multiple-choice options, the correct answer, skill category, difficulty level, and a brief explanation.

Return ONLY valid JSON with this structure:
{
  "type": "${assessmentType}",
  "total_questions": <number>,
  "sections": [
    {
      "skill": "<skill_name>",
      "questions": [
        {
          "question": "<question_text>",
          "options": ["A", "B", "C", "D"],
          "correct_answer": "<correct_option>",
          "difficulty": "<CEFR_level>",
          "explanation": "<brief_explanation>"
        }
      ],
      "time_limit_minutes": <minutes>
    }
  ]
}`,
    },
  ]

  const ai = getAIProvider()
  const response = await ai.chatWithFallback(messages, {
    temperature: 0.7,
    maxTokens: 4096,
  })

  let assessment: AssessmentData
  try {
    const jsonMatch = response.content.match(/\{[\s\S]*\}/)
    assessment = jsonMatch
      ? JSON.parse(jsonMatch[0])
      : { type: assessmentType, total_questions: 0, sections: [] }
  } catch {
    assessment = { type: assessmentType, total_questions: 0, sections: [] }
  }

  const totalQuestions = assessment.sections.reduce(
    (sum, section) => sum + section.questions.length,
    0,
  )
  assessment.total_questions = totalQuestions

  const { data: savedAssessment, error: insertError } = await supabase
    .from('assessments')
    .insert({
      user_id: profile.id,
      type: assessmentType,
      status: 'in_progress',
      questions_data: assessment,
      target_language: promptContext.targetLanguage,
      native_language: promptContext.nativeLanguage,
      starting_level: profile?.proficiency_level || 'A1',
    })
    .select('id')
    .single()

  if (insertError) {
    console.error('Failed to save assessment:', insertError)
    return serverError('Failed to create assessment session')
  }

  const sectionsWithoutAnswers = assessment.sections.map((section) => ({
    ...section,
    questions: section.questions.map((q) => ({
      question: q.question,
      options: q.options,
      skill: q.skill,
      difficulty: q.difficulty,
    })),
  }))

  return createdResponse({
    assessment_id: savedAssessment.id,
    type: assessmentType,
    total_questions: totalQuestions,
    sections: sectionsWithoutAnswers,
    tokens_used: response.tokensUsed,
  }, 'Assessment started successfully.')
}

async function handleSubmit(
  supabase: any,
  userId: string,
  req: Request,
): Promise<Response> {
  const body = await req.json()
  const { assessment_id, answers } = body

  const validation = validateRequired({ assessment_id, answers })
  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '))
  }

  if (!Array.isArray(answers) || answers.length === 0) {
    return badRequest('answers must be a non-empty array')
  }

  const { data: profile } = await supabase
    .from('user_profiles')
    .select('id, native_language, target_language, proficiency_level')
    .eq('auth_user_id', userId)
    .single()

  if (!profile) {
    return notFound('User profile not found')
  }

  const { data: existing, error: fetchError } = await supabase
    .from('assessments')
    .select('*')
    .eq('id', assessment_id)
    .eq('user_id', profile.id)
    .single()

  if (fetchError || !existing) {
    return notFound('Assessment session not found')
  }

  if (existing.status === 'completed') {
    return badRequest('This assessment has already been submitted')
  }

  const messages: ChatMessage[] = [
    {
      role: 'system',
      content: `You are an expert language assessment evaluator. Evaluate the user's answers against the correct answers and determine their CEFR proficiency level.

Scoring rules:
- Each correct answer = 1 point, incorrect = 0 points
- Calculate percentage score per skill and overall
- Determine CEFR level: A1 (0-19%), A2 (20-39%), B1 (40-54%), B2 (55-69%), C1 (70-84%), C2 (85-100%)
- Provide detailed feedback on strengths and weaknesses
- Suggest specific areas for improvement

Return ONLY valid JSON:
{
  "overall_score": <0-100>,
  "proficiency_level": "<CEFR_level>",
  "skill_scores": {
    "grammar": <0-100>,
    "vocabulary": <0-100>,
    "reading": <0-100>,
    "listening": <0-100>,
    "writing": <0-100>,
    "speaking": <0-100>
  },
  "question_results": [
    {
      "question_index": <number>,
      "skill": "<skill_name>",
      "user_answer": "<user_answer>",
      "correct_answer": "<correct_answer>",
      "is_correct": <boolean>,
      "explanation": "<explanation>"
    }
  ],
  "feedback": "<overall_feedback>",
  "strengths": ["<strength1>", "<strength2>"],
  "weaknesses": ["<weakness1>", "<weakness2>"],
  "recommendations": ["<recommendation1>", "<recommendation2>"]
}`,
    },
    {
      role: 'user',
      content: `Original assessment data:\n${JSON.stringify(existing.questions_data)}

User answers:\n${JSON.stringify(answers)}

Evaluate each answer, calculate scores, and determine the overall CEFR proficiency level.`,
    },
  ]

  const ai = getAIProvider()
  const response = await ai.chatWithFallback(messages, {
    temperature: 0.3,
    maxTokens: 4096,
  })

  let evaluation: EvaluationResult & { question_results?: any[] }
  try {
    const jsonMatch = response.content.match(/\{[\s\S]*\}/)
    evaluation = jsonMatch
      ? JSON.parse(jsonMatch[0])
      : {
          overall_score: 0,
          proficiency_level: profile?.proficiency_level || 'A1',
          skill_scores: {
            grammar: 0,
            vocabulary: 0,
            reading: 0,
            listening: 0,
            writing: 0,
            speaking: 0,
          },
          feedback: 'Evaluation could not be completed.',
          strengths: [],
          weaknesses: [],
          recommendations: [],
        }
  } catch {
    evaluation = {
      overall_score: 0,
      proficiency_level: profile?.proficiency_level || 'A1',
      skill_scores: {
        grammar: 0,
        vocabulary: 0,
        reading: 0,
        listening: 0,
        writing: 0,
        speaking: 0,
      },
      feedback: 'Evaluation could not be completed due to a parsing error.',
      strengths: [],
      weaknesses: [],
      recommendations: [],
    }
  }

  const calculatedLevel = calculateCEFRLevel(evaluation.overall_score)
  if (!evaluation.proficiency_level || evaluation.proficiency_level === 'A1') {
    evaluation.proficiency_level = calculatedLevel
  }

  const { error: updateError } = await supabase
    .from('assessments')
    .update({
      status: 'completed',
      score: evaluation.overall_score,
      proficiency_level: evaluation.proficiency_level,
      skill_scores: evaluation.skill_scores,
      feedback: evaluation.feedback,
      strengths: evaluation.strengths,
      weaknesses: evaluation.weaknesses,
      recommendations: evaluation.recommendations,
      question_results: (evaluation as any).question_results || [],
      answers_data: answers,
      completed_at: new Date().toISOString(),
      tokens_used: response.tokensUsed,
    })
    .eq('id', assessment_id)

  if (updateError) {
    console.error('Failed to update assessment:', updateError)
    return serverError('Failed to save assessment results')
  }

  if (evaluation.proficiency_level) {
    await supabase
      .from('user_profiles')
      .update({ proficiency_level: evaluation.proficiency_level })
      .eq('auth_user_id', userId)
  }

  return successResponse({
    assessment_id,
    overall_score: evaluation.overall_score,
    proficiency_level: evaluation.proficiency_level,
    skill_scores: evaluation.skill_scores,
    feedback: evaluation.feedback,
    strengths: evaluation.strengths,
    weaknesses: evaluation.weaknesses,
    recommendations: evaluation.recommendations,
    tokens_used: response.tokensUsed,
  }, 'Assessment submitted and evaluated successfully.')
}

async function handleResults(
  supabase: any,
  userId: string,
): Promise<Response> {
  const { data: profile } = await supabase
    .from('user_profiles')
    .select('id')
    .eq('auth_user_id', userId)
    .single()

  if (!profile) {
    return notFound('User profile not found')
  }

  const { data: latest, error } = await supabase
    .from('assessments')
    .select('*')
    .eq('user_id', profile.id)
    .eq('status', 'completed')
    .order('completed_at', { ascending: false })
    .limit(1)
    .single()

  if (error || !latest) {
    return notFound('No completed assessment results found')
  }

  return successResponse({
    assessment: {
      id: latest.id,
      type: latest.type,
      score: latest.score,
      proficiency_level: latest.proficiency_level,
      skill_scores: latest.skill_scores,
      feedback: latest.feedback,
      strengths: latest.strengths,
      weaknesses: latest.weaknesses,
      recommendations: latest.recommendations,
      question_results: latest.question_results,
      starting_level: latest.starting_level,
      target_language: latest.target_language,
      created_at: latest.created_at,
      completed_at: latest.completed_at,
    },
  }, 'Latest assessment results retrieved successfully.')
}

async function handleHistory(
  supabase: any,
  userId: string,
  url: URL,
): Promise<Response> {
  const { data: profile } = await supabase
    .from('user_profiles')
    .select('id')
    .eq('auth_user_id', userId)
    .single()

  if (!profile) {
    return notFound('User profile not found')
  }

  const { limit, offset } = parsePagination(url.searchParams)
  const typeFilter = url.searchParams.get('type')

  let query = supabase
    .from('assessments')
    .select(
      'id, type, status, score, proficiency_level, skill_scores, starting_level, target_language, created_at, completed_at',
      { count: 'exact' },
    )
    .eq('user_id', profile.id)
    .eq('status', 'completed')

  if (typeFilter) {
    query = query.eq('type', typeFilter)
  }

  const { data: history, error, count } = await query
    .order('completed_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) {
    console.error('Failed to fetch assessment history:', error)
    return serverError('Failed to fetch assessment history')
  }

  const total = count || 0

  const summary = (history || []).reduce(
    (acc, assessment) => {
      acc.total_assessments += 1
      if (assessment.score !== null) {
        acc.avg_score += assessment.score
        if (assessment.score > acc.best_score) {
          acc.best_score = assessment.score
        }
      }
      acc.levels[assessment.proficiency_level] =
        (acc.levels[assessment.proficiency_level] || 0) + 1
      return acc
    },
    {
      total_assessments: 0,
      avg_score: 0,
      best_score: 0,
      levels: {} as Record<string, number>,
    },
  )

  if (summary.total_assessments > 0) {
    summary.avg_score = Math.round(summary.avg_score / summary.total_assessments)
  }

  return successResponse({
    assessments: history || [],
    summary,
    pagination: {
      limit,
      offset,
      total,
      total_pages: Math.ceil(total / limit),
    },
  }, 'Assessment history retrieved successfully.')
}

// ─── Router ──────────────────────────────────────────────────────────────────

Deno.serve(async (req: Request): Promise<Response> => {
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

    if (req.method === 'POST' && action === 'start') {
      return await handleStart(supabase, userId, req)
    }

    if (req.method === 'POST' && action === 'submit') {
      return await handleSubmit(supabase, userId, req)
    }

    if (req.method === 'GET' && action === 'results') {
      return await handleResults(supabase, userId)
    }

    if (req.method === 'GET' && action === 'history') {
      return await handleHistory(supabase, userId, url)
    }

    return badRequest('Route not found. Use POST /start, POST /submit, GET /results, or GET /history')
  } catch (error) {
    console.error('Assessment API error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
