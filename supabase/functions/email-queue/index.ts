// supabase/functions/email-queue/index.ts
// Email queue processor - processes pending emails and handles retries

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, unauthorized, serverError } from '../shared/errors.ts'
import { sendEmail, replaceVariables, wrapEmailTemplate, type EmailOptions } from '../shared/email.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200, headers: corsHeaders })
  }

  try {
    // Use service role for queue processing
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const url = new URL(req.url)
    const action = url.searchParams.get('action') || 'process'

    switch (action) {
      case 'process': {
        // Check if queue is enabled
        const { data: settingData } = await supabaseAdmin
          .from('email_settings')
          .select('setting_value')
          .eq('setting_key', 'queue_enabled')
          .single()

        if (settingData) {
          const enabled = typeof settingData.setting_value === 'string'
            ? JSON.parse(settingData.setting_value)
            : settingData.setting_value
          if (enabled === false) {
            return successResponse({ message: 'Queue processing is disabled', processed: 0 })
          }
        }

        // Fetch pending items (up to 10 at a time)
        const { data: pendingItems, error: fetchError } = await supabaseAdmin
          .from('email_queue')
          .select('*, email_logs(*)')
          .eq('status', 'pending')
          .lte('scheduled_at', new Date().toISOString())
          .order('priority', { ascending: false })
          .order('scheduled_at', { ascending: true })
          .limit(10)

        if (fetchError) return serverError(fetchError.message)
        if (!pendingItems || pendingItems.length === 0) {
          return successResponse({ message: 'No pending emails', processed: 0 })
        }

        let processed = 0
        let failed = 0

        for (const item of pendingItems) {
          const log = item.email_logs
          if (!log) {
            // Orphaned queue entry
            await supabaseAdmin.from('email_queue').delete().eq('id', item.id)
            continue
          }

          // Mark as processing
          await supabaseAdmin
            .from('email_queue')
            .update({ status: 'processing', started_at: new Date().toISOString() })
            .eq('id', item.id)

          await supabaseAdmin
            .from('email_logs')
            .update({ status: 'sending' })
            .eq('id', log.id)

          try {
            // Fetch template if available
            let html = ''
            let text = ''
            let subject = log.subject

            if (log.template_slug) {
              const { data: template } = await supabaseAdmin
                .from('email_templates')
                .select('html_body, text_body, subject')
                .eq('slug', log.template_slug)
                .single()

              if (template) {
                const variables = typeof log.metadata === 'string' ? JSON.parse(log.metadata) : (log.metadata || {})
                subject = replaceVariables(template.subject, variables)
                html = wrapEmailTemplate(replaceVariables(template.html_body, variables))
                text = template.text_body ? replaceVariables(template.text_body, variables) : ''
              }
            }

            if (!html) {
              // Fallback - log as failed
              await supabaseAdmin.rpc('mark_email_failed', {
                p_log_id: log.id,
                p_error_message: 'Template not found or empty',
                p_error_code: 'TEMPLATE_MISSING'
              })
              failed++
              continue
            }

            // Send via Resend
            const result = await sendEmail({
              to: log.recipient_email,
              subject,
              html,
              text: text || undefined,
              tags: [{ name: 'queue_id', value: item.id }],
            })

            if (result.success) {
              await supabaseAdmin.rpc('mark_email_sent', {
                p_log_id: log.id,
                p_provider_message_id: result.messageId || '',
              })
              processed++
            } else {
              await supabaseAdmin.rpc('mark_email_failed', {
                p_log_id: log.id,
                p_error_message: result.error || 'Send failed',
                p_error_code: result.errorCode || 'SEND_FAILED',
              })
              failed++
            }
          } catch (error) {
            await supabaseAdmin.rpc('mark_email_failed', {
              p_log_id: log.id,
              p_error_message: error instanceof Error ? error.message : 'Unknown error',
              p_error_code: 'PROCESSING_ERROR',
            })
            failed++
          }
        }

        return successResponse({
          message: `Processed ${processed} emails, ${failed} failed`,
          processed,
          failed,
          total_pending: pendingItems.length,
        })
      }

      case 'retry-failed': {
        // Reset all failed emails for retry
        const { count, error } = await supabaseAdmin
          .from('email_queue')
          .update({ status: 'pending', scheduled_at: new Date().toISOString() })
          .eq('status', 'failed')
          .lt('attempts', 3)

        if (error) return serverError(error.message)
        return successResponse({ retried: count }, 'Failed emails queued for retry')
      }

      case 'cancel': {
        const body = await req.json()
        const { queue_ids } = body

        if (!queue_ids || !Array.isArray(queue_ids)) {
          return badRequest('queue_ids array is required')
        }

        const { error } = await supabaseAdmin
          .from('email_queue')
          .update({ status: 'cancelled' })
          .in('id', queue_ids)
          .eq('status', 'pending')

        if (error) return serverError(error.message)
        return successResponse({ cancelled: queue_ids.length }, 'Queue items cancelled')
      }

      case 'status': {
        const { data: stats, error: statsError } = await supabaseAdmin
          .from('email_queue')
          .select('status')
          .then(({ data, error }) => {
            if (error || !data) return { data: null, error }
            const counts: Record<string, number> = {}
            for (const item of data) {
              counts[item.status] = (counts[item.status] || 0) + 1
            }
            return { data: counts, error: null }
          })

        if (statsError) return serverError(statsError.message)
        return successResponse(stats)
      }

      default:
        return badRequest('Invalid action. Use: process, retry-failed, cancel, or status')
    }
  } catch (error) {
    console.error('email-queue error:', error)
    return serverError(error instanceof Error ? error.message : 'Unknown error')
  }
})
