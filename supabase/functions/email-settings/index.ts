// supabase/functions/email-settings/index.ts
// Email settings management

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, unauthorized, serverError } from '../shared/errors.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200, headers: corsHeaders })
  }

  try {
    const auth = await validateRequest(req)
    if (auth.error) return auth.error

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Verify admin
    const { data: profile } = await supabaseAdmin
      .from('user_profiles')
      .select('role')
      .eq('auth_user_id', auth.user.id)
      .single()

    if (!profile || !['admin', 'super_admin'].includes(profile.role)) {
      return unauthorized('Admin access required')
    }

    switch (req.method) {
      case 'GET': {
        const { data, error } = await supabaseAdmin
          .from('email_settings')
          .select('*')
          .order('setting_key')

        if (error) return serverError(error.message)

        // Parse JSON values
        const settings = data.map(s => {
          let parsed = s.setting_value
          if (typeof parsed === 'string') {
            try { parsed = JSON.parse(parsed) } catch { /* keep as string */ }
          }
          return { ...s, setting_value: parsed }
        })

        return successResponse(settings)
      }

      case 'PUT': {
        const body = await req.json()
        const { settings } = body

        if (!settings || typeof settings !== 'object') {
          return badRequest('settings object is required')
        }

        const updates = []
        for (const [key, value] of Object.entries(settings)) {
          updates.push(
            supabaseAdmin
              .from('email_settings')
              .upsert({
                setting_key: key,
                setting_value: JSON.stringify(value),
                updated_by: null,
                updated_at: new Date().toISOString(),
              }, { onConflict: 'setting_key' })
          )
        }

        await Promise.all(updates)

        return successResponse(null, 'Settings updated successfully')
      }

      default:
        return badRequest('Method not allowed')
    }
  } catch (error) {
    console.error('email-settings error:', error)
    return serverError(error instanceof Error ? error.message : 'Unknown error')
  }
})
