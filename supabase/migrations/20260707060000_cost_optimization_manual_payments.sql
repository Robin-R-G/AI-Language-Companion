-- 20260707060000_cost_optimization_manual_payments.sql
-- Implement AI Caching, Payment Methods, Manual Payments queue, and Storage bucket configuration.

-- ── 1. AI Cache Table ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ai_cache (
    cache_key         text PRIMARY KEY, -- sha256(feature || ':' || language || ':' || prompt)
    feature           text NOT NULL,
    language          text NOT NULL,
    prompt            text NOT NULL,
    response_content  text NOT NULL,
    created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_cache_feature ON public.ai_cache(feature);

-- ── 2. Payment Methods Table ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.payment_methods (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    method_type   text UNIQUE NOT NULL CHECK (method_type IN ('upi', 'bank', 'card')),
    display_name  text NOT NULL,
    details       jsonb NOT NULL DEFAULT '{}'::jsonb,
    is_active     boolean NOT NULL DEFAULT true,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

-- ── 3. Manual Payments Table ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.manual_payments (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    plan_type         text NOT NULL,
    payment_method    text NOT NULL,
    utr_number        text UNIQUE NOT NULL,
    amount            numeric(20,4) NOT NULL,
    screenshot_url    text NOT NULL,
    payment_date      timestamptz NOT NULL,
    status            text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    rejection_reason  text,
    notes             text,
    verified_by       uuid REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    verified_at       timestamptz,
    created_at        timestamptz NOT NULL DEFAULT now(),
    updated_at        timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_manual_payments_user_id ON public.manual_payments(user_id);
CREATE INDEX IF NOT EXISTS idx_manual_payments_status  ON public.manual_payments(status);
CREATE INDEX IF NOT EXISTS idx_manual_payments_utr     ON public.manual_payments(utr_number);

-- ── 4. Seed Default Payment Details ──────────────────────────────────────────
INSERT INTO public.payment_methods (method_type, display_name, details, is_active) VALUES
  ('upi', 'UPI Payment', '{"upi_id": "pay@companion", "payee_name": "AI Language Companion Ltd"}'::jsonb, true),
  ('bank', 'Bank Transfer', '{"bank_name": "Global Bank", "account_number": "9876543210", "ifsc": "GLB0000123", "account_name": "AI Language Companion Ltd"}'::jsonb, true)
ON CONFLICT (method_type) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  details = EXCLUDED.details;

-- ── 5. RLS Enablement ────────────────────────────────────────────────────────
ALTER TABLE public.ai_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.manual_payments ENABLE ROW LEVEL SECURITY;

-- ── 6. RLS Policies ──────────────────────────────────────────────────────────

-- AI Cache policies
CREATE POLICY "Anyone can read AI cache"
    ON public.ai_cache FOR SELECT
    USING (true);

CREATE POLICY "Authenticated users can insert AI cache"
    ON public.ai_cache FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Payment Methods policies
CREATE POLICY "Anyone can view active payment methods"
    ON public.payment_methods FOR SELECT
    USING (is_active = true);

CREATE POLICY "Admins manage payment methods"
    ON public.payment_methods FOR ALL
    USING (public.is_admin_check());

-- Manual Payments policies
CREATE POLICY "Users can view own manual payments"
    ON public.manual_payments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = manual_payments.user_id AND auth_user_id = auth.uid()
        ) OR public.is_admin_check()
    );

CREATE POLICY "Users can create manual payments"
    ON public.manual_payments FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = user_id AND auth_user_id = auth.uid()
        )
    );

CREATE POLICY "Admins manage manual payments"
    ON public.manual_payments FOR UPDATE
    USING (public.is_admin_check());

-- ── 7. Storage Bucket & Policies ──────────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('payment-receipts', 'payment-receipts', false, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Allow authenticated upload receipts"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'payment-receipts' AND auth.role() = 'authenticated');

CREATE POLICY "Allow owner/admin select receipts"
ON storage.objects FOR SELECT
USING (bucket_id = 'payment-receipts' AND (
    auth.uid()::text = (storage.foldername(name))[1]
    OR public.is_admin_check()
));

-- ── 8. Correct Super Admin override in OmniRoute RLS ─────────────────────────
-- Fix previous migration references from id to auth_user_id for user_profiles
DROP POLICY IF EXISTS "Only admin can write AI providers" ON public.ai_providers;
CREATE POLICY "Only admin can write AI providers"
    ON public.ai_providers FOR ALL
    USING (public.is_admin_check());

DROP POLICY IF EXISTS "Only admin can write AI routing" ON public.ai_feature_routing;
CREATE POLICY "Only admin can write AI routing"
    ON public.ai_feature_routing FOR ALL
    USING (public.is_admin_check());
