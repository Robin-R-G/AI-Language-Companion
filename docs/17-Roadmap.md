# Project Roadmap: AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Lifecycle Stages:** Phase 0 to Phase 6  
**Last Updated:** July 2026  

---

## 1. Vision & Mission
*   **Vision:** Build the world's most personalized AI language learning companion focused on exam success, real-world communication, and continuous improvement through AI-powered coaching.
*   **Mission:** Help learners confidently achieve their target scores in internationally recognized exams (IELTS, PTE, TOEFL, Goethe, DELF, OET, TOPIK) while building natural, real-world fluency.

---

## 2. Long-Term Product Goals

```
+-----------------------------------+-----------------------------------+---------------------------+
| YEAR                              | ACQUISITION TARGET                | STRATEGIC FOCUS           |
+-----------------------------------+-----------------------------------+---------------------------+
| Year 1                            | 10,000+ Active Users              | Launch MVP, validate      |
|                                   |                                   | product-market fit        |
+-----------------------------------+-----------------------------------+---------------------------+
| Year 2                            | 100,000+ Active Users             | Global expansion, launch  |
|                                   |                                   | B2B Institution Portal    |
+-----------------------------------+-----------------------------------+---------------------------+
| Year 3                            | 1,000,000+ Active Users           | Market leadership, enterprise|
|                                   |                                   | integrations, career prep |
+-----------------------------------+-----------------------------------+---------------------------+
```

---

## 3. Development Phase Matrix

The development roadmap is divided into structured, sequential phases:

```
+----------------+------------------+------------------------------------------------+-------------+
| PHASE NAME     | DURATION TARGET  | KEY DELIVERABLES & FEATURES                    | STATUS      |
+----------------+------------------+------------------------------------------------+-------------+
| Phase 0:       | 2 Weeks          | PRD, DRD, Database Schema, System Architecture,| Completed   |
| Research       |                  | API Specifications, UI wireframes              |             |
+----------------+------------------+------------------------------------------------+-------------+
| Phase 1:       | 10-12 Weeks      | User auth, onboarding wizards, text chat loops,| In Progress |
| MVP Core       |                  | grammar corrections, vocab SRS, home dashboard |             |
+----------------+------------------+------------------------------------------------+-------------+
| Phase 2:       | 6 Weeks          | LiveKit WebRTC setups, Whisper STT integration,| Not Started |
| AI Voice       |                  | Cartesia TTS voices streams, VAD interruptions |             |
+----------------+------------------+------------------------------------------------+-------------+
| Phase 3:       | 6 Weeks          | Exam modules (IELTS, PTE), timed mock tests,   | Not Started |
| Exam Prep      |                  | essay scoring, speech pronunciation analytics  |             |
+----------------+------------------+------------------------------------------------+-------------+
| Phase 4:       | 8 Weeks          | Referral programs, gamified league boards,     | Not Started |
| Growth         |                  | weekly report generators, RAG memory expansion |             |
+----------------+------------------+------------------------------------------------+-------------+
| Phase 5:       | 8 Weeks          | Teacher dashboard, student progress analytics, | Not Started |
| Institution    |                  | classroom assignments, centralized B2B billing |             |
+----------------+------------------+------------------------------------------------+-------------+
| Phase 6:       | Continuous       | Support for Spanish, French, Japanese, Korean, | Not Started |
| Global         |                  | Arabic, and additional CEFR certifications     |             |
+----------------+------------------+------------------------------------------------+-------------+
```

---

## 4. Version Release Timeline
*   `v0.1`: Static UI Wireframe Prototype.
*   `v0.2`: Supabase project linked and database schema initialized.
*   `v0.3`: Authentication APIs (Email, Google, Apple SSO) active.
*   `v0.4`: AI text-based Chat and lessons engine functional.
*   `v0.5`: Grammar correction JSON API integrated.
*   `v0.6`: LiveKit WebRTC Voice connection operational (Voice MVP).
*   `v0.7`: Analytics Dashboard and streak indicators complete.
*   `v0.8`: In-App purchases subscription payments verified.
*   `v0.9`: Internal QA Beta release (Play Console / TestFlight).
*   `v1.0`: Google Play & App Store Public Launch.
*   `v1.1+`: Phased feature enhancements (blueprints updates).

