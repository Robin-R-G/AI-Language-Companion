# Analytics & Events Document: AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Telemetry SDKs:** Firebase Analytics, PostHog, Firebase Crashlytics  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the analytics strategy, event taxonomy, user properties registry, conversion funnel tracking, KPI definitions, and product telemetry controls for **AI Language Coach**. 

It provides product managers, data engineers, and mobile developers with a unified tracking blueprint to measure user engagement, improve learning retention, optimize AI prompt performance, and monitor subscription conversion.

---

## 2. Analytics Stack Architecture
The telemetry system combines client-side event tracking with backend usage monitoring:
*   **Firebase Analytics:** Core mobile event tracking, conversion attribution, and Google Play/App Store optimization signals.
*   **PostHog:** User journey visual maps, cohort retention analytics, A/B testing variables, and conversion funnels.
*   **Supabase PostgreSQL Logs:** Tracks server-side metrics, API latency, token usages, and database changes.
*   **Firebase Crashlytics:** Automated crash recording, ANR monitoring, and error stack trace dumps.

---

## 3. Event Naming Protocol
Events are written in a standardized snake_case format:

> **Format:** `[category]_[action]_[object]`

### Constraints:
*   Use lowercase strings only.
*   Keep event names descriptive and short (under 40 characters).
*   Avoid adding dynamic values (IDs, names) to the event title. Route these details to the properties dictionary instead.
*   Once an event is deployed, its name and properties list are locked (immutable) to prevent database regressions.

---

## 4. User Properties Registry

User properties represent persistent attributes linked to the user's profile:

```
+---------------------------+---------------------------+-------------------------------------------+
| PROPERTY KEY              | DATA TYPE                 | PURPOSE & DETAILS                         |
+---------------------------+---------------------------+-------------------------------------------+
| native_language           | String                    | Native language (L1) - e.g., Malayalam     |
+---------------------------+---------------------------+-------------------------------------------+
| target_language           | String                    | Learning target (L2)                      |
+---------------------------+---------------------------+-------------------------------------------+
| proficiency_level         | String                    | Target level (A1 to C2)                   |
+---------------------------+---------------------------+-------------------------------------------+
| target_exam               | String                    | Target exam (IELTS, PTE, Goethe, None)    |
+---------------------------+---------------------------+-------------------------------------------+
| subscription_plan         | String                    | Free, Premium, Premium+                   |
+---------------------------+---------------------------+-------------------------------------------+
| onboarding_completed      | Boolean                   | Onboarding process state                  |
+---------------------------+---------------------------+-------------------------------------------+
| streak_days               | Integer                   | Consecutive active study days             |
+---------------------------+---------------------------+-------------------------------------------+
| country                   | String                    | User country code (ISO 3166-1)            |
+---------------------------+---------------------------+-------------------------------------------+
| app_version               | String                    | Mobile build number                       |
+---------------------------+---------------------------+-------------------------------------------+
```

---

## 5. Authentication & Onboarding Events

```
+---------------------------+-------------------------------------------------------+---------------------------------------+
| EVENT NAME                | TRIGGER CONDITION                                     | PROPERTY ARRAYS                       |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| auth_signup_started       | User clicks register button                           | auth_method (Email, Google, Apple)    |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| auth_signup_completed     | Verification link dispatched successfully            | auth_method, user_id                  |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| auth_login_success        | User signs in successfully                           | auth_method, user_id, subscription_plan|
+---------------------------+-------------------------------------------------------+---------------------------------------+
| auth_login_failed         | Credentials verification fails                        | auth_method, error_code               |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| onboarding_started        | User opens first screen of onboarding wizard          | country, app_version                  |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| onboarding_completed      | User finishes onboarding diagnostic                   | native_language, target_exam, target_level|
+---------------------------+-------------------------------------------------------+---------------------------------------+
```

---

## 6. Lessons & Vocabulary Events

```
+---------------------------+-------------------------------------------------------+---------------------------------------+
| EVENT NAME                | TRIGGER CONDITION                                     | PROPERTY ARRAYS                       |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| lesson_started            | User clicks "Start Lesson"                            | lesson_id, lesson_type, difficulty    |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| lesson_completed          | User answers last question and claims XP              | lesson_id, score, time_spent_seconds  |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| word_saved                | User bookmarks a card during review                   | word_id, category, user_level         |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| vocabulary_quiz_completed | User finishes a spaced repetition review quiz         | cards_reviewed, correct_percentage    |
+---------------------------+-------------------------------------------------------+---------------------------------------+
```

---

## 7. AI Chat & Voice Call Events

```
+---------------------------+-------------------------------------------------------+---------------------------------------+
| EVENT NAME                | TRIGGER CONDITION                                     | PROPERTY ARRAYS                       |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| chat_message_sent         | User clicks send text message                         | model, conversation_id, message_length|
+---------------------------+-------------------------------------------------------+---------------------------------------+
| chat_response_received    | Backend returns AI response                           | latency_ms, tokens_used, model        |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| voice_session_started     | LiveKit room connection starts                        | session_id, language, persona         |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| voice_connected           | WebRTC audio stream established                       | connection_time_ms, server_region     |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| voice_interrupted         | User barge-in cancels active TTS playback             | duration_seconds, cancel_latency_ms   |
+---------------------------+-------------------------------------------------------+---------------------------------------+
| voice_session_completed   | User ends call session                                | duration_seconds, average_latency_ms  |
+---------------------------+-------------------------------------------------------+---------------------------------------+
```

