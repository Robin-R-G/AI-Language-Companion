-- Migration: 20260708100000_system_settings_and_upi.sql
-- Creates system_settings table for key-value config and seeds UPI payment defaults

-- ─── System Settings (key-value store) ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.system_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

-- Admin can read all settings
DROP POLICY IF EXISTS "Admins can read system_settings" ON public.system_settings;
CREATE POLICY "Admins can read system_settings"
  ON public.system_settings FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid()
        AND role IN ('admin', 'super_admin')
    )
  );

-- Admin can upsert settings
DROP POLICY IF EXISTS "Admins can upsert system_settings" ON public.system_settings;
CREATE POLICY "Admins can upsert system_settings"
  ON public.system_settings FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid()
        AND role IN ('admin', 'super_admin')
    )
  );

-- ─── Seed default settings ─────────────────────────────────────────────────
INSERT INTO public.system_settings (key, value) VALUES
  ('app_name',               'AI Language Coach'),
  ('support_email',          ''),
  ('timezone',               'UTC'),
  ('stripe_publishable_key', ''),
  ('stripe_secret_key',      ''),
  ('paypal_client_id',       ''),
  ('upi_id',                 'metherobin@oksbi'),
  ('upi_enabled',            'true'),
  ('wallet_enabled',         'true'),
  ('wallet_signup_bonus',    '50'),
  ('wallet_referral_bonus',  '25'),
  ('wallet_daily_bonus',     '5'),
  ('credit_grammar_check',   '2'),
  ('credit_translation',     '3'),
  ('credit_ai_chat',         '1'),
  ('referrals_enabled',      'true'),
  ('referral_reward_amount', '5'),
  ('max_referrals_per_user', '10'),
  ('maintenance_mode',       'false'),
  ('voice_engine_active',    'true'),
  ('translations_active',    'true'),
  ('sub_only_assessments',   'false'),
  ('livekit_url',            'wss://livekit.ailanguagecoach.com'),
  ('revenuecat_secret',      ''),
  ('ads_enabled',            'false'),
  ('ad_banner_price',        '0.50'),
  ('ad_interstitial_price',  '1.00'),
  ('tutor_commission_rate',  '20'),
  ('tutor_min_payout',       '50'),
  ('tutor_payout_schedule',  'weekly')
ON CONFLICT (key) DO NOTHING;

-- ─── Also ensure is_admin() includes 'admin' role ─────────────────────────
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE auth_user_id = auth.uid()
      AND role IN ('admin', 'super_admin')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Similarly update is_admin_check()
CREATE OR REPLACE FUNCTION public.is_admin_check()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE auth_user_id = auth.uid()
      AND role IN ('admin', 'super_admin')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