---

## 5. 2-Week Sprint Cadence (Agile Methodology)

We run feature development cycles in 2-week iterations:

```
  [WEEK 1]
  - Day 1: Sprint Planning & Task Allocations
  - Days 2-5: Core development and local unit tests compilation
                    |
                    v
  [WEEK 2]
  - Days 6-7: Integration tests execution (Hive and Supabase syncing)
  - Days 8-9: QA verification, security validation, and documentation updates
  - Day 10: Sprint Demo, retrospective, and branch merges to develop
```

---

## 6. Project Team Responsibilities
*   **Product Manager:** Manages project vision, prioritizes roadmap milestones, and compiles user feedback.
*   **Flutter Developer:** Builds the mobile application, manages Riverpod state logic, and coordinates local Hive cache layers.
*   **Backend Engineer:** Manages Supabase databases, writes Deno Edge Functions, and configures PostgreSQL RLS policies.
*   **AI Engineer:** Coordinates system prompts, structures model parameters, and designs evaluation rubrics.
*   **UI/UX Designer:** Manages the Figma Design System, coordinates layout screens, and verifies accessibility compliance.
*   **QA Engineer:** Writes automated widget and Patrol integration tests, and manages manual regression tests.
*   **DevOps Engineer:** Coordinates GitHub Actions CI/CD pipelines, handles credentials, and monitors server latency.

---

## 7. Strategic Milestones Checklist
*   [x] **Milestone 0:** Foundation - Project setup, shared widgets, utilities, core services (Completed July 4, 2026)
*   [ ] **Milestone 1:** Core Infrastructure - Freezed models, repositories, Riverpod providers (Week 1-4)
*   [ ] **Milestone 2:** Authentication & Onboarding - Supabase Auth, onboarding flows (Week 5-6)
*   [ ] **Milestone 3:** AI Chat & Corrections - Text-based chat, grammar corrections (Week 7-8)
*   [ ] **Milestone 4:** LiveKit Voice - WebRTC voice calls, STT/TTS integration (Week 9-10)
*   [ ] **Milestone 5:** Gamification - Streaks, XP, leaderboards, achievements (Week 11-12)
*   [ ] **Milestone 6:** Mock Exams - IELTS, PTE, TOEFL exam modules (Week 13-14)
*   [ ] **Milestone 7:** Subscriptions - RevenueCat integration, payment flows (Week 15-16)
*   [ ] **Milestone 8:** Testing & QA - Comprehensive test coverage (Week 17-18)
*   [ ] **Milestone 9:** Performance - Optimization and profiling (Week 19-20)
*   [ ] **Milestone 10:** Security - Security audit and hardening (Week 21-22)
*   [ ] **Milestone 11:** Deployment - CI/CD, store preparation (Week 23-24)
*   [ ] **Milestone 12:** Beta Launch - Internal testing release (Week 25-26)
*   [ ] **Milestone 13:** Production Launch - Public release v1.0 (Week 27-28)

---

## 8. MVP Feature Checklist
*   **Core Experience (Free Tier):**
    *   [x] OAuth Signup & Login.
    *   [x] Native Language selection dropdowns (L1 Malayalam scaffoldings).
    *   [x] AI conversational text-based chat.
    *   [x] Grammar correction inline highlights.
    *   [x] Spaced Repetition vocabulary cards.
    *   [x] Analytical dashboard tracking active study goals.
    *   [x] Push notifications reminders.
*   **Monetization & Engagement:**
    *   [x] In-App Purchase subscription checks (Premium tier).
    *   [x] Consumable purchases (extra speaking minutes, mock test keys).

---

## 9. Risk & Mitigations Log

