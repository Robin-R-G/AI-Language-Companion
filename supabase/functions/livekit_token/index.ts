// supabase/functions/livekit_token/index.ts
// Issues LiveKit JWT tokens for authenticated users.
// Validates session ownership before issuing token.

import { createClient } from 'npm:@supabase/supabase-js@2';
import { AccessToken } from 'npm:livekit-server-sdk@2';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

const LIVEKIT_API_KEY = Deno.env.get('LIVEKIT_API_KEY')!;
const LIVEKIT_API_SECRET = Deno.env.get('LIVEKIT_API_SECRET')!;
const LIVEKIT_URL = Deno.env.get('LIVEKIT_URL') ?? 'wss://your-livekit-server.livekit.cloud';

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }

  // ── Auth ─────────────────────────────────────────────────────────────────────
  const authHeader = req.headers.get('Authorization') ?? '';
  const jwt = authHeader.replace('Bearer ', '');

  const { data: { user }, error: authError } = await supabase.auth.getUser(jwt);
  if (authError || !user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const { session_id, is_host } = await req.json();

  if (!session_id) {
    return new Response(JSON.stringify({ error: 'session_id required' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // ── Validate session ownership ────────────────────────────────────────────────
  const { data: session } = await supabase
    .from('live_sessions')
    .select('id, tutor_id, student_id, status, room_name')
    .eq('id', session_id)
    .single();

  if (!session) {
    return new Response(JSON.stringify({ error: 'Session not found' }), {
      status: 404,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const isParticipant =
    session.tutor_id === user.id || session.student_id === user.id;

  if (!isParticipant) {
    return new Response(JSON.stringify({ error: 'Forbidden' }), {
      status: 403,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  if (session.status === 'ended') {
    return new Response(JSON.stringify({ error: 'Session has ended' }), {
      status: 410,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // ── Generate room name ────────────────────────────────────────────────────────
  const roomName = session.room_name ?? `session-${session_id}`;

  // ── Create LiveKit access token ───────────────────────────────────────────────
  const isHost = is_host === true || session.tutor_id === user.id;

  const at = new AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET, {
    identity: user.id,
    name: user.email ?? user.id,
    ttl: '4h',
  });

  at.addGrant({
    roomJoin: true,
    room: roomName,
    canPublish: true,           // everyone can publish audio
    canPublishData: true,       // everyone can publish data (chat)
    canSubscribe: true,         // everyone can subscribe
    canPublishSources: isHost
      ? ['camera', 'microphone', 'screen_share'] as any
      : ['microphone'] as any,  // students: mic only (tutor has camera)
    roomAdmin: isHost,
    roomCreate: isHost,
  });

  const token = await at.toJwt();

  // ── Update room name in DB if not set ─────────────────────────────────────────
  if (!session.room_name) {
    await supabase.from('live_sessions').update({ room_name: roomName })
      .eq('id', session_id);
  }

  return new Response(
    JSON.stringify({ token, livekit_url: LIVEKIT_URL, room_name: roomName }),
    {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    },
  );
});
