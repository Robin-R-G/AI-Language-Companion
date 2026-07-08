-- =====================================================
-- TRANSACTIONAL EMAIL SYSTEM
-- Tables: email_templates, email_logs, email_queue,
--         email_failures, email_campaigns, email_settings
-- =====================================================

-- ─── Email Templates ─────────────────────────────────
CREATE TABLE IF NOT EXISTS email_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  category VARCHAR(50) NOT NULL CHECK (category IN ('student','tutor','admin','system')),
  subject TEXT NOT NULL,
  html_body TEXT NOT NULL,
  text_body TEXT,
  variables JSONB DEFAULT '[]'::jsonb,
  is_active BOOLEAN DEFAULT true,
  is_default BOOLEAN DEFAULT false,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_email_templates_slug ON email_templates(slug);
CREATE INDEX IF NOT EXISTS idx_email_templates_category ON email_templates(category);
CREATE INDEX IF NOT EXISTS idx_email_templates_active ON email_templates(is_active);

-- ─── Email Logs ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS email_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_email VARCHAR(255) NOT NULL,
  recipient_name TEXT,
  template_id UUID REFERENCES email_templates(id) ON DELETE SET NULL,
  template_slug VARCHAR(100),
  subject TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','queued','sending','sent','delivered','opened','clicked','failed','bounced')),
  provider VARCHAR(20) DEFAULT 'resend',
  provider_message_id VARCHAR(255),
  sent_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  opened_at TIMESTAMPTZ,
  clicked_at TIMESTAMPTZ,
  failure_reason TEXT,
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  related_user_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
  related_transaction_id TEXT,
  related_booking_id UUID,
  related_payment_id UUID,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_email_logs_recipient ON email_logs(recipient_email);
CREATE INDEX IF NOT EXISTS idx_email_logs_status ON email_logs(status);
CREATE INDEX IF NOT EXISTS idx_email_logs_template ON email_logs(template_id);
CREATE INDEX IF NOT EXISTS idx_email_logs_created ON email_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_email_logs_related_user ON email_logs(related_user_id);
CREATE INDEX IF NOT EXISTS idx_email_logs_provider_id ON email_logs(provider_message_id);

