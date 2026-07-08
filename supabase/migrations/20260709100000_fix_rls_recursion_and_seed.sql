-- Fix infinite recursion in user_profiles RLS + seed admin user + update is_admin()

-- 1. Drop ALL policies on user_profiles to break the recursion
DO $$ DECLARE
    pol record;
BEGIN
    FOR pol IN
        SELECT policyname FROM pg_policies WHERE tablename = 'user_profiles' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS "%s" ON public.user_profiles', pol.policyname);
    END LOOP;
END $$;

-- 2. Recreate is_admin() — uses raw_user_meta_data instead of user_profiles to avoid recursion
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = auth.uid()
      AND raw_user_meta_data ->> 'role' IN ('admin', 'super_admin')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Self-read policy (no recursion — checks auth.uid() directly)
CREATE POLICY "Users can read own profile"
  ON public.user_profiles FOR SELECT
  TO authenticated
  USING (auth_user_id = auth.uid());

-- 4. Admin full access policy — checks auth.users.raw_user_meta_data, not user_profiles
CREATE POLICY "Admins have full access on user_profiles"
  ON public.user_profiles FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE id = auth.uid()
        AND raw_user_meta_data ->> 'role' IN ('admin', 'super_admin')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE id = auth.uid()
        AND raw_user_meta_data ->> 'role' IN ('admin', 'super_admin')
    )
  );

-- 5. Insert admin profile if not exists (user already in auth.users)
INSERT INTO public.user_profiles (id, auth_user_id, full_name, email, role, is_active)
SELECT
  au.id,
  au.id,
  COALESCE(au.raw_user_meta_data ->> 'full_name', 'Robin RG'),
  au.email,
  'super_admin',
  true
FROM auth.users au
WHERE au.email = 'therobinrg@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM public.user_profiles up WHERE up.auth_user_id = au.id
  );
