-- Migration: 20260709000000_fix_admin_portal_missing_tables.sql
-- Creates all missing tables, columns, and FKs required by the admin portal.
-- All statements use IF NOT EXISTS / OR REPLACE for safe re-application.

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Add missing columns to existing tables
-- ═══════════════════════════════════════════════════════════════════════════════

-- user_profiles.email — subscriptions page joins on this
ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS email TEXT;

-- user_profiles.is_active — admin portal filters students by this
ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;

-- user_profiles.country — admin portal stores user country
ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS country TEXT;

-- exam_attempts.score — admin portal reads this for avg score stats
ALTER TABLE public.exam_attempts
  ADD COLUMN IF NOT EXISTS score NUMERIC;

-- Backfill exam_attempts.score from estimated_score where score is NULL
UPDATE public.exam_attempts SET score = estimated_score WHERE score IS NULL;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. Create missing tables
-- ═══════════════════════════════════════════════════════════════════════════════

-- support_tickets — dashboard stats
CREATE TABLE IF NOT EXISTS public.support_tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.user_profiles(auth_user_id) ON DELETE SET NULL,
  subject TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','in_progress','resolved','closed')),
  priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low','medium','high','urgent')),
  category TEXT DEFAULT 'general',
  assigned_to UUID REFERENCES public.user_profiles(auth_user_id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- marketplace_categories — tutor marketplace page
CREATE TABLE IF NOT EXISTS public.marketplace_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- courses — courses management page
CREATE TABLE IF NOT EXISTS public.courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  language_id UUID REFERENCES public.languages(id) ON DELETE SET NULL,
  category TEXT,
  difficulty_level TEXT CHECK (difficulty_level IN ('beginner','intermediate','advanced')),
  price_cents INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES public.user_profiles(auth_user_id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- course_enrollments — reports & analytics page
CREATE TABLE IF NOT EXISTS public.course_enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.user_profiles(auth_user_id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'enrolled' CHECK (status IN ('enrolled','in_progress','completed','dropped')),
  enrolled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ,
  UNIQUE(course_id, user_id)
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. Ensure tables from earlier migrations exist (IF NOT EXISTS safety net)
-- ═══════════════════════════════════════════════════════════════════════════════

-- system_settings
CREATE TABLE IF NOT EXISTS public.system_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- feature_flags
CREATE TABLE IF NOT EXISTS public.feature_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  flag_key VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  is_enabled BOOLEAN DEFAULT false,
  rollout_percentage INTEGER DEFAULT 0 CHECK (rollout_percentage >= 0 AND rollout_percentage <= 100),
  target_roles TEXT[] DEFAULT '{}',
  target_countries TEXT[] DEFAULT '{}',
  created_by UUID REFERENCES public.user_profiles(auth_user_id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- coupons
CREATE TABLE IF NOT EXISTS public.coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage','fixed_amount')),
  discount_value NUMERIC(10,2) NOT NULL,
  min_booking_amount_cents INTEGER DEFAULT 0,
  max_discount_cents INTEGER,
  usage_limit INTEGER,
  used_count INTEGER DEFAULT 0,
  applicable_to VARCHAR(20) DEFAULT 'all' CHECK (applicable_to IN ('all','subscriptions','tutor_bookings','credit_packs')),
  valid_from TIMESTAMPTZ DEFAULT now(),
  valid_until TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES public.user_profiles(auth_user_id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- tutor_profiles
CREATE TABLE IF NOT EXISTS public.tutor_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.user_profiles(auth_user_id) ON DELETE CASCADE,
  status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('draft','pending_review','under_review','approved','rejected','suspended')),
  rejection_reason TEXT,
  approved_by UUID REFERENCES public.user_profiles(auth_user_id) ON DELETE SET NULL,
  approved_at TIMESTAMPTZ,
  submitted_at TIMESTAMPTZ,
  years_of_experience INTEGER DEFAULT 0,
  specializations TEXT[] DEFAULT '{}',
  languages_spoken TEXT[] DEFAULT '{}',
  education TEXT,
  proposed_price_cents INTEGER,
  approved_price_cents INTEGER,
  total_students INTEGER DEFAULT 0,
  total_hours_taught NUMERIC(10,1) DEFAULT 0,
  total_earnings_cents INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT false,
  is_hidden BOOLEAN DEFAULT false,
  is_blocked BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ai_providers
CREATE TABLE IF NOT EXISTS public.ai_providers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  is_enabled BOOLEAN NOT NULL DEFAULT true,
  priority INT NOT NULL DEFAULT 1,
  cost_per_input_token NUMERIC(20,12) NOT NULL DEFAULT 0,
  cost_per_output_token NUMERIC(20,12) NOT NULL DEFAULT 0,
  config JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. Enable RLS on new tables + admin policies
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketplace_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_enrollments ENABLE ROW LEVEL SECURITY;

-- Admin ALL-access on support_tickets
DROP POLICY IF EXISTS "Admins have full access on support_tickets" ON public.support_tickets;
CREATE POLICY "Admins have full access on support_tickets"
  ON public.support_tickets FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('admin','super_admin')
    )
  );

-- Admin ALL-access on marketplace_categories
DROP POLICY IF EXISTS "Admins have full access on marketplace_categories" ON public.marketplace_categories;
CREATE POLICY "Admins have full access on marketplace_categories"
  ON public.marketplace_categories FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('admin','super_admin')
    )
  );

