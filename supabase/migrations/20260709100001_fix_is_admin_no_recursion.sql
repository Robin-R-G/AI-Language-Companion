-- Fix is_admin() to use auth.jwt() instead of querying user_profiles (avoids recursion)

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    auth.jwt() -> 'app_metadata' ->> 'role'
  ) IN ('admin', 'super_admin');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Also update user_profiles admin policy to use the same approach
DO $$ DECLARE
    pol record;
BEGIN
    FOR pol IN
        SELECT policyname FROM pg_policies WHERE tablename = 'user_profiles' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS "%s" ON public.user_profiles', pol.policyname);
    END LOOP;
END $$;

-- Self-read policy
CREATE POLICY "Users can read own profile"
  ON public.user_profiles FOR SELECT
  TO authenticated
  USING (auth_user_id = auth.uid());

-- Admin full access — checks app_metadata.role via JWT (no recursion)
CREATE POLICY "Admins have full access on user_profiles"
  ON public.user_profiles FOR ALL
  TO authenticated
  USING ((auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'super_admin'))
  WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'super_admin'));

-- Set role in raw_app_meta_data for the admin user
UPDATE auth.users
SET raw_app_meta_data = jsonb_set(
  COALESCE(raw_app_meta_data, '{}'),
  '{role}',
  '"super_admin"'
)
WHERE id = '1beec3ca-d12b-48bd-b901-d0ecbf6e3ab1';

-- Also set raw_user_meta_data for the login page check
UPDATE auth.users
SET raw_user_meta_data = jsonb_set(
  COALESCE(raw_user_meta_data, '{}'),
  '{role}',
  '"super_admin"'
)
WHERE id = '1beec3ca-d12b-48bd-b901-d0ecbf6e3ab1';