-- ─── Email Queue ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS email_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email_log_id UUID REFERENCES email_logs(id) ON DELETE CASCADE,
  priority INTEGER DEFAULT 5 CHECK (priority BETWEEN 1 AND 10),
  scheduled_at TIMESTAMPTZ DEFAULT now(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','processing','completed','failed','cancelled')),
  attempts INTEGER DEFAULT 0,
  max_attempts INTEGER DEFAULT 3,
  last_error TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_email_queue_status ON email_queue(status, scheduled_at);
CREATE INDEX IF NOT EXISTS idx_email_queue_priority ON email_queue(priority DESC, scheduled_at ASC);

-- ─── Email Failures ──────────────────────────────────
CREATE TABLE IF NOT EXISTS email_failures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email_log_id UUID REFERENCES email_logs(id) ON DELETE CASCADE,
  attempt_number INTEGER NOT NULL,
  error_code VARCHAR(50),
  error_message TEXT,
  error_details JSONB,
  failed_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_email_failures_log ON email_failures(email_log_id);

-- ─── Email Campaigns ─────────────────────────────────
CREATE TABLE IF NOT EXISTS email_campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(200) NOT NULL,
  template_id UUID REFERENCES email_templates(id) ON DELETE SET NULL,
  subject_override TEXT,
  target_audience VARCHAR(50) NOT NULL CHECK (target_audience IN ('all','students','tutors','premium','inactive','new','custom')),
  custom_recipients JSONB,
  status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','scheduled','sending','sent','cancelled','failed')),
  scheduled_at TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  total_recipients INTEGER DEFAULT 0,
  total_sent INTEGER DEFAULT 0,
  total_failed INTEGER DEFAULT 0,
  total_opened INTEGER DEFAULT 0,
  total_clicked INTEGER DEFAULT 0,
  created_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_email_campaigns_status ON email_campaigns(status);

-- ─── Email Settings ──────────────────────────────────
CREATE TABLE IF NOT EXISTS email_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value JSONB NOT NULL,
  description TEXT,
  updated_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Seed default email settings
INSERT INTO email_settings (setting_key, setting_value, description) VALUES
  ('sender_name', '"AI Language Coach"', 'Display name for outgoing emails'),
  ('sender_email', '"noreply@ailanguagecoach.com"', 'From email address'),
  ('reply_to_email', '"support@ailanguagecoach.com"', 'Reply-to email address'),
  ('brand_logo_url', '"https://ailanguagecoach.com/logo.png"', 'Brand logo URL for email headers'),
  ('brand_color', '"#2563eb"', 'Primary brand color (hex)'),
  ('footer_text', '"AI Language Coach - Your personalized language learning companion."', 'Email footer text'),
  ('privacy_policy_url', '"https://ailanguagecoach.com/privacy"', 'Privacy policy link'),
  ('terms_of_service_url', '"https://ailanguagecoach.com/terms"', 'Terms of service link'),
  ('support_email', '"support@ailanguagecoach.com"', 'Support contact email'),
  ('email_enabled', 'true', 'Global toggle for transactional emails'),
  ('queue_enabled', 'true', 'Enable/disable email queue processing'),
  ('max_retries', '3', 'Maximum retry attempts for failed emails'),
  ('rate_limit_per_minute', '50', 'Max emails per minute (provider rate limit)')
ON CONFLICT (setting_key) DO NOTHING;

-- ─── Email Unsubscribes ──────────────────────────────
CREATE TABLE IF NOT EXISTS email_unsubscribes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL,
  category VARCHAR(50) NOT NULL DEFAULT 'marketing',
  unsubscribed_at TIMESTAMPTZ DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_email_unsubscribes_email_cat ON email_unsubscribes(email, category);

-- ─── RLS Policies ────────────────────────────────────
ALTER TABLE email_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_failures ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_unsubscribes ENABLE ROW LEVEL SECURITY;

-- Admin full access on all email tables
CREATE POLICY "Admins have full access on email_templates"
  ON email_templates FOR ALL
  USING (public.is_admin_check());

CREATE POLICY "Admins have full access on email_logs"
  ON email_logs FOR ALL
  USING (public.is_admin_check());

CREATE POLICY "Admins have full access on email_queue"
  ON email_queue FOR ALL
  USING (public.is_admin_check());

CREATE POLICY "Admins have full access on email_failures"
  ON email_failures FOR ALL
  USING (public.is_admin_check());

CREATE POLICY "Admins have full access on email_campaigns"
  ON email_campaigns FOR ALL
  USING (public.is_admin_check());

CREATE POLICY "Admins have full access on email_settings"
  ON email_settings FOR ALL
  USING (public.is_admin_check());

CREATE POLICY "Admins have full access on email_unsubscribes"
  ON email_unsubscribes FOR ALL
  USING (public.is_admin_check());

-- Service role access (for edge functions)
CREATE POLICY "Service role manages email_queue"
  ON email_queue FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "Service role manages email_logs"
  ON email_logs FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "Service role manages email_failures"
  ON email_failures FOR ALL
  USING (auth.role() = 'service_role');

-- Users can view their own email logs
CREATE POLICY "Users can view own email logs"
  ON email_logs FOR SELECT
  USING (related_user_id IN (
    SELECT id FROM user_profiles WHERE auth_user_id = auth.uid()
  ));

-- Users can manage their own unsubscribes
CREATE POLICY "Users can view own unsubscribes"
  ON email_unsubscribes FOR SELECT
  USING (true);

CREATE POLICY "Users can insert own unsubscribes"
  ON email_unsubscribes FOR INSERT
  WITH CHECK (true);

-- ─── Helper Functions ────────────────────────────────

-- Function to queue an email for sending
CREATE OR REPLACE FUNCTION queue_email(
  p_recipient_email VARCHAR(255),
  p_recipient_name TEXT,
  p_template_slug VARCHAR(100),
  p_subject TEXT,
  p_variables JSONB DEFAULT '{}'::jsonb,
  p_related_user_id UUID DEFAULT NULL,
  p_priority INTEGER DEFAULT 5,
  p_scheduled_at TIMESTAMPTZ DEFAULT now()
) RETURNS UUID AS $$
DECLARE
  v_template_id UUID;
  v_log_id UUID;
  v_queue_id UUID;
BEGIN
  -- Check if email sending is enabled
  IF (SELECT setting_value::text::boolean FROM email_settings WHERE setting_key = 'email_enabled') = false THEN
    RETURN NULL;
  END IF;

  -- Look up template
  SELECT id INTO v_template_id FROM email_templates WHERE slug = p_template_slug AND is_active = true;

  -- Insert log entry
  INSERT INTO email_logs (
    recipient_email, recipient_name, template_id, template_slug,
    subject, status, related_user_id, metadata
  ) VALUES (
    p_recipient_email, p_recipient_name, v_template_id, p_template_slug,
    p_subject, 'queued', p_related_user_id, p_variables
  ) RETURNING id INTO v_log_id;

  -- Insert queue entry
  INSERT INTO email_queue (
    email_log_id, priority, scheduled_at, status
  ) VALUES (
    v_log_id, p_priority, p_scheduled_at, 'pending'
  ) RETURNING id INTO v_queue_id;

  RETURN v_queue_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to mark email as sent
CREATE OR REPLACE FUNCTION mark_email_sent(
  p_log_id UUID,
  p_provider_message_id TEXT
) RETURNS void AS $$
BEGIN
  UPDATE email_logs SET
    status = 'sent',
    provider_message_id = p_provider_message_id,
    sent_at = now(),
    updated_at = now()
  WHERE id = p_log_id;

  UPDATE email_queue SET
    status = 'completed',
    completed_at = now()
  WHERE email_log_id = p_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to mark email as failed
CREATE OR REPLACE FUNCTION mark_email_failed(
  p_log_id UUID,
  p_error_message TEXT,
  p_error_code TEXT DEFAULT NULL
) RETURNS void AS $$
DECLARE
  v_retry_count INTEGER;
  v_max_retries INTEGER;
BEGIN
  SELECT retry_count, max_retries INTO v_retry_count, v_max_retries
  FROM email_logs WHERE id = p_log_id;

  -- Log the failure
  INSERT INTO email_failures (email_log_id, attempt_number, error_code, error_message)
  VALUES (p_log_id, v_retry_count + 1, p_error_code, p_error_message);

  IF v_retry_count + 1 >= v_max_retries THEN
    -- Max retries reached, mark as failed
    UPDATE email_logs SET
      status = 'failed',
      failure_reason = p_error_message,
      retry_count = v_retry_count + 1,
      updated_at = now()
    WHERE id = p_log_id;

    UPDATE email_queue SET
      status = 'failed',
      last_error = p_error_message,
      attempts = v_retry_count + 1
    WHERE email_log_id = p_log_id;
  ELSE
    -- Schedule retry with exponential backoff
    UPDATE email_logs SET
      retry_count = v_retry_count + 1,
      updated_at = now()
    WHERE id = p_log_id;

    UPDATE email_queue SET
      status = 'pending',
      attempts = v_retry_count + 1,
      last_error = p_error_message,
      scheduled_at = now() + (interval '1 minute' * power(2, v_retry_count + 1))
    WHERE email_log_id = p_log_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get email statistics
CREATE OR REPLACE FUNCTION get_email_stats(
  p_days INTEGER DEFAULT 30
) RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'total_sent', (SELECT count(*) FROM email_logs WHERE status IN ('sent','delivered','opened','clicked') AND created_at > now() - (p_days || ' days')::interval),
    'total_failed', (SELECT count(*) FROM email_logs WHERE status = 'failed' AND created_at > now() - (p_days || ' days')::interval),
    'total_delivered', (SELECT count(*) FROM email_logs WHERE status IN ('delivered','opened','clicked') AND created_at > now() - (p_days || ' days')::interval),
    'total_opened', (SELECT count(*) FROM email_logs WHERE opened_at IS NOT NULL AND created_at > now() - (p_days || ' days')::interval),
    'total_clicked', (SELECT count(*) FROM email_logs WHERE clicked_at IS NOT NULL AND created_at > now() - (p_days || ' days')::interval),
    'total_bounced', (SELECT count(*) FROM email_logs WHERE status = 'bounced' AND created_at > now() - (p_days || ' days')::interval),
    'success_rate', CASE WHEN (SELECT count(*) FROM email_logs WHERE created_at > now() - (p_days || ' days')::interval) > 0
      THEN round((SELECT count(*)::numeric FROM email_logs WHERE status IN ('sent','delivered','opened','clicked') AND created_at > now() - (p_days || ' days')::interval) / (SELECT count(*)::numeric FROM email_logs WHERE created_at > now() - (p_days || ' days')::interval) * 100, 1)
      ELSE 0 END,
    'today_sent', (SELECT count(*) FROM email_logs WHERE status IN ('sent','delivered','opened','clicked') AND created_at > current_date),
    'week_sent', (SELECT count(*) FROM email_logs WHERE status IN ('sent','delivered','opened','clicked') AND created_at > current_date - interval '7 days'),
    'month_sent', (SELECT count(*) FROM email_logs WHERE status IN ('sent','delivered','opened','clicked') AND created_at > current_date - interval '30 days'),
    'queue_pending', (SELECT count(*) FROM email_queue WHERE status = 'pending'),
    'queue_processing', (SELECT count(*) FROM email_queue WHERE status = 'processing'),
    'avg_delivery_time_ms', (SELECT COALESCE(avg(extract(epoch from (delivered_at - sent_at)) * 1000), 0)::int FROM email_logs WHERE delivered_at IS NOT NULL AND sent_at IS NOT NULL AND created_at > now() - (p_days || ' days')::interval),
    'top_templates', (
      SELECT COALESCE(jsonb_agg(t), '[]'::jsonb) FROM (
        SELECT jsonb_build_object('template', template_slug, 'count', count(*)) as t
        FROM email_logs WHERE template_slug IS NOT NULL AND created_at > now() - (p_days || ' days')::interval
        GROUP BY template_slug ORDER BY count(*) DESC LIMIT 5
      ) sub
    ),
    'recent_failures', (
      SELECT COALESCE(jsonb_agg(f), '[]'::jsonb) FROM (
        SELECT jsonb_build_object('id', el.id, 'recipient', el.recipient_email, 'subject', el.subject, 'error', el.failure_reason, 'at', el.created_at) as f
        FROM email_logs el WHERE el.status = 'failed' AND el.created_at > now() - interval '7 days'
        ORDER BY el.created_at DESC LIMIT 10
      ) sub
    )
  ) INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Trigger: auto-update updated_at ─────────────────
CREATE OR REPLACE FUNCTION update_email_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_email_templates_updated
  BEFORE UPDATE ON email_templates
  FOR EACH ROW EXECUTE FUNCTION update_email_timestamp();

CREATE TRIGGER trg_email_logs_updated
  BEFORE UPDATE ON email_logs
  FOR EACH ROW EXECUTE FUNCTION update_email_timestamp();

CREATE TRIGGER trg_email_campaigns_updated
  BEFORE UPDATE ON email_campaigns
  FOR EACH ROW EXECUTE FUNCTION update_email_timestamp();

CREATE TRIGGER trg_email_settings_updated
  BEFORE UPDATE ON email_settings
  FOR EACH ROW EXECUTE FUNCTION update_email_timestamp();
