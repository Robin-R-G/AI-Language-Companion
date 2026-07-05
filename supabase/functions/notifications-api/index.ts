// supabase/functions/notifications-api/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, notFound, serverError, noContentResponse } from '../shared/errors.ts'
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
    const path = url.pathname.replace(/^\/notifications-api/, '')
    const pathParts = path.split('/').filter(Boolean)

    // GET /notifications - List user notifications
    if (req.method === 'GET' && pathParts.length === 1 && pathParts[0] === 'notifications') {
      const unreadOnly = url.searchParams.get('unread_only') === 'true'
      const limit = parseInt(url.searchParams.get('limit') || '50')
      const offset = parseInt(url.searchParams.get('offset') || '0')

      let query = supabase
        .from('notifications')
        .select('*', { count: 'exact' })
        .eq('user_id', userId)

      if (unreadOnly) {
        query = query.is('read_at', null)
      }

      const { data: notifications, error, count } = await query
        .order('sent_at', { ascending: false })
        .range(offset, offset + limit - 1)

      if (error) {
        console.error('Failed to fetch notifications:', error)
        return serverError('Failed to fetch notifications')
      }

      const { count: unreadCount } = await supabase
        .from('notifications')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', userId)
        .is('read_at', null)

      return successResponse(
        {
          items: notifications || [],
          unread_count: unreadCount || 0,
          total: count || 0,
          limit,
          offset,
        },
        'Notifications retrieved successfully',
      )
    }

    // PUT /notifications/read - Mark notifications as read
    if (req.method === 'PUT' && pathParts.length === 2 && pathParts[0] === 'notifications' && pathParts[1] === 'read') {
      const body = await req.json()
      const { notification_ids, mark_all } = body

      if (!mark_all && (!notification_ids || !Array.isArray(notification_ids) || notification_ids.length === 0)) {
        return badRequest('Provide notification_ids array or set mark_all to true')
      }

      let query = supabase
        .from('notifications')
        .update({ read_at: new Date().toISOString() })
        .eq('user_id', userId)
        .is('read_at', null)

      if (!mark_all) {
        query = query.in('id', notification_ids)
      }

      const { error, count } = await query

      if (error) {
        console.error('Failed to mark notifications as read:', error)
        return serverError('Failed to update notifications')
      }

      return successResponse(
        { updated: count || 0 },
        'Notifications marked as read successfully',
      )
    }

    // DELETE /notifications/{id} - Delete a notification
    if (req.method === 'DELETE' && pathParts.length === 2 && pathParts[0] === 'notifications') {
      const notificationId = pathParts[1]

      const { error, count } = await supabase
        .from('notifications')
        .delete()
        .eq('id', notificationId)
        .eq('user_id', userId)

      if (error) {
        console.error('Failed to delete notification:', error)
        return serverError('Failed to delete notification')
      }

      if (!count) {
        return notFound('Notification not found')
      }

      return noContentResponse()
    }

    return badRequest('Route not found')
  } catch (error) {
    console.error('Notifications API error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
