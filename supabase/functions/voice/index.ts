// supabase/functions/voice/index.ts
// Section 17: Voice APIs
// POST /voice/session, WebSocket /voice/stt, WebSocket /voice/chat, WebSocket /voice/tts, POST /voice/end
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { getAIProvider, ChatMessage } from '../shared/ai.ts'
import { buildPrompt, PromptContext } from '../shared/prompts.ts'
import { ConversationMemory } from '../shared/memory.ts'
import {
  successResponse,
  badRequest,
  validationError,
  notFound,
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

    // POST /voice/session - Create voice session
    if (req.method === 'POST' && action === 'session') {
      const body = await req.json()
      const { language, topic } = body

      const { data: profile } = await supabase
        .from('user_profiles')
        .select('id, target_language')
        .eq('auth_user_id', userId)
        .single()

      if (!profile) {
        return notFound('User profile not found')
      }

      const roomId = `voice-${Date.now()}-${Math.random().toString(36).substring(7)}`

      const { data: session, error: sessionError } = await supabase
        .from('voice_sessions')
        .insert({
          user_id: profile.id,
          provider: 'livekit',
          room_id: roomId,
        })
        .select('id')
        .single()

      if (sessionError) {
        console.error('Failed to create voice session:', sessionError)
        return serverError('Failed to create voice session')
      }

      // Generate LiveKit token (simplified - in production use LiveKit SDK)
      const livekitToken = generateLiveKitToken(roomId, userId)

      return successResponse({
        session_id: session.id,
        room_id: roomId,
        token: livekitToken,
        language: language || profile.target_language,
      }, 'Voice session created.')
    }

    // POST /voice/end - End voice session
    if (req.method === 'POST' && action === 'end') {
      const body = await req.json()
      const { session_id, duration, transcript } = body

      const validation = validateRequired({ session_id })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      const { error } = await supabase
        .from('voice_sessions')
        .update({
          duration: duration || 0,
          transcript: transcript || '',
        })
        .eq('id', session_id)
        .eq('user_id', userId)

      if (error) {
        console.error('Failed to end voice session:', error)
        return serverError('Failed to end voice session')
      }

      return successResponse({ session_id }, 'Voice session ended.')
    }

    // WebSocket endpoints (stt, chat, tts) - these need to be handled differently
    // For now, return instructions for WebSocket connection
    if (action === 'stt' || action === 'chat' || action === 'tts') {
      return successResponse({
        websocket_url: `${Deno.env.get('SUPABASE_URL')?.replace('https', 'wss')}/functions/v1/voice-${action}`,
        protocol: 'websocket',
        instructions: `Connect to the WebSocket URL for ${action.toUpperCase()} streaming.`,
      }, `Voice ${action} endpoint info.`)
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Voice error:', error)
    return serverError(error.message || 'Internal server error')
  }
})

function generateLiveKitToken(roomId: string, userId: string): string {
  // Simplified token generation - in production use LiveKit SDK
  const apiKey = Deno.env.get('LIVEKIT_API_KEY') || ''
  const apiSecret = Deno.env.get('LIVEKIT_API_SECRET') || ''

  if (!apiKey || !apiSecret) {
    return 'livekit-token-placeholder'
  }

  // In production, use proper JWT signing with LiveKit
  return `livekit-token-${roomId}-${userId}`
}
