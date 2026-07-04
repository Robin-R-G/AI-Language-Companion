// supabase/functions/ai-chat/index.ts
// AI Chat Edge Function with Real AI Integration & Streaming
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { getAIProvider, ChatMessage } from '../shared/ai.ts'
import { buildPrompt, PromptContext } from '../shared/prompts.ts'
import { ConversationMemory, extractMemoryInsights } from '../shared/memory.ts'
import { successResponse, badRequest, serverError, aiProviderError } from '../shared/errors.ts'
import { validateRequired } from '../shared/validator.ts'

import { corsHeaders } from '../shared/cors.ts'

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const authResult = await validateRequest(req)
  if (authResult.error) return authResult.error
  if (authResult.isPreflight) return authResult.response!

  try {
    const body = await req.json()
    const { conversation_id, message, mode = 'conversation', stream = false } = body

    // Validate request
    const validation = validateRequired({ conversation_id, message })
    if (!validation.isValid) {
      return badRequest(validation.errors.join(', '))
    }

    const supabase = authResult.supabaseClient
    const userId = authResult.user.id
    const memory = new ConversationMemory(supabase)

    // Ensure conversation exists
    let activeConversationId = conversation_id
    const { data: existingConv } = await supabase
      .from('ai_conversations')
      .select('id')
      .eq('id', conversation_id)
      .single()

    if (!existingConv) {
      // Create new conversation
      const newId = await memory.createConversation(userId, message.substring(0, 50), 'gemini', 'gemini-1.5-flash')
      if (!newId) {
        return serverError('Failed to create conversation')
      }
      activeConversationId = newId
    }

    // Save user message
    await memory.saveMessage(activeConversationId, 'user', message)

    // Load conversation context
    const context = await memory.loadContext(activeConversationId, userId)

    // Build prompt context
    const promptContext: PromptContext = {
      userName: context.userProfile?.fullName,
      nativeLanguage: context.userProfile?.nativeLanguage,
      targetLanguage: context.userProfile?.targetLanguage,
      learningLevel: context.userProfile?.proficiencyLevel,
      targetExam: context.userProfile?.targetExam,
      learningMemory: context.memories.map((m) => m.content),
      conversationHistory: context.recentMessages,
    }

    // Build system prompt
    const systemPrompt = buildPrompt('tutor', promptContext)

    // Prepare messages for AI
    const messages: ChatMessage[] = [
      { role: 'system', content: systemPrompt },
      ...context.recentMessages,
      { role: 'user', content: message },
    ]

    // Call AI with fallback
    const ai = getAIProvider()
    let aiResponse

    if (stream) {
      // Streaming mode - return SSE
      const encoder = new TextEncoder()
      const stream = new ReadableStream({
        async start(controller) {
          try {
            const response = await ai.chatStreamWithFallback(
              messages,
              { temperature: 0.7, maxTokens: 2048 },
              (chunk) => {
                controller.enqueue(encoder.encode(`data: ${JSON.stringify({ type: 'chunk', content: chunk })}\n\n`))
              }
            )

            // Parse grammar feedback from final response
            const grammarFeedback = parseGrammarFeedback(response.content)

            // Save AI response
            await memory.saveMessage(activeConversationId, 'assistant', response.content, {
              grammarFeedback,
              tokenCount: response.tokensUsed,
              latencyMs: response.latencyMs,
            })

            // Extract and save memory insights
            const insights = extractMemoryInsights(message, response.content, grammarFeedback)
            for (const insight of insights) {
              await memory.saveMemory(userId, insight.type, insight.content, insight.importance)
            }

            // Send final metadata
            controller.enqueue(encoder.encode(`data: ${JSON.stringify({
              type: 'done',
              reply: response.content,
              grammar_feedback: grammarFeedback,
              conversation_id: activeConversationId,
              tokens_used: response.tokensUsed,
              latency_ms: response.latencyMs,
              provider: response.provider,
            })}\n\n`))

            controller.close()
          } catch (error) {
            controller.enqueue(encoder.encode(`data: ${JSON.stringify({ type: 'error', message: error.message })}\n\n`))
            controller.close()
          }
        },
      })

      return new Response(stream, {
        headers: {
          ...corsHeaders,
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'Connection': 'keep-alive',
        },
      })
    } else {
      // Non-streaming mode
      aiResponse = await ai.chatWithFallback(messages, {
        temperature: 0.7,
        maxTokens: 2048,
      })

      // Parse grammar feedback from response
      const grammarFeedback = parseGrammarFeedback(aiResponse.content)

      // Save AI response
      await memory.saveMessage(activeConversationId, 'assistant', aiResponse.content, {
        grammarFeedback,
        tokenCount: aiResponse.tokensUsed,
        latencyMs: aiResponse.latencyMs,
      })

      // Extract and save memory insights
      const insights = extractMemoryInsights(message, aiResponse.content, grammarFeedback)
      for (const insight of insights) {
        await memory.saveMemory(userId, insight.type, insight.content, insight.importance)
      }

      return successResponse({
        reply: aiResponse.content,
        grammar_feedback: grammarFeedback,
        conversation_id: activeConversationId,
        tokens_used: aiResponse.tokensUsed,
        latency_ms: aiResponse.latencyMs,
        provider: aiResponse.provider,
      }, 'Chat response processed')
    }
  } catch (error) {
    console.error('AI Chat error:', error)
    if (error.message?.includes('AI providers failed')) {
      return aiProviderError('AI service temporarily unavailable. Please try again.')
    }
    return serverError(error.message || 'Internal server error')
  }
})

// ─── Helper Functions ────────────────────────────────────────────────────────

function parseGrammarFeedback(response: string): any {
  try {
    // Try to extract JSON grammar feedback from response
    const jsonMatch = response.match(/\{[\s\S]*"is_correct"[\s\S]*\}/)
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0])
    }
  } catch {
    // Not JSON, that's fine
  }
  return null
}