-- Anyone can read active marketplace categories
DROP POLICY IF EXISTS "Anyone can view active marketplace_categories" ON public.marketplace_categories;
CREATE POLICY "Anyone can view active marketplace_categories"
  ON public.marketplace_categories FOR SELECT
  USING (is_active = true);

-- Admin ALL-access on courses
DROP POLICY IF EXISTS "Admins have full access on courses" ON public.courses;
CREATE POLICY "Admins have full access on courses"
  ON public.courses FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('admin','super_admin')
    )
  );

-- Anyone can read active courses
DROP POLICY IF EXISTS "Anyone can view active courses" ON public.courses;
CREATE POLICY "Anyone can view active courses"
  ON public.courses FOR SELECT
  USING (is_active = true);

-- Admin ALL-access on course_enrollments
DROP POLICY IF EXISTS "Admins have full access on course_enrollments" ON public.course_enrollments;
CREATE POLICY "Admins have full access on course_enrollments"
  ON public.course_enrollments FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('admin','super_admin')
    )
  );

-- Users can view own enrollments
DROP POLICY IF EXISTS "Users can view own course_enrollments" ON public.course_enrollments;
CREATE POLICY "Users can view own course_enrollments"
  ON public.course_enrollments FOR SELECT
  USING (user_id = auth.uid());

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. Ensure RLS + policies on tables that may have been deployed without them
-- ═══════════════════════════════════════════════════════════════════════════════

-- system_settings RLS
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can read system_settings" ON public.system_settings;
CREATE POLICY "Admins can read system_settings"
  ON public.system_settings FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('admin','super_admin')
    )
  );
DROP POLICY IF EXISTS "Admins can upsert system_settings" ON public.system_settings;
CREATE POLICY "Admins can upsert system_settings"
  ON public.system_settings FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('admin','super_admin')
    )
  );

-- feature_flags RLS
ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated users can read feature flags" ON public.feature_flags;
CREATE POLICY "Authenticated users can read feature flags"
  ON public.feature_flags FOR SELECT
  USING (auth.role() = 'authenticated');
DROP POLICY IF EXISTS "Admins can manage feature flags" ON public.feature_flags;
CREATE POLICY "Admins can manage feature flags"
  ON public.feature_flags FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('admin','super_admin')
    )
  );

-- coupons RLS
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active coupons" ON public.coupons;
CREATE POLICY "Anyone can view active coupons"
  ON public.coupons FOR SELECT
  USING (is_active = true);
DROP POLICY IF EXISTS "Admins can manage coupons" ON public.coupons;
CREATE POLICY "Admins can manage coupons"
  ON public.coupons FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('admin','super_admin')
    )
  );

-- tutor_profiles RLS
ALTER TABLE public.tutor_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view approved tutor profiles" ON public.tutor_profiles;
CREATE POLICY "Anyone can view approved tutor profiles"
  ON public.tutor_profiles FOR SELECT
  USING (status = 'approved' OR user_id = auth.uid());
DROP POLICY IF EXISTS "Tutors can insert/update own profile" ON public.tutor_profiles;
CREATE POLICY "Tutors can insert/update own profile"
  ON public.tutor_profiles FOR ALL
  USING (user_id = auth.uid());
DROP POLICY IF EXISTS "Admins can manage tutor_profiles" ON public.tutor_profiles;
CREATE POLICY "Admins can manage tutor_profiles"
  ON public.tutor_profiles FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('admin','super_admin')
    )
  );

-- ai_providers RLS
ALTER TABLE public.ai_providers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can read AI providers" ON public.ai_providers;
CREATE POLICY "Anyone can read AI providers"
  ON public.ai_providers FOR SELECT
  USING (true);
DROP POLICY IF EXISTS "Admins can manage AI providers" ON public.ai_providers;
CREATE POLICY "Admins can manage AI providers"
  ON public.ai_providers FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE auth_user_id = auth.uid() AND role IN ('admin','super_admin')
    )
  );
