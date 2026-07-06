-- 20260707000000_multi_tenant.sql
-- Multi-tenant architecture foundation tables.

-- ── Tenants ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tenants (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name          text NOT NULL,
    slug          text NOT NULL UNIQUE,
    logo_url      text,
    domain        text UNIQUE,              -- custom domain for enterprise
    plan          text NOT NULL DEFAULT 'basic', -- basic, pro, enterprise
    max_users     int NOT NULL DEFAULT 100,
    is_active     boolean NOT NULL DEFAULT true,
    settings      jsonb DEFAULT '{}',
    created_by    uuid,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_tenants_slug   ON public.tenants(slug);
CREATE INDEX idx_tenants_domain ON public.tenants(domain);

-- ── Tenant Users (role within tenant context) ────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tenant_users (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id  uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    user_id    uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    role       text NOT NULL DEFAULT 'student',
    joined_at  timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, user_id)
);

CREATE INDEX idx_tenant_users_tenant_id ON public.tenant_users(tenant_id);
CREATE INDEX idx_tenant_users_user_id   ON public.tenant_users(user_id);

-- ── Tenant Features ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tenant_features (
    tenant_id  uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    feature    text NOT NULL,
    is_enabled boolean NOT NULL DEFAULT true,
    config     jsonb DEFAULT '{}',
    PRIMARY KEY (tenant_id, feature)
);

-- ── RLS ──────────────────────────────────────────────────────────────────────
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Super admins can manage tenants"
    ON public.tenants FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );
CREATE POLICY "Users can read their own tenant"
    ON public.tenants FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.tenant_users
            WHERE tenant_id = tenants.id AND user_id = auth.uid()
        )
    );

ALTER TABLE public.tenant_users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tenant admins can manage tenant users"
    ON public.tenant_users FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role IN ('super_admin', 'admin')
        )
    );

-- Add tenant_id column to user_profiles if not already present
ALTER TABLE public.user_profiles
    ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.tenants(id),
    ADD COLUMN IF NOT EXISTS revenuecat_user_id text UNIQUE;

CREATE INDEX IF NOT EXISTS idx_user_profiles_tenant_id ON public.user_profiles(tenant_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_revenuecat ON public.user_profiles(revenuecat_user_id);
