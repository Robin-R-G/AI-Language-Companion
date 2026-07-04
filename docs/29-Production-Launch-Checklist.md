# Production Launch Checklist & Runbook: AI Language Coach
**Version:** 1.0  
**Status:** Production  
**Target Environment:** iOS App Store, Google Play Console, Production Supabase  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the pre-launch requirements, quality gates, security audits, App Store submission checklists, legal checks, launch-day runbooks, phased rollout schedules, post-launch monitoring, and incident response procedures for **AI Language Coach**. 

Following this checklist ensures a secure, high-availability release with zero-downtime database updates and verified payment flows.

---

## 2. Pre-Launch Verification Checklists

### 2.1 Product & UX Verification
*   [ ] Verify all MVP learning pathways (conversational chat, LiveKit calls, and mock exam timers) function end-to-end.
*   [ ] Confirm core UI elements meet responsive layout standards across both phones and tablets.
*   [ ] Ensure touch targets meet the minimum **48 x 48dp** dimensions.

### 2.2 Backend & DB verification
*   [ ] Push all database migrations to the production project:
    *   `supabase db push --project-ref your_prod_ref`
*   [ ] Verify that Row-Level Security (RLS) is active on all user-owned tables.
*   [ ] Confirm production indexes are configured for lookup and SRS scheduler keys.
*   [ ] Set up daily automated backups with 30-day retention policies in Supabase.

### 2.3 AI Prompt & Provider configurations
*   [ ] Verify that the fallback mechanism routes requests to the backup provider (Gemini Flash) if the primary API fails.
*   [ ] Verify that system prompts reject injection attacks.
*   [ ] Confirm predicted exam scores display advisory disclaimers.

### 2.4 Voice Call Configurations (LiveKit)
*   [ ] Verify LiveKit audio channels connect without packet loss.
*   [ ] Ensure microphone permission requests display clear user disclosures.

### 2.5 Billing & Payments (RevenueCat)
*   [ ] Confirm subscriptions offerings (Monthly/Annual tiers) match Google Play and App Store consoles.
*   [ ] Test Sandbox purchases to verify receipts are processed correctly before deploying to production.

### 2.6 Notifications & Analytics
*   [ ] Verify Firebase FCM credentials and certificates are active.
*   [ ] Ensure analytics events do not track passwords, session keys, or user transcripts.

---

## 3. Quality Assurance Gates
*   **Testing criteria:** All unit, widget, and integration tests must pass before the release build is generated:
    *   `flutter test`
*   **Defect thresholds:**
    *   No P0 (Blockers) or P1 (High Severity) issues.
    *   Any open P2 (Medium Severity) issues must be documented in the release notes.

---

## 4. Security Audit
*   [ ] Enforce secure HTTPS/WSS protocols.
*   [ ] Mask passwords, tokens, and transcripts in application logs.
*   [ ] Verify API gateways drop requests exceeding **100 requests per minute per IP address**.
*   [ ] Store user JWT session tokens securely in the device's keystore (Keychain for iOS, Keystore for Android).

---

## 5. Storefront Submission Blueprints

### 5.1 Google Play Store (App Bundle)
*   [ ] Upload signed App Bundle release files (.aab).
*   [ ] Update description copy, keywords, feature graphics, and tablet/phone screenshots.
*   [ ] Renders Data Safety disclosures (declaring analytics usage and user deletions options).

### 5.2 Apple App Store Connect
*   [ ] Renders signed IPA files.
*   [ ] Complete App Description, Keywords, and Support URL pages.
*   [ ] Configure Privacy Manifests and data tracking disclosures.

---

## 6. Legal & Compliance
*   [ ] Publish Privacy Policy and Terms of Service links in-app and on the marketing website.
*   [ ] Include copyright notices and AI disclaimers in mock exam result cards.
*   [ ] Document license credits for third-party libraries.
*   [ ] Verify GDPR delete actions cascading deletes on user profile wipes.

---

## 7. Launch Day Runbook Timeline

```
  [1. Pre-Release checks (T-2 Hours)]
  - Verify server logs, confirm backups are active, notify developers.
                 |
                 v
  [2. Release Rollout (T-0)]
  - Trigger store releases and begin gradual rollout percentage steps.
                 |
                 v
  [3. Post-Release sanity audits (T+1 Hour)]
  - Test login, verify translation triggers, run payment check, monitor errors.
```

### Post-Release Sanity Checks:
1.  Sign up a test user, complete onboarding, and verify default study goals are created in the database.
2.  Send a message in the chat tab and confirm the grammar review JSON response parses correctly.
3.  Launch a LiveKit voice session, test speaking, and check for connection errors.
4.  Purchase a Premium subscription in the store sandbox to verify receipt validations.

---

## 8. Rollout Strategy

We use a phased rollout strategy over 48 hours to minimize release risks:

```
  [Phase 1: 5% Rollout] ---> [Phase 2: 25% Rollout] ---> [Phase 3: 50% Rollout]
                                                                  |
                                                                  v
  [Production (100%)] <--------------------------------------+
```

*   **Emergency Rollback:** If crash rates exceed **0.5%** or critical payment errors occur, pause the rollout immediately. Revert to the previous stable build in the store console.

---

## 9. 30-Day Post-Launch Roadmap

*   **Week 1:** Prioritize fixing bugs identified by early users, monitor crash rates in Crashlytics, and provide customer support.
*   **Week 2:** Review user analytics to identify drop-off steps in the onboarding funnel, and tune AI prompts.
*   **Week 3:** Deploy performance improvements to optimize LiveKit audio latency.
*   **Week 4:** Prepare and push hotfix release v1.1. Review MRR and paid conversion targets.

---

## 10. Incident Response Escalation Flow

```
  [1. Event Detected]
  - Alerts trigger for crash surges (>0.5%) or payment failures.
          |
          v
  [2. Severity Assessment]
  - Severity 1 (Outage): AI gateway down or payments failing.
  - Severity 2 (Degraded): Slow voice latencies or cosmetic bugs.
          |
          v
  [3. Resolution Actions]
  - Severity 1: Pause rollout, switch to fallback models, or rollback build.
  - Severity 2: Log issue, assign fix to the next sprint, deploy patch.
```

---

## 11. Final Launch Checklist

Verify the launch readiness against this checklist:
*   [ ] Are production environment variables and API keys active?
*   [ ] Have database migrations pushed successfully to production?
*   [ ] Are RLS policies and performance indexes active?
*   [ ] Does the fallback model route chat requests if the primary API fails?
*   [ ] Are sandbox subscriptions and receipt validations tested?
*   [ ] Are Firebase crash reporting and analytics active?
*   [ ] Are privacy policies and disclaimers updated on the store listings?
*   [ ] Has the incident response escalation path been assigned to the team?
