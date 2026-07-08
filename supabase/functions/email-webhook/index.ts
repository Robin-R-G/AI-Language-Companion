// supabase/functions/email-webhook/index.ts
// Resend webhook handler for delivery status updates

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { corsHeaders } from '../shared/cors.ts'
import { successResponse, badRequest, serverError } from '../shared/errors.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface WebhookEvent {
  type: 'email.sent' | 'email.delivered' | 'email.opened' | 'email.clicked' | 'email.bounced' | 'email.complained'
  created_at: string
  data: {
    email_id: string
    from: string
    to: string[]
    subject: string
    created_at: string
  }
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200, headers: corsHeaders })
  }

  try {
    // Verify webhook signature (optional but recommended)
    const signature = req.headers.get('resend-signature')

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const event: WebhookEvent = await req.json()

    if (!event.type || !event.data) {
      return badRequest('Invalid webhook payload')
    }

    console.log(`Webhook received: ${event.type} for ${event.data.email_id}`)

    // Find the matching email log by provider_message_id
    const { data: log, error: findError } = await supabaseAdmin
      .from('email_logs')
      .select('id, status')
      .eq('provider_message_id', event.data.email_id)
      .single()

    if (findError || !log) {
      console.log(`No matching email log found for provider ID: ${event.data.email_id}`)
      return successResponse({ message: 'Webhook received but no matching log found' })
    }

    // Update status based on event type
    const statusMap: Record<string, string> = {
      'email.sent': 'sent',
      'email.delivered': 'delivered',
      'email.opened': 'opened',
      'email.clicked': 'clicked',
      'email.bounced': 'bounced',
      'email.complained': 'failed',
    }

    const updateData: Record<string, unknown> = {
      status: statusMap[event.type] || log.status,
      updated_at: new Date().toISOString(),
    }

    if (event.type === 'email.delivered') {
      updateData.delivered_at = event.created_at
    } else if (event.type === 'email.opened') {
      updateData.opened_at = event.created_at
    } else if (event.type === 'email.clicked') {
      updateData.clicked_at = event.created_at
    } else if (event.type === 'email.bounced' || event.type === 'email.complained') {
      updateData.failure_reason = `Webhook: ${event.type}`
    }

    const { error: updateError } = await supabaseAdmin
      .from('email_logs')
      .update(updateData)
      .eq('id', log.id)

    if (updateError) {
      console.error('Failed to update email log:', updateError)
      return serverError('Failed to update email status')
    }

    return successResponse({ message: 'Webhook processed', event_type: event.type })
  } catch (error) {
    console.error('email-webhook error:', error)
    return serverError(error instanceof Error ? error.message : 'Unknown error')
  }
})
