# Software Requirements Specification (SRS): AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Author:** Robin R G  
**Last Updated:** July 2026  

---

## 1. System Overview
**AI Language Coach** is an intelligent, voice-first mobile application designed to bridge the gap between passive language comprehension and active conversational speech. The system acts as a personalized, adaptive language tutor and mock examiner, enabling users to build confidence, identify grammatical or pronunciation gaps, and prepare for high-stakes international examinations (IELTS, PTE, TOEFL, OET, Goethe, TestDaF, DELF, JLPT, and TOPIK).

By leveraging real-time WebRTC audio streaming pipelines, generative artificial intelligence (LLMs), dynamic native-language (L1) scaffolding, and persistent user memory graphs, AI Language Coach simulates the role of a private, high-fidelity native tutor at a fraction of the cost, making conversational fluency globally accessible.

---

## 2. Business Goals
*   **Democratic Accessibility:** Provide highly personalized, oral language coaching globally, targeting regions lacking access to native speaking partners.
*   **Exam Excellence:** Empower candidates to achieve verified target band scores (e.g., IELTS Band 7.0+, Goethe B2+) through simulations that mirror official testing environments.
*   **Pedagogical Calibration:** Transition learners from recognition memory to active recall through real-time feedback loops and contextual grammar corrections.
*   **Commercial Viability:** Acquire **100,000+ registered downloads** in Year 1, converting **30% of active users** to premium plans through highly valued features.

---

## 3. Target Platforms
*   **Android Mobile:** Compiled natively via Flutter, supporting Android 9.0 (API Level 28) and higher.
*   **iOS Mobile:** Compiled natively via Flutter, supporting iOS 15.0 and higher.
*   *Future Roadmap Extensions:* Cross-platform Web Client (compiled via Flutter Web) and Desktop clients (macOS/Windows) designed for institutional dashboard use.

---

## 4. Functional Requirements

The system's functional capabilities are detailed in the sections below.

### FR-001: User Registration
*   **Description:** The system must allow new users to create accounts using multiple authentication methods.
*   **System Action:**
    1.  *Email Signups:* Validate email uniqueness and format, encrypt password hash, and trigger a verification email link via Supabase Auth.
    2.  *Social SSO Signups:* Obtain OAuth credentials from Google Play Services or Apple Identity services, register profile maps in the `users` database table, and issue a session JWT.
*   **Edge Cases:**
    *   *Duplicate Email:* Display: *"An account with this email already exists."*
    *   *Invalid Email Format:* Deny submission, highlighting the input field in red.
*   **Acceptance Criteria:** Account is successfully created in Supabase Auth, and the user is routed directly to the Onboarding wizard.

### FR-002: User Authentication
*   **Description:** Enforce secure user login, session caching, password resets, and session termination.
*   **System Action:**
    *   *Login:* Authenticate credential tokens against Supabase Auth. Cache JWT locally in secure device storage (Keychain/Keystore).
    *   *Session Refresh:* Automatically refresh JWT tokens in the background every 50 minutes.
    *   *Reset Password:* Validate registered emails, send password reset OTPs or redirect links, and enforce update validations.
*   **Acceptance Criteria:** Active JWT sessions persist across app restarts until explicit logouts are triggered.

### FR-003: User Profile Management
*   **Description:** Maintain and update user preferences, targets, and subscription status in the database.
*   **System Inputs:** Name, profile image data, selection of native language (L1), target language (L2), target CEFR level, target exam goal, and active subscription indicators.
*   **Acceptance Criteria:** Changes saved in the profile view must reflect instantly in PostgreSQL.

### FR-004: Onboarding Wizard
*   **Description:** Guide new users through configuration screens to construct their initial syllabus.
*   **System Inputs:** Select Native Language ( Malayalam support standard), Learning Language, Current Level, Target Exam, Target Score, and Daily Study Time.
*   **System Output:** Initialize the user's personal memory graph and generate a tailored 30-day learning plan.
*   **Acceptance Criteria:** The onboarding wizard cannot be skipped. Uncompleted onboarding routes must redirect back to onboarding step 1.

### FR-005: AI Text Chat
*   **Description:** Provide real-time chat conversations with dynamic grammar corrections.
*   **System Action:** Receive user text, query Gemini API (via Supabase Edge Functions), return conversational answers, and output asynchronous grammar evaluation cards.
*   **Acceptance Criteria:** Conversational replies return under 2 seconds. Clicking on grammatical mistakes overlays a detailed correction card.

