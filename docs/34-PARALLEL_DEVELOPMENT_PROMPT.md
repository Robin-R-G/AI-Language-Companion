# Parallel Development Prompt & System Rules: AI Language Coach (34-PARALLEL_DEVELOPMENT_PROMPT)
**Version:** 1.0  
**Status:** Production  
**Target Environment:** Parallel AI Co-Engineers, Code Review Agents, DevOps  
**Last Updated:** July 2026  

---

## 1. Purpose & Role Definition
This document defines the instructions, task priorities, quality thresholds, and operational rules for parallel AI co-engineers. 

### Core Role Boundaries:
*   **Quality & Infrastructure Focus:** You are **not** the primary code generator implementing app features. Your primary responsibility is to improve code architecture, developer experience (tooling), testing frameworks, security, documentation, and performance.
*   **Non-Duplication:** Never write, regenerate, or edit active feature implementations unless the Clean Architecture design rules are violated. Complement the primary developer's commits.

---

## 2. Infrastructure Stack Reference
*   **Frontend:** Flutter Stable, Dart.
*   **Backend:** Supabase (Postgres, Auth, Storage, Edge Functions).
*   **State & Routing:** Riverpod code generators, GoRouter.
*   **Audio WebRTC:** LiveKit Cloud.
*   **Analytics & Payments:** Firebase Crashlytics/FCM, PostHog, RevenueCat.

---

## 3. Parallel Development Phase-by-Phase Priority Tasks

### Phase 1: Repository & Architecture Auditing
Analyze the repository and confirm compliance across:
*   Clean Architecture directory structures.
*   Correct package naming conventions.
*   No dependency loops or circular imports.
*   Document files and links integrity. Return an audit summary.

### Phase 2: DevOps & Automation Tooling
Generate and deploy CI/CD workflows:
*   *GitHub Actions:* `.github/workflows/flutter_ci.yml` (Linting, Analyze, Test).
*   *Dependabot:* Configure monthly dependency scans.
*   *Templates:* Pull Request templates, bug reports, and features request templates.
*   *Security Guidelines:* Standardize `SECURITY.md` policies and code owners access controls list.

### Phase 3: Developer Experience (DX) Scripts
Improve development loops:
*   Deploy a global `Makefile` containing tasks compile targets (`build_runner`, translations generators, clean cache targets).
*   Create environment validation bash scripts to audit `.env` keys parameters before local runs.

### Phase 4: Testing Infrastructure
Implement mock interfaces and test helpers:
*   Set up mocking frameworks for remote repositories and HTTP clients.
*   Provide custom golden image testing configurations.
*   Set up automated code coverage reports configurations.

### Phase 5: Clean Architecture Audits
Perform feature audits to enforce SOLID principles and Riverpod notifier lifecycle patterns. Review imports, ensure controllers use `autoDispose`, and verify selectors optimize rebuild limits.

### Phase 6: Security Auditing
Review authentication token keychains storage, Row-Level Security (RLS) tables policies loops, Edge Functions JWT checks, and sanitizers protecting against prompt injection.

### Phase 7: Performance Optimization
Audit app startup cold boot times, rendering frames (60/120 FPS), database connection queries execution, and LiveKit WebRTC packet buffering.

### Phase 8: Documentation Synchronization
Ensure the main `README.md`, developer onboarding scripts, database ERDs, API schemas, and deployment guides match the active codebase state.

### Phase 9: Quality & Scorecard Reporting
Provide QA report scores before releasing versions:
*   *Target Scorecards:* Architecture Score (max 20), Security Score (max 20), Performance Score (max 15), Testing Score (max 15), Accessibility Score (max 10), Documentation Score (max 10), Maintainability Score (max 10).

---

## 4. Reusable Co-Engineer Output Report Template

For every PR or audit iteration completed, return the following template log:
```text
## 1. Summary
[Brief explanation of the tasks completed]

## 2. Files Created
*   [Path to new files]

## 3. Files Updated
*   [Path to modified files]

## 4. Architectural Rationale
[Why the modifications were made and how they protect code health]

## 5. Deployment Risk
[High / Medium / Low - with mitigation details]

## 6. Next Recommended Task
[What the co-engineer should focus on next]
```

---

## 5. Parallel Development Checklist

Verify parallel contributions against this checklist:
*   [ ] Does the edit avoid duplicating active feature development?
*   [ ] Do all generated automation scripts run cleanly in CI targets?
*   [ ] Have mock objects been verified to bypass actual external network calls during tests?
*   [ ] Do modified controllers use autoDispose hooks?
*   [ ] Do log updates mask secure credentials?
