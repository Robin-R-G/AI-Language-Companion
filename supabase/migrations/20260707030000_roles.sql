-- 20260707030000_roles.sql
-- Add role enum and role column to user_profiles for RBAC

-- Create enum type for roles (idempotent)
DO $$ BEGIN
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
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Add role column to user_profiles (default student)
ALTER TABLE public.user_profiles
    ADD COLUMN IF NOT EXISTS role public.user_role NOT NULL DEFAULT 'student';

-- Add tenant_id column for future multi‑tenant support (nullable for now)
ALTER TABLE public.user_profiles
    ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id);

-- Create index on role for fast queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);

-- Add RLS policy to restrict access based on role (example for admin)
DO $$ BEGIN
    CREATE POLICY "admin_access"
        ON public.user_profiles
        FOR ALL
        USING (auth.uid() = id OR EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = auth.uid() AND up.role IN ('admin', 'super_admin')
        ));
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
