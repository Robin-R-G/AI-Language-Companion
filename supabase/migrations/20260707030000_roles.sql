-- 20260707030000_roles.sql
-- Add role enum and role column to user_profiles for RBAC

-- Create enum type for roles
CREATE TYPE public.user_role AS ENUM (
    'student',
    'tutor',
    'admin',
    'super_admin',
    'finance_manager',
    'tutor_manager',
    'support_manager',
    'content_manager',
    'marketing_manager'
);

-- Add role column to user_profiles (default student)
ALTER TABLE public.user_profiles
    ADD COLUMN role public.user_role NOT NULL DEFAULT 'student';

-- Add tenant_id column for future multi‑tenant support (nullable for now)
ALTER TABLE public.user_profiles
    ADD COLUMN tenant_id uuid REFERENCES public.tenants(id);

-- Create index on role for fast queries
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);

-- Add RLS policy to restrict access based on role (example for admin)
CREATE POLICY "admin_access"
    ON public.user_profiles
    USING (auth.role() = 'admin' OR auth.role() = 'super_admin');

-- Note: Existing RLS policies in other files will need to reference the new role column.
