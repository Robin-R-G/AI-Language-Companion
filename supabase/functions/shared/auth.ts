// supabase/functions/shared/auth.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'
import { corsHeaders } from './cors.ts'

export async function validateRequest(req: Request) {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    return { isPreflight: true, response: new Response('ok', { headers: corsHeaders }) }
  }

  const authHeader = req.headers.get('Authorization')
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return {
      isPreflight: false,
      error: new Response(
        JSON.stringify({ success: false, error: { code: 'UNAUTHORIZED', message: 'Missing JWT authorization token' } }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      ),
    }
  }

  const token = authHeader.split(' ')[1]
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: authHeader } } }
  )

  const { data: { user }, error } = await supabaseClient.auth.getUser(token)
  if (error || !user) {
    return {
      isPreflight: false,
      error: new Response(
        JSON.stringify({ success: false, error: { code: 'AUTH_FAILED', message: 'Invalid JWT authorization token' } }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      ),
    }
  }

  return { isPreflight: false, user, supabaseClient }
}
