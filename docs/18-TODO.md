# Developer Task Backlog: AI Language Coach (18-TODO)
**Version:** 1.0  
**Status:** In Progress  
**Last Updated:** July 4, 2026  

---

## 0. Milestone 0: Foundation (Completed July 4, 2026)
*   [x] Configure Flutter project using Clean Architecture folders.
*   [x] Set up analysis_options.yaml with strict linting.
*   [x] Download and configure Inter font assets.
*   [x] Create placeholder assets (logo, illustrations, animations).
*   [x] Fix DioClient with proper Supabase token injection.
*   [x] Fix LocalStorage with proper type casting.
*   [x] Create shared widgets (AppButton, ShimmerLoading, EmptyState, ErrorView, AppTextField, AppCard, AppAvatar).
*   [x] Create utility extensions (StringExtensions, DateTimeExtensions).
*   [x] Create formatters and validators.
*   [x] Create core services (LoggerService, AnalyticsService, ConnectivityService).
*   [x] Update bootstrap.dart with Firebase and RevenueCat initialization.
*   [x] Fix all compilation errors (8 errors → 0 errors).
*   [x] Format all code with dart format.
*   [x] Create implementation progress documentation.

---

## 1. Milestone 1: Core Infrastructure & Models (Week 1-4)
*   [ ] Create Freezed models for User, Lesson, Vocabulary, VoiceSession, MockExam, Achievement, Subscription.
*   [ ] Generate JSON serialization with json_serializable.
*   [ ] Create abstract repository interfaces for all features.
*   [ ] Create Riverpod providers for state management.
*   [ ] Implement comprehensive error handling with Failure classes and Result<T> pattern.
*   [ ] Write unit tests for all models, repositories, and providers.
*   [ ] Set up GitHub Actions CI/CD pipeline.
*   [ ] Update documentation with implemented architecture.

---

## 2. Milestone 2: Authentication & Onboarding (Week 2)
*   [ ] Integrate Supabase auth templates.
*   [ ] Implement secure email, Google, and Apple social logins.
*   [ ] Build onboarding UI screens (Native Malayalam, target L2 goals, placements diagnostic).
*   [ ] Setup placement quiz UI components (Grammar checks, Vocabulary reviews, shadowing speech).

---

## 3. Milestone 3: AI Chat & Corrections Engine (Week 3)
*   [ ] Connect chat views to backend Edge Functions.
*   [ ] Render user slate-blue bubbles (right aligned) and AI bubbles (left aligned).
*   [ ] Parse JSON grammar check responses to highlight errors with dotted underlines.
*   [ ] Build slide-up sheets displaying rule definitions, Malayalam scaffolding explanations, and synonym recommendations.
*   [ ] Integrate translation toggle to reveal Malayalam definitions.

---

## 4. Milestone 4: LiveKit Voice Rooms (Week 4)
*   [ ] Configure LiveKit WebRTC client in Flutter.
*   [ ] Implement mic permissions popups and VAD sound interruptions.
*   [ ] Render dynamic waveforms (Blue curves for AI, Green curves for users speaking).
*   [ ] Build floating control panel (speaker toggle, mute button, red end-call action).

---

## 5. Milestone 5: Gamification & Leaderboards (Week 5)
*   [ ] Deploy weekly leaderboards database triggers and reset calendars.
*   [ ] Implement promotions (top 10) and demotions (bottom 5) algorithms.
*   [ ] Configure badge unlocks validations triggers in PostgreSQL.
*   [ ] Build streak flames glows and XP level progress bars widgets.

---

## 6. Milestone 6: RevenueCat Subscriptions (Week 6)
*   [ ] Configure Entitlements, Offerings, and Products in App Store and Google Play Console.
*   [ ] Integrate RevenueCat billing SDK.
*   [ ] Build gold-styled premium upgrade cards paywalls comparison grids.
*   [ ] Verify Stripe webhook handlers updating subscription statuses in Supabase.

---

## 7. Milestone 7: Testing & SLA Performance Audits (Week 7)
*   [ ] Write unit tests for local repositories and Riverpod controllers.
*   [ ] Run performance audits verifying app launches in under 3 seconds.
*   [ ] Validate WCAG AA contrast criteria and verify touch targets exceed 48x48dp.

---

## 8. Milestone 8: Store Launches (Week 8)
*   [ ] Upload signed APK/AAB to Google Play Console internal test tracks.
*   [ ] Upload TestFlight IPA builds to App Store Connect.
*   [ ] Publish terms policies links, content safety forms, data safety definitions.
