-- Update is_admin() to accept all admin roles (not just admin/super_admin)
-- The role is stored in app_metadata.role on the JWT

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

-- Also update user_profiles admin policy to accept all admin roles
DROP POLICY IF EXISTS "Admins have full access on user_profiles" ON public.user_profiles;
CREATE POLICY "Admins have full access on user_profiles"
  ON public.user_profiles FOR ALL
  TO authenticated
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN (
      'super_admin', 'admin', 'finance_manager', 'support_manager',
      'content_manager', 'tutor_manager', 'marketing_manager'
    )
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN (
      'super_admin', 'admin', 'finance_manager', 'support_manager',
      'content_manager', 'tutor_manager', 'marketing_manager'
    )
  );
