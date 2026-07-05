// supabase/functions/ai-tutor/index.ts
// Section 16: AI Tutor APIs
// POST /ai/chat, POST /ai/lesson, POST /ai/grammar, POST /ai/vocabulary, POST /ai/translation, POST /ai/pronunciation
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { getAIProvider, ChatMessage } from '../shared/ai.ts'
import { buildPrompt, PromptContext } from '../shared/prompts.ts'
import { ConversationMemory } from '../shared/memory.ts'
import {
  successResponse,
  badRequest,
  validationError,
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

    const body = await req.json()
    const memory = new ConversationMemory(supabase)
    const context = await memory.loadContext('', userId)

    const { data: profile } = await supabase
      .from('user_profiles')
      .select('native_language, target_language, proficiency_level, target_exam')
      .eq('auth_user_id', userId)
      .single()

    const promptContext: PromptContext = {
      userName: context.userProfile?.fullName,
      nativeLanguage: profile?.native_language || 'Malayalam',
      targetLanguage: profile?.target_language || 'English',
      learningLevel: profile?.proficiency_level || 'A1',
      targetExam: profile?.target_exam || 'IELTS',
    }

    // POST /ai/chat - General AI chat
    if (action === 'chat') {
      const { message, conversation_id } = body
      const validation = validateRequired({ message })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      const systemPrompt = buildPrompt('tutor', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: message },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.7,
        maxTokens: 2048,
      })

      // Save conversation
      let convId = conversation_id
      if (!convId) {
        const { data: conv } = await supabase
          .from('ai_conversations')
          .insert({
            user_id: userId,
            title: message.substring(0, 50),
            provider: response.provider,
            model: response.model,
          })
          .select('id')
          .single()
        convId = conv?.id
      }

      if (convId) {
        await supabase.from('chat_messages').insert([
          { conversation_id: convId, role: 'user', content: message },
          { conversation_id: convId, role: 'assistant', content: response.content, token_count: response.tokensUsed, latency_ms: response.latencyMs },
        ])
      }

      return successResponse({
        response: response.content,
        conversation_id: convId,
        tokens_used: response.tokensUsed,
        latency_ms: response.latencyMs,
        provider: response.provider,
      }, 'AI response generated.')
    }

    // POST /ai/lesson - Generate AI lesson
    if (action === 'lesson') {
      const { topic, difficulty } = body

      const systemPrompt = buildPrompt('lesson', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Generate a ${difficulty || promptContext.learningLevel} level lesson about ${topic || 'general English'}. Return JSON: { "title": "", "content": "", "vocabulary": [{ "word": "", "meaning": "", "example": "" }], "exercises": [{ "question": "", "answer": "" }], "tips": [""] }` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.7,
        maxTokens: 2048,
      })

      let lesson
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        lesson = jsonMatch ? JSON.parse(jsonMatch[0]) : { title: 'AI Lesson', content: response.content }
      } catch {
        lesson = { title: 'AI Lesson', content: response.content }
      }

      return successResponse({
        ...lesson,
        tokens_used: response.tokensUsed,
        provider: response.provider,
      }, 'AI lesson generated.')
    }

    // POST /ai/grammar - AI grammar check
    if (action === 'grammar') {
      const { text } = body
      const validation = validateRequired({ text })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
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

      let result
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        result = jsonMatch ? JSON.parse(jsonMatch[0]) : { original: text, corrected: text, explanation: response.content }
      } catch {
        result = { original: text, corrected: text, explanation: response.content }
      }

      return successResponse({
        ...result,
        tokens_used: response.tokensUsed,
        provider: response.provider,
      }, 'Grammar checked.')
    }

    // POST /ai/vocabulary - AI vocabulary help
    if (action === 'vocabulary') {
      const { word, context: wordContext } = body
      const validation = validateRequired({ word })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      const systemPrompt = buildPrompt('vocabulary', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Explain the word "${word}"${wordContext ? ` in the context of "${wordContext}"` : ''}. Return JSON: { "word": "", "meaning": "", "pronunciation": "", "part_of_speech": "", "examples": [""], "synonyms": [""], "antonyms": [""], "etymology": "" }` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.5,
        maxTokens: 1024,
      })

      let vocabResult
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        vocabResult = jsonMatch ? JSON.parse(jsonMatch[0]) : { word, explanation: response.content }
      } catch {
        vocabResult = { word, explanation: response.content }
      }

      return successResponse({
        ...vocabResult,
        tokens_used: response.tokensUsed,
        provider: response.provider,
      }, 'Vocabulary explanation generated.')
    }

    // POST /ai/translation - AI translation
    if (action === 'translation') {
      const { text, target_language } = body
      const validation = validateRequired({ text })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      const systemPrompt = buildPrompt('translation', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Translate "${text}" to ${target_language || promptContext.targetLanguage}. Return JSON: { "original": "", "translated": "", "pronunciation": "", "alternatives": [""], "formal": "", "casual": "" }` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.3,
        maxTokens: 1024,
      })

      let translation
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        translation = jsonMatch ? JSON.parse(jsonMatch[0]) : { original: text, translated: response.content }
      } catch {
        translation = { original: text, translated: response.content }
      }

      return successResponse({
        ...translation,
        tokens_used: response.tokensUsed,
        provider: response.provider,
      }, 'Translation generated.')
    }

    // POST /ai/pronunciation - AI pronunciation help
    if (action === 'pronunciation') {
      const { word, transcript } = body
      const validation = validateRequired({ word })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      const systemPrompt = buildPrompt('pronunciation', promptContext)
      const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Help with pronunciation of "${word}"${transcript ? `. The user said: "${transcript}"` : ''}. Return JSON: { "word": "", "phonetic": "", "syllables": [""], "tips": [""], "common_mistakes": [""], "score": 0-100 }` },
      ]

      const ai = getAIProvider()
      const response = await ai.chatWithFallback(messages, {
        temperature: 0.3,
        maxTokens: 1024,
      })

      let pronunciation
      try {
        const jsonMatch = response.content.match(/\{[\s\S]*\}/)
        pronunciation = jsonMatch ? JSON.parse(jsonMatch[0]) : { word, feedback: response.content }
      } catch {
        pronunciation = { word, feedback: response.content }
      }

      return successResponse({
        ...pronunciation,
        tokens_used: response.tokensUsed,
        provider: response.provider,
      }, 'Pronunciation guidance generated.')
    }

    return badRequest('Unknown AI tutor endpoint')
  } catch (error) {
    console.error('AI tutor error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
