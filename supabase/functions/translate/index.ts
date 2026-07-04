// supabase/functions/translate/index.ts
// Translation Edge Function with Real AI Integration
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { getAIProvider, ChatMessage } from '../shared/ai.ts'
import { buildPrompt, PromptContext } from '../shared/prompts.ts'
import { ConversationMemory } from '../shared/memory.ts'
import { successResponse, badRequest, serverError } from '../shared/errors.ts'
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
    const { text, target_language, source_language } = await req.json()

    const validation = validateRequired({ text, target_language })
    if (!validation.isValid) {
      return badRequest(validation.errors.join(', '))
    }

    const supabase = authResult.supabaseClient
    const userId = authResult.user.id
    const memory = new ConversationMemory(supabase)

    const context = await memory.loadContext('', userId)

    const promptContext: PromptContext = {
      userName: context.userProfile?.fullName,
      nativeLanguage: target_language,
      targetLanguage: source_language || context.userProfile?.targetLanguage || 'English',
      learningLevel: context.userProfile?.proficiencyLevel || 'A1',
    }

    const systemPrompt = buildPrompt('translation', promptContext)

    const messages: ChatMessage[] = [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: `Translate the following text and return ONLY the JSON response:\n\n"${text}"` },
    ]

    const ai = getAIProvider()
    const response = await ai.chatWithFallback(messages, {
      temperature: 0.3,
      maxTokens: 1024,
    })

    // Parse the AI response as JSON
    let translationResult
    try {
      const jsonMatch = response.content.match(/\{[\s\S]*\}/)
      if (jsonMatch) {
        translationResult = JSON.parse(jsonMatch[0])
      } else {
        translationResult = {
          translation: response.content,
          pronunciation: '',
          alternative_expressions: { casual: '', formal: '' },
          explanation: '',
        }
      }
    } catch {
      translationResult = {
        translation: response.content,
        pronunciation: '',
        alternative_expressions: { casual: '', formal: '' },
        explanation: '',
      }
    }

    return successResponse({
      original: text,
      translation: translationResult.translation,
      pronunciation: translationResult.pronunciation,
      alternative_expressions: translationResult.alternative_expressions,
      explanation: translationResult.explanation,
      target_language,
    }, 'Translation complete')
  } catch (error) {
    console.error('Translation error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
