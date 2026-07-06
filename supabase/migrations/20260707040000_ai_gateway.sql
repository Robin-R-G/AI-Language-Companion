-- 20260707040000_ai_gateway.sql
-- AI usage tracking, cost monitoring, and provider configuration tables.

-- ── AI Providers (admin-configurable) ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ai_providers (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name            text NOT NULL UNIQUE, -- 'openai', 'anthropic', 'gemini', 'groq'
    display_name    text NOT NULL,
    is_enabled      boolean NOT NULL DEFAULT true,
    priority        int NOT NULL DEFAULT 1,  -- lower = preferred
    cost_per_input_token  numeric(20,12) NOT NULL DEFAULT 0,
    cost_per_output_token numeric(20,12) NOT NULL DEFAULT 0,
    config          jsonb DEFAULT '{}',      -- non-secret config
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

-- ── AI Usage Logs ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ai_usage (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    provider          text NOT NULL,
    feature           text NOT NULL, -- 'chat', 'grammar', 'writing', etc.
    language          text NOT NULL DEFAULT 'en',
    prompt_tokens     int NOT NULL DEFAULT 0,
    completion_tokens int NOT NULL DEFAULT 0,
    total_tokens      int NOT NULL DEFAULT 0,
    credits_used      int NOT NULL DEFAULT 1,
    cost_usd          numeric(20,12) NOT NULL DEFAULT 0,
    created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_ai_usage_user_id     ON public.ai_usage(user_id);
CREATE INDEX idx_ai_usage_provider    ON public.ai_usage(provider);
CREATE INDEX idx_ai_usage_feature     ON public.ai_usage(feature);
CREATE INDEX idx_ai_usage_created_at  ON public.ai_usage(created_at);

-- ── AI Cost Aggregates (materialized for dashboard) ──────────────────────────
CREATE TABLE IF NOT EXISTS public.ai_cost_daily (
    date           date NOT NULL,
    provider       text NOT NULL,
    feature        text NOT NULL,
    total_requests bigint NOT NULL DEFAULT 0,
    total_tokens   bigint NOT NULL DEFAULT 0,
    total_cost_usd numeric(20,6) NOT NULL DEFAULT 0,
    total_credits  bigint NOT NULL DEFAULT 0,
    PRIMARY KEY (date, provider, feature)
);

-- ── Live Sessions ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.live_sessions (
    id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tutor_id         uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    student_id       uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    room_name        text UNIQUE,
    scheduled_at     timestamptz NOT NULL,
    started_at       timestamptz,
    ended_at         timestamptz,
    duration_minutes int NOT NULL DEFAULT 60,
    subject          text NOT NULL DEFAULT 'General',
    status           text NOT NULL DEFAULT 'scheduled', -- scheduled, active, ended, cancelled
    recording_url    text,
    notes            text,
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_live_sessions_tutor_id    ON public.live_sessions(tutor_id);
CREATE INDEX idx_live_sessions_student_id  ON public.live_sessions(student_id);
CREATE INDEX idx_live_sessions_scheduled   ON public.live_sessions(scheduled_at);
CREATE INDEX idx_live_sessions_status      ON public.live_sessions(status);

-- ── Invoices ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.invoices (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    invoice_number  text NOT NULL UNIQUE,
    plan_id         text,
    type            text NOT NULL, -- subscription_new, subscription_renewal, credit_purchase, tutor_session
    amount          numeric(20,4) NOT NULL DEFAULT 0,
    currency        text NOT NULL DEFAULT 'USD',
    status          text NOT NULL DEFAULT 'paid', -- draft, pending, paid, refunded, void
    environment     text NOT NULL DEFAULT 'PRODUCTION', -- PRODUCTION, SANDBOX
    issued_at       timestamptz NOT NULL DEFAULT now(),
    due_at          timestamptz,
    paid_at         timestamptz,
    pdf_url         text,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_invoices_user_id ON public.invoices(user_id);

-- ── Subscription Audit Logs ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.subscription_audit_logs (
    id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          uuid REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    event_type       text NOT NULL,
    product_id       text NOT NULL,
    amount           numeric(20,4) DEFAULT 0,
    currency         text DEFAULT 'USD',
    credits_awarded  int DEFAULT 0,
    environment      text DEFAULT 'PRODUCTION',
    raw_event        jsonb DEFAULT '{}',
    created_at       timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_sub_audit_user_id    ON public.subscription_audit_logs(user_id);
CREATE INDEX idx_sub_audit_event_type ON public.subscription_audit_logs(event_type);
CREATE INDEX idx_sub_audit_created_at ON public.subscription_audit_logs(created_at);

-- ── Feature Flags ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.feature_flags (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    key         text NOT NULL UNIQUE,
    description text,
    is_enabled  boolean NOT NULL DEFAULT false,
    rollout_pct int NOT NULL DEFAULT 0,     -- 0-100% gradual rollout
    target_roles text[] DEFAULT '{}',       -- empty = all roles
    config      jsonb DEFAULT '{}',
    updated_by  uuid REFERENCES public.user_profiles(id),
    updated_at  timestamptz NOT NULL DEFAULT now()
);

-- Default feature flags
INSERT INTO public.feature_flags (key, description, is_enabled, rollout_pct) VALUES
  ('live_classes', 'Enable live tutoring sessions via LiveKit', true, 100),
  ('ai_streaming', 'Enable streaming AI responses', true, 100),
  ('razorpay_payments', 'Enable Razorpay payment gateway', true, 100),
  ('stripe_payments', 'Enable Stripe payment gateway', true, 100),
  ('referral_program', 'Enable referral rewards program', true, 100),
  ('affiliate_marketplace', 'Enable affiliate marketplace', true, 100),
  ('certificate_generation', 'Enable digital certificates', true, 100),
  ('multi_tenant', 'Enable multi-tenant features', false, 0),
  ('mfa_required_for_staff', 'Require MFA for all staff accounts', false, 0),
  ('ai_evaluation_beta', 'Beta AI evaluation features', false, 20)
ON CONFLICT (key) DO NOTHING;

-- ── RLS Policies ─────────────────────────────────────────────────────────────

ALTER TABLE public.ai_usage ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own AI usage"
    ON public.ai_usage FOR SELECT
    USING (auth.uid() = user_id);
CREATE POLICY "Service role can insert AI usage"
    ON public.ai_usage FOR INSERT
    WITH CHECK (true);

ALTER TABLE public.live_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Session participants can view sessions"
    ON public.live_sessions FOR SELECT
    USING (auth.uid() = tutor_id OR auth.uid() = student_id);
CREATE POLICY "Tutors can create sessions"
    ON public.live_sessions FOR INSERT
    WITH CHECK (auth.uid() = tutor_id);
CREATE POLICY "Service role full access to live_sessions"
    ON public.live_sessions FOR ALL
    USING (true);

ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own invoices"
    ON public.invoices FOR SELECT
    USING (auth.uid() = user_id);

ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read feature flags"
    ON public.feature_flags FOR SELECT
    USING (true);
CREATE POLICY "Only super admin can modify feature flags"
    ON public.feature_flags FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );

-- ── Stored function: deduct AI credits ───────────────────────────────────────
CREATE OR REPLACE FUNCTION public.deduct_ai_credits(
    p_user_id uuid,
    p_credits int,
    p_source text DEFAULT 'ai_usage',
    p_description text DEFAULT ''
) RETURNS void AS $$
BEGIN
    UPDATE public.wallets
    SET ai_credits = GREATEST(0, ai_credits - p_credits),
        updated_at = now()
    WHERE user_id = p_user_id;

    INSERT INTO public.wallet_transactions(
        user_id, amount, type, source, description, created_at
    ) VALUES (
        p_user_id, -p_credits, 'debit', p_source, p_description, now()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── Stored function: add AI credits ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.add_ai_credits(
    p_user_id uuid,
    p_credits int,
    p_source text DEFAULT 'manual',
    p_description text DEFAULT ''
) RETURNS void AS $$
BEGIN
    INSERT INTO public.wallets (user_id, ai_credits, updated_at)
    VALUES (p_user_id, p_credits, now())
    ON CONFLICT (user_id)
    DO UPDATE SET
        ai_credits = public.wallets.ai_credits + p_credits,
        updated_at = now();

    INSERT INTO public.wallet_transactions(
        user_id, amount, type, source, description, created_at
    ) VALUES (
        p_user_id, p_credits, 'credit', p_source, p_description, now()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── Aggregation job (called by cron or webhook) ───────────────────────────────
CREATE OR REPLACE FUNCTION public.refresh_revenue_aggregates() RETURNS void AS $$
BEGIN
    -- Update AI cost daily aggregate for today
    INSERT INTO public.ai_cost_daily (date, provider, feature, total_requests, total_tokens, total_cost_usd, total_credits)
    SELECT
        DATE(created_at),
        provider,
        feature,
        COUNT(*) AS total_requests,
        SUM(total_tokens) AS total_tokens,
        SUM(cost_usd) AS total_cost_usd,
        SUM(credits_used) AS total_credits
    FROM public.ai_usage
    WHERE DATE(created_at) = CURRENT_DATE
    GROUP BY DATE(created_at), provider, feature
    ON CONFLICT (date, provider, feature) DO UPDATE SET
        total_requests = EXCLUDED.total_requests,
        total_tokens   = EXCLUDED.total_tokens,
        total_cost_usd = EXCLUDED.total_cost_usd,
        total_credits  = EXCLUDED.total_credits;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
