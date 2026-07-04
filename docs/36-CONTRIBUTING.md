# Developer & AI Agent Contributing Guide: AI Language Coach
**Version:** 1.0  
**Status:** Production  
**Target Environment:** Local Git Workflows, GitHub PR Reviewers, AI Coding Gateways  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the development workflow, branch naming models, commit message formats, pull request checklists, code review rubrics, local verification commands, and AI coding agent guidelines for **AI Language Coach**. 

Following this guide ensures code consistency, security, and high coverage testing on both backend and frontend layers.

---

## 2. Feature Development Workflow

All contributions must follow this sequence:
1.  **Branch Creation:** Create a new branch off the latest `develop` branch.
2.  **Implementation:** Write clean Dart (Flutter) or TypeScript (Deno Edge Functions) code following coding standards.
3.  **Local Quality Checks:** Run formatting, code analysis, and unit test tools locally.
4.  **Documentation Updates:** Update related markdown guides (e.g. API spec or DRD files) if your changes introduce new endpoints, schema columns, or UI components.
5.  **Pull Request Submission:** Open a PR targeting the `develop` branch.

---

## 3. Branch Naming Conventions

Branches must use lowercase letters, hyphens, and the appropriate prefix:
*   `feature/` (New feature modules): e.g., `feature/ai-chat`, `feature/dashboard-charts`.
*   `bugfix/` (Non-breaking bug fixes): e.g., `bugfix/login-refresh-token`.
*   `hotfix/` (Critical production fixes branched off `main`): e.g., `hotfix/payment-receipt-validation`.
*   `docs/` (Documentation-only changes): e.g., `docs/update-api-specification`.
*   `test/` (Adding or improving tests): e.g., `test/grammar-evaluator-unit`.

---

## 4. Conventional Commits Standard

We follow the Conventional Commits specification. Commit messages must use one of these prefixes:
*   `feat:` A new user-facing feature.
*   `fix:` A bug fix.
*   `refactor:` Code changes that neither fix a bug nor add a feature.
*   `docs:` Documentation updates.
*   `test:` Adding missing tests or correcting existing ones.
*   `perf:` Code changes that improve performance (e.g., latency, memory footprint).
*   `chore:` Maintenance tasks (e.g., dependency updates, CI/CD tweaks).

---

## 5. Pull Request (PR) Checklist

Ensure your PR template includes the following completed checklist before requesting reviews:
*   [ ] **Code Complete:** Has the feature or bug fix been fully implemented?
*   [ ] **Tests Added:** Have corresponding unit or widget tests been included?
*   [ ] **Linter Passes:** Does the local code pass analysis and formatting checks?
*   [ ] **No Secrets:** Have you verified no API credentials or `.env` files are tracked in this commit?
*   [ ] **CI Build Passes:** Has the automated GitHub Actions build passed?
*   [ ] **Documentation Updated:** Have changes been documented in the `docs/` folder?

---

## 6. Code Review Rubric
PR reviewers must evaluate submissions against these criteria:
*   **Architecture compliance:** Does the code adhere to the Clean Architecture design rules?
*   **Readability:** Is the code self-documenting with clean, logical separation?
*   **Security:** Are RLS rules active on database tables? Are user permissions verified?
*   **Performance:** Does the implementation avoid expensive DB queries or blocking loops?
*   **Edge Cases:** Are potential failure points (timeouts, network errors) handled gracefully?

---

## 7. Local Testing & Verification Commands

Run these verification commands in the workspace root before pushing changes:

### 7.1 Flutter Frontend Validation
```bash
# Analyze formatting consistency
dart format --set-exit-if-changed .

# Run static analysis
flutter analyze

# Run all unit and widget tests
flutter test
```

### 7.2 Supabase Backend Validation
```bash
# Run database schema linter
supabase db lint

# Verify Edge Functions Deno code
deno lint supabase/functions/
```

---

## 8. AI Coding Agent Rules

All AI agents (Antigravity, Gemini CLI, Claude Code) contributing to this project must follow these rules:
*   **Understand Context first:** Read the `docs/` specs folder before modifying source code.
*   **Write Null-Safe Dart:** Never use raw dynamic types unless absolutely necessary.
*   **Do Not Duplicate logic:** Reuse existing helper classes and constants.
*   **Include Tests:** Every new controller or repository class must be accompanied by unit tests.
*   **Keep Changes Minimal:** Only modify files related to the requested task. Do not rewrite unaffected files.

---

## 9. Definition of Done (DoD)

A task is considered complete when:
1.  All related code has been merged into the `develop` or `main` branch.
2.  All automated tests pass in the CI/CD pipeline.
3.  The feature is verified in staging or TestFlight.
4.  Documentation reflects all updates.
5.  No secrets or API keys are exposed.
