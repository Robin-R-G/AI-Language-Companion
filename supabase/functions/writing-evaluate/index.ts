// supabase/functions/writing-evaluate/index.ts
// Writing Evaluation Edge Function with AI-powered IELTS/PTE Scoring
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
    const { essay_text, prompt_id, exam_type } = await req.json()

    const validation = validateRequired({ essay_text })
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
      targetExam: exam_type || context.userProfile?.targetExam || 'IELTS',
    }

    const systemPrompt = buildPrompt('writing', promptContext)

    const messages: ChatMessage[] = [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: `Evaluate this essay and return ONLY the JSON response:\n\n"${essay_text}"` },
    ]

    const ai = getAIProvider()
    const response = await ai.chatWithFallback(messages, {
      temperature: 0.3,
      maxTokens: 2048,
    })

    let evaluation
    try {
      const jsonMatch = response.content.match(/\{[\s\S]*\}/)
      if (jsonMatch) {
        evaluation = JSON.parse(jsonMatch[0])
      } else {
        evaluation = {
          estimated_band: 'N/A',
          grammar_score: 0,
          vocabulary_score: 0,
          organization_score: 0,
          clarity_score: 0,
          strengths: [],
          mistakes: [],
          improved_version: response.content,
          recommendations: [],
        }
      }
    } catch {
      evaluation = {
        estimated_band: 'N/A',
        grammar_score: 0,
        vocabulary_score: 0,
        organization_score: 0,
        clarity_score: 0,
        strengths: [],
        mistakes: [],
        improved_version: response.content,
        recommendations: [],
      }
    }

    // Save evaluation to writing_tasks table if prompt_id is provided
    if (prompt_id) {
      const { error } = await supabase.from('writing_tasks').insert({
        user_id: userId,
        prompt_id,
        essay_text,
        estimated_band: evaluation.estimated_band,
        grammar_score: evaluation.grammar_score,
        vocabulary_score: evaluation.vocabulary_score,
        organization_score: evaluation.organization_score,
        clarity_score: evaluation.clarity_score,
        feedback: evaluation,
      })
      if (error) {
        console.error('Failed to save evaluation:', error)
      }
    }

    return successResponse({
      ...evaluation,
      tokens_used: response.tokensUsed,
      latency_ms: response.latencyMs,
      provider: response.provider,
    }, 'Writing evaluated successfully')
  } catch (error) {
    console.error('Writing evaluate error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
