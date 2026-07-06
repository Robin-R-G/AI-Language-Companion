-- Migration: 20260706020000_marketplace_payment_settlement.sql
-- Multi-sided marketplace, payment settlement & admin revenue engine

----------------------------------------------------
-- 1. MULTI-ROLE USER ROLES & PERMISSIONS
----------------------------------------------------

-- Extend user_profiles with granular role system
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS role VARCHAR(30) DEFAULT 'student'
  CHECK (role IN ('student', 'tutor', 'admin', 'super_admin', 'support_staff', 'finance_manager', 'content_manager'));

ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS is_email_verified BOOLEAN DEFAULT false;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS is_phone_verified BOOLEAN DEFAULT false;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS phone_number VARCHAR(20);
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS is_identity_verified BOOLEAN DEFAULT false;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS is_banned BOOLEAN DEFAULT false;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS ban_reason TEXT;

-- Role permissions matrix
CREATE TABLE IF NOT EXISTS public.role_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role VARCHAR(30) NOT NULL,
  permission_key VARCHAR(100) NOT NULL,
  is_granted BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(role, permission_key)
);

-- Seed default permissions per role
INSERT INTO public.role_permissions (role, permission_key, is_granted) VALUES
-- Student permissions
('student', 'book_tutor', true),
('student', 'make_payment', true),
('student', 'view_own_bookings', true),
('student', 'view_own_receipts', true),
('student', 'submit_review', true),
('student', 'request_refund', true),
('student', 'open_dispute', true),
('student', 'view_tutor_marketplace', true),
('student', 'view_wallet', true),
('student', 'use_ai_credits', true),
('student', 'access_lessons', true),
('student', 'access_chat', true),
-- Tutor permissions
('tutor', 'view_own_dashboard', true),
('tutor', 'view_own_earnings', true),
('tutor', 'request_payout', true),
('tutor', 'manage_availability', true),
('tutor', 'view_own_students', true),
('tutor', 'respond_to_messages', true),
('tutor', 'upload_documents', true),
('tutor', 'manage_profile', true),
('tutor', 'view_own_reviews', true),
('tutor', 'view_own_schedule', true),
('tutor', 'view_wallet', true),
-- Admin permissions
('admin', 'manage_users', true),
('admin', 'manage_tutors', true),
('admin', 'approve_tutors', true),
('admin', 'manage_content', true),
('admin', 'manage_courses', true),
('admin', 'manage_exams', true),
('admin', 'manage_subscriptions', true),
('admin', 'manage_credit_packs', true),
('admin', 'view_financials', true),
('admin', 'manage_settlements', true),
('admin', 'manage_commissions', true),
('admin', 'manage_pricing', true),
('admin', 'manage_payouts', true),
('admin', 'view_audit_logs', true),
('admin', 'manage_disputes', true),
('admin', 'manage_notifications', true),
('admin', 'manage_platform_accounts', true),
('admin', 'view_revenue', true),
('admin', 'manage_featured_tutors', true),
('admin', 'manage_refunds', true),
('admin', 'configure_ai_settings', true),
('admin', 'manage_affiliates', true),
('admin', 'manage_sponsored_content', true),
-- Super admin
('super_admin', 'manage_admins', true),
('super_admin', 'manage_business_config', true),
('super_admin', 'manage_commission_rules', true),
('super_admin', 'manage_financial_accounts', true),
('super_admin', 'manage_payment_providers', true),
('super_admin', 'manage_ai_providers', true),
('super_admin', 'manage_revenuecat', true),
('super_admin', 'manage_razorpay', true),
('super_admin', 'manage_stripe', true),
('super_admin', 'manage_admob', true),
('super_admin', 'manage_affiliate_networks', true),
('super_admin', 'manage_taxes', true),
('super_admin', 'manage_currencies', true),
('super_admin', 'manage_platform_settings', true),
('super_admin', 'manage_feature_flags', true),
('super_admin', 'view_all_audit_logs', true),
('super_admin', 'manage_exchange_rates', true),
-- Finance manager
('finance_manager', 'view_financials', true),
('finance_manager', 'view_revenue', true),
('finance_manager', 'manage_settlements', true),
('finance_manager', 'manage_payouts', true),
('finance_manager', 'view_audit_logs', true),
('finance_manager', 'generate_reports', true),
('finance_manager', 'view_tutor_earnings', true),
('finance_manager', 'manage_invoices', true),
-- Support staff
('support_staff', 'manage_disputes', true),
('support_staff', 'view_users', true),
('support_staff', 'view_bookings', true),
('support_staff', 'respond_to_complaints', true),
('support_staff', 'view_audit_logs', true),
('support_staff', 'manage_refund_requests', true),
-- Content manager
('content_manager', 'manage_content', true),
('content_manager', 'manage_courses', true),
('content_manager', 'manage_exams', true),
('content_manager', 'manage_tutor_featured', true),
('content_manager', 'manage_sponsored_content', true)
ON CONFLICT (role, permission_key) DO NOTHING;

