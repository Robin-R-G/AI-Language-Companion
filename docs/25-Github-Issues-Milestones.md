# GitHub Projects, Milestones & Issues Specification: AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Target Environment:** GitHub Repository Settings, Issue Templates Configurations  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the project management framework, ticket labeling taxonomies, sprint milestone deliveries, pull request layouts, issue templates, and automated workflows on **GitHub** for the **AI Language Coach** platform. 

Following these procedures ensures clean backlog grooming, structured task sizing, and automated status tracking across frontend and backend updates.

---

## 2. GitHub Projects Boards Layout
We organize task execution across four distinct boards:
*   **Development Board (Kanban):** Active sprint tracking (Todo, In Progress, Review, Done).
*   **Bug Board:** Open issues logs, sorted by priority (P0 to P3).
*   **Roadmap:** Long-term feature epics tracking.
*   **Backlog:** Unprioritized feature cards and refactoring tickets.

---

## 3. GitHub Label Taxonomy

Labels categorize tickets automatically. Ensure color codes match standard category palettes:

```
+-------------------+-------------------+-------------------+---------------------------------------+
| LABEL GROUP       | LABEL NAME        | HEX COLOR CODE    | DESCRIPTION                           |
+-------------------+-------------------+-------------------+---------------------------------------+
| Type              | feat              | #0E8A16           | New product features addition         |
|                   | bug               | #D93F0B           | Software defects or crashes logs      |
|                   | refactor          | #A2EEEF           | Code adjustments without behaviors    |
+-------------------+-------------------+-------------------+---------------------------------------+
| Priority          | P0-Critical       | #B60205           | Blockers requiring immediate patches  |
|                   | P1-High           | #D93F0B           | Major feature disruptions             |
|                   | P2-Medium         | #FBCA04           | Normal product enhancements           |
|                   | P3-Low            | #0E8A16           | Minor cosmetic or layout updates      |
+-------------------+-------------------+-------------------+---------------------------------------+
| Status            | status:ready      | #FBCA04           | Groomed tasks ready for estimation    |
|                   | status:in-progress| #1D76DB           | Dev actively working on implementation|
|                   | status:review     | #5319E7           | Pull request awaiting code checks     |
|                   | status:blocked    | #B60205           | Task stopped due to dependencies      |
+-------------------+-------------------+-------------------+---------------------------------------+
| Area              | area:frontend     | #1D76DB           | Flutter mobile application scopes     |
|                   | area:backend      | #FBCA04           | Supabase Edge Functions scopes        |
|                   | area:ai           | #5319E7           | Prompts tuning and model validations  |
|                   | area:payments     | #0E8A16           | Stripe purchase receipt processing    |
+-------------------+-------------------+-------------------+---------------------------------------+
```

---

## 4. Weekly Milestone Delivery Schedule

We run development in **1-week sprints** mapped to seven core delivery milestones:

```
  [Week 1: Setup] ---> [Weeks 2-3: Core AI] ---> [Week 4: Voice Call]
                                                      |
                                                      v
  [Week 8: Release] <--- [Week 7: Billing] <--- [Week 6: Streaks] <--- [Week 5: Timed Exams]
```

*   **Milestone 1 (Week 1) - Architecture Setup:** Bootstrap Flutter project directories, Supabase schema migrations, auth edge functions, and design system.
*   **Milestone 2 (Weeks 2-3) - Core AI Tutoring:** Deconstruct grammar checks, Malay translation toggles, RAG memory database setups, and chatbot conversations.
*   **Milestone 3 (Week 4) - Voice Integration:** Establish LiveKit rooms API, WebRTC token setups, interruption bary-ins VAD thresholds, and spoken transcripts processing.
*   **Milestone 4 (Week 5) - Exam Prep:** Implement writing evaluation engines, IELTS rubrics grading, and mock exams timed simulators.
*   **Milestone 5 (Week 6) - Gamification:** Enable streaks database logs triggers, XP logs, level ups, and weekly report aggregates.
*   **Milestone 6 (Week 7) - Monetization:** Stripe subscription gating hooks, Apple/Google IAP validations, and paywall locks.
*   **Milestone 7 (Week 8) - QA & Stores Release:** Unit coverage audits, asset optimizations, Store deployment keys configurations.

---

