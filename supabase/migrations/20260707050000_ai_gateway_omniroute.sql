-- 20260707050000_ai_gateway_omniroute.sql
-- Seed AI providers, add routing rules per feature, and create failures tracking table.

-- ── Seed default providers in public.ai_providers ──────────────────────────
INSERT INTO public.ai_providers (name, display_name, is_enabled, priority, cost_per_input_token, cost_per_output_token) VALUES
  ('omniroute', 'OmniRoute', true, 1, 0.00000005, 0.00000015),
  ('openai', 'OpenAI', true, 2, 0.00000015, 0.00000060),
  ('gemini', 'Gemini', true, 3, 0.000000075, 0.00000030),
  ('groq', 'Groq', true, 4, 0.00000005, 0.00000008),
  ('anthropic', 'Anthropic', true, 5, 0.00000025, 0.00000125)
ON CONFLICT (name) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  priority = EXCLUDED.priority,
  cost_per_input_token = EXCLUDED.cost_per_input_token,
  cost_per_output_token = EXCLUDED.cost_per_output_token;

-- ── AI Feature Routing Table ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ai_feature_routing (
    feature           text PRIMARY KEY,
    provider_order    text[] NOT NULL,
    created_at        timestamptz NOT NULL DEFAULT now(),
    updated_at        timestamptz NOT NULL DEFAULT now()
);

-- Seed default routing orders
INSERT INTO public.ai_feature_routing (feature, provider_order) VALUES
  ('chat', ARRAY['omniroute', 'openai', 'gemini', 'groq']),
  ('grammar', ARRAY['omniroute', 'openai', 'gemini', 'anthropic']),
  ('vocabulary', ARRAY['omniroute', 'gemini', 'openai', 'groq']),
  ('writing', ARRAY['anthropic', 'openai', 'gemini']), -- IELTS/Essay doesn't automatically use OmniRoute
  ('speaking', ARRAY['openai', 'groq', 'gemini']),    -- Speaking Evaluation doesn't automatically use OmniRoute
  ('listening', ARRAY['omniroute', 'openai', 'groq', 'gemini']),
  ('reading', ARRAY['omniroute', 'openai', 'gemini', 'anthropic']),
  ('exam', ARRAY['openai', 'anthropic', 'gemini']),   -- Complex exam reasoning uses standard routing
  ('default', ARRAY['omniroute', 'openai', 'gemini', 'groq'])
ON CONFLICT (feature) DO UPDATE SET
  provider_order = EXCLUDED.provider_order,
  updated_at = now();

-- ── AI Failures Table ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ai_failures (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           uuid REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    provider          text NOT NULL,
    feature           text NOT NULL,
    error_message     text,
    created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_failures_provider ON public.ai_failures(provider);
CREATE INDEX IF NOT EXISTS idx_ai_failures_feature ON public.ai_failures(feature);
CREATE INDEX IF NOT EXISTS idx_ai_failures_created_at ON public.ai_failures(created_at);

-- ── Security & RLS Policies ──────────────────────────────────────────────────
ALTER TABLE public.ai_providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_feature_routing ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_failures ENABLE ROW LEVEL SECURITY;

-- Allow reading providers/routing to authenticated users
CREATE POLICY "Anyone can read AI providers"
    ON public.ai_providers FOR SELECT
    USING (true);

CREATE POLICY "Anyone can read AI routing configurations"
    ON public.ai_feature_routing FOR SELECT
    USING (true);

-- Allow super_admin to perform all operations on configuration tables
CREATE POLICY "Only admin can write AI providers"
    ON public.ai_providers FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );

CREATE POLICY "Only admin can write AI routing"
    ON public.ai_feature_routing FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );

-- Policies for AI Failures logging
CREATE POLICY "Users can read own AI failures"
    ON public.ai_failures FOR SELECT
    USING (auth.uid() = user_id OR EXISTS (
        SELECT 1 FROM public.user_profiles
        WHERE id = auth.uid() AND role = 'super_admin'
    ));

CREATE POLICY "Service role can insert AI failures"
    ON public.ai_failures FOR INSERT
    WITH CHECK (true);