----------------------------------------------------
-- 2. TUTOR REGISTRATION & VERIFICATION
----------------------------------------------------

-- Extended tutor profile for full registration flow
CREATE TABLE IF NOT EXISTS public.tutor_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES public.user_profiles(auth_user_id) ON DELETE CASCADE,
  status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('draft', 'pending_review', 'under_review', 'approved', 'rejected', 'suspended')),
  rejection_reason TEXT,
  approved_by UUID REFERENCES public.user_profiles(auth_user_id),
  approved_at TIMESTAMPTZ,
  submitted_at TIMESTAMPTZ,
  -- Identity
  government_id_type VARCHAR(30) CHECK (government_id_type IN ('passport', 'drivers_license', 'national_id', 'aadhaar')),
  government_id_url TEXT,
  government_id_verified BOOLEAN DEFAULT false,
  -- Teaching certificate
  certificate_type VARCHAR(50),
  certificate_url TEXT,
  certificate_verified BOOLEAN DEFAULT false,
  -- Intro video
  intro_video_url TEXT,
  intro_video_verified BOOLEAN DEFAULT false,
  -- Teaching experience
  years_of_experience INTEGER DEFAULT 0,
  specializations TEXT[] DEFAULT '{}',
  languages_spoken TEXT[] DEFAULT '{}',
  target_exams TEXT[] DEFAULT '{}',
  education TEXT,
  -- Pricing (admin-controlled)
  proposed_price_cents INTEGER,
  approved_price_cents INTEGER,
  price_change_requested BOOLEAN DEFAULT false,
  price_change_requested_at TIMESTAMPTZ,
  -- Verification checklist
  id_verified BOOLEAN DEFAULT false,
  certificate_uploaded BOOLEAN DEFAULT false,
  profile_photo_uploaded BOOLEAN DEFAULT false,
  intro_video_uploaded BOOLEAN DEFAULT false,
  background_check_passed BOOLEAN DEFAULT false,
  -- Metrics
  total_students INTEGER DEFAULT 0,
  total_hours_taught NUMERIC(10,1) DEFAULT 0,
  total_earnings_cents INTEGER DEFAULT 0,
  -- Featured status
  is_featured BOOLEAN DEFAULT false,
  featured_at TIMESTAMPTZ,
  is_hidden BOOLEAN DEFAULT false,
  is_blocked BOOLEAN DEFAULT false,
  block_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Tutor documents (upload tracking)
CREATE TABLE IF NOT EXISTS public.tutor_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tutor_id UUID NOT NULL REFERENCES public.tutor_profiles(id) ON DELETE CASCADE,
  document_type VARCHAR(30) NOT NULL CHECK (document_type IN ('government_id', 'teaching_certificate', 'intro_video', 'resume', 'other')),
  file_url TEXT NOT NULL,
  file_name TEXT,
  file_size_bytes INTEGER,
  mime_type VARCHAR(50),
  verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
  rejection_reason TEXT,
  verified_by UUID REFERENCES public.user_profiles(auth_user_id),
  verified_at TIMESTAMPTZ,
  uploaded_at TIMESTAMPTZ DEFAULT now()
);

