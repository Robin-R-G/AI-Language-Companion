// supabase/functions/shared/email.ts
// Resend Email Service Integration

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

export interface EmailOptions {
  from?: string
  to: string | string[]
  cc?: string[]
  bcc?: string[]
  subject: string
  html?: string
  text?: string
  reply_to?: string
  attachments?: EmailAttachment[]
  tags?: { name: string; value: string }[]
}

export interface EmailAttachment {
  filename: string
  content: string // base64 encoded
  contentType?: string
}

export interface EmailSendResult {
  success: boolean
  messageId?: string
  error?: string
  errorCode?: string
}

export interface TemplateVariables {
  [key: string]: string | number | boolean | undefined
}

// ─── Branding Constants ──────────────────────────────
export const BRAND = {
  name: 'AI Language Coach',
  primaryColor: '#2563eb',
  secondaryColor: '#7c3aed',
  accentColor: '#14b8a6',
  successColor: '#22c55e',
  warningColor: '#f59e0b',
  errorColor: '#ef4444',
  bgColor: '#f8fafc',
  textColor: '#1e293b',
  textSecondary: '#64748b',
  borderColor: '#e2e8f0',
  logoUrl: 'https://ailanguagecoach.com/logo.png',
  supportEmail: 'support@ailanguagecoach.com',
  privacyUrl: 'https://ailanguagecoach.com/privacy',
  termsUrl: 'https://ailanguagecoach.com/terms',
  websiteUrl: 'https://ailanguagecoach.com',
}

