// supabase/functions/email-triggers/index.ts
// Email trigger functions - called by database webhooks and cron jobs
// Sends transactional emails based on system events

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { corsHeaders } from '../shared/cors.ts'
import { successResponse, badRequest, serverError } from '../shared/errors.ts'
import { sendTemplateEmail } from '../shared/email.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface TriggerRequest {
  trigger: string
  user_id?: string
  data?: Record<string, string | number | boolean>
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200, headers: corsHeaders })
  }

  // Only allow POST
  if (req.method !== 'POST') {
    return badRequest('Method not allowed')
  }

  try {
    // Service role for internal triggers
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const body: TriggerRequest = await req.json()

    if (!body.trigger) {
      return badRequest('trigger is required')
    }

    // Look up user profile if user_id provided
    let userProfile: Record<string, unknown> | null = null
    if (body.user_id) {
      const { data } = await supabaseAdmin
        .from('user_profiles')
        .select('*')
        .eq('id', body.user_id)
        .single()
      userProfile = data
    }

    const vars: Record<string, string | number | boolean> = {
      app_name: 'AI Language Coach',
      support_email: 'support@ailanguagecoach.com',
      website_url: 'https://ailanguagecoach.com',
      ...body.data,
    }

    if (userProfile) {
      vars.user_name = (userProfile.full_name as string) || 'Learner'
      vars.user_email = (userProfile.email as string) || ''
      vars.target_language = (userProfile.target_language as string) || 'English'
      vars.proficiency_level = (userProfile.proficiency_level as string) || 'Beginner'
    }

    let templateSlug = ''
    let recipientEmail = ''
    let recipientName = ''

    switch (body.trigger) {
      // ─── Student Triggers ────────────────────────
      case 'welcome':
        templateSlug = 'student-welcome'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        break

      case 'premium_activated':
        templateSlug = 'student-premium-activated'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.plan_name = (body.data?.plan_name as string) || 'Premium'
        vars.expires_at = (body.data?.expires_at as string) || ''
        break

      case 'premium_expiring':
        templateSlug = 'student-premium-expiring'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.days_remaining = (body.data?.days_remaining as string) || '3'
        vars.expires_at = (body.data?.expires_at as string) || ''
        break

      case 'manual_payment_received':
        templateSlug = 'student-manual-payment-received'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.amount = (body.data?.amount as string) || '0'
        vars.payment_method = (body.data?.payment_method as string) || ''
        vars.utr_number = (body.data?.utr_number as string) || ''
        break

      case 'manual_payment_approved':
        templateSlug = 'student-manual-payment-approved'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.amount = (body.data?.amount as string) || '0'
        vars.plan_name = (body.data?.plan_name as string) || ''
        break

      case 'manual_payment_rejected':
        templateSlug = 'student-manual-payment-rejected'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.amount = (body.data?.amount as string) || '0'
        vars.rejection_reason = (body.data?.rejection_reason as string) || ''
        break

      case 'wallet_credits_added':
        templateSlug = 'student-wallet-credits-added'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.credits_added = (body.data?.credits_added as string) || '0'
        vars.new_balance = (body.data?.new_balance as string) || '0'
        vars.reason = (body.data?.reason as string) || ''
        break

      case 'ai_credits_low':
        templateSlug = 'student-ai-credits-low'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.credits_remaining = (body.data?.credits_remaining as string) || '0'
        break

      case 'certificate_ready':
        templateSlug = 'student-certificate-ready'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.certificate_type = (body.data?.certificate_type as string) || ''
        vars.course_name = (body.data?.course_name as string) || ''
        break

      case 'weekly_summary':
        templateSlug = 'student-weekly-summary'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.lessons_completed = (body.data?.lessons_completed as string) || '0'
        vars.words_learned = (body.data?.words_learned as string) || '0'
        vars.xp_earned = (body.data?.xp_earned as string) || '0'
        vars.streak_days = (body.data?.streak_days as string) || '0'
        vars.minutes_practiced = (body.data?.minutes_practiced as string) || '0'
        break

      case 'referral_reward':
        templateSlug = 'student-referral-reward'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.referred_name = (body.data?.referred_name as string) || ''
        vars.credits_earned = (body.data?.credits_earned as string) || '0'
        break

      case 'achievement_unlocked':
        templateSlug = 'student-achievement-unlocked'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.achievement_name = (body.data?.achievement_name as string) || ''
        vars.xp_reward = (body.data?.xp_reward as string) || '0'
        break

      case 'booking_confirmation':
        templateSlug = 'student-booking-confirmation'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.tutor_name = (body.data?.tutor_name as string) || ''
        vars.booking_date = (body.data?.booking_date as string) || ''
        vars.booking_time = (body.data?.booking_time as string) || ''
        vars.meeting_link = (body.data?.meeting_link as string) || ''
        break

      case 'booking_reminder':
        templateSlug = 'student-booking-reminder'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.tutor_name = (body.data?.tutor_name as string) || ''
        vars.booking_date = (body.data?.booking_date as string) || ''
        vars.booking_time = (body.data?.booking_time as string) || ''
        vars.minutes_until = (body.data?.minutes_until as string) || '30'
        break

      case 'booking_cancelled':
        templateSlug = 'student-booking-cancelled'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.tutor_name = (body.data?.tutor_name as string) || ''
        vars.booking_date = (body.data?.booking_date as string) || ''
        vars.cancellation_reason = (body.data?.cancellation_reason as string) || ''
        break

      case 'tutor_assigned':
        templateSlug = 'student-tutor-assigned'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.tutor_name = (body.data?.tutor_name as string) || ''
        break

      case 'new_message':
        templateSlug = 'student-new-message'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.sender_name = (body.data?.sender_name as string) || ''
        vars.message_preview = (body.data?.message_preview as string) || ''
        break

      case 'security_alert':
        templateSlug = 'student-security-alert'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.event_type = (body.data?.event_type as string) || ''
        vars.ip_address = (body.data?.ip_address as string) || ''
        vars.device_info = (body.data?.device_info as string) || ''
        break

      case 'account_deleted':
        templateSlug = 'student-account-deleted'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        break

      // ─── Tutor Triggers ──────────────────────────
      case 'tutor_application_received':
        templateSlug = 'tutor-application-received'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        break

      case 'tutor_approved':
        templateSlug = 'tutor-approved'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        break

      case 'tutor_rejected':
        templateSlug = 'tutor-rejected'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.rejection_reason = (body.data?.rejection_reason as string) || ''
        break

      case 'tutor_booking_request':
        templateSlug = 'tutor-booking-request'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.student_name = (body.data?.student_name as string) || ''
        vars.booking_date = (body.data?.booking_date as string) || ''
        vars.booking_time = (body.data?.booking_time as string) || ''
        vars.subject = (body.data?.subject as string) || ''
        break

      case 'tutor_booking_cancelled':
        templateSlug = 'tutor-booking-cancelled'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.student_name = (body.data?.student_name as string) || ''
        vars.booking_date = (body.data?.booking_date as string) || ''
        vars.cancellation_reason = (body.data?.cancellation_reason as string) || ''
        break

      case 'tutor_payment_processed':
        templateSlug = 'tutor-payment-processed'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.amount = (body.data?.amount as string) || '0'
        vars.period = (body.data?.period as string) || ''
        break

      case 'tutor_monthly_earnings':
        templateSlug = 'tutor-monthly-earnings'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.month = (body.data?.month as string) || ''
        vars.total_earnings = (body.data?.total_earnings as string) || '0'
        vars.total_sessions = (body.data?.total_sessions as string) || '0'
        vars.avg_rating = (body.data?.avg_rating as string) || '0'
        break

      case 'tutor_new_review':
        templateSlug = 'tutor-new-review'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.student_name = (body.data?.student_name as string) || ''
        vars.rating = (body.data?.rating as string) || '0'
        vars.review_text = (body.data?.review_text as string) || ''
        break

      case 'tutor_account_suspended':
        templateSlug = 'tutor-account-suspended'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.suspension_reason = (body.data?.suspension_reason as string) || ''
        break

      case 'tutor_verification_approved':
        templateSlug = 'tutor-verification-approved'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        break

      case 'tutor_verification_rejected':
        templateSlug = 'tutor-verification-rejected'
        recipientEmail = vars.user_email as string || ''
        recipientName = vars.user_name as string || ''
        vars.rejection_reason = (body.data?.rejection_reason as string) || ''
        break

      // ─── Admin Triggers ──────────────────────────
      case 'admin_new_purchase':
        templateSlug = 'admin-new-purchase'
        recipientEmail = vars.admin_email as string || ''
        recipientName = vars.admin_name as string || ''
        vars.user_name = (body.data?.user_name as string) || ''
        vars.plan_name = (body.data?.plan_name as string) || ''
        vars.amount = (body.data?.amount as string) || '0'
        break

      case 'admin_manual_payment_pending':
        templateSlug = 'admin-manual-payment-pending'
        recipientEmail = vars.admin_email as string || ''
        recipientName = vars.admin_name as string || ''
        vars.user_name = (body.data?.user_name as string) || ''
        vars.amount = (body.data?.amount as string) || '0'
        vars.payment_method = (body.data?.payment_method as string) || ''
        vars.utr_number = (body.data?.utr_number as string) || ''
        break

      case 'admin_fraud_alert':
        templateSlug = 'admin-fraud-alert'
        recipientEmail = vars.admin_email as string || ''
        recipientName = vars.admin_name as string || ''
        vars.user_name = (body.data?.user_name as string) || ''
        vars.alert_type = (body.data?.alert_type as string) || ''
        vars.details = (body.data?.details as string) || ''
        break

      case 'admin_tutor_waiting':
        templateSlug = 'admin-tutor-waiting'
        recipientEmail = vars.admin_email as string || ''
        recipientName = vars.admin_name as string || ''
        vars.tutor_name = (body.data?.tutor_name as string) || ''
        vars.application_date = (body.data?.application_date as string) || ''
        break

      case 'admin_critical_error':
        templateSlug = 'admin-critical-error'
        recipientEmail = vars.admin_email as string || ''
        recipientName = vars.admin_name as string || ''
        vars.error_type = (body.data?.error_type as string) || ''
        vars.error_message = (body.data?.error_message as string) || ''
        vars.service = (body.data?.service as string) || ''
        break

      case 'admin_daily_report':
        templateSlug = 'admin-daily-report'
        recipientEmail = vars.admin_email as string || ''
        recipientName = vars.admin_name as string || ''
        vars.date = (body.data?.date as string) || ''
        vars.new_users = (body.data?.new_users as string) || '0'
        vars.active_users = (body.data?.active_users as string) || '0'
        vars.revenue = (body.data?.revenue as string) || '0'
        vars.ai_cost = (body.data?.ai_cost as string) || '0'
        vars.emails_sent = (body.data?.emails_sent as string) || '0'
        break

      default:
        return badRequest(`Unknown trigger: ${body.trigger}`)
    }

    if (!templateSlug || !recipientEmail) {
      return badRequest('Could not determine template or recipient')
    }

    const result = await sendTemplateEmail(
      supabaseAdmin,
      templateSlug,
      recipientEmail,
      recipientName,
      vars,
      { relatedUserId: body.user_id }
    )

    if (result.success) {
      return successResponse({ message_id: result.messageId }, 'Email triggered successfully')
    } else {
      return serverError(`Failed to send email: ${result.error}`)
    }
  } catch (error) {
    console.error('email-triggers error:', error)
    return serverError(error instanceof Error ? error.message : 'Unknown error')
  }
})
