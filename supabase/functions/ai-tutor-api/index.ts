// supabase/functions/ai-tutor-api/index.ts
import { successResponse, badRequest, serverError } from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequest } from '../shared/auth.ts'
import { validateRequired } from '../shared/validator.ts'
import { getAIProvider, type ChatMessage, type GrammarResult, type TranslationResult, type PronunciationEvaluation, type VocabularyWord } from '../shared/ai.ts'
import { ConversationMemory, type PromptContext } from '../shared/memory.ts'
import { buildPrompt } from '../shared/prompts.ts'

interface LessonContent {
  title: string
  category: string
  difficulty: string
  estimated_minutes: number
  content: string
  vocabulary: { word: string; definition: string; example: string }[]
  quizzes: { question: string; options: string[]; correct_option_index: number; explanation: string }[]
}

// ─── Route Handler ────────────────────────────────────────────────────────────

function getPathname(url: string): string {
  return new URL(url).pathname
}

function getQueryParam(url: string, key: string): string | null {
  return new URL(url).searchParams.get(key)
}

// ─── Chat Handler ─────────────────────────────────────────────────────────────

async function handleChat(
  req: Request,
  userId: string,
  supabaseClient: any
): Promise<Response> {
  const body = await req.json()
  const validation = validateRequired({
    message: body.message,
    conversation_id: body.conversation_id,
  })

  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '), validation.errors)
  }

  const memory = new ConversationMemory(supabaseClient)
  const context = await memory.loadContext(body.conversation_id, userId)

  const profile = context.userProfile
  const promptCtx: PromptContext = {
    userName: profile?.fullName,
    nativeLanguage: profile?.nativeLanguage,
    targetLanguage: profile?.targetLanguage,
    learningLevel: profile?.proficiencyLevel,
    targetExam: profile?.targetExam,
    conversationHistory: context.recentMessages,
    learningMemory: context.memories.map((m) => m.content),
  }

  const systemPrompt = buildPrompt('tutor', promptCtx)

  const messages: ChatMessage[] = [
    { role: 'system', content: systemPrompt },
    ...context.recentMessages,
    { role: 'user', content: body.message },
  ]

  const ai = getAIProvider()
  const aiResponse = await ai.chatWithFallback(messages, { temperature: 0.7 })

  await memory.saveMessage(body.conversation_id, 'user', body.message)
  await memory.saveMessage(body.conversation_id, 'assistant', aiResponse.content, {
    tokenCount: aiResponse.tokensUsed,
    latencyMs: aiResponse.latencyMs,
  })

  return successResponse({
    reply: aiResponse.content,
    provider: aiResponse.provider,
    model: aiResponse.model,
    tokens_used: aiResponse.tokensUsed,
    latency_ms: aiResponse.latencyMs,
  })
}

// ─── Lesson Handler ───────────────────────────────────────────────────────────

async function handleLesson(
  req: Request,
  userId: string,
  supabaseClient: any
): Promise<Response> {
  const body = await req.json()
  const validation = validateRequired({
    topic: body.topic,
  })

  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '), validation.errors)
  }

  const { data: profile } = await supabaseClient
    .from('user_profiles')
    .select('full_name, native_language, target_language, proficiency_level, target_exam')
    .eq('auth_user_id', userId)
    .single()

  const promptCtx: PromptContext = {
    userName: profile?.full_name,
    nativeLanguage: profile?.native_language,
    targetLanguage: profile?.target_language,
    learningLevel: body.level || profile?.proficiency_level,
    targetExam: profile?.target_exam,
  }

  const systemPrompt = buildPrompt('lesson', promptCtx)

  const messages: ChatMessage[] = [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: `Generate a lesson about: ${body.topic}${body.category ? ` (category: ${body.category})` : ''}` },
  ]

  const ai = getAIProvider()
  const aiResponse = await ai.chatWithFallback(messages, {
    temperature: 0.7,
    maxTokens: 4096,
  })

  let lesson: LessonContent
  try {
    const jsonMatch = aiResponse.content.match(/\{[\s\S]*\}/)
    lesson = JSON.parse(jsonMatch ? jsonMatch[0] : aiResponse.content)
  } catch {
    lesson = {
      title: body.topic,
      category: body.category || 'general',
      difficulty: body.level || profile?.proficiency_level || 'A1',
      estimated_minutes: 15,
      content: aiResponse.content,
      vocabulary: [],
      quizzes: [],
    }
  }

  return successResponse({
    lesson,
    provider: aiResponse.provider,
    model: aiResponse.model,
  })
}

// ─── Grammar Handler ──────────────────────────────────────────────────────────

