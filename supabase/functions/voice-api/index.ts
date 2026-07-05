// supabase/functions/voice-api/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequest } from '../shared/auth.ts'
import { validateRequired } from '../shared/validator.ts'
import { successResponse, badRequest, notFound, serverError } from '../shared/errors.ts'

const LIVEKIT_URL = Deno.env.get('LIVEKIT_URL') ?? ''
const LIVEKIT_API_KEY = Deno.env.get('LIVEKIT_API_KEY') ?? ''
const LIVEKIT_API_SECRET = Deno.env.get('LIVEKIT_API_SECRET') ?? ''

function generateLiveKitToken(
  roomName: string,
  identity: string,
  name: string,
): string {
  const now = Math.floor(Date.now() / 1000)
  const header = { alg: 'HS256', typ: 'JWT' }

  const payload = {
    iss: LIVEKIT_API_KEY,
    sub: identity,
    name,
    video: {
      room: roomName,
      roomJoin: true,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    },
    nbf: now,
    exp: now + 86400,
  }

  const base64url = (data: string) =>
    btoa(data).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')

  const encoder = new TextEncoder()
  const headerB64 = base64url(JSON.stringify(header))
  const payloadB64 = base64url(JSON.stringify(payload))
  const signingInput = `${headerB64}.${payloadB64}`

  const key = crypto.subtle.importKey(
    'raw',
    encoder.encode(LIVEKIT_API_SECRET),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  )

  return crypto.subtle
    .sign('HMAC', key, encoder.encode(signingInput))
    .then((sig) => {
      const signature = base64url(String.fromCharCode(...new Uint8Array(sig)))
      return `${signingInput}.${signature}`
    })
}

async function handleCreateSession(req: Request, user: { id: string }): Promise<Response> {
  const body = await req.json()
  const { isValid, errors } = validateRequired({
    language: body.language,
    level: body.level,
  })

  if (!isValid) {
    return badRequest('Missing required fields', errors)
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  const supabase = createClient(supabaseUrl, supabaseServiceKey)

  const { data: session, error: insertError } = await supabase
    .from('voice_sessions')
    .insert({
      user_id: user.id,
      language: body.language,
      level: body.level,
      scenario: body.scenario ?? null,
      status: 'active',
      started_at: new Date().toISOString(),
    })
    .select('id')
    .single()

  if (insertError || !session) {
    return serverError('Failed to create voice session')
  }

  const sessionId = session.id as string
  const roomName = `voice-${sessionId}`

  try {
    const token = await generateLiveKitToken(roomName, user.id, user.email ?? user.id)

    return successResponse(
      { session_id: sessionId, token, room_name: roomName },
      'Voice session created.',
    )
  } catch {
    await supabase.from('voice_sessions').update({ status: 'failed' }).eq('id', sessionId)
    return serverError('Failed to generate voice session token')
  }
}

async function handleEndSession(req: Request, user: { id: string }): Promise<Response> {
  const body = await req.json()
  const { isValid, errors } = validateRequired({ session_id: body.session_id })

  if (!isValid) {
    return badRequest('Missing required fields', errors)
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  const supabase = createClient(supabaseUrl, supabaseServiceKey)

  const { data: session, error: fetchError } = await supabase
    .from('voice_sessions')
    .select('*')
    .eq('id', body.session_id)
    .eq('user_id', user.id)
    .single()

  if (fetchError || !session) {
    return notFound('Voice session not found')
  }

  if (session.status !== 'active') {
    return badRequest('Session is not active')
  }

  const now = new Date()
  const startedAt = new Date(session.started_at)
  const durationSeconds = Math.floor((now.getTime() - startedAt.getTime()) / 1000)

  const { error: updateError } = await supabase
    .from('voice_sessions')
    .update({
      status: 'completed',
      ended_at: now.toISOString(),
      duration_seconds: durationSeconds,
    })
    .eq('id', body.session_id)

  if (updateError) {
    return serverError('Failed to update voice session')
  }

  return successResponse(
    {
      session_id: body.session_id,
      language: session.language,
      level: session.level,
      scenario: session.scenario,
      duration_seconds: durationSeconds,
      started_at: session.started_at,
      ended_at: now.toISOString(),
    },
    'Voice session ended.',
  )
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200, headers: corsHeaders })
  }

  const url = new URL(req.url)
  const path = url.pathname

  const auth = await validateRequest(req)
  if (auth.isPreflight) return auth.response!
  if (auth.error) return auth.error

  try {
    if (path.endsWith('/voice/session') && req.method === 'POST') {
      return await handleCreateSession(req, auth.user)
    }

    if (path.endsWith('/voice/end') && req.method === 'POST') {
      return await handleEndSession(req, auth.user)
    }

    return notFound('Endpoint not found')
  } catch (err) {
    console.error('Voice API error:', err)
    return serverError('An unexpected error occurred')
  }
})
