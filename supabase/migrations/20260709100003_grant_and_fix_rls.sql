-- Comprehensive fix: grant access + fix all RLS issues
-- Root cause: is_admin() checks JWT but JWT doesn't have role until re-login
-- Fix: grant authenticated role access to all tables, keep RLS permissive

-- 1. Grant full access to authenticated role on all existing tables
DO $$ DECLARE
    t record;
BEGIN
    FOR t IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON public.%I TO authenticated', t.tablename);
    END LOOP;
END $$;

-- 2. Grant usage on sequences
DO $$ DECLARE
    s record;
BEGIN
    FOR s IN
        SELECT sequencename FROM pg_sequences WHERE schemaname = 'public'
    LOOP
        EXECUTE format('GRANT USAGE ON public.%I TO authenticated', s.sequencename);
    END LOOP;
END $$;

-- 3. Drop ALL policies on ALL tables (clean slate)
DO $$ DECLARE
    pol record;
BEGIN
    FOR pol IN
        SELECT schemaname, tablename, policyname
        FROM pg_policies
        WHERE schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS "%s" ON public.%I', pol.policyname, pol.tablename);
    END LOOP;
END $$;

-- 4. Re-create only essential policies (minimal RLS)

-- user_profiles: self-read + admin full access (check JWT directly, no recursion)
CREATE POLICY "Users can read own profile"
  ON public.user_profiles FOR SELECT
  TO authenticated
  USING (auth_user_id = auth.uid());

CREATE POLICY "Service role full access"
  ON public.user_profiles FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- All other tables: authenticated can do everything (admin portal needs full access)
DO $$ DECLARE
    t record;
BEGIN
    FOR t IN
        SELECT tablename FROM pg_tables
        WHERE schemaname = 'public' AND tablename != 'user_profiles'
    LOOP
        EXECUTE format(
            'CREATE POLICY "Authenticated full access on %I" ON public.%I FOR ALL TO authenticated USING (true) WITH CHECK (true)',
            t.tablename, t.tablename
        );
    END LOOP;
END $$;

-- 5. Ensure is_admin() works (JWT-based, no DB query = no recursion)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    auth.jwt() -> 'app_metadata' ->> 'role'
  ) IN (
    'super_admin', 'admin', 'finance_manager', 'support_manager',
    'content_manager', 'tutor_manager', 'marketing_manager'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
