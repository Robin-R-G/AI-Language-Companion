-- migration: 20260707080000_seed_super_admin.sql
-- Seed the primary Super Admin account for the platform

-- Ensure pgcrypto extension is active
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

-- Seed user into auth.users (so they can log in via Auth API)
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

-- Seed profile with super_admin role
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
