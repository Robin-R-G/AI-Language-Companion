-- Migration: 20260708000000_fix_critical_db_issues.sql
-- Fixes critical database issues found during audit

-- ── 1. Add missing email column to user_profiles ──────────────────────────────
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- ── 2. Fix deduct_ai_credits function (was using wrong table name) ────────────
CREATE OR REPLACE FUNCTION public.deduct_ai_credits(
    p_user_id uuid,
    p_credits int,
    p_source text DEFAULT 'ai_usage',
    p_description text DEFAULT ''
) RETURNS void AS $$
DECLARE
    v_wallet_id UUID;
BEGIN
    -- Get wallet ID
    SELECT id INTO v_wallet_id FROM public.wallet WHERE user_id = p_user_id;
    
    IF v_wallet_id IS NULL THEN
        RAISE EXCEPTION 'Wallet not found for user %', p_user_id;
    END IF;

    UPDATE public.wallet
    SET balance = GREATEST(0, balance - p_credits),
        updated_at = now()
    WHERE user_id = p_user_id;

    INSERT INTO public.wallet_transactions(
        wallet_id, amount, type, description, created_at
    ) VALUES (
        v_wallet_id, -p_credits, 'spend', p_description, now()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── 3. Fix add_ai_credits function (was using wrong table name) ──────────────
CREATE OR REPLACE FUNCTION public.add_ai_credits(
    p_user_id uuid,
    p_credits int,
    p_source text DEFAULT 'manual',
    p_description text DEFAULT ''
) RETURNS void AS $$
DECLARE
    v_wallet_id UUID;
BEGIN
    -- Get or create wallet
    INSERT INTO public.wallet (user_id, balance, updated_at)
    VALUES (p_user_id, p_credits, now())
    ON CONFLICT (user_id)
    DO UPDATE SET
        balance = public.wallet.balance + p_credits,
        updated_at = now()
    RETURNING id INTO v_wallet_id;

    INSERT INTO public.wallet_transactions(
        wallet_id, amount, type, description, created_at
    ) VALUES (
        v_wallet_id, p_credits, 'monthly_grant', p_description, now()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── 4. Fix RLS policies using id = auth.uid() instead of auth_user_id ────────
-- Fix tenants admin policy
DROP POLICY IF EXISTS "Super admins can manage tenants" ON public.tenants;
CREATE POLICY "Super admins can manage tenants"
  ON public.tenants FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role = 'super_admin'
    )
  );

-- Fix tenant_users admin policy
DROP POLICY IF EXISTS "Admins can manage tenant_users" ON public.tenant_users;
CREATE POLICY "Admins can manage tenant_users"
  ON public.tenant_users FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('super_admin', 'admin')
    )
  );

-- Fix ai_usage service insert policy
DROP POLICY IF EXISTS "Service can insert ai_usage" ON public.ai_usage;
CREATE POLICY "Service can insert ai_usage"
  ON public.ai_usage FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Fix ai_cost_daily - add RLS
ALTER TABLE public.ai_cost_daily ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can read ai_cost_daily"
  ON public.ai_cost_daily FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('super_admin', 'admin')
    )
  );

-- Fix subscription_audit_logs - add RLS
ALTER TABLE public.subscription_audit_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can read subscription_audit_logs"
  ON public.subscription_audit_logs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('super_admin', 'admin')
    )
  );

-- Fix tenant_features - add RLS
ALTER TABLE public.tenant_features ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Super admins can manage tenant_features"
  ON public.tenant_features FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role = 'super_admin'
    )
  );
