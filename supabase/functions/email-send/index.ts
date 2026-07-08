// supabase/functions/email-send/index.ts
// Main email sending edge function - send emails via Resend
// Called by admin dashboard and internal triggers

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, unauthorized, serverError } from '../shared/errors.ts'
import { sendEmail, sendTemplateEmail, wrapEmailTemplate, replaceVariables, sanitizeHtml, type EmailOptions } from '../shared/email.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface SendEmailRequest {
  mode: 'direct' | 'template'
  // Direct mode
  to?: string | string[]
  subject?: string
  html?: string
  text?: string
  reply_to?: string
  cc?: string[]
  bcc?: string[]
  // Template mode
  template_slug?: string
  recipient_email?: string
  recipient_name?: string
  variables?: Record<string, string | number | boolean>
  // Common
  related_user_id?: string
  priority?: number
  scheduled_at?: string
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200, headers: corsHeaders })
  }

  try {
    // Validate auth
    const auth = await validateRequest(req)
    if (auth.error) return auth.error

    // Check admin role
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { data: profile } = await supabaseAdmin
      .from('user_profiles')
      .select('role')
      .eq('auth_user_id', auth.user.id)
      .single()

    if (!profile || !['admin', 'super_admin'].includes(profile.role)) {
      return unauthorized('Admin access required to send emails')
    }

    // Check if email is enabled
    const { data: settingData } = await supabaseAdmin
      .from('email_settings')
      .select('setting_value')
      .eq('setting_key', 'email_enabled')
      .single()

    if (settingData) {
      const enabled = typeof settingData.setting_value === 'string'
        ? JSON.parse(settingData.setting_value)
        : settingData.setting_value
      if (enabled === false) {
        return badRequest('Email sending is currently disabled')
      }
    }

    const body: SendEmailRequest = await req.json()

    if (!body.mode) {
      return badRequest('mode is required (direct or template)')
    }

    let result

    if (body.mode === 'template') {
      if (!body.template_slug || !body.recipient_email) {
        return badRequest('template_slug and recipient_email are required for template mode')
      }

      const variables = body.variables || {}
      variables.recipient_name = body.recipient_name || 'User'
      variables.app_name = 'AI Language Coach'
      variables.support_email = 'support@ailanguagecoach.com'

      result = await sendTemplateEmail(
        supabaseAdmin,
        body.template_slug,
        body.recipient_email,
        body.recipient_name || 'User',
        variables,
        {
          relatedUserId: body.related_user_id,
          priority: body.priority,
          scheduledAt: body.scheduled_at,
        }
      )
    } else if (body.mode === 'direct') {
      if (!body.to || !body.subject || !body.html) {
        return badRequest('to, subject, and html are required for direct mode')
      }

      result = await sendEmail({
        to: body.to,
        subject: body.subject,
        html: body.html,
        text: body.text,
        reply_to: body.reply_to,
        cc: body.cc,
        bcc: body.bcc,
      })

      // Log direct emails too
      const recipients = Array.isArray(body.to) ? body.to : [body.to]
      for (const email of recipients) {
        await supabaseAdmin.from('email_logs').insert({
          recipient_email: email,
          subject: body.subject,
          status: result.success ? 'sent' : 'failed',
          provider: 'resend',
          provider_message_id: result.messageId || null,
          sent_at: result.success ? new Date().toISOString() : null,
          failure_reason: result.error || null,
          related_user_id: body.related_user_id || null,
          metadata: JSON.stringify({ mode: 'direct' }),
        })
      }
    } else {
      return badRequest('Invalid mode. Must be "direct" or "template"')
    }

    if (result.success) {
      return successResponse({ message_id: result.messageId }, 'Email sent successfully')
    } else {
      return serverError(`Failed to send email: ${result.error}`)
    }
  } catch (error) {
    console.error('email-send error:', error)
    return serverError(error instanceof Error ? error.message : 'Unknown error')
  }
})