-- Tutor availability schedule
CREATE TABLE IF NOT EXISTS public.tutor_availability (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tutor_id UUID NOT NULL REFERENCES public.tutor_profiles(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  CHECK (start_time < end_time)
);

-- Tutor reviews
CREATE TABLE IF NOT EXISTS public.tutor_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tutor_id UUID NOT NULL REFERENCES public.tutor_profiles(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.user_profiles(auth_user_id) ON DELETE CASCADE,
  booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  review_text TEXT,
  is_anonymous BOOLEAN DEFAULT false,
  is_approved BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(tutor_id, student_id, booking_id)
);

----------------------------------------------------
-- 3. ENHANCED BOOKINGS TABLE
----------------------------------------------------

ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS platform_commission_cents INTEGER DEFAULT 0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS tutor_payout_cents INTEGER DEFAULT 0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS payment_method VARCHAR(30);
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS transaction_id TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS invoice_id UUID;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS refund_status VARCHAR(20) DEFAULT 'none' CHECK (refund_status IN ('none', 'requested', 'approved', 'denied', 'refunded'));
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS refund_amount_cents INTEGER DEFAULT 0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS refund_reason TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS refund_requested_at TIMESTAMPTZ;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS refund_processed_at TIMESTAMPTZ;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS cancelled_by UUID REFERENCES public.user_profiles(auth_user_id);
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS dispute_id UUID;

----------------------------------------------------
-- 4. PLATFORM RECEIVING ACCOUNTS
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.platform_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider VARCHAR(30) NOT NULL CHECK (provider IN ('upi', 'bank_account', 'razorpay', 'stripe', 'google_play', 'apple', 'revenuecat', 'paypal', 'wise')),
  account_name VARCHAR(200) NOT NULL,
  business_name VARCHAR(200),
  account_number VARCHAR(100),
  ifsc_code VARCHAR(20),
  branch_name VARCHAR(100),
  upi_id VARCHAR(100),
  beneficiary_name VARCHAR(150),
  gst_number VARCHAR(30),
  pan_number VARCHAR(20),
  tax_details JSONB DEFAULT '{}'::jsonb,
  invoice_prefix VARCHAR(20) DEFAULT 'INV',
  company_address TEXT,
  business_logo_url TEXT,
  country_code VARCHAR(5) DEFAULT 'IN',
  currency VARCHAR(5) DEFAULT 'INR',
  is_active BOOLEAN DEFAULT true,
  is_default BOOLEAN DEFAULT false,
  verified_at TIMESTAMPTZ,
  created_by UUID REFERENCES public.user_profiles(auth_user_id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- 5. COMMISSION ENGINE
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.commission_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rule_type VARCHAR(30) NOT NULL CHECK (rule_type IN ('global', 'per_tutor', 'per_subject', 'per_exam', 'per_promotion')),
  reference_id UUID,
  commission_percent NUMERIC(5,2) NOT NULL DEFAULT 20.00 CHECK (commission_percent BETWEEN 0 AND 100),
  min_commission_cents INTEGER DEFAULT 0,
  max_commission_cents INTEGER,
  is_active BOOLEAN DEFAULT true,
  effective_from TIMESTAMPTZ DEFAULT now(),
  effective_until TIMESTAMPTZ,
  created_by UUID REFERENCES public.user_profiles(auth_user_id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Seed default global commission
INSERT INTO public.commission_rules (rule_type, commission_percent, created_by)
SELECT 'global', 20.00, auth_user_id FROM public.user_profiles WHERE role = 'admin' LIMIT 1
ON CONFLICT DO NOTHING;

----------------------------------------------------
-- 6. SMART PRICING SYSTEM
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.pricing_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  config_type VARCHAR(30) NOT NULL CHECK (config_type IN ('global', 'per_tutor', 'per_subject', 'per_exam', 'per_country')),
  reference_id UUID,
  min_price_cents INTEGER NOT NULL DEFAULT 500,
  max_price_cents INTEGER NOT NULL DEFAULT 10000,
  default_price_cents INTEGER NOT NULL DEFAULT 2000,
  premium_multiplier NUMERIC(3,2) DEFAULT 1.00,
  currency VARCHAR(5) DEFAULT 'INR',
  country_code VARCHAR(5),
  discount_rules JSONB DEFAULT '{}'::jsonb,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES public.user_profiles(auth_user_id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Seed default pricing
INSERT INTO public.pricing_config (config_type, min_price_cents, max_price_cents, default_price_cents)
VALUES ('global', 500, 10000, 2000)
ON CONFLICT DO NOTHING;

----------------------------------------------------
-- 7. TUTOR WALLET & PAYOUTS
----------------------------------------------------

-- Tutor wallet (separate from student wallet)
CREATE TABLE IF NOT EXISTS public.tutor_wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tutor_id UUID NOT NULL UNIQUE REFERENCES public.tutor_profiles(id) ON DELETE CASCADE,
  pending_balance_cents INTEGER NOT NULL DEFAULT 0 CHECK (pending_balance_cents >= 0),
  available_balance_cents INTEGER NOT NULL DEFAULT 0 CHECK (available_balance_cents >= 0),
  processing_balance_cents INTEGER NOT NULL DEFAULT 0 CHECK (processing_balance_cents >= 0),
  total_earned_cents INTEGER NOT NULL DEFAULT 0,
  total_withdrawn_cents INTEGER NOT NULL DEFAULT 0,
  total_tax_deducted_cents INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Tutor wallet transactions
CREATE TABLE IF NOT EXISTS public.tutor_wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL REFERENCES public.tutor_wallets(id) ON DELETE CASCADE,
  amount_cents INTEGER NOT NULL,
  type VARCHAR(30) NOT NULL CHECK (type IN ('booking_earned', 'bonus', 'tip', 'refund_deduction', 'withdrawal', 'withdrawal_reversed', 'tax_deduction', 'adjustment')),
  reference_id UUID,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Tutor payout methods
CREATE TABLE IF NOT EXISTS public.tutor_payout_methods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tutor_id UUID NOT NULL REFERENCES public.tutor_profiles(id) ON DELETE CASCADE,
  method_type VARCHAR(30) NOT NULL CHECK (method_type IN ('upi', 'bank_account', 'stripe_connect', 'paypal', 'wise', 'razorpay_route')),
  account_holder_name VARCHAR(150) NOT NULL,
  account_number VARCHAR(100),
  ifsc_code VARCHAR(20),
  branch_name VARCHAR(100),
  upi_id VARCHAR(100),
  beneficiary_name VARCHAR(150),
  stripe_account_id VARCHAR(100),
  paypal_email VARCHAR(150),
  is_verified BOOLEAN DEFAULT false,
  verified_at TIMESTAMPTZ,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Tutor payout requests
CREATE TABLE IF NOT EXISTS public.tutor_payouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tutor_id UUID NOT NULL REFERENCES public.tutor_profiles(id) ON DELETE CASCADE,
  payout_method_id UUID REFERENCES public.tutor_payout_methods(id) ON DELETE SET NULL,
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  charges_cents INTEGER DEFAULT 0,
  tax_deducted_cents INTEGER DEFAULT 0,
  net_amount_cents INTEGER NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'processing', 'completed', 'failed', 'cancelled')),
  rejection_reason TEXT,
  approved_by UUID REFERENCES public.user_profiles(auth_user_id),
  approved_at TIMESTAMPTZ,
  processed_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  transaction_reference TEXT,
  receipt_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- 8. PAYMENT SETTLEMENT CENTER
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.payment_settlements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.user_profiles(auth_user_id),
  tutor_id UUID NOT NULL REFERENCES public.tutor_profiles(id),
  amount_paid_cents INTEGER NOT NULL,
  platform_commission_cents INTEGER NOT NULL,
  commission_percent NUMERIC(5,2) NOT NULL,
  tax_amount_cents INTEGER DEFAULT 0,
  net_tutor_amount_cents INTEGER NOT NULL,
  platform_revenue_cents INTEGER NOT NULL,
  payment_method VARCHAR(30),
  payment_provider VARCHAR(30),
  transaction_id TEXT,
  student_receipt_id UUID,
  tutor_receipt_id UUID,
  invoice_number VARCHAR(50),
  settlement_status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (settlement_status IN ('pending', 'settled', 'refunded', 'disputed')),
  settled_at TIMESTAMPTZ,
  settlement_batch_id UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Settlement batches (daily/weekly/monthly)
CREATE TABLE IF NOT EXISTS public.settlement_batches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  batch_type VARCHAR(20) NOT NULL CHECK (batch_type IN ('daily', 'weekly', 'monthly')),
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  total_settlements INTEGER DEFAULT 0,
  total_amount_cents INTEGER DEFAULT 0,
  total_commission_cents INTEGER DEFAULT 0,
  total_tutor_payouts_cents INTEGER DEFAULT 0,
  processed_by UUID REFERENCES public.user_profiles(auth_user_id),
  processed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- 9. ADMIN FINANCE CENTER
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.platform_finances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL UNIQUE,
  platform_wallet_balance_cents INTEGER DEFAULT 0,
  available_balance_cents INTEGER DEFAULT 0,
  pending_balance_cents INTEGER DEFAULT 0,
  tutor_payables_cents INTEGER DEFAULT 0,
  tax_payables_cents INTEGER DEFAULT 0,
  refund_reserve_cents INTEGER DEFAULT 0,
  -- Revenue streams
  subscription_revenue_cents INTEGER DEFAULT 0,
  ai_credit_revenue_cents INTEGER DEFAULT 0,
  tutor_commission_revenue_cents INTEGER DEFAULT 0,
  ad_revenue_cents INTEGER DEFAULT 0,
  affiliate_revenue_cents INTEGER DEFAULT 0,
  certificate_revenue_cents INTEGER DEFAULT 0,
  institution_revenue_cents INTEGER DEFAULT 0,
  sponsored_revenue_cents INTEGER DEFAULT 0,
  marketplace_revenue_cents INTEGER DEFAULT 0,
  -- Costs
  ai_cost_cents INTEGER DEFAULT 0,
  infrastructure_cost_cents INTEGER DEFAULT 0,
  server_cost_cents INTEGER DEFAULT 0,
  storage_cost_cents INTEGER DEFAULT 0,
  payment_gateway_charges_cents INTEGER DEFAULT 0,
  tutor_payout_costs_cents INTEGER DEFAULT 0,
  refund_costs_cents INTEGER DEFAULT 0,
  -- Totals
  gross_revenue_cents INTEGER DEFAULT 0,
  net_revenue_cents INTEGER DEFAULT 0,
  actual_profit_cents INTEGER DEFAULT 0,
  -- Forecasts
  forecast_monthly_revenue_cents INTEGER DEFAULT 0,
  forecast_monthly_ai_cost_cents INTEGER DEFAULT 0,
  forecast_monthly_tutor_payouts_cents INTEGER DEFAULT 0,
  forecast_monthly_profit_cents INTEGER DEFAULT 0,
  forecast_churn_rate NUMERIC(5,2) DEFAULT 0,
  forecast_break_even_date DATE,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- 10. DISPUTE MANAGEMENT
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dispute_type VARCHAR(30) NOT NULL CHECK (dispute_type IN ('refund_request', 'tutor_complaint', 'session_complaint', 'payment_issue', 'quality_issue', 'other')),
  filed_by UUID NOT NULL REFERENCES public.user_profiles(auth_user_id),
  against_user UUID REFERENCES public.user_profiles(auth_user_id),
  booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
  tutor_id UUID REFERENCES public.tutor_profiles(id) ON DELETE SET NULL,
  subject VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  evidence_urls TEXT[] DEFAULT '{}',
  status VARCHAR(20) NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'under_review', 'resolved', 'escalated', 'closed')),
  resolution TEXT,
  resolved_by UUID REFERENCES public.user_profiles(auth_user_id),
  resolved_at TIMESTAMPTZ,
  refund_amount_cents INTEGER DEFAULT 0,
  refund_issued BOOLEAN DEFAULT false,
  priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Dispute messages (audit trail)
