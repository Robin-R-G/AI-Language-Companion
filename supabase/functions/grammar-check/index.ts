// supabase/functions/grammar-check/index.ts
// Grammar Check Edge Function with Real AI Integration
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
    const { text, language_level, native_language } = await req.json()

    const validation = validateRequired({ text })
    if (!validation.isValid) {
      return badRequest(validation.errors.join(', '))
    }

    const supabase = authResult.supabaseClient
    const userId = authResult.user.id
    const memory = new ConversationMemory(supabase)

    // Load user profile for context
    const context = await memory.loadContext('', userId)

    const promptContext: PromptContext = {
      userName: context.userProfile?.fullName,
      nativeLanguage: native_language || context.userProfile?.nativeLanguage || 'Malayalam',
      targetLanguage: context.userProfile?.targetLanguage || 'English',
      learningLevel: language_level || context.userProfile?.proficiencyLevel || 'A1',
      targetExam: context.userProfile?.targetExam,
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

    // Parse the AI response as JSON
    let grammarResult
    try {
      // Try to extract JSON from the response
      const jsonMatch = response.content.match(/\{[\s\S]*\}/)
      if (jsonMatch) {
        grammarResult = JSON.parse(jsonMatch[0])
      } else {
        grammarResult = {
          is_correct: true,
          original: text,
          corrected: text,
          explanation: response.content,
          explanation_malayalam: '',
          category: 'General',
          examples: [],
        }
      }
    } catch {
      // If parsing fails, treat the response as a general correction
      grammarResult = {
        is_correct: true,
        original: text,
        corrected: text,
        explanation: response.content,
        explanation_malayalam: '',
        category: 'General',
        examples: [],
      }
    }

    return successResponse(grammarResult, 'Grammar evaluated')
  } catch (error) {
    console.error('Grammar check error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