async function handleGrammar(
  req: Request,
  userId: string,
  supabaseClient: any
): Promise<Response> {
  const body = await req.json()
  const validation = validateRequired({ text: body.text })

  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '), validation.errors)
  }

  const { data: profile } = await supabaseClient
    .from('user_profiles')
    .select('full_name, native_language, target_language, proficiency_level')
    .eq('auth_user_id', userId)
    .single()

  const promptCtx: PromptContext = {
    nativeLanguage: profile?.native_language,
    targetLanguage: profile?.target_language,
    learningLevel: profile?.proficiency_level,
  }

  const systemPrompt = buildPrompt('grammar', promptCtx)

  const messages: ChatMessage[] = [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: body.text },
  ]

  const ai = getAIProvider()
  const aiResponse = await ai.chatWithFallback(messages, { temperature: 0.3 })

  let result: GrammarResult
  try {
    const jsonMatch = aiResponse.content.match(/\{[\s\S]*\}/)
    const parsed = JSON.parse(jsonMatch ? jsonMatch[0] : aiResponse.content)
    result = {
      isCorrect: parsed.is_correct,
      original: parsed.original || body.text,
      corrected: parsed.corrected || body.text,
      explanation: parsed.explanation || '',
      explanationMalayalam: parsed.explanation_malayalam || '',
      category: parsed.category || 'General',
      examples: parsed.examples || [],
    }
  } catch {
    result = {
      isCorrect: true,
      original: body.text,
      corrected: body.text,
      explanation: aiResponse.content,
      explanationMalayalam: '',
      category: 'General',
      examples: [],
    }
  }

  return successResponse({
    grammar: result,
    provider: aiResponse.provider,
    model: aiResponse.model,
  })
}

// ─── Vocabulary Handler ───────────────────────────────────────────────────────

async function handleVocabulary(
  req: Request,
  userId: string,
  supabaseClient: any
): Promise<Response> {
  const body = await req.json()
  const validation = validateRequired({ word: body.word })

  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '), validation.errors)
  }

  const { data: profile } = await supabaseClient
    .from('user_profiles')
    .select('full_name, native_language, target_language, proficiency_level')
    .eq('auth_user_id', userId)
    .single()

  const promptCtx: PromptContext = {
    nativeLanguage: profile?.native_language,
    targetLanguage: profile?.target_language,
    learningLevel: profile?.proficiency_level,
  }

  const systemPrompt = buildPrompt('vocabulary', promptCtx)

  const messages: ChatMessage[] = [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: `Define and explain the word: "${body.word}"${body.context ? ` (used in context: "${body.context}")` : ''}` },
  ]

  const ai = getAIProvider()
  const aiResponse = await ai.chatWithFallback(messages, { temperature: 0.5 })

  let vocab: VocabularyWord
  try {
    const jsonMatch = aiResponse.content.match(/\{[\s\S]*\}/)
    const parsed = JSON.parse(jsonMatch ? jsonMatch[0] : aiResponse.content)
    vocab = {
      word: parsed.word || body.word,
      meaning: parsed.meaning || '',
      meaningMalayalam: parsed.meaning_malayalam || '',
      pronunciation: parsed.pronunciation || '',
      exampleSentence: parsed.example_sentence || '',
      synonyms: parsed.synonyms || [],
      antonyms: parsed.antonyms || [],
      memoryTip: parsed.memory_tip || '',
      cefrLevel: parsed.cefr_level || '',
    }
  } catch {
    vocab = {
      word: body.word,
      meaning: aiResponse.content,
      meaningMalayalam: '',
      pronunciation: '',
      exampleSentence: '',
      synonyms: [],
      antonyms: [],
      memoryTip: '',
      cefrLevel: '',
    }
  }

  return successResponse({
    vocabulary: vocab,
    provider: aiResponse.provider,
    model: aiResponse.model,
  })
}

// ─── Translation Handler ──────────────────────────────────────────────────────

async function handleTranslation(
  req: Request,
  userId: string,
  supabaseClient: any
): Promise<Response> {
  const body = await req.json()
  const validation = validateRequired({ text: body.text })

  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '), validation.errors)
  }

  const { data: profile } = await supabaseClient
    .from('user_profiles')
    .select('full_name, native_language, target_language, proficiency_level')
    .eq('auth_user_id', userId)
    .single()

  const promptCtx: PromptContext = {
    nativeLanguage: profile?.native_language,
    targetLanguage: profile?.target_language,
    learningLevel: profile?.proficiency_level,
  }

  const systemPrompt = buildPrompt('translation', promptCtx)

  const messages: ChatMessage[] = [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: body.text },
  ]

  const ai = getAIProvider()
  const aiResponse = await ai.chatWithFallback(messages, { temperature: 0.3 })

  let result: TranslationResult
  try {
    const jsonMatch = aiResponse.content.match(/\{[\s\S]*\}/)
    const parsed = JSON.parse(jsonMatch ? jsonMatch[0] : aiResponse.content)
    result = {
      translation: parsed.translation || '',
      pronunciation: parsed.pronunciation || '',
      alternativeExpressions: {
        casual: parsed.alternative_expressions?.casual || '',
        formal: parsed.alternative_expressions?.formal || '',
      },
      explanation: parsed.explanation || '',
    }
  } catch {
    result = {
      translation: aiResponse.content,
      pronunciation: '',
      alternativeExpressions: { casual: '', formal: '' },
      explanation: '',
    }
  }

  return successResponse({
    translation: result,
    source_language: body.source_language || profile?.target_language,
    target_language: body.target_language || profile?.native_language,
    provider: aiResponse.provider,
    model: aiResponse.model,
  })
}