CREATE TABLE IF NOT EXISTS public.dispute_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dispute_id UUID NOT NULL REFERENCES public.disputes(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.user_profiles(auth_user_id),
  message TEXT NOT NULL,
  attachment_urls TEXT[] DEFAULT '{}',
  is_internal_note BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- 11. BUSINESS DOCUMENTS (AUTO-GENERATED)
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.business_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_type VARCHAR(30) NOT NULL CHECK (document_type IN ('invoice', 'receipt', 'tutor_earnings_report', 'commission_report', 'tax_report', 'gst_report', 'financial_statement', 'monthly_report', 'annual_report', 'payout_receipt')),
  reference_id UUID,
  reference_type VARCHAR(30),
  recipient_id UUID REFERENCES public.user_profiles(auth_user_id),
  document_number VARCHAR(50) NOT NULL,
  document_date DATE NOT NULL DEFAULT CURRENT_DATE,
  amount_cents INTEGER,
  tax_cents INTEGER,
  total_cents INTEGER,
  currency VARCHAR(5) DEFAULT 'INR',
  file_url TEXT,
  file_format VARCHAR(10) CHECK (file_format IN ('pdf', 'csv', 'xlsx')),
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- 12. AUDIT LOGS (ENHANCED)
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.financial_audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action VARCHAR(50) NOT NULL,
  entity_type VARCHAR(30) NOT NULL,
  entity_id UUID,
  performed_by UUID NOT NULL REFERENCES public.user_profiles(auth_user_id),
  old_values JSONB DEFAULT '{}'::jsonb,
  new_values JSONB DEFAULT '{}'::jsonb,
  ip_address VARCHAR(45),
  user_agent TEXT,
  reason TEXT,
  requires_approval BOOLEAN DEFAULT false,
  approved_by UUID REFERENCES public.user_profiles(auth_user_id),
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- 13. COUPON & DISCOUNT ENGINE
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed_amount')),
  discount_value NUMERIC(10,2) NOT NULL,
  min_booking_amount_cents INTEGER DEFAULT 0,
  max_discount_cents INTEGER,
  usage_limit INTEGER,
  used_count INTEGER DEFAULT 0,
  applicable_to VARCHAR(20) DEFAULT 'all' CHECK (applicable_to IN ('all', 'subscriptions', 'tutor_bookings', 'credit_packs')),
  valid_from TIMESTAMPTZ DEFAULT now(),
  valid_until TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES public.user_profiles(auth_user_id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Coupon usage tracking
CREATE TABLE IF NOT EXISTS public.coupon_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID NOT NULL REFERENCES public.coupons(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.user_profiles(auth_user_id),
  booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
  discount_amount_cents INTEGER NOT NULL,
  used_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- 14. REVENUE FORECAST DATA
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.revenue_forecasts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  forecast_date DATE NOT NULL,
  forecast_type VARCHAR(20) NOT NULL CHECK (forecast_type IN ('monthly', 'quarterly', 'annual')),
  predicted_revenue_cents INTEGER DEFAULT 0,
  predicted_ai_cost_cents INTEGER DEFAULT 0,
  predicted_tutor_payouts_cents INTEGER DEFAULT 0,
  predicted_profit_cents INTEGER DEFAULT 0,
  predicted_subscriber_count INTEGER DEFAULT 0,
  predicted_churn_rate NUMERIC(5,2) DEFAULT 0,
  confidence_score NUMERIC(3,2) DEFAULT 0.5,
  actual_revenue_cents INTEGER,
  actual_profit_cents INTEGER,
  variance_cents INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- 15. FEATURE FLAGS
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.feature_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  flag_key VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  is_enabled BOOLEAN DEFAULT false,
  rollout_percentage INTEGER DEFAULT 0 CHECK (rollout_percentage BETWEEN 0 AND 100),
  target_roles TEXT[] DEFAULT '{}',
  target_countries TEXT[] DEFAULT '{}',
  created_by UUID REFERENCES public.user_profiles(auth_user_id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- 16. CURRENCIES & EXCHANGE RATES
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.currencies (
  code VARCHAR(5) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  symbol VARCHAR(10) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  decimal_places INTEGER DEFAULT 2,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.exchange_rates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_currency VARCHAR(5) NOT NULL REFERENCES public.currencies(code),
  to_currency VARCHAR(5) NOT NULL REFERENCES public.currencies(code),
  rate NUMERIC(12,6) NOT NULL,
  source VARCHAR(50) DEFAULT 'manual',
  valid_from TIMESTAMPTZ DEFAULT now(),
  valid_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Seed currencies
INSERT INTO public.currencies (code, name, symbol) VALUES
('INR', 'Indian Rupee', '₹'),
('USD', 'US Dollar', '$'),
('EUR', 'Euro', '€'),
('GBP', 'British Pound', '£'),
('AED', 'UAE Dirham', 'د.إ'),
('AUD', 'Australian Dollar', 'A$'),
('CAD', 'Canadian Dollar', 'C$')
ON CONFLICT (code) DO NOTHING;

-- Seed exchange rates
INSERT INTO public.exchange_rates (from_currency, to_currency, rate) VALUES
('USD', 'INR', 83.50),
('EUR', 'INR', 91.20),
('GBP', 'INR', 105.80),
('AED', 'INR', 22.73),
('AUD', 'INR', 54.90),
('CAD', 'INR', 61.30)
ON CONFLICT DO NOTHING;

----------------------------------------------------
-- 17. HELPER FUNCTIONS
----------------------------------------------------

-- Calculate platform commission
CREATE OR REPLACE FUNCTION public.calculate_commission(
  p_amount_cents INTEGER,
  p_tutor_id UUID DEFAULT NULL,
  p_subject TEXT DEFAULT NULL
) RETURNS TABLE (
  commission_cents INTEGER,
  commission_percent NUMERIC,
  net_amount_cents INTEGER
) AS $$
DECLARE
  v_commission_pct NUMERIC;
  v_commission_cents INTEGER;
  v_rule RECORD;
BEGIN
  -- Check per-tutor commission
  IF p_tutor_id IS NOT NULL THEN
    SELECT cr.commission_percent INTO v_commission_pct
    FROM public.commission_rules cr
    WHERE cr.rule_type = 'per_tutor' AND cr.reference_id = p_tutor_id AND cr.is_active = true
    LIMIT 1;
  END IF;

  -- Check per-subject commission
  IF v_commission_pct IS NULL AND p_subject IS NOT NULL THEN
    SELECT cr.commission_percent INTO v_commission_pct
    FROM public.commission_rules cr
    WHERE cr.rule_type = 'per_subject' AND cr.reference_id IS NULL AND cr.is_active = true
    LIMIT 1;
  END IF;

  -- Fallback to global commission
  IF v_commission_pct IS NULL THEN
    SELECT cr.commission_percent INTO v_commission_pct
    FROM public.commission_rules cr
    WHERE cr.rule_type = 'global' AND cr.is_active = true
    ORDER BY cr.created_at DESC
    LIMIT 1;
  END IF;

  -- Default to 20% if no rule found
  IF v_commission_pct IS NULL THEN
    v_commission_pct := 20.00;
  END IF;

  v_commission_cents := ROUND(p_amount_cents * v_commission_pct / 100);

  RETURN QUERY SELECT v_commission_cents, v_commission_pct, (p_amount_cents - v_commission_cents)::INTEGER;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Validate pricing within bounds
CREATE OR REPLACE FUNCTION public.validate_tutor_price(
  p_price_cents INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
  v_min INTEGER;
  v_max INTEGER;
BEGIN
  SELECT min_price_cents, max_price_cents INTO v_min, v_max
  FROM public.pricing_config
  WHERE config_type = 'global' AND is_active = true
  LIMIT 1;

  IF v_min IS NULL THEN v_min := 500; END IF;
  IF v_max IS NULL THEN v_max := 10000; END IF;

  RETURN p_price_cents >= v_min AND p_price_cents <= v_max;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check role permission
CREATE OR REPLACE FUNCTION public.has_permission(
  p_user_id UUID,
  p_permission_key VARCHAR
) RETURNS BOOLEAN AS $$
DECLARE
  v_role VARCHAR;
BEGIN
  SELECT role INTO v_role FROM public.user_profiles WHERE auth_user_id = p_user_id;
  IF v_role IS NULL THEN RETURN false; END IF;
  RETURN EXISTS (
    SELECT 1 FROM public.role_permissions
    WHERE role = v_role AND permission_key = p_permission_key AND is_granted = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Auto-update tutor wallet on completed booking
CREATE OR REPLACE FUNCTION public.handle_booking_completed()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    NEW.completed_at := now();

    -- Calculate commission
    DECLARE
      v_commission RECORD;
      v_wallet_id UUID;
    BEGIN
      SELECT * INTO v_commission FROM public.calculate_commission(NEW.price_paid_cents, NEW.tutor_id);
      NEW.platform_commission_cents := v_commission.commission_cents;
      NEW.tutor_payout_cents := v_commission.net_amount_cents;

      -- Create settlement record
      INSERT INTO public.payment_settlements (
        booking_id, student_id, tutor_id, amount_paid_cents,
        platform_commission_cents, commission_percent,
        net_tutor_amount_cents, platform_revenue_cents,
        payment_method, transaction_id
      ) VALUES (
        NEW.id, NEW.student_id, NEW.tutor_id, NEW.price_paid_cents,
        v_commission.commission_cents, v_commission.commission_percent,
        v_commission.net_amount_cents, v_commission.commission_cents,
        NEW.payment_method, NEW.transaction_id
      );

      -- Credit tutor wallet (pending)
      SELECT id INTO v_wallet_id FROM public.tutor_wallets WHERE tutor_id = NEW.tutor_id;
      IF v_wallet_id IS NOT NULL THEN
        UPDATE public.tutor_wallets
        SET pending_balance_cents = pending_balance_cents + v_commission.net_amount_cents,
            total_earned_cents = total_earned_cents + v_commission.net_amount_cents,
            updated_at = now()
        WHERE id = v_wallet_id;

        INSERT INTO public.tutor_wallet_transactions (wallet_id, amount_cents, type, reference_id, description)
        VALUES (v_wallet_id, v_commission.net_amount_cents, 'booking_earned', NEW.id,
                'Session completed - ' || NEW.start_time::date);
      END IF;
    END;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_booking_completed ON public.bookings;
CREATE TRIGGER on_booking_completed
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_booking_completed();

----------------------------------------------------
-- 18. ROW LEVEL SECURITY (RLS)
----------------------------------------------------

ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutor_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutor_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutor_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commission_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pricing_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutor_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutor_wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutor_payout_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutor_payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_settlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settlement_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_finances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispute_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupon_usages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.revenue_forecasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;

-- Role permissions (admin only)
CREATE POLICY "Admins manage role permissions" ON public.role_permissions FOR ALL USING (public.is_admin_check());

-- Tutor profiles
CREATE POLICY "Anyone can view approved tutor profiles" ON public.tutor_profiles FOR SELECT USING (status = 'approved' OR auth.uid() = user_id);
CREATE POLICY "Tutors can insert own profile" ON public.tutor_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Tutors can update own profile" ON public.tutor_profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Admins have full access on tutor profiles" ON public.tutor_profiles FOR ALL USING (public.is_admin_check());

-- Tutor documents
CREATE POLICY "Tutors can view own documents" ON public.tutor_documents FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.tutor_profiles tp WHERE tp.id = tutor_documents.tutor_id AND tp.user_id = auth.uid()));
CREATE POLICY "Tutors can insert own documents" ON public.tutor_documents FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM public.tutor_profiles tp WHERE tp.id = tutor_documents.tutor_id AND tp.user_id = auth.uid()));
CREATE POLICY "Admins have full access on tutor documents" ON public.tutor_documents FOR ALL USING (public.is_admin_check());

-- Tutor availability
CREATE POLICY "Anyone can view tutor availability" ON public.tutor_availability FOR SELECT USING (true);
CREATE POLICY "Tutors can manage own availability" ON public.tutor_availability FOR ALL
  USING (EXISTS (SELECT 1 FROM public.tutor_profiles tp WHERE tp.id = tutor_availability.tutor_id AND tp.user_id = auth.uid()));
CREATE POLICY "Admins have full access on tutor availability" ON public.tutor_availability FOR ALL USING (public.is_admin_check());

-- Tutor reviews
CREATE POLICY "Anyone can view approved reviews" ON public.tutor_reviews FOR SELECT USING (is_approved = true);
CREATE POLICY "Students can insert reviews for their bookings" ON public.tutor_reviews FOR INSERT
  WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Admins have full access on reviews" ON public.tutor_reviews FOR ALL USING (public.is_admin_check());

-- Platform accounts (admin only)
CREATE POLICY "Admins manage platform accounts" ON public.platform_accounts FOR ALL USING (public.is_admin_check());

-- Commission rules (admin only)
CREATE POLICY "Admins manage commission rules" ON public.commission_rules FOR ALL USING (public.is_admin_check());
CREATE POLICY "Anyone can view active commission rules" ON public.commission_rules FOR SELECT USING (is_active = true);

-- Pricing config (admin only)
CREATE POLICY "Admins manage pricing" ON public.pricing_config FOR ALL USING (public.is_admin_check());
CREATE POLICY "Anyone can view active pricing" ON public.pricing_config FOR SELECT USING (is_active = true);

-- Tutor wallets
CREATE POLICY "Tutors can view own wallet" ON public.tutor_wallets FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.tutor_profiles tp WHERE tp.id = tutor_wallets.tutor_id AND tp.user_id = auth.uid()));
CREATE POLICY "Admins have full access on tutor wallets" ON public.tutor_wallets FOR ALL USING (public.is_admin_check());

-- Tutor wallet transactions
CREATE POLICY "Tutors can view own transactions" ON public.tutor_wallet_transactions FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.tutor_wallets tw
    JOIN public.tutor_profiles tp ON tp.id = tw.tutor_id
    WHERE tw.id = tutor_wallet_transactions.wallet_id AND tp.user_id = auth.uid()
  ));
