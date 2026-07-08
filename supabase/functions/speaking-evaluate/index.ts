// supabase/functions/speaking-evaluate/index.ts
// Speaking Evaluation Edge Function with AI-powered Pronunciation & Fluency Scoring
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
    const { transcript_text, target_language } = await req.json()

    const validation = validateRequired({ transcript_text })
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
      targetLanguage: target_language || context.userProfile?.targetLanguage || 'English',
      learningLevel: context.userProfile?.proficiencyLevel || 'A1',
      targetExam: context.userProfile?.targetExam,
    }

    const systemPrompt = buildPrompt('speaking', promptContext)

    const messages: ChatMessage[] = [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: `Evaluate this speech transcript and return ONLY the JSON response:\n\n"${transcript_text}"` },
    ]

    const ai = getAIProvider()
    const response = await ai.chatWithFallback(messages, {
      temperature: 0.3,
      maxTokens: 1024,
    })

    let evaluation
    try {
      const jsonMatch = response.content.match(/\{[\s\S]*\}/)
      if (jsonMatch) {
        evaluation = JSON.parse(jsonMatch[0])
      } else {
        evaluation = {
          fluency_score: 0,
          grammar_score: 0,
          vocabulary_score: 0,
          pronunciation_score: 0,
          overall_score: 0,
          feedback: response.content,
          strengths: [],
          issues: [],
          practice_words: [],
          shadowing_exercise: '',
          estimated_proficiency: 'N/A',
        }
      }
    } catch {
      evaluation = {
        fluency_score: 0,
        grammar_score: 0,
        vocabulary_score: 0,
        pronunciation_score: 0,
        overall_score: 0,
        feedback: response.content,
        strengths: [],
        issues: [],
        practice_words: [],
        shadowing_exercise: '',
        estimated_proficiency: 'N/A',
      }
    }

    // Save session to voice_sessions table
    const { error: sessionError } = await supabase.from('voice_sessions').insert({
      user_id: userId,
      transcript: transcript_text,
      pronunciation_score: evaluation.pronunciation_score,
      fluency_score: evaluation.fluency_score,
    })
    if (sessionError) {
      console.error('Failed to save voice session:', sessionError)
    }

    return successResponse({
      ...evaluation,
      tokens_used: response.tokensUsed,
      latency_ms: response.latencyMs,
      provider: response.provider,
    }, 'Speaking evaluated successfully')
  } catch (error) {
    console.error('Speaking evaluate error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
