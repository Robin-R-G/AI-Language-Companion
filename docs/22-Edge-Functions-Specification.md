# Supabase Edge Functions Specification: AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Runtime Environment:** Deno v1.40+ (Supabase Edge Runtime)  
**Programming Language:** TypeScript  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the architecture, directory layouts, middle-tier components, security boundaries, and service APIs for the serverless Deno Edge Functions hosted on **Supabase**. 

It ensures a stateless, decoupled backend layer that handles authentication verification, prompt formatting, database operations, billing validations, and provider-agnostic AI integrations.

---

## 2. Directory Layout Architecture

Deno Edge Functions are structured under the `supabase/functions/` directory:

```text
supabase/
└── functions/
    ├── shared/                    # Reusable modules (Deno modules)
    │   ├── auth.ts                # JWT decode and session validation
    │   ├── database.ts            # Supabase Client initializations
    │   ├── errors.ts              # Global error class structures
    │   ├── ai.ts                  # Provider adapter abstractions
    │   ├── validator.ts           # Schema validation helpers
    │   └── logger.ts              # Structured audit log compiler
    │
    ├── auth-sync/                 # Sync profiles upon native signup
    ├── ai-chat/                   # Orchestrate text conversational loops
    ├── grammar-check/             # Inline grammatical analysis
    ├── translate/                 # Multi-language translations
    ├── vocabulary/                # SRS cards review queues
    ├── speaking-evaluate/         # Oral pronunciation grading
    ├── writing-evaluate/          # Essay coherence grading
    ├── voice-session/             # LiveKit WebRTC tokens allocations
    ├── lesson-engine/             # Recommend and complete syllabus
    ├── dashboard/                 # Fetch aggregate progress cards
    ├── achievements/              # Check XP badge status triggers
    ├── analytics/                 # Telemetry logs ingestion gateway
    ├── notifications/             # FCM schedules dispatching
    ├── subscriptions/             # stripe payments and IAP verify
    ├── webhooks/                  # stripe billing event listeners
    └── admin/                     # Feature flags and admin triggers
```

---

## 3. Shared Library Specification

The `/shared` folder contains reusable modules to prevent code duplication across Edge Functions:
*   **auth.ts:** Validates Bearer tokens and returns the active user's UUID.
*   **database.ts:** Instantiates Supabase DB clients using service-role or anon roles.
*   **errors.ts:** Standardizes error codes and compiles JSON error responses.
*   **ai.ts:** Contains provider adapters (Gemini, OpenAI) to switch models dynamically.
*   **validator.ts:** Parses JSON payloads and validates parameters.
*   **logger.ts:** Logs audit events while ensuring PII data is masked.

---

## 4. Edge Functions Profiles

### 4.1 auth-sync
*   **Purpose:** Triggers on auth schema changes to initialize profiles.
*   **Inputs:** Supabase Auth event payload.
*   **Output:** New record in `public.user_profiles` and default `user_goals` profiles.

### 4.2 ai-chat
*   **Purpose:** Coordinates conversational text chat.
*   **Inputs:** `message`, `conversation_id`, and `mode`.
*   **Output:** AI reply, grammar corrections array, and Kerala-bilingual scaffolding cards.

### 4.3 grammar-check
*   **Purpose:** Standard grammar checks.
*   **Inputs:** `text`.
*   **Output:** Corrected text, explanations, and rule categories.

### 4.4 translate
*   **Purpose:** Localized translations.
*   **Inputs:** `text`, `target_language`.
*   **Output:** Translation text, phonetic enunciation guides, and context notes.

### 4.5 vocabulary
*   **Purpose:** Manage Daily SRS queues.
*   **Inputs:** `word_id`, `mastery_score` (1-5 reviews).
*   **Output:** Calculated review date timestamps (`next_review`).

### 4.6 speaking-evaluate
*   **Purpose:** Evaluate speech pronunciation.
*   **Inputs:** Binary spoken audio file (multipart/form-data).
*   **Output:** Pronunciation details (fluency, clarity, stress scores) and feedback cards.

### 4.7 writing-evaluate
*   **Purpose:** Evaluate essay writing.
*   **Inputs:** `essay_text`, `prompt_id`.
*   **Output:** Coherence, vocabulary, and grammar scores, rewritten samples, and band scores.

### 4.8 voice-session
*   **Purpose:** Initialize LiveKit room access tokens.
*   **Inputs:** `language`, `ai_persona`.
*   **Output:** LiveKit token credentials, room coordinates, and `session_id`.

### 4.9 lesson-engine
*   **Purpose:** Recommend and complete lessons.
*   **Inputs:** `lesson_id`, `score`, `completion_percentage`.
*   **Output:** XP rewards earned, new streak counts, and syllabus updates.