### FR-006: AI Voice Calls (LiveKit-Powered)
*   **Description:** Establish hands-free, real-time voice sessions with the AI Coach.
*   **System Action:** Connect to LiveKit WebRTC channel, stream audio to Whisper STT, send transcribed text to the LLM agent, synthesize the response using ElevenLabs/Cartesia TTS, and stream audio chunks back to the client.
*   **Interruption Handling:** When user speech is detected by client-side Voice Activity Detection (VAD) during AI speech output, the client must send a WebSockets cancel signal to stop AI audio play immediately.
*   **Acceptance Criteria:** Average voice call response latency is under 800ms. Audio continues without drops on connection drops by triggering reconnection handshakes.

### FR-007: Grammar Correction Engine
*   **Description:** Parse and highlight grammatical syntax errors in user inputs.
*   **System Output:** Generate structured correction boxes containing:
    1.  *Original Sentence:* (User's input).
    2.  *Corrected Sentence:* (Grammatically correct version).
    3.  *Explanation:* (Why the error occurred).
    4.  *Alternative Examples:* (2-3 native equivalent phrases).
*   **Acceptance Criteria:** Grammatical corrections are logged in the user's personal review deck.

### FR-008: Native Language Assistance (Scaffolding)
*   **Description:** Use the user's native language to explain target language grammar rules.
*   **System Action:** Detect the chosen L1 (e.g., Malayalam). Display grammar corrections and vocabulary definitions in Malayalam.
*   **Decay Logic:** As the user's vocabulary and grammar metrics improve, the system must reduce L1 assistance by 15% per level, shifting toward total immersion.
*   **Acceptance Criteria:** Users can request manual translation cards by double-tapping target-language phrases.

### FR-009: Pronunciation Analysis
*   **Description:** Analyze and grade user spoken audio samples.
*   **System Action:** Process voice packet frequencies to generate scores (0–100%) for:
    *   *Fluency:* Words spoken per minute and pause durations.
    *   *Clarity:* Syllable alignment with standard phonetic charts.
    *   *Stress:* Correct syllable-level emphasis.
    *   *Intonation:* Pitch modulation analysis showing emotional expressions.
    *   *Confidence:* Hesitation and repetition counts.
*   **Acceptance Criteria:** Highlight words in Red (errors), Yellow (issues), and Green (correct) on transcript panels.

### FR-010: Vocabulary Trainer
*   **Description:** Facilitate vocabulary memorization through spaced repetition.
*   **System Action:** Queue words flagged as weak in a Spaced Repetition System (SRS) using the SuperMemo-2 algorithm. Schedule reviews and send daily push notification alerts.
*   **Acceptance Criteria:** Users can swipe cards to self-evaluate, adjusting the next review interval dynamically.

### FR-011: Reading Practice
*   **Description:** Generate and assess reading comprehension exercises.
*   **System Action:** Retrieve articles, emails, or mock academic texts matching the target exam. Provide interactive multiple-choice questions with explanations.
*   **Acceptance Criteria:** Scores and time spent are saved to progress dashboards.

### FR-012: Listening Practice
*   **Description:** Play native audio exercises with comprehension checks.
*   **System Action:** Stream mock conversations, podcasts, or lectures. Provide audio control sliders (talking speed adjustments) and multiple-choice questions.
*   **Acceptance Criteria:** Responses are graded automatically upon submission.

### FR-013: Writing Evaluation
*   **Description:** Grade writing essays using standardized exam rubrics.
*   **System Inputs:** Typed essays or reports.
*   **System Action:** Run scoring prompts via OpenAI API evaluating:
    *   *Grammar range & accuracy*
    *   *Vocabulary resource variety*
    *   *Coherence & paragraph flow*
    *   *Task completion accuracy*
*   **Acceptance Criteria:** Provide estimated band scores and detailed, inline grammar correction marks within 30 seconds.

### FR-014: Speaking Evaluation (Mock Exams)
*   **Description:** Simulate timed oral exams (IELTS, PTE, TOEFL, OET, Goethe).
*   **System Action:** Launch mock test screens with strict timers. AI Examiner leads structured interview sections.
*   **Acceptance Criteria:** Generate full band score estimates and detailed pronunciation and grammar diagnostics upon test completion.

### FR-015: Adaptive Learning Engine
*   **Description:** Automatically scale lesson difficulty based on user metrics.
*   **System Action:** Monitor daily success rates. If scores fall below 60%, automatically reduce sentence speed and vocabulary complexity. If scores exceed 90%, increase difficulty.
*   **Acceptance Criteria:** Dynamic updates are made to the user's daily study agenda.

### FR-016: AI Memory Graph
*   **Description:** Maintain user context and error histories.
*   **System Action:** Store logged grammar errors and personal biographical details in vector databases. Query this memory graph during session setups to customize conversations.
*   **Acceptance Criteria:** The AI naturally references facts from previous sessions.

### FR-017: Weekly Performance Dashboard
*   **Description:** Display studies history and projected exam readiness.
*   **System Output:** Interactive charts plotting:
    *   Speaking clear scores, grammar accuracy, and vocabulary growth.
    *   Active streak counts and total study hours.
    *   Projected Exam Score (with confidence probability margins).
*   **Acceptance Criteria:** Dashboard updates within 5 seconds of session completion.

### FR-018: Gamification
*   **Description:** Motivate learners through points, levels, and leagues.
*   **System Action:** Reward XP for session completions. Maintain daily streaks. Group users into competitive weekly leaderboards based on XP.
*   **Acceptance Criteria:** Issue badges for milestones (e.g., "7-Day Streak").

### FR-019: Push Notifications
*   **Description:** Remind users to practice daily to maintain streaks.
*   **System Action:** Send targeted push notifications via Firebase Cloud Messaging (FCM) based on the user's localized study preferences.
*   **Acceptance Criteria:** Clicking notifications routes the user directly to the daily study task.

### FR-020: Subscription Tier Gating
*   **Description:** Enforce pricing plan limits.
*   **System Action:**
    *   *Free Plan:* Block voice calls after 5 daily minutes are consumed. Restrict advanced scenarios.
    *   *Premium Plan:* Allow unlimited voice calling, high-priority routing, and detailed diagnostics.
    *   *Mock Exam Credits:* Deduct 1 mock exam credit per exam evaluation.
*   **Acceptance Criteria:** Paywall displays instantly when limits are hit.

---

## 5. Non-Functional Requirements

### 5.1 Performance & Latency SLAs
*   **Audio Pipeline Latency (NFR-PERF-01):** Under standard 4G/Wi-Fi connection speeds, the delay between a user finishing their sentence and hearing the AI's spoken response must be **less than 800 milliseconds**.
*   **Screen Loading Speed (NFR-PERF-02):** Core screen transitions and dashboard metrics must render within **1.5 seconds**.
*   **LLM Processing Latency (NFR-PERF-03):** AI text response generation (via edge functions) must complete in **under 2.5 seconds**.

### 5.2 System Availability
*   **Uptime SLA (NFR-AV-01):** The Supabase database and LiveKit infrastructure must maintain a **99.9% monthly uptime**.
*   **Automatic Scaling (NFR-AV-02):** Backend systems must scale automatically to support up to **10,000 active concurrent voice sessions** without latency degradation.

### 5.3 Reliability & Fault Tolerance
*   **Offline Cache (NFR-REL-01):** Vocabulary decks, lessons, and configurations must cache locally. The app must execute sync tasks automatically once internet connectivity returns.
*   **Graceful Degradation (NFR-REL-02):** If high-fidelity TTS systems fail, the client must dynamically fall back to system native text-to-speech engines.

### 5.4 Security & Data Hardening
*   **Connection Encryption (NFR-SEC-01):** Enforce HTTPS/TLS 1.3 across all communication layers.
*   **Secure Storage (NFR-SEC-02):** Enforce Keystore (Android) and Keychain (iOS) encryption configurations for session JWT storage.
*   **Row-Level Security (NFR-SEC-03):** Enable PostgreSQL RLS on all database tables.

### 5.5 Privacy & Consent
*   **Data Portability (NFR-PRV-01):** Users must be able to export their profile histories and transcripts in JSON format.
*   **GDPR Erasure (NFR-PRV-02):** Settings must feature a "Delete Account" button that triggers cascading database deletes of all user records, profile details, and voice logs.

### 5.6 Accessibility Conformance
*   **Screen Reader Compatibility (NFR-ACC-01):** Flutter layouts must map semantic descriptive fields to support screen readers (TalkBack / VoiceOver).
*   **Typography Scaling (NFR-ACC-02):** Text elements must support dynamic sizing up to 200% zoom without breaks.

---

## 6. Business Rules

*   **BR-001 (Account Identity):** A single verified email address can only map to one user account in the system.
*   **BR-002 (Usage Caps):** Free tier users are limited to exactly 5 minutes of voice calls per rolling 24-hour cycle.
*   **BR-003 (Subscription Gating):** Upgrading to Premium overrides usage limits and enables premium OpenAI scoring models.
*   **BR-004 (Exam Grading Disclaimer):** AIpredicted score outputs must be accompanied by a clear disclaimer stating they are advisory, not official grades.
*   **BR-005 (Adaptive Scaling):** Individual syllabus plans must be re-calibrated by the adaptive engine after every completed lesson.

---

## 7. External System Interfaces

```
+------------------+------------------------------+---------------------------------+
| EXTERNAL SYSTEM  | PROTOCOL / TRANSPORT         | FUNCTIONAL ROLE                 |
+------------------+------------------------------+---------------------------------+
| Supabase Auth    | HTTPS / JWT REST             | Session logic, login, SSO keys  |
+------------------+------------------------------+---------------------------------+
| LiveKit Server   | WebSockets & WebRTC Streams  | Ultra-low latency voice exchange|
+------------------+------------------------------+---------------------------------+
| Google Gemini    | HTTPS Rest / JSON Payload    | Standard conversational loops   |
+------------------+------------------------------+---------------------------------+
| OpenAI API       | HTTPS Rest / JSON Payload    | Premium writing and mock exams  |
+------------------+------------------------------+---------------------------------+
| Firebase FCM     | gRPC / HTTPS                 | Push notification reminders     |
+------------------+------------------------------+---------------------------------+
| Stripe & IAP     | App Store / Play Store API   | Monthly subscription billing    |
+------------------+------------------------------+---------------------------------+
```

---

## 8. Data Architecture & Entities

The relational PostgreSQL database contains the following 10 core entities:

```
  +--------------+          +--------------+          +------------------+
  |    USERS     | -------> |   PROFILES   | -------> |  CONVERSATIONS   |
  |  (Auth JWT)  |          | (L1/L2 Goals)|          | (Transcripts/VAD)|
  +--------------+          +--------------+          +------------------+
                                   |                           |
                                   v                           v
                            +--------------+          +------------------+
                            |  VOCABULARY  |          |  GRAMMAR_ERRORS  |
                            | (SRS Queues) |          | (Original/Correct|
                            +--------------+          +------------------+
```

1.  **Users:** Stores identity records, email credentials, and registration timestamps.
2.  **Profiles:** Stores names, selected native/target languages, target CEFR levels, and daily study goals.
3.  **Conversations:** Logs text/voice dialog transactions, timestamps, and active tutor IDs.
4.  **Lessons:** Logs syllabus units, exercises, reading passages, and listening tasks.
5.  **Vocabulary:** Keeps cards database, user difficulty ratings, next review timestamps, and native language Malayalam translations.
6.  **Progress Log:** Records study times, dashboard metric data, and cumulative XP.
7.  **Exam Attempts:** Logs mock test metadata, target scores, estimated band results, and text evaluations.
8.  **Achievements:** Logs unlocks, streak records, badges, and level metrics.
9.  **Subscriptions:** Stores payment logs, stripe subscription ID numbers, tier states, and expiration dates.
10. **Notifications:** Logs alert queues, delivery statuses, and device FCM tokens.

---

## 9. Error Handling Protocols
*   **Transient Connection Retries:** If connection drops occur during voice calls, the LiveKit client must automatically attempt reconnection for 10 seconds before returning a failure.
*   **User-Friendly Interfaces:** For API failures, show simple error banners (e.g., *"Cannot connect to the server. Please check your internet connection."*).
*   **System Integrity:** Write active progress records (like lesson completion statuses) to the local Hive database before calling remote sync endpoints.

---

## 10. Regulatory Compliance (GDPR/CCPA)
*   **Data Minimization:** Only store user data directly required for language training and profile operations.
*   **Explicit Consent Verification:** Onboarding must include checkboxes for terms of service, privacy protocols, and analytical telemetry tracking.
*   **Account Deletion Flow:** Triggering account deletion must execute cascading deletes across database records and wipe related media storage directories (voice records) within 72 hours.

---

## 11. Core Assumptions
*   The user's mobile device maintains active internet connectivity (minimum 3G or stable Wi-Fi) during voice calls.
*   Third-party AI providers (Google Gemini, OpenAI) maintain API service availability.
*   Users input accurate onboarding metrics and goal scores.

---

## 12. System Constraints
*   **Computational Expense:** Conversational LLM and high-fidelity TTS API fees require usage limits on free plans.
*   **Hardware Variations:** Lower-end devices may experience local transcription or layout lag.
*   **Grading Variances:** AI score estimates are probabilistic and may vary slightly from official grading patterns.

---

## 13. System Acceptance Criteria

The system is declared production-ready when:
1.  All functional requirements are implemented and verified.
2.  The voice call interface maintains a response latency under 800ms.
3.  No security vulnerabilities are found in JWT session validations or database RLS configurations.
4.  Unit and widget test coverage exceed **80%**.
5.  The app runs stably on both physical iOS and Android test devices.

---

## 14. Future Product Extensions
*   **Peer Rooms:** AI-guided group conversation rooms.
*   **AI Interview Simulator:** Recreating target corporate job interviews.
*   **Wearable Syncing:** Access audio vocabularies directly on smartwatches.
*   **Offline Local Models:** Deploying light, local voice processors for offline practice.

---

## 15. Revision History

| Version | Date | Description | Author |
| :--- | :--- | :--- | :--- |
| **1.0 (Draft)** | July 2026 | Initial Software Requirements Specification (SRS) | Robin R G |