CREATE POLICY "Admins have full access on tutor transactions" ON public.tutor_wallet_transactions FOR ALL USING (public.is_admin_check());

-- Tutor payout methods
CREATE POLICY "Tutors can manage own payout methods" ON public.tutor_payout_methods FOR ALL
  USING (EXISTS (SELECT 1 FROM public.tutor_profiles tp WHERE tp.id = tutor_payout_methods.tutor_id AND tp.user_id = auth.uid()));
CREATE POLICY "Admins can view tutor payout methods" ON public.tutor_payout_methods FOR SELECT USING (public.is_admin_check());

-- Tutor payouts
CREATE POLICY "Tutors can view own payouts" ON public.tutor_payouts FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.tutor_profiles tp WHERE tp.id = tutor_payouts.tutor_id AND tp.user_id = auth.uid()));
CREATE POLICY "Tutors can insert own payout requests" ON public.tutor_payouts FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM public.tutor_profiles tp WHERE tp.id = tutor_payouts.tutor_id AND tp.user_id = auth.uid()));
CREATE POLICY "Admins have full access on payouts" ON public.tutor_payouts FOR ALL USING (public.is_admin_check());

-- Payment settlements
CREATE POLICY "Admins manage settlements" ON public.payment_settlements FOR ALL USING (public.is_admin_check());
CREATE POLICY "Tutors can view own settlements" ON public.payment_settlements FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.tutor_profiles tp WHERE tp.id = payment_settlements.tutor_id AND tp.user_id = auth.uid()));
CREATE POLICY "Students can view own settlements" ON public.payment_settlements FOR SELECT USING (auth.uid() = student_id);

