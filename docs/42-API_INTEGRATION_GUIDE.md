# API Integration Guide: Frontend & Backend (42-API_INTEGRATION_GUIDE)
**Version:** 1.0  
**Status:** Production  
**Target Environment:** Frontend Dio Client, Deno Edge Functions, WebRTC Gateways  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines how every third-party service and API provider is integrated into the **AI Language Coach** platform. 

It ensures secure API usage, robust error handling, low-latency audio transport, and provider abstractions that prevent vendor lock-in.

---

## 2. Integration Architecture
To prevent the user interface from calling LLM APIs or database services directly, the app follows a strict decoupling pattern:

```
Flutter App UI Layer
         │
         ▼
  Repository Layer
         │
         ▼
   Service Layer
         │
         ▼
  Provider Abstraction (AIProvider Interface)
         │
  ┌──────┴──────────────────────┐
  │                             │
  ▼                             ▼
OpenAI Client             Gemini Client
  │                             │
  └──────────────┬──────────────┘
                 │
                 ▼
          Unified Response
```

---

## 3. Environment Variables Registry
All API keys, secrets, and connection URLs must be loaded securely from environment variables. Do not commit these values to the git repository:
*   `SUPABASE_URL`: Core DB server URL.
*   `SUPABASE_ANON_KEY`: Client authorization key.
*   `OPENAI_API_KEY`: Primary LLM credentials.
*   `GEMINI_API_KEY`: Fallback LLM credentials.
*   `LIVEKIT_URL`: WebRTC audio server address.
*   `LIVEKIT_API_KEY` & `LIVEKIT_API_SECRET`: Token generation secret.
*   `FIREBASE_PROJECT_ID`: Push notification configuration.
*   `REVENUECAT_PUBLIC_KEY`: Purchase receipt validation.
*   `POSTHOG_API_KEY`: Event logging key.

---

## 4. Service Integration Specifications

### 4.1 Supabase Backend Integration
*   **Scope:** User authentication, PostgreSQL schema, storage buckets, realtime synchronization, and Deno Edge Functions.
*   **Rules:** Enforce Row-Level Security (RLS) policies on all tables. Restrict public storage bucket read/write permissions.

### 4.2 AI Provider Abstraction Interface
The codebase defines a unified interface to interact with language models:
```dart
abstract class AIProvider {
  Future<AIResponse> chat(List<ChatMessage> history);
  Future<GrammarResult> grammar(String text);
  Future<TranslationResult> translate(String text, String targetLang);
  Future<WritingScore> evaluateWriting(String essay, String prompt);
}
```

### 4.3 OpenAI Integration (Primary Provider)
*   **Scope:** Streaming conversation chat, essay evaluations, and grammar corrections.
*   **Rules:** Stream response chunks to minimize time-to-first-token. Limit context history sizes to control token overheads.

### 4.4 Gemini Integration (Backup/Secondary Provider)
*   **Scope:** Backup conversational chat, translation tasks, and vocabulary explanations.
*   **Rules:** Implement the same `AIProvider` interface to support seamless hot-swapping during OpenAI service outages.

### 4.5 Translation Service (Malayalam Scaffolding)
*   **Scope:** Dual English-Malayalam translations and pronunciation transliteration guides.
*   **Rules:** Support dynamic explanation fading based on user CEFR levels.

### 4.6 Speech-to-Text (STT) & Text-to-Speech (TTS)
*   **STT Scope:** Audio voice recognition, transcription stream, and accent tolerance filters.
*   **TTS Scope:** Adaptive speech pacing (adjustable speeds), pronunciation replays.

### 4.7 LiveKit Audio Transport
*   **Scope:** WebRTC voice sessions, room token allocations, and active voice activity detection (VAD).
*   **Workflow:**
    ```
    Create Token (Edge Function) ---> Join Room (Client) ---> Live Call (WebRTC) ---> Disconnect & Cleanup
    ```

### 4.8 RevenueCat Payments Integration
*   **Scope:** In-app purchase validations, entitlements, and restore purchases actions.
*   **Products:** `Premium Monthly` and `Premium Yearly` subscriptions.

---

## 5. Resilience & Error Handling Strategies

### 5.1 Exponential Backoff Retry Policy
Only transient network failures (HTTP 502/503/504 or socket timeouts) are retried automatically. Do not retry authentication errors or client-side bad requests.
*   **Attempt 1:** Send request. If fail, wait 1 second.
*   **Attempt 2:** Retry request. If fail, wait 2 seconds.
*   **Attempt 3:** Retry request. If fail, wait 4 seconds.
*   **Final Action:** Fail gracefully and display a friendly error message to the user.

### 5.2 Rate Limiting
*   **Client Quotas:** Limit free-tier users to 50 chat messages and 10 voice minutes per day.
*   **API Gateway limits:** Edge Functions drop requests exceeding **100 requests per minute per IP address**.

### 5.3 Local Caching (Offline Capabilities)
*   **Cached Assets:** Cache user profiles, vocabulary list tags, and static lesson data locally.
*   **Write Queue:** Enqueue offline mutations. Sync changes with Supabase once the network is restored.

---

## 6. Security, Logging & Telemetry

*   **Security SLA:** Enforce HTTPS/WSS protocols exclusively. Rotate keys regularly, and audit database permissions.
*   **Logging Rules:** Log API request IDs, latency metrics, and HTTP error codes. Never log user passwords, secure tokens, personal conversations, or credit card details.
*   **Monitoring Metrics:** Track Edge Function latency, LiveKit packet loss, and database transaction times. Alert developers on critical threshold violations.

---

## 7. API Integration Verification Checklist

Verify integrations against this checklist before production release:
*   [ ] Are environment variables loaded securely without committing secrets?
*   [ ] Is the `AIProvider` interface implemented by both OpenAI and Gemini clients?
*   [ ] Does the voice room generator create valid tokens using LiveKit secrets?
*   [ ] Has the exponential backoff retry policy been verified on transient timeouts?
*   [ ] Do edge function calls run under HTTPS protocols?
*   [ ] Are user-facing error messages clean and free of technical stack trace leaks?
*   [ ] Have mock interfaces been created for all integrations to run offline unit tests?