### 4.10 dashboard
*   **Purpose:** Aggregate metrics for home layouts.
*   **Inputs:** JWT context.
*   **Output:** XP, streaks, levels, charts dataset, and exam score predictions.

### 4.11 achievements
*   **Purpose:** Claim unlocked badges.
*   **Inputs:** `achievement_id`.
*   **Output:** Unlocked badge status and XP reward flags.

### 4.12 analytics
*   **Purpose:** Ingest telemetry logs.
*   **Inputs:** Event names and properties dictionaries.
*   **Output:** Row written to `analytics_events`.

### 4.13 notifications
*   **Purpose:** Dispatch notifications.
*   **Inputs:** FCM payloads, trigger constraints.
*   **Output:** HTTP 200 to Firebase notifications services.

### 4.14 subscriptions
*   **Purpose:** Verify Stripe/IAP receipts.
*   **Inputs:** `purchase_token`, `plan_type`.
*   **Output:** Updated profiles subscription status and expiry dates.

### 4.15 webhooks
*   **Purpose:** Process external billing events (Stripe, Play Store).
*   **Inputs:** Provider webhook payloads.
*   **Output:** Updated DB profiles.

### 4.16 admin
*   **Purpose:** Admin settings.
*   **Inputs:** Feature flag configurations, prompt versions parameters.
*   **Output:** Updated configurations databases.

---

## 5. Deno Authentication Middleware Code Skeleton

Every Edge Function validates JWT keys using the shared auth middleware before processing requests:

```typescript
// supabase/functions/shared/auth.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

export async function validateRequest(req: Request) {
  // 1. Handle CORS preflight options
  if (req.method === 'OPTIONS') {
    return { isPreflight: true, response: new Response('ok', { headers: corsHeaders }) }
  }

  const authHeader = req.headers.get('Authorization')
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return {
      isPreflight: false,
      error: new Response(
        JSON.stringify({ success: false, error: { code: 'UNAUTHORIZED', message: 'Missing JWT' } }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      ),
    }
  }

  const token = authHeader.split(' ')[1]
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: authHeader } } }
  )

  // 2. Fetch authenticated user profile using token
  const { data: { user }, error } = await supabaseClient.auth.getUser(token)
  if (error || !user) {
    return {
      isPreflight: false,
      error: new Response(
        JSON.stringify({ success: false, error: { code: 'AUTH_FAILED', message: 'Invalid JWT' } }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      ),
    }
  }

  return { isPreflight: false, user, supabaseClient }
}
```

---

## 6. AI Provider Adapter Architecture
Functions decoupling prompt requests from AI endpoints route payloads through the adapter module:

```
  [Edge Function Request]
            |
            v
  [Shared Adapter: ai.ts]
            |
            | (Determine active provider and model variables)
            +---> [Route to Gemini Adapter -> Google REST Endpoint]
            |
            +---> [Route to OpenAI Adapter -> OpenAI REST Endpoint]
```

*   **Provider Fallback:** If the primary OpenAI endpoint returns status 503, the adapter automatically switches to the backup model (Gemini Flash) and repeats the request.

---

## 7. Error Handling Standard JSON Schema

Every Edge Function returns errors in a standard format:

```json
{
  "success": false,
  "error": {
    "code": "AI_TIMEOUT",
    "message": "AI provider timed out"
  }
}
```

*   **Standard Diagnostic Codes:** Includes `UNAUTHORIZED` (401), `RATE_LIMIT_MET` (429), `AI_TIMEOUT` (504), and `PAYMENT_REQUIRED` (402).

---

## 8. Logging & PII Security Rules
*   Every invocation logs execution metrics: `RequestId`, `UserId`, `FunctionName`, `DurationMs`, and `TokenUsage`.
*   **PII Masking:** Logs must exclude user passwords, email values, database credentials, or prompt transcript details to ensure data security.

---

## 9. Rate Limiting Configurations
*   Free Tier endpoints block invocations if limits are met (e.g., maximum 50 API requests per day).
*   API gateways automatically drop requests that exceed **100 requests per minute per IP address**.

---

## 10. CLI Deployment Strategy

Edge Functions are deployed using the Supabase CLI:
```bash
# Deploy all functions to production
supabase functions deploy --project-ref your_ref

# Deploy a single function
supabase functions deploy ai-chat --project-ref your_ref
```

---

## 11. Supabase Edge Functions Checklist

Verify Edge Functions against this checklist before production release:
*   [ ] Does the auth middleware validate JWT keys on all protected routes?
*   [ ] Do CORS configurations allow safe cross-origin preflight requests?
*   [ ] Are API keys and AI credentials stored securely in Deno environment variables?
*   [ ] Does the AI adapter switch to the backup provider if the primary model fails?
*   [ ] Do all errors return standard JSON envelopes?
*   [ ] Are PII data and text transcripts excluded from application logs?
*   [ ] Have rate limits been configured for free plans?