---

## 8. Grammar & Translation Events
*   `grammar_correction_accepted`: Triggered when a user taps inline dotted lines and opens a grammar correction card. Properties: `word_id`, `rule_type`, `language`.
*   `translation_requested`: Triggered when a user clicks the L1 translation toggle to view explanations in Malayalam. Properties: `source_length`, `level`.

---

## 9. Mock Exam Events
*   `mock_exam_started`: Triggered when a user opens a timed diagnostic mock exam. Properties: `exam_id`, `exam_type`, `limit_minutes`.
*   `mock_exam_submitted`: Triggered when the final answer payload is sent. Properties: `attempt_id`, `score`, `duration_minutes`.

---

## 10. Gamification & Streaks
*   `xp_earned`: Triggered on lesson or quiz completions. Properties: `amount`, `source` (`Lesson`, `DailyGoal`, `Achievement`).
*   `streak_extended`: Triggered when a user completes their first daily study task. Properties: `streak_days`, `freeze_consumed` (boolean).
*   `streak_lost`: Triggered when the database reset trigger fires. Properties: `lost_streak_count`.

---

## 11. Subscription & billing
*   `paywall_viewed`: Triggered when a free plan user hits gating blocks. Properties: `trigger_source` (`MockExam`, `VoiceLimit`, `DashboardUpgrade`).
*   `subscription_purchased`: Triggered when Stripe/IAP verified receipts updates profiles. Properties: `plan` (`Premium`, `Premium+`), `billing_cycle` (`Monthly`, `Annual`), `price_usd`.
*   `subscription_cancelled`: Triggered when a cancellation request is logged. Properties: `plan`, `expiry_date`.

---

## 12. Error telemetry
*   `api_failed`: Triggered when an API request fails. Properties: `error_code`, `endpoint`, `http_status`, `retry_count`.
*   `voice_error`: Triggered when a LiveKit session drops. Properties: `error_message`, `reconnect_successful` (boolean).

---

## 13. Conversion Funnel Structures

Funnels track drop-off rates across user paths:

### 13.1 Signup & First Lesson Funnel
```text
  [1. App Open] ---> [2. Signup Started] ---> [3. Onboarding Completed]
                                                      |
                                                      v
  [6. Day 2 Return] <--- [5. First Lesson Done] <--- [4. Profile Diagnostic Completed]
```

### 13.2 Subscription Upgrade Funnel
```text
  [1. Active User] ---> [2. Hits Premium Gate] ---> [3. Renders Paywall Screen]
                                                            |
                                                            v
  [5. Sub active] <--- [4. Clicks Buy Plan (IAP)] <--------+
```

---

## 14. Cohort Retention Matrix
PostHog tracks retention by grouping users into weekly signup cohorts:
*   **Retention benchmarks:** Goal retention rates:
    *   Day 1 Retention: **>50%**.
    *   Day 7 Retention: **>40%**.
    *   Day 30 Retention: **>35%**.
    *   Day 90 Retention: **>20%**.

---

## 15. Real-Time AI Metrics
*   **Response Pacing:** Average latency must remain under the 2.0-second SLA.
*   **Token Consumption:** Monthly tracking of input/output token usage per user to manage infrastructure costs.
*   **Hallucination Rate:** Thumbs-down events flagged with *"Incorrect grammar/translation"* must remain below 2% of total requests.

---

## 16. Key Performance Indicators (KPIs)
*   **DAU/MAU Stickiness:** Target stickiness ratio of **>25%** (`DAU / MAU * 100`).
*   **Subscription Conversion:** Target conversion of **>5%** from free to paid tiers.
*   **Learner Success Metric:** User speaking speed increases (WPM) and grammar score increases verified over 30-day periods.

---

## 17. Telemetry Privacy & Data Quality (GDPR)
*   **PII Masking:** Exclude passwords, emails, names, and transcript texts from analytics payloads.
*   **GDPR Erasure Sync:** When a user deletes their account, dispatch deletion requests to PostHog and Firebase to wipe their analytics data.
*   **Data Validation:** GitHub CI runs checking routines on the events properties JSON schemas to prevent schema mismatch errors during backend updates.

---

## 18. Analytics Implementation Checklist

Verify the analytics setup against this checklist before production release:
*   [ ] Do event names follow the `category_action_object` snake_case naming protocol?
*   [ ] Are PII data and text transcripts excluded from analytics payloads?
*   [ ] Do onboarding and subscription funnels track drop-offs correctly?
*   [ ] Does the database reset trigger fire `streak_lost` events correctly?
*   [ ] Have PostHog and Firebase SDK configurations been tested for offline events caching?
*   [ ] Does deleting an account trigger corresponding data deletions in Firebase and PostHog?
*   [ ] Are daily token consumption logs active in the backend dashboards?
