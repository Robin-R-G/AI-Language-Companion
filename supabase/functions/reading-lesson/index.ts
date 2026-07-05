// supabase/functions/reading-lesson/index.ts
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

ROLE: Reading comprehension specialist.
Generate a reading passage with comprehension questions based on the topic.

OUTPUT FORMAT (respond ONLY with valid JSON):
{
  "passage": "reading passage text",
  "title": "passage title",
  "word_count": number,
  "cefr_level": "target CEFR level",
  "vocabulary": [
    { "word": "word", "definition": "meaning", "example": "usage" }
  ],
  "comprehension_questions": [
    {
      "question": "question text",
      "options": ["A", "B", "C", "D"],
      "correct_index": number,
      "explanation": "why correct"
    }
  ],
  "cultural_notes": "relevant cultural context"
}`

    const messages: ChatMessage[] = [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: `Generate a reading lesson about: ${topic}` },
    ]

    const ai = getAIProvider()
    const response = await ai.chatWithFallback(messages, {
      temperature: 0.6,
      maxTokens: 2048,
    })

    let result
    try {
      const jsonMatch = response.content.match(/\{[\s\S]*\}/)
      if (jsonMatch) {
        result = JSON.parse(jsonMatch[0])
      } else {
        result = {
          passage: response.content,
          title: `Reading: ${topic}`,
          word_count: response.content.split(' ').length,
          cefr_level: promptContext.learningLevel || 'A1',
          vocabulary: [],
          comprehension_questions: [],
          cultural_notes: '',
        }
      }
    } catch {
      result = {
        passage: response.content,
        title: `Reading: ${topic}`,
        word_count: response.content.split(' ').length,
        cefr_level: promptContext.learningLevel || 'A1',
        vocabulary: [],
        comprehension_questions: [],
        cultural_notes: '',
      }
    }

    return successResponse(result, 'Reading lesson generated')
  } catch (error) {
    console.error('Reading lesson error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
