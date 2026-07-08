-- migration: 20260707080000_seed_super_admin.sql
-- Seed the primary Super Admin account for the platform

-- Ensure pgcrypto extension is active
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Seed user into auth.users (so they can log in via Auth API)
DO $$ BEGIN
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        '33beec3c-a1d2-48bd-b901-d0ecbf6e3ab2',
        'authenticated',
        'authenticated',
        'therobinrg@gmail.com',
        crypt('RobinRG@Admin2', gen_salt('bf')),
        now(),
        '{"provider": "email", "providers": ["email"]}'::jsonb,
        '{"full_name": "Robin RG"}'::jsonb,
        now(),
        now(),
        '',
        '',
        '',
        ''
    ) ON CONFLICT (id) DO NOTHING;
EXCEPTION
    WHEN undefined_function THEN RAISE NOTICE 'pgcrypto not available, skipping auth.users seed';
END $$;

-- Seed profile with super_admin role
DO $$ BEGIN
    INSERT INTO public.user_profiles (
        id,
        auth_user_id,
        full_name,
        email,
        role
    ) VALUES (
        '33beec3c-a1d2-48bd-b901-d0ecbf6e3ab2',
        '33beec3c-a1d2-48bd-b901-d0ecbf6e3ab2',
        'Robin RG',
        'therobinrg@gmail.com',
        'super_admin'::public.user_role
    ) ON CONFLICT (email) DO UPDATE SET role = 'super_admin'::public.user_role;
EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'user_profiles schema differs, skipping seed';
    WHEN undefined_object THEN RAISE NOTICE 'user_role type not available, skipping seed';
END $$;
