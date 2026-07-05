// supabase/functions/voice-session/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, serverError } from '../shared/errors.ts'

serve(async (req: Request) => {
  const authResult = await validateRequest(req)
  if (authResult.error) return authResult.error
  if (authResult.isPreflight) return authResult.response!

  try {
    const { room_id } = await req.json()
    const identity = authResult.user.id
    const targetRoom = room_id || `room_${identity.substring(0, 8)}`

    const apiKey = Deno.env.get('LIVEKIT_API_KEY')
    const apiSecret = Deno.env.get('LIVEKIT_API_SECRET')
    const livekitUrl = Deno.env.get('LIVEKIT_URL') ?? 'wss://mock.livekit.cloud'

    let token = "simulated_livekit_token_for_offline_development_purposes"

    if (apiKey && apiSecret) {
      // In production, load LiveKit server SDK dynamically to sign JWT
      // Deno imports livekit-server-sdk from ESM.sh to generate tokens
      try {
        const { AccessToken } = await import('https://esm.sh/livekit-server-sdk@1.2.7')
        const at = new AccessToken(apiKey, apiSecret, {
          identity: identity,
          name: authResult.user.email ?? 'Language Learner',
        })
        at.addGrant({ roomJoin: true, room: targetRoom, canPublish: true, canSubscribe: true })
        token = await at.toJwt()
      } catch (err) {
        console.error("LiveKit token generation failed:", err)
      }
    }

    return successResponse({
      token,
      room_id: targetRoom,
      livekit_url: livekitUrl,
    }, 'LiveKit token generated')

  } catch (error) {
    return serverError(error.message || 'Internal server error')
  }
})