// ─── Pronunciation Handler ────────────────────────────────────────────────────

async function handlePronunciation(
  req: Request,
  userId: string,
  supabaseClient: any
): Promise<Response> {
  const body = await req.json()
  const validation = validateRequired({ audio_url: body.audio_url })

  if (!validation.isValid) {
    return badRequest(validation.errors.join(', '), validation.errors)
  }

  const { data: profile } = await supabaseClient
    .from('user_profiles')
    .select('full_name, native_language, target_language, proficiency_level')
    .eq('auth_user_id', userId)
    .single()

  const promptCtx: PromptContext = {
    nativeLanguage: profile?.native_language,
    targetLanguage: profile?.target_language,
    learningLevel: profile?.proficiency_level,
  }

  const systemPrompt = buildPrompt('pronunciation', promptCtx)

  const messages: ChatMessage[] = [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: `Evaluate the pronunciation for this audio: ${body.audio_url}${body.target_text ? `\nTarget text: "${body.target_text}"` : ''}` },
  ]

  const ai = getAIProvider()
  const aiResponse = await ai.chatWithFallback(messages, { temperature: 0.3 })

  let result: PronunciationEvaluation
  try {
    const jsonMatch = aiResponse.content.match(/\{[\s\S]*\}/)
    const parsed = JSON.parse(jsonMatch ? jsonMatch[0] : aiResponse.content)
    result = {
      fluencyScore: parsed.fluency_score ?? 0,
      grammarScore: parsed.grammar_score ?? 0,
      vocabularyScore: parsed.vocabulary_score ?? 0,
      pronunciationScore: parsed.pronunciation_score ?? 0,
      overallScore: parsed.overall_score ?? 0,
      feedback: parsed.feedback || '',
      strengths: parsed.strengths || [],
      issues: parsed.issues || [],
      practiceWords: parsed.practice_words || [],
      shadowingExercise: parsed.shadowing_exercise || '',
      estimatedProficiency: parsed.estimated_proficiency || '',
    }
  } catch {
    result = {
      fluencyScore: 0,
      grammarScore: 0,
      vocabularyScore: 0,
      pronunciationScore: 0,
      overallScore: 0,
      feedback: aiResponse.content,
      strengths: [],
      issues: [],
      practiceWords: [],
      shadowingExercise: '',
      estimatedProficiency: '',
    }
  }

  return successResponse({
    pronunciation: result,
    audio_url: body.audio_url,
    provider: aiResponse.provider,
    model: aiResponse.model,
  })
}

// ─── Router ───────────────────────────────────────────────────────────────────

function route(pathname: string, method: string): string | null {
  const segments = pathname.split('/').filter(Boolean)
  const lastSegment = segments[segments.length - 1]

  if (method === 'POST') {
    switch (lastSegment) {
      case 'chat': return 'chat'
      case 'lesson': return 'lesson'
      case 'grammar': return 'grammar'
      case 'vocabulary': return 'vocabulary'
      case 'translation': return 'translation'
      case 'pronunciation': return 'pronunciation'
      default: return null
    }
  }

  return null
}

// ─── Entry Point ──────────────────────────────────────────────────────────────

Deno.serve(async (req: Request): Promise<Response> => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200, headers: corsHeaders })
  }

  try {
    const auth = await validateRequest(req)

    if (auth.isPreflight) {
      return auth.response!
    }

    if (auth.error) {
      return auth.error
    }

    const pathname = getPathname(req.url)
    const endpoint = route(pathname, req.method)

    if (!endpoint) {
      return badRequest('Invalid endpoint. Use POST /ai/chat, /ai/lesson, /ai/grammar, /ai/vocabulary, /ai/translation, or /ai/pronunciation')
    }

    switch (endpoint) {
      case 'chat':
        return await handleChat(req, auth.user.id, auth.supabaseClient)
      case 'lesson':
        return await handleLesson(req, auth.user.id, auth.supabaseClient)
      case 'grammar':
        return await handleGrammar(req, auth.user.id, auth.supabaseClient)
      case 'vocabulary':
        return await handleVocabulary(req, auth.user.id, auth.supabaseClient)
      case 'translation':
        return await handleTranslation(req, auth.user.id, auth.supabaseClient)
      case 'pronunciation':
        return await handlePronunciation(req, auth.user.id, auth.supabaseClient)
      default:
        return badRequest('Unknown endpoint')
    }
  } catch (error) {
    console.error('AI Tutor API error:', error)
    return serverError(error instanceof Error ? error.message : 'Unexpected error occurred')
  }
})
