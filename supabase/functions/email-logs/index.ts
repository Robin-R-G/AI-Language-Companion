// supabase/functions/email-logs/index.ts
// Email log querying and management

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

    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(Boolean)
    const logId = pathParts.length > 1 ? pathParts[pathParts.length - 1] : null

    // Stats endpoint
    if (url.searchParams.has('stats')) {
      const days = parseInt(url.searchParams.get('days') || '30')
      const { data, error } = await supabaseAdmin.rpc('get_email_stats', { p_days: days })
      if (error) return serverError(error.message)
      return successResponse(data)
    }

    switch (req.method) {
      case 'GET': {
        if (logId && logId !== 'email-logs') {
          const { data, error } = await supabaseAdmin
            .from('email_logs')
            .select('*, email_templates(name, slug, category)')
            .eq('id', logId)
            .single()

          if (error || !data) return badRequest('Log not found')
          return successResponse(data)
        }

        // List logs with filters
        const status = url.searchParams.get('status')
        const template = url.searchParams.get('template')
        const recipient = url.searchParams.get('recipient')
        const search = url.searchParams.get('search')
        const limit = parseInt(url.searchParams.get('limit') || '50')
        const offset = parseInt(url.searchParams.get('offset') || '0')
        const fromDate = url.searchParams.get('from')
        const toDate = url.searchParams.get('to')

        let query = supabaseAdmin
          .from('email_logs')
          .select('*, email_templates(name, slug, category)', { count: 'exact' })
          .order('created_at', { ascending: false })
          .range(offset, offset + limit - 1)

        if (status) query = query.eq('status', status)
        if (template) query = query.eq('template_slug', template)
        if (recipient) query = query.ilike('recipient_email', `%${recipient}%`)
        if (search) {
          query = query.or(`recipient_email.ilike.%${search}%,subject.ilike.%${search}%,recipient_name.ilike.%${search}%`)
        }
        if (fromDate) query = query.gte('created_at', fromDate)
        if (toDate) query = query.lte('created_at', toDate)

        const { data, error, count } = await query
        if (error) return serverError(error.message)

        return successResponse(data, 'Logs retrieved', { total: count, limit, offset })
      }

      case 'POST': {
        // Resend a failed email
        const body = await req.json()
        const { log_id } = body

        if (!log_id) return badRequest('log_id is required')

        const { data: log, error: logError } = await supabaseAdmin
          .from('email_logs')
          .select('*')
          .eq('id', log_id)
          .single()

        if (logError || !log) return badRequest('Email log not found')

        if (log.status !== 'failed') {
          return badRequest('Only failed emails can be resent')
        }

        // Reset status and requeue
        await supabaseAdmin
          .from('email_logs')
          .update({ status: 'queued', retry_count: 0, failure_reason: null })
          .eq('id', log_id)

        await supabaseAdmin
          .from('email_queue')
          .insert({
            email_log_id: log_id,
            priority: 1,
            scheduled_at: new Date().toISOString(),
            status: 'pending',
            attempts: 0,
          })

        return successResponse({ log_id }, 'Email queued for resending')
      }

      default:
        return badRequest('Method not allowed')
    }
  } catch (error) {
    console.error('email-logs error:', error)
    return serverError(error instanceof Error ? error.message : 'Unknown error')
  }
})
