// supabase/functions/shared/auth.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { unauthorized } from './errors.ts'

export interface AuthResult {
  user: { id: string; email?: string }
  supabaseClient: ReturnType<typeof createClient>
  error?: Response
  isPreflight?: boolean
  response?: Response
}

export async function validateRequest(req: Request): Promise<AuthResult> {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return {
      user: { id: '' },
      supabaseClient: null as any,
      isPreflight: true,
      response: new Response('ok', { status: 200 }),
    }
  }

  const authHeader = req.headers.get('Authorization')

  if (!authHeader) {
    return {
      user: { id: '' },
      supabaseClient: null as any,
      error: unauthorized('Authorization header required'),
    }
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
  const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY') ?? ''

  const supabase = createClient(supabaseUrl, supabaseKey, {
    global: { headers: { Authorization: authHeader } },
  })

  const { data: { user }, error } = await supabase.auth.getUser()

  if (error || !user) {
    return {
      user: { id: '' },
      supabaseClient: supabase,
      error: unauthorized('Invalid or expired token'),
    }
  }

  return {
    user: { id: user.id, email: user.email },
    supabaseClient: supabase,
  }
}
