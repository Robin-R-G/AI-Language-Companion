# Feature Build Prompts Guide: AI Language Coach (39-FEATURE_BUILD_PROMPTS)
**Version:** 1.0  
**Status:** Production  
**Target Environment:** AI Coding Subagents, Workspace Developers  
**Last Updated:** July 2026  

---

## 1. Purpose
This document contains reusable, standardized instruction prompts for AI coding agents to generate, modify, and build core features for **AI Language Coach** consistently. 

### General Architect System Rules
Every feature must adhere to the following baseline standards:
*   **Clean Architecture:** Maintain strict separation of concerns (Domain, Data, Presentation layers).
*   **State Management:** Use Riverpod code-generator syntax (`@riverpod`).
*   **Navigation:** Use GoRouter with authentication redirect route guards.
*   **Code Generators:** Use Freezed for immutable data models and JSON Serialization.
*   **Networking:** Connect to the backend using the Dio HTTP client and the Supabase Dart SDK.
*   **Quality Gates:** Every feature must include unit tests, widget tests, error handlers, and responsive layout structures.

---

## 2. Reusable Feature Prompts

### Prompt 1: Authentication
Build a complete Authentication module using Supabase Auth.
*   **Requirements:**
    *   Email & Password Login, Signup, and Forgot Password routes.
    *   OAuth integration (Google Sign-In, Apple Sign-In).
    *   Secure token storage in mobile secure storage keychains.
    *   Session refresh triggers, auto-login, and logout functions.
    *   Shimmer loading overlays and descriptive authentication error cards.

### Prompt 2: Onboarding
Build the onboarding profile wizard experience.
*   **Requirements:**
    *   Wizard steps capturing Native Language (Malayalam Spotlighted), Target Language (English/German), Goals (IELTS, PTE, Goethe, General), Daily Commitments, and preferred study times.
    *   Calculate placement diagnostic CEFR bands and save preferences.
    *   Persist user onboard data to Supabase database.

### Prompt 3: Dashboard
Build a personalized home dashboard.
*   **Requirements:**
    *   Greeting card displaying streaks, XP levels progress bar.
    *   Quick-start CTA buttons for daily lessons and mock examinations.
    *   Widgets displaying vocabulary masteries, speaking parameters logs, and notification feeds.

### Prompt 4: AI Chat
Build an interactive streaming chat interface.
*   **Requirements:**
    *   Stream response logs using chunked inputs. Render markdown elements.
    *   Grammar corrections highlight text inline with dotted underlines. Tapping triggers slide-up explanation sheets.
    *   Translation switch toggle translating individual bubbles into Malayalam.

### Prompt 5: Live Voice Conversation
Build a real-time WebRTC AI calling module.
*   **Requirements:**
    *   Connect to LiveKit Cloud Rooms pipelines.
    *   Implement microphone capture, VAD interruption checks, and automatic reconnect logs.
    *   Render pulsing circular avatars and live audio waveforms (blue for AI, green for user).

### Prompt 6: Grammar Coach
Create an analytical grammar correction screen.
*   **Requirements:**
    *   Display incorrect input, corrected alternative, explanation text, and comparative L1 Malayalam structural panels.
    *   Log mistakes history in the database.

### Prompt 7: Translation Assistant
Implement translation tools.
*   **Requirements:**
    *   Bidirectional translations with phonetics transcription.
    *   Audio text-to-speech (TTS) playback and bookmarks manager.

### Prompt 8: Vocabulary Builder
Create a vocabulary flashcard database.
*   **Requirements:**
    *   Display terms definitions, IPA spellings, sample sentences, and synonyms.
    *   Incorporate Spaced Repetition System (SRS) interval rating schedules.

### Prompt 9: Flashcards
Build interactive flashcards components.
*   **Requirements:**
    *   Support swipe slide actions, double-tap flip animations, and favorites triggers.

### Prompt 10: Speaking Practice
Create conversational oral exercise rooms.
*   **Requirements:**
    *   Evaluate recorded speech against fluency, accuracy, vocabulary ranges, and confidence.
    *   Provide AI grading summaries.

### Prompt 11: Pronunciation Coach
Analyze pronunciation on a phoneme level.
*   **Requirements:**
    *   Display segment score bands, pinpoint difficult sounds, and render compare waveforms graphs.

### Prompt 12: Writing Coach
Build essay evaluation editors.
*   **Requirements:**
    *   Evaluate typed essays against IELTS task responses or PTE rubrics.
    *   Return band scores and suggested paragraph restructures.

### Prompt 13: Listening Practice
Create an audio player lesson interface.
*   **Requirements:**
    *   Render audio playback speed sliders, transcripts scroll containers, and comprehension questions.

### Prompt 14: Reading Practice
Create text comprehension modules.
*   **Requirements:**
    *   Support tap definitions highlight lookups, and timed exam settings.

### Prompt 15: IELTS Module
Support simulation tracks for IELTS Speaking, Writing, Reading, and Listening.
*   **Requirements:**
    *   Generate official equivalent band scores with diagnostic reports.

### Prompt 16: PTE Module
Support PTE exercises (Read Aloud, Repeat Sentence, Describe Image).
*   **Requirements:**
    *   Evaluate responses against PTE scoring criteria.

### Prompt 17: Goethe German Module
Support Goethe CEFR (A1-C2) prep paths.
*   **Requirements:**
    *   Provide grammar guides explaining cases structures (Nominativ, Dativ).

### Prompt 18: Progress Dashboard
Create charts analytics dashboards.
*   **Requirements:**
    *   Render weekly study times line charts, vocabulary metrics, and exam readiness scores.

### Prompt 19: Gamification
Implement streak flames and XP leveling structures.
*   **Requirements:**
    *   Connect to DB streaking functions and unlock achievements badges.

### Prompt 20: Notifications
Integrate Firebase FCM alerts.
*   **Requirements:**
    *   Configure daily study alerts, streak warnings, and weekly progress alerts.

### Prompt 21: Premium Subscription
Integrate RevenueCat billing.
*   **Requirements:**
    *   Display paywall grid cards and test purchase receipts.

### Prompt 22: Profile & Settings
Build user profile tiles.
*   **Requirements:**
    *   Manage avatars, language parameters, theme settings, and GDPR account delete actions.

### Prompt 23: Offline Mode
Implement offline local capabilities.
*   **Requirements:**
    *   Cache lessons, sync vocabulary changes on connection reconnects.

### Prompt 24: Search
Build global search indexing.
*   **Requirements:**
    *   Support fuzzy matching across lessons, exams, and vocabulary databases.

### Prompt 25: AI Memory
Implement personal AI memory graphs.
*   **Requirements:**
    *   Enable users to review, edit, or delete stored preferences or weak points.

### Prompt 26: Admin Dashboard
Create web administration panels.
*   **Requirements:**
    *   Manage users accounts, feature flags configurations, and billing analytics graphs.

---

## 3. Quality Assurance Checklist

Verify the feature against this checklist before code completion:
*   [ ] Does the code adhere to the Clean Architecture domain rules?
*   [ ] Have unit and widget tests been implemented and run successfully?
*   [ ] Do all lists and detail views include shimmer loading states?
*   [ ] Do empty lists displayillustrations and a clear call-to-action (CTA)?
*   [ ] Have layouts been verified for responsive scaling on small screen form factors?
*   [ ] Do text contrast ratios meet WCAG AA specifications?
*   [ ] Has dark mode support been tested?