-- Settlement batches (admin only)
CREATE POLICY "Admins manage settlement batches" ON public.settlement_batches FOR ALL USING (public.is_admin_check());

-- Platform finances (admin/finance_manager only)
CREATE POLICY "Admins manage platform finances" ON public.platform_finances FOR ALL USING (public.is_admin_check());
CREATE POLICY "Finance managers can view platform finances" ON public.platform_finances FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.user_profiles WHERE auth_user_id = auth.uid() AND role = 'finance_manager'));

-- Disputes
CREATE POLICY "Users can view own disputes" ON public.disputes FOR SELECT
  USING (auth.uid() = filed_by OR auth.uid() = against_user);
CREATE POLICY "Users can create disputes" ON public.disputes FOR INSERT WITH CHECK (auth.uid() = filed_by);
CREATE POLICY "Admins/support have full access on disputes" ON public.disputes FOR ALL
  USING (public.is_admin_check() OR EXISTS (
    SELECT 1 FROM public.user_profiles WHERE auth_user_id = auth.uid() AND role IN ('support_staff', 'admin')
  ));

-- Dispute messages
CREATE POLICY "Dispute participants can view messages" ON public.dispute_messages FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.disputes d
    WHERE d.id = dispute_messages.dispute_id
    AND (d.filed_by = auth.uid() OR d.against_user = auth.uid() OR public.is_admin_check())
  ));
