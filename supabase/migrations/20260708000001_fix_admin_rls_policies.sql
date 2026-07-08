-- Migration: 20260708000001_fix_admin_rls_policies.sql
-- Fixes the is_admin() helper function to include 'super_admin' and adds self-read policy on user_profiles

-- 1. Fix is_admin() function to support both admin and super_admin roles
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

-- 2. Add RLS policy allowing authenticated users to select their own profile
DROP POLICY IF EXISTS "Users can read own profile" ON public.user_profiles;
CREATE POLICY "Users can read own profile"
  ON public.user_profiles FOR SELECT
  TO authenticated
  USING (auth_user_id = auth.uid());