```
+-------------------+-----------------------------------+-------------------------------------------+
| RISK CLASSIFICATION| RISK TECHNICAL IMPACT              | ACTIONABLE MITIGATION PATH               |
+-------------------+-----------------------------------+-------------------------------------------+
| Technical Risk    | High latency during real-time voice| Buffer audio in 40ms packets, implement  |
|                   | calls (>1.5s loop delay)          | VAD checks, stream TTS chunk playback     |
+-------------------+-----------------------------------+-------------------------------------------+
| Technical Risk    | AI Model provider API outages      | Configure dynamic fallback routing        |
|                   | (e.g. OpenAI HTTP 503 error)      | (switch from OpenAI to Gemini Flash)      |
+-------------------+-----------------------------------+-------------------------------------------+
| Business Risk     | High API token costs exceed average| Implement daily free quotas, leverage    |
|                   | monthly user subscription values   | prompt caching, route simple queries to   |
|                   |                                   | lower-cost models                         |
+-------------------+-----------------------------------+-------------------------------------------+
| User Risk         | High churn rates due to loss of    | Integrate streaks, weekly report cards,  |
|                   | daily motivation                  | and interactive league boards            |
+-------------------+-----------------------------------+-------------------------------------------+
```

---

## 10. Launch Readiness Gates

### 10.1 Before Beta Launch Gate:
*   [ ] Core features (Auth, Chat, Lessons) pass QA validation.
*   [ ] Security audit confirms all PostgreSQL tables enforce Row-Level Security (RLS).
*   [ ] Automated unit and widget tests achieve coverage targets (>90% and >85%).
*   [ ] Play Store Console and App Store TestFlight configurations complete.

### 10.2 Before Public Launch Gate:
*   [ ] Legal documentation (Privacy Policy, Terms of Service) published.
*   [ ] Google Play Console and App Store developer accounts verified.
*   [ ] Production databases and storage buckets backups configured.
*   [ ] Customer support portals active.
*   [ ] App Store marketing assets (screenshots, descriptions) prepared.

---

## 11. Documentation Inventory Checklist
Every document must reside under the `docs/` repository directory for version control:
*   [x] `01-Project-Vision.md` (Vision statement & target market TAM/SAM/SOM).
*   [x] `02-PRD.md` (Product Requirements Document).
*   [x] `03-DRD.md` (Development Requirements Document).
*   [x] `04-SRS.md` (Software Requirements Specification).
*   [x] `04-System-Architecture.md` (System block diagrams and sequence maps).
*   [x] `05-Database-Schema.md` (PostgreSQL schemas DDL & Streaks triggers).
*   [x] `06-API-Specification.md` (REST payload schemas & webhook events).
*   [x] `07-UI-UX-Guidelines.md` (Visual design language guidelines).
*   [x] `08-Design-System.md` (Color and typography tokens).
*   [x] `09-User-Flows.md` (Interactive flows diagrams).
*   [x] `10-AI-Prompts.md` (System prompts library and variables).
*   [x] `11-Voice-Architecture.md` (LiveKit WebRTC and STT/TTS channels).
*   [x] `13-Subscription.md` (Freemium plans and quota gating SQL).
*   [x] `14-Security.md` (Security policies, RLS, mobile secure storage).
*   [x] `15-Testing.md` (Testing strategy and CI/CD quality gates).
*   [x] `16-Deployment.md` (GitHub Actions YAML scripts & release management).
*   [x] `17-Roadmap.md` (Strategic roadmap phases).
*   [x] `18-TODO.md` (Developer task checklist).

---

## 12. Definition of Success
The roadmap reaches its target destination when:
*   Version 1.0 is successfully published on Google Play and Apple App Store.
*   The system operates with a crash-free user rate of **>99.5%**.
*   In-app subscription conversions exceed the **5%** threshold.
*   Users achieve measurable language improvements as verified by AI diagnostic analytics.
*   The codebase and deployment pipelines are ready to support global scaling.