CREATE POLICY "Dispute participants can insert messages" ON public.dispute_messages FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

-- Business documents
CREATE POLICY "Users can view own documents" ON public.business_documents FOR SELECT
  USING (auth.uid() = recipient_id);
CREATE POLICY "Admins have full access on business documents" ON public.business_documents FOR ALL USING (public.is_admin_check());

-- Financial audit logs (admin only)
CREATE POLICY "Admins view financial audit logs" ON public.financial_audit_logs FOR SELECT USING (public.is_admin_check());
CREATE POLICY "System can insert audit logs" ON public.financial_audit_logs FOR INSERT WITH CHECK (true);

-- Coupons
CREATE POLICY "Anyone can view active coupons" ON public.coupons FOR SELECT USING (is_active = true);
CREATE POLICY "Admins manage coupons" ON public.coupons FOR ALL USING (public.is_admin_check());

-- Coupon usages
CREATE POLICY "Users can view own coupon usages" ON public.coupon_usages FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own coupon usages" ON public.coupon_usages FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins have full access on coupon usages" ON public.coupon_usages FOR ALL USING (public.is_admin_check());

-- Revenue forecasts (admin only)
CREATE POLICY "Admins manage revenue forecasts" ON public.revenue_forecasts FOR ALL USING (public.is_admin_check());

-- Feature flags (admin only)
CREATE POLICY "Admins manage feature flags" ON public.feature_flags FOR ALL USING (public.is_admin_check());
CREATE POLICY "Authenticated users can read feature flags" ON public.feature_flags FOR SELECT USING (auth.role() = 'authenticated');

-- Schema permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
