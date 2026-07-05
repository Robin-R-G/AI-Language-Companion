// supabase/functions/notifications/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, serverError } from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const authResult = await validateRequest(req)
  if (authResult.error) return authResult.error
  if (authResult.isPreflight) return authResult.response!

  const url = new URL(req.url)

  if (req.method === 'GET') {
    try {
      const supabase = authResult.supabaseClient
      const userId = authResult.user.id

      const { data: notifications } = await supabase
        .from('notifications')
        .select('*')
        .eq('user_id', userId)
        .order('sent_at', { ascending: false })
        .limit(50)

      return successResponse({ notifications: notifications || [] }, 'Notifications loaded')
    } catch (error) {
      return serverError(error.message || 'Internal server error')
    }
  }

  if (req.method === 'PUT') {
    try {
      const supabase = authResult.supabaseClient
      const userId = authResult.user.id
      const body = await req.json()

      if (!body.notification_id) {
        return badRequest('notification_id is required')
      }

      const updateData: any = {}
      if (body.read_at) updateData.read_at = body.read_at
      if (body.dismissed_at) updateData.dismissed_at = body.dismissed_at

      const { error } = await supabase
        .from('notifications')
        .update(updateData)
        .eq('id', body.notification_id)
        .eq('user_id', userId)

      if (error) return badRequest(error.message)

      return successResponse(null, 'Notification updated')
    } catch (error) {
      return serverError(error.message || 'Internal server error')
    }
  }

  return badRequest('Invalid method')
})
