// supabase/functions/notifications/index.ts
// Section 22: Notification APIs
// GET /notifications, PUT /notifications/read, DELETE /notifications/{id}
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import {
  successResponse,
  noContentResponse,
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
    const lastPart = pathParts[pathParts.length - 1]

    // GET /notifications - List notifications
    if (req.method === 'GET' && lastPart === 'notifications') {
      const page = parseInt(url.searchParams.get('page') || '1')
      const limit = parseInt(url.searchParams.get('limit') || '50')
      const unread_only = url.searchParams.get('unread_only') === 'true'

      let query = supabase
        .from('notifications')
        .select('*', { count: 'exact' })
        .eq('user_id', userId)

      if (unread_only) {
        query = query.eq('is_read', false)
      }

      const { data: notifications, error, count } = await query
        .order('created_at', { ascending: false })
        .range((page - 1) * limit, page * limit - 1)

      if (error) {
        console.error('Failed to fetch notifications:', error)
        return serverError('Failed to fetch notifications')
      }

      // Count unread
      const { count: unreadCount } = await supabase
        .from('notifications')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', userId)
        .eq('is_read', false)

      const total = count || 0
      return successResponse({
        notifications: notifications || [],
        unread_count: unreadCount || 0,
        pagination: {
          page,
          limit,
          total,
          total_pages: Math.ceil(total / limit),
        },
      }, 'Notifications retrieved.')
    }

    // PUT /notifications/read - Mark notifications as read
    if (req.method === 'PUT' && lastPart === 'read') {
      const body = await req.json()
      const { notification_ids, mark_all } = body

      let query = supabase
        .from('notifications')
        .update({ is_read: true })
        .eq('user_id', userId)

      if (mark_all) {
        // Mark all as read
        query = query.eq('is_read', false)
      } else if (notification_ids && Array.isArray(notification_ids)) {
        query = query.in('id', notification_ids)
      } else {
        return validationError('Provide notification_ids array or mark_all: true')
      }

      const { error } = await query

      if (error) {
        console.error('Failed to mark notifications as read:', error)
        return serverError('Failed to update notifications')
      }

      return successResponse(null, 'Notifications marked as read.')
    }

    // DELETE /notifications/{id} - Delete notification
    if (req.method === 'DELETE' && lastPart !== 'notifications' && lastPart !== 'read') {
      const notificationId = lastPart

      const { error } = await supabase
        .from('notifications')
        .delete()
        .eq('id', notificationId)
        .eq('user_id', userId)

      if (error) {
        console.error('Failed to delete notification:', error)
        return serverError('Failed to delete notification')
      }

      return noContentResponse()
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Notifications error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
