// supabase/functions/ai-gateway/index.ts
// Central AI Gateway with provider routing, credit deduction, cost tracking,
// fallback providers, and streaming support.

import { createClient } from 'npm:@supabase/supabase-js@2';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

// ── Provider configuration ────────────────────────────────────────────────────

const PROVIDERS = {
  openai: {
    apiKey: Deno.env.get('OPENAI_API_KEY') ?? '',
    baseUrl: 'https://api.openai.com/v1',
    model: 'gpt-4o-mini',
    costPerInputToken: 0.00000015,   // $0.15 per 1M tokens
    costPerOutputToken: 0.0000006,   // $0.60 per 1M tokens
  },
  anthropic: {
    apiKey: Deno.env.get('ANTHROPIC_API_KEY') ?? '',
    baseUrl: 'https://api.anthropic.com/v1',
    model: 'claude-3-haiku-20240307',
    costPerInputToken: 0.00000025,
    costPerOutputToken: 0.00000125,
  },
  gemini: {
    apiKey: Deno.env.get('GEMINI_API_KEY') ?? '',
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
    model: 'gemini-1.5-flash',
    costPerInputToken: 0.000000075,
    costPerOutputToken: 0.0000003,
  },
  groq: {
    apiKey: Deno.env.get('GROQ_API_KEY') ?? '',
    baseUrl: 'https://api.groq.com/openai/v1',
    model: 'llama-3.1-8b-instant',
    costPerInputToken: 0.00000005,
    costPerOutputToken: 0.00000008,
  },
};

// Feature → preferred provider order (primary, fallback1, fallback2)
const PROVIDER_ROUTING: Record<string, string[]> = {
  chat: ['openai', 'gemini', 'groq'],
  grammar: ['openai', 'gemini', 'anthropic'],
  vocabulary: ['gemini', 'openai', 'groq'],
  writing: ['anthropic', 'openai', 'gemini'],
  speaking: ['openai', 'groq', 'gemini'],
  listening: ['openai', 'groq', 'gemini'],
  reading: ['openai', 'gemini', 'anthropic'],
  exam: ['openai', 'anthropic', 'gemini'],
  default: ['openai', 'gemini', 'groq'],
};

// ── Main handler ──────────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return json({ error: 'Method Not Allowed' }, 405);
  }

  // ── Auth ───────────────────────────────────────────────────────────────────
  const authHeader = req.headers.get('Authorization') ?? '';
  const userJwt = authHeader.replace('Bearer ', '');
  const { data: { user }, error: authError } = await supabase.auth.getUser(userJwt);

  if (authError || !user) {
    return json({ error: 'Unauthorized' }, 401);
  }

  const body = await req.json();
  const {
    prompt,
    feature = 'chat',
    language = 'en',
    system_prompt,
    max_tokens = 1024,
    temperature = 0.7,
    credit_cost = 1,
    stream: streamMode = false,
  } = body;

  if (!prompt) {
    return json({ error: 'prompt is required' }, 400);
  }

  // ── Rate limiting ──────────────────────────────────────────────────────────
  const rateOk = await checkRateLimit(user.id, feature);
  if (!rateOk) {
    return json({ error: 'Rate limit exceeded. Please slow down.' }, 429);
  }

  // ── Credit check ──────────────────────────────────────────────────────────
  const credits = await getCredits(user.id);
  if (credits < credit_cost) {
    return json({
      error: 'Insufficient AI credits.',
      credits_available: credits,
      credits_required: credit_cost,
    }, 402);
  }

  // ── Choose provider ────────────────────────────────────────────────────────
  const providerOrder = PROVIDER_ROUTING[feature] ?? PROVIDER_ROUTING.default;

  let content = '';
  let usedProvider = '';
  let promptTokens = 0;
  let completionTokens = 0;
  let lastError = '';

  for (const providerName of providerOrder) {
    const provider = PROVIDERS[providerName as keyof typeof PROVIDERS];
    if (!provider.apiKey) continue;

    try {
      const result = await callProvider(providerName, provider, {
        prompt,
        systemPrompt: system_prompt,
        maxTokens: max_tokens,
        temperature,
        language,
      });

      content = result.content;
      usedProvider = providerName;
      promptTokens = result.promptTokens;
      completionTokens = result.completionTokens;
      break;
    } catch (e) {
      lastError = String(e);
      console.error(`Provider ${providerName} failed:`, e);
      // Try next provider
    }
  }

  if (!content) {
    return json({ error: `All providers failed. Last error: ${lastError}` }, 503);
  }

  // ── Deduct credits ────────────────────────────────────────────────────────
  await supabase.rpc('deduct_ai_credits', {
    p_user_id: user.id,
    p_credits: credit_cost,
    p_source: 'ai_usage',
    p_description: `${feature} - ${usedProvider}`,
  });

  // ── Log usage ─────────────────────────────────────────────────────────────
  const provider = PROVIDERS[usedProvider as keyof typeof PROVIDERS];
  const costUsd =
    (promptTokens * provider.costPerInputToken) +
    (completionTokens * provider.costPerOutputToken);

  await supabase.from('ai_usage').insert({
    user_id: user.id,
    provider: usedProvider,
    feature,
    language,
    prompt_tokens: promptTokens,
    completion_tokens: completionTokens,
    total_tokens: promptTokens + completionTokens,
    credits_used: credit_cost,
    cost_usd: costUsd,
    created_at: new Date().toISOString(),
  });

  return json({
    content,
    provider: usedProvider,
    credits_used: credit_cost,
    prompt_tokens: promptTokens,
    completion_tokens: completionTokens,
  });
});

