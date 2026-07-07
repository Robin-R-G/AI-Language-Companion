-- migration: 20260707070000_pxpipe_optimization_layer.sql
-- Create PxPipe Analytics tracking schema

CREATE TABLE IF NOT EXISTS public.pxpipe_analytics (
    id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    ai_usage_id            uuid REFERENCES public.ai_usage(id) ON DELETE SET NULL,
    intent                 text NOT NULL,
    original_prompt_size   int NOT NULL DEFAULT 0,
    optimized_prompt_size  int NOT NULL DEFAULT 0,
    token_savings          int NOT NULL DEFAULT 0,
    is_cache_hit           boolean NOT NULL DEFAULT false,
    latency_ms             int NOT NULL DEFAULT 0,
    provider_used          text NOT NULL,
    cost_savings_usd       numeric(20,12) NOT NULL DEFAULT 0,
    created_at             timestamptz NOT NULL DEFAULT now()
);

-- Add indexes for admin dashboard filters
CREATE INDEX IF NOT EXISTS idx_pxpipe_analytics_user_id ON public.pxpipe_analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_pxpipe_analytics_intent ON public.pxpipe_analytics(intent);
CREATE INDEX IF NOT EXISTS idx_pxpipe_analytics_created_at ON public.pxpipe_analytics(created_at);

-- RLS policies
ALTER TABLE public.pxpipe_analytics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own pxpipe analytics" 
    ON public.pxpipe_analytics FOR SELECT
    USING (auth.uid() = (SELECT auth_user_id FROM public.user_profiles WHERE id = user_id));

CREATE POLICY "Admin can read all pxpipe analytics"
    ON public.pxpipe_analytics FOR SELECT
    USING (public.is_admin_check());
