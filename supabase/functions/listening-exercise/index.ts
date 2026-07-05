// supabase/functions/listening-exercise/index.ts
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
    const { topic } = await req.json()

    const validation = validateRequired({ topic })
    if (!validation.isValid) {
      return badRequest(validation.errors.join(', '))
    }

    const supabase = authResult.supabaseClient
    const userId = authResult.user.id
    const memory = new ConversationMemory(supabase)
    const context = await memory.loadContext('', userId)

    const promptContext: PromptContext = {
      userName: context.userProfile?.fullName,
      nativeLanguage: context.userProfile?.nativeLanguage || 'Malayalam',
      targetLanguage: context.userProfile?.targetLanguage || 'English',
      learningLevel: context.userProfile?.proficiencyLevel || 'A1',
      targetExam: context.userProfile?.targetExam,
    }

    const systemPrompt = `${buildPrompt('tutor', promptContext)}

ROLE: Listening comprehension specialist.
Generate a listening exercise with a script and gap-fill exercises.

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "script": "audio script for TTS",
  "title": "exercise title",
  "cefr_level": "target level",
  "gap_fill": [
    { "sentence": "The cat ___ on the mat", "answer": "sat", "hint": "past tense of sit" }
  ],
  "comprehension_questions": [
    { "question": "question", "options": ["A","B","C"], "correct_index": number, "explanation": "why" }
  ],
  "speed_notes": "recommended speech speed (slow|normal|fast)"
}`

    const messages: ChatMessage[] = [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: `Generate a listening exercise about: ${topic}` },
    ]

    const ai = getAIProvider()
    const response = await ai.chatWithFallback(messages, {
      temperature: 0.5,
      maxTokens: 2048,
    })

    let result
    try {
      const jsonMatch = response.content.match(/\{[\s\S]*\}/)
      if (jsonMatch) {
        result = JSON.parse(jsonMatch[0])
      } else {
        result = {
          script: response.content,
          title: `Listening: ${topic}`,
          cefr_level: promptContext.learningLevel || 'A1',
          gap_fill: [],
          comprehension_questions: [],
          speed_notes: 'normal',
        }
      }
    } catch {
      result = {
        script: response.content,
        title: `Listening: ${topic}`,
        cefr_level: promptContext.learningLevel || 'A1',
        gap_fill: [],
        comprehension_questions: [],
        speed_notes: 'normal',
      }
    }

    return successResponse(result, 'Listening exercise generated')
  } catch (error) {
    console.error('Listening exercise error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
