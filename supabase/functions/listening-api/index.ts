// supabase/functions/listening-api/index.ts
// Listening API - Exercises, Audio, and Answer Submission
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, notFound, serverError } from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequired, parsePagination } from '../shared/validator.ts'

interface ListeningExercise {
  id: string
  title: string
  transcript: string
  audio_url: string
  difficulty: string
  exercise_type: string
  questions: ListeningQuestion[]
  created_at: string
}

interface ListeningQuestion {
  id: string
  question: string
  question_type: 'gap_fill' | 'comprehension'
  options: string[] | null
  correct_answer: string
  explanation: string
}

interface SubmissionAnswer {
  question_id: string
  answer: string
}

interface AnswerFeedback {
  question_id: string
  correct: boolean
  user_answer: string
  correct_answer: string
  explanation: string
}

const BASE_PATH = '/listening-api'

async function getProfileId(supabase: any, userId: string): Promise<string | null> {
  const { data: profile, error } = await supabase
    .from('user_profiles')
    .select('id')
    .eq('auth_user_id', userId)
    .single()

  if (error || !profile) return null
  return profile.id
}

async function getProfileLevel(supabase: any, userId: string): Promise<string> {
  const { data: profile } = await supabase
    .from('user_profiles')
    .select('proficiency_level')
    .eq('auth_user_id', userId)
    .single()

  return profile?.proficiency_level || 'A1'
}

async function handleListExercises(
  supabase: any,
  userId: string,
  url: URL,
): Promise<Response> {
  const { limit, offset } = parsePagination(url.searchParams)
  const level = url.searchParams.get('level')
  const exerciseType = url.searchParams.get('type')

  const filterLevel = level || await getProfileLevel(supabase, userId)

  let query = supabase
    .from('listening_lessons')
    .select('*', { count: 'exact' })
    .eq('difficulty', filterLevel)

  if (exerciseType) {
    query = query.eq('exercise_type', exerciseType)
  }

  const { data: exercises, error, count } = await query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) {
    console.error('Failed to fetch listening exercises:', error)
    return serverError('Failed to fetch listening exercises')
  }

  const items = (exercises || []).map((ex: ListeningExercise) => ({
    id: ex.id,
    title: ex.title,
    difficulty: ex.difficulty,
    exercise_type: ex.exercise_type,
    question_count: ex.questions?.length || 0,
    created_at: ex.created_at,
  }))

  return successResponse(
    {
      exercises: items,
      level: filterLevel,
    },
    'Listening exercises retrieved successfully',
    {
      limit,
      offset,
      total: count || 0,
      total_pages: Math.ceil((count || 0) / limit),
    },
  )
}

async function handleGetAudio(
  supabase: any,
  exerciseId: string,
): Promise<Response> {
  const { data: exercise, error } = await supabase
    .from('listening_lessons')
    .select('id, title, transcript, audio_url, difficulty, exercise_type, questions')
    .eq('id', exerciseId)
    .single()

  if (error || !exercise) {
    return notFound('Listening exercise not found')
  }

  return successResponse(
    {
      id: exercise.id,
      title: exercise.title,
      transcript: exercise.transcript,
      audio_url: exercise.audio_url,
      difficulty: exercise.difficulty,
      exercise_type: exercise.exercise_type,
      questions: (exercise.questions || []).map((q: ListeningQuestion) => ({
        id: q.id,
        question: q.question,
        question_type: q.question_type,
        options: q.options,
      })),
    },
    'Listening audio retrieved successfully',
  )
}

function evaluateGapFillAnswer(
  userAnswer: string,
  correctAnswer: string,
): boolean {
  const normalise = (s: string) => s.trim().toLowerCase().replace(/[.,!?;:'"]/g, '')
  return normalise(userAnswer) === normalise(correctAnswer)
}

async function handleSubmitAnswers(
  supabase: any,
  userId: string,
  req: Request,
): Promise<Response> {
  const body = await req.json()
  const { exercise_id, answers } = body

  const validation = validateRequired({ exercise_id, answers })
  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '))
  }

  if (!Array.isArray(answers) || answers.length === 0) {
    return badRequest('answers must be a non-empty array')
  }

  for (const ans of answers) {
    const ansValidation = validateRequired({
      question_id: ans.question_id,
      answer: ans.answer,
    })
    if (!ansValidation.isValid) {
      return badRequest('Each answer must include question_id and answer')
    }
  }

  const { data: exercise, error: fetchError } = await supabase
    .from('listening_lessons')
    .select('id, questions')
    .eq('id', exercise_id)
    .single()

  if (fetchError || !exercise) {
    return notFound('Listening exercise not found')
  }

  const questions: ListeningQuestion[] = exercise.questions || []
  const feedback: AnswerFeedback[] = []
  let correctCount = 0

  const questionMap = new Map<string, ListeningQuestion>()
  for (const q of questions) {
    questionMap.set(q.id, q)
  }

  for (const ans of answers) {
    const question = questionMap.get(ans.question_id)

    if (!question) {
      feedback.push({
        question_id: ans.question_id,
        correct: false,
        user_answer: ans.answer,
        correct_answer: '',
        explanation: 'Question not found in this exercise.',
      })
      continue
    }

    let isCorrect = false

    if (question.question_type === 'gap_fill') {
      isCorrect = evaluateGapFillAnswer(ans.answer, question.correct_answer)
    } else {
      isCorrect = ans.answer.trim().toLowerCase() === question.correct_answer.trim().toLowerCase()
    }

    if (isCorrect) correctCount++

    feedback.push({
      question_id: question.id,
      correct: isCorrect,
      user_answer: ans.answer,
      correct_answer: question.correct_answer,
      explanation: question.explanation,
    })
  }

  const score = questions.length > 0
    ? Math.round((correctCount / questions.length) * 100)
    : 0

  const profileId = await getProfileId(supabase, userId)
  if (profileId) {
    await supabase.from('listening_submissions').insert({
      user_id: profileId,
      exercise_id,
      answers,
      score,
      correct_count: correctCount,
      total_questions: questions.length,
      submitted_at: new Date().toISOString(),
    })
  }

  return successResponse(
    {
      exercise_id,
      score,
      correct_count: correctCount,
      total_questions: questions.length,
      feedback,
    },
    'Listening answers evaluated successfully',
  )
}

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
    const path = url.pathname

    // GET /listening-api/exercises
    if (path === `${BASE_PATH}/exercises` && req.method === 'GET') {
      return await handleListExercises(supabase, userId, url)
    }

    // GET /listening-api/audio/{id}
    const audioMatch = path.match(/^\/listening-api\/audio\/([^/]+)$/)
    if (audioMatch && req.method === 'GET') {
      return await handleGetAudio(supabase, audioMatch[1])
    }

    // POST /listening-api/submit
    if (path === `${BASE_PATH}/submit` && req.method === 'POST') {
      return await handleSubmitAnswers(supabase, userId, req)
    }

    return badRequest('Route not found')
  } catch (error) {
    console.error('Listening API error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