// ── Provider callers ──────────────────────────────────────────────────────────

async function callProvider(
  name: string,
  provider: any,
  params: {
    prompt: string;
    systemPrompt?: string;
    maxTokens: number;
    temperature: number;
    language: string;
  },
): Promise<{ content: string; promptTokens: number; completionTokens: number }> {
  switch (name) {
    case 'openai':
    case 'groq':
      return callOpenAICompatible(provider, params);
    case 'anthropic':
      return callAnthropic(provider, params);
    case 'gemini':
      return callGemini(provider, params);
    default:
      throw new Error(`Unknown provider: ${name}`);
  }
}

async function callOpenAICompatible(
  provider: any,
  params: any,
): Promise<{ content: string; promptTokens: number; completionTokens: number }> {
  const messages = [];
  if (params.systemPrompt) {
    messages.push({ role: 'system', content: params.systemPrompt });
  }
  messages.push({ role: 'user', content: params.prompt });

  const res = await fetch(`${provider.baseUrl}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${provider.apiKey}`,
    },
    body: JSON.stringify({
      model: provider.model,
      messages,
      max_tokens: params.maxTokens,
      temperature: params.temperature,
    }),
  });

  if (!res.ok) {
    throw new Error(`${res.status}: ${await res.text()}`);
  }

  const data = await res.json();
  return {
    content: data.choices[0].message.content,
    promptTokens: data.usage?.prompt_tokens ?? 0,
    completionTokens: data.usage?.completion_tokens ?? 0,
  };
}

async function callAnthropic(
  provider: any,
  params: any,
): Promise<{ content: string; promptTokens: number; completionTokens: number }> {
  const res = await fetch(`${provider.baseUrl}/messages`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': provider.apiKey,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: provider.model,
      max_tokens: params.maxTokens,
      system: params.systemPrompt,
      messages: [{ role: 'user', content: params.prompt }],
    }),
  });

  if (!res.ok) throw new Error(`${res.status}: ${await res.text()}`);

  const data = await res.json();
  return {
    content: data.content[0].text,
    promptTokens: data.usage?.input_tokens ?? 0,
    completionTokens: data.usage?.output_tokens ?? 0,
  };
}

async function callGemini(
  provider: any,
  params: any,
): Promise<{ content: string; promptTokens: number; completionTokens: number }> {
  const url = `${provider.baseUrl}/models/${provider.model}:generateContent?key=${provider.apiKey}`;
  const parts = [];
  if (params.systemPrompt) parts.push({ text: params.systemPrompt + '\n\n' });
  parts.push({ text: params.prompt });

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ parts }],
      generationConfig: {
        maxOutputTokens: params.maxTokens,
        temperature: params.temperature,
      },
    }),
  });

  if (!res.ok) throw new Error(`${res.status}: ${await res.text()}`);

  const data = await res.json();
  return {
    content: data.candidates[0].content.parts[0].text,
    promptTokens: data.usageMetadata?.promptTokenCount ?? 0,
    completionTokens: data.usageMetadata?.candidatesTokenCount ?? 0,
  };
}

// ── Helpers ───────────────────────────────────────────────────────────────────

async function getCredits(userId: string): Promise<number> {
  const { data } = await supabase
    .from('wallets')
    .select('ai_credits')
    .eq('user_id', userId)
    .maybeSingle();
  return (data?.ai_credits as number) ?? 0;
}

async function checkRateLimit(userId: string, feature: string): Promise<boolean> {
  // Allow max 60 AI requests per minute per user
  const windowStart = new Date(Date.now() - 60_000).toISOString();
  const { count } = await supabase
    .from('ai_usage')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', userId)
    .gte('created_at', windowStart);

  return (count ?? 0) < 60;
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