## 5. Agile Product Epics
1.  **Epic 1: Authentication** – Secure signups and email verifications.
2.  **Epic 2: Onboarding** – Target exam selections and initial diagnostics.
3.  **Epic 3: AI Tutoring** – Chatbot conversational feedback.
4.  **Epic 4: Voice Calls** – Low-latency oral conversations.
5.  **Epic 5: Grammar Engine** – Parsing grammatical corrections.
6.  **Epic 6: Localized Scaffolding** – Malayalam explanations.
7.  **Epic 7: Spaced Repetition (SRS)** – Vocabulary review flashcards.
8.  **Epic 8: Exam Simulator** – Under-time test mock models.
9.  **Epic 9: Dashboards** – Progress metrics charts logs.
10. **Epic 10: Gamification** – Streaks and achievement badges.
11. **Epic 11: Payments** – Subscriptions plans gating.
12. **Epic 12: Notification alerts** – Reminders and streak savers.
13. **Epic 13: Analytics** – Telemetry ingestion.
14. **Epic 14: Admin Portals** – Prompts configuration controls.

---

## 6. Agile User Stories

### 6.1 L1 Malayalam Translation Scaffolding
*   **Story:** As a Malayalam-native learner, I want difficult grammar terms to include Malayalam scaffolding explanations, so that I can understand complex L2 grammatical terms easily.

### 6.2 Oral Conversational Lessons
*   **Story:** As an IELTS exam candidate, I want to practice speaking with a virtual IELTS examiner, so that I can improve my oral pronunciation and fluency scores before the timed exam.

---

## 7. GitHub YAML Issue Templates Configs

Save this configuration at `.github/issue_template/feature_request.yml` to standardize feature tickets styling:

```yaml
# .github/issue_template/feature_request.yml
name: Feature Request
description: Propose a new feature for the AI Language Coach
title: "feat: [Feature Name]"
labels: ["feat", "status:ready"]
body:
  - type: markdown
    attributes:
      value: "Thank you for suggesting a feature. Fill out the sections below."
  - type: textarea
    id: objective
    attributes:
      label: Objective
      placeholder: "What problem does this feature solve? What is the user value?"
    validations:
      required: true
  - type: textarea
    id: acceptance-criteria
    attributes:
      label: Acceptance Criteria
      placeholder: "Gherkin format preferred: Given/When/Then scenarios."
    validations:
      required: true
  - type: textarea
    id: technical-notes
    attributes:
      label: Technical Notes
      placeholder: "Specify database schema impacts, Edge Functions routing, or UI models."
```

---

## 8. Definition of Ready (DoR) & Definition of Done (DoD)

### 8.1 Definition of Ready (DoR)
A backlog ticket is considered Ready for development when:
1.  User value and business objective are defined.
2.  Acceptance criteria are documented.
3.  Design assets or Figma templates are available (if the task includes UI updates).
4.  Relational database tables or API specifications are defined.
5.  Dependencies have been resolved.

### 8.2 Definition of Done (DoD)
A task card is moved to Done when:
1.  Features compile cleanly without warnings or errors.
2.  Unit and integration tests pass, meeting target test coverage (>90%).
3.  Code conforms to the project architecture guidelines.
4.  Pull requests are reviewed and approved by code owners.
5.  Secrets and API keys are verified as excluded from git commits.

---

## 9. Pull Request Markdown Template

Save this format at `.github/pull_request_template.md` to coordinate reviews:

```markdown
# Pull Request Description

## Related Issue
Closes #[Issue Number]

## Summary of Changes
Provide a brief summary of the implemented code and architecture impacts.

## Verification Screen Maps
*Insert UI screenshots or LiveKit screen recording links demonstrating features.*

## Verification Checklist
- [ ] Code compiles without warnings.
- [ ] Automated tests run and pass.
- [ ] RLS policies and indexes are configured (if database schema changes are present).
- [ ] Secrets and API keys are excluded from code changes.
- [ ] Lint checks pass.
```

---

## 10. Automation & Workflows
*   **Merge Guard:** Prevent PR merges unless GitHub Actions check pipelines (linter, unit tests) return successful statuses.
*   **Automatic Close:** Using standard git tags (e.g. `Closes #123`) in PR bodies automatically closes linked issues upon merge.
*   **Code Owners:** Require approval from matching team members before merging changes to sensitive paths (like database schema migrations).

---

## 11. Sprint Telemetry Success Metrics
Project health is tracked using Agile telemetry targets:
*   **Sprint Velocity:** Consistent target completion rate (e.g. 35 story points per sprint).
*   **Bug Rate:** Production defects logged must remain under **5%** of weekly feature tickets.
*   **PR Lead Time:** Target review time under **24 hours** from PR submission to code owner merge.

---

## 12. GitHub Setup Checklist

Verify the repository setup against this checklist before production release:
*   [ ] Have feature request and bug report templates been configured in `.github/` folders?
*   [ ] Are git check pipelines active on all PR branches?
*   [ ] Do projects boards map the complete Kanban backlog workflow?
*   [ ] Have code ownership rules been activated on the migration folders?
*   [ ] Are weekly milestones scheduled to align with roadmap sprints?
*   [ ] Does the pull request template require screenshots and tests verification checks?
*   [ ] Has issue linkage tracking been configured to automatically close tickets upon merge?