// ─── Email Wrapper ───────────────────────────────────
export function wrapEmailTemplate(content: string, options?: { darkMode?: boolean }): string {
  const bg = options?.darkMode ? '#0f172a' : BRAND.bgColor
  const text = options?.darkMode ? '#f1f5f9' : BRAND.textColor
  const border = options?.darkMode ? '#334155' : BRAND.borderColor

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="color-scheme" content="light dark">
  <meta name="supported-color-schemes" content="light dark">
  <title>${BRAND.name}</title>
</head>
<body style="margin:0;padding:0;background-color:${bg};color:${text};font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:${bg};">
    <tr>
      <td align="center" style="padding:24px 16px;">
        <table role="presentation" width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%;">
          <!-- Header -->
          <tr>
            <td style="padding:24px 32px;background-color:#ffffff;border-radius:12px 12px 0 0;border-bottom:3px solid ${BRAND.primaryColor};">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <span style="font-size:24px;font-weight:700;color:${BRAND.primaryColor};letter-spacing:-0.5px;">${BRAND.name}</span>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:32px;background-color:#ffffff;">
              ${content}
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="padding:24px 32px;background-color:#f8fafc;border-radius:0 0 12px 12px;border-top:1px solid ${border};">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="font-size:12px;color:${BRAND.textSecondary};line-height:1.6;">
                    <p style="margin:0 0 8px 0;">${BRAND.name} &mdash; Your personalized language learning companion.</p>
                    <p style="margin:0 0 8px 0;">
                      <a href="${BRAND.privacyUrl}" style="color:${BRAND.primaryColor};text-decoration:none;">Privacy Policy</a>
                      &nbsp;&bull;&nbsp;
                      <a href="${BRAND.termsUrl}" style="color:${BRAND.primaryColor};text-decoration:none;">Terms of Service</a>
                      &nbsp;&bull;&nbsp;
                      <a href="mailto:${BRAND.supportEmail}" style="color:${BRAND.primaryColor};text-decoration:none;">Contact Support</a>
                    </p>
                    <p style="margin:0;font-size:11px;color:#94a3b8;">This is a transactional email. You received this because of activity on your account.</p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`
}

// ─── Variable Replacement ────────────────────────────
export function replaceVariables(template: string, variables: TemplateVariables): string {
  let result = template
  for (const [key, value] of Object.entries(variables)) {
    const regex = new RegExp(`{{\\s*${key}\\s*}}`, 'gi')
    result = result.replace(regex, String(value ?? ''))
  }
  return result
}

// ─── Send Email via Resend ───────────────────────────
export async function sendEmail(options: EmailOptions): Promise<EmailSendResult> {
  const resendApiKey = Deno.env.get('RESEND_API_KEY')

  if (!resendApiKey) {
    console.error('RESEND_API_KEY not configured')
    return { success: false, error: 'Email service not configured', errorCode: 'CONFIG_MISSING' }
  }

  const from = options.from || `${BRAND.name} <noreply@ailanguagecoach.com>`

  try {
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from,
        to: Array.isArray(options.to) ? options.to : [options.to],
        cc: options.cc,
        bcc: options.bcc,
        subject: options.subject,
        html: options.html,
        text: options.text,
        reply_to: options.reply_to,
        attachments: options.attachments,
        tags: options.tags,
      }),
    })

    const data = await response.json()

    if (!response.ok) {
      console.error('Resend API error:', data)
      return {
        success: false,
        error: data.message || 'Failed to send email',
        errorCode: data.name || 'SEND_FAILED',
      }
    }

    return {
      success: true,
      messageId: data.id,
    }
  } catch (error) {
    console.error('Email send error:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
      errorCode: 'NETWORK_ERROR',
    }
  }
}

// ─── Send Template Email ─────────────────────────────
export async function sendTemplateEmail(
  supabase: ReturnType<typeof createClient>,
  templateSlug: string,
  recipientEmail: string,
  recipientName: string,
  variables: TemplateVariables,
  options?: {
    relatedUserId?: string
    priority?: number
    scheduledAt?: string
    replyTo?: string
  }
): Promise<EmailSendResult> {
  // Fetch template
  const { data: template, error: templateError } = await supabase
    .from('email_templates')
    .select('*')
    .eq('slug', templateSlug)
    .eq('is_active', true)
    .single()

  if (templateError || !template) {
    console.error(`Template not found: ${templateSlug}`, templateError)
    return { success: false, error: `Template '${templateSlug}' not found or inactive`, errorCode: 'TEMPLATE_NOT_FOUND' }
  }

  // Replace variables in subject and body
  const subject = replaceVariables(template.subject, variables)
  const htmlBody = replaceVariables(template.html_body, variables)
  const textBody = template.text_body ? replaceVariables(template.text_body, variables) : undefined

  // Send via Resend
  const result = await sendEmail({
    to: recipientEmail,
    subject,
    html: htmlBody,
    text: textBody,
    reply_to: options?.replyTo,
    tags: [{ name: 'template', value: templateSlug }],
  })

  // Log the email
  const logData: Record<string, unknown> = {
    recipient_email: recipientEmail,
    recipient_name: recipientName,
    template_id: template.id,
    template_slug: templateSlug,
    subject,
    status: result.success ? 'sent' : 'failed',
    provider: 'resend',
    provider_message_id: result.messageId || null,
    sent_at: result.success ? new Date().toISOString() : null,
    failure_reason: result.error || null,
    related_user_id: options?.relatedUserId || null,
    metadata: JSON.stringify(variables),
  }

  await supabase.from('email_logs').insert(logData)

  return result
}

// ─── Get Email Settings ──────────────────────────────
export async function getEmailSetting(
  supabase: ReturnType<typeof createClient>,
  key: string
): Promise<string | null> {
  const { data } = await supabase
    .from('email_settings')
    .select('setting_value')
    .eq('setting_key', key)
    .single()

  if (!data) return null
  const val = data.setting_value
  if (typeof val === 'string') {
    try { return JSON.parse(val) } catch { return val }
  }
  return String(val)
}

// ─── HTML Sanitizer (basic) ──────────────────────────
export function sanitizeHtml(input: string): string {
  return input
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
    .replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, '')
    .replace(/on\w+="[^"]*"/gi, '')
    .replace(/on\w+='[^']*'/gi, '')
}
