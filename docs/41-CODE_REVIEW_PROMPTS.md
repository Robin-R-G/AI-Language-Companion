# Code Review & Compliance Prompts Guide: AI Language Coach (41-CODE_REVIEW_PROMPTS)
**Version:** 1.0  
**Status:** Production  
**Target Environment:** AI Code Reviewers, PR Reviewers, Technical Leads  
**Last Updated:** July 2026  

---

## 1. Purpose
This document provides standardized, reusable prompts for AI coding agents to perform comprehensive code reviews before merging pull requests.

The goal is to verify that all contributions are production-ready, secure, performant, accessible, and compliant with Clean Architecture principles.

### Global Review Rules
*   **Role Representation:** Act as a Principal Software Engineer, Flutter Staff Engineer, Backend Architect, DevOps Engineer, Security Engineer, and QA Lead.
*   **Objective Auditing:** Review the pull request objectively. Recommend only necessary improvements. Do not rewrite unaffected modules.
*   **Actionable Explanations:** Always explain *why* an issue exists, classify its severity, and offer a concrete resolution plan.

---

## 2. Severity Classification Matrix

*   **Critical:** Security vulnerability, potential data loss, application crash, authorization flaw, or authentication issue.
*   **High:** Clean Architecture violation, major performance bottleneck, memory leak, or broken feature functionality.
*   **Medium:** Poor readability, duplicate logic, or missing test cases.
*   **Low:** Minor naming deviations, style inconsistencies, or outdated inline documentation.

---

## 3. Code Review Prompts

### Prompt 1: Architecture Review
Audit the codebase organization and package dependencies.
*   **Review Checkpoints:**
    *   Verify Clean Architecture bounds (Domain purity, no UI dependencies in domain layer).
    *   Ensure proper use of the Repository pattern and abstract interfaces separation.
    *   Validate Riverpod dependency injections and verify feature isolation.

### Prompt 2: Flutter Review
Audit Flutter code rendering and layouts.
*   **Review Checkpoints:**
    *   Verify const constructor usage, widget tree nesting depths, and rebuild optimizations.
    *   Ensure Material 3 compliance, Dark Mode support, and responsive layouts.
    *   Check error boundaries, exception handling, and loading state shimmers.

### Prompt 3: Riverpod Review
Verify state management lifecycles.
*   **Review Checkpoints:**
    *   Confirm all providers use `@riverpod` autoDispose configurations.
    *   Identify circular dependency risks and verify state rebuild triggers.

### Prompt 4: Backend Review
Review database queries and edge logic.
*   **Review Checkpoints:**
    *   Verify Supabase query performance and RLS policies on database tables.
    *   Confirm JWT checks are active in Edge Functions.
    *   Check storage buckets permissions models.

### Prompt 5: API Review
Audit network layers and integration components.
*   **Review Checkpoints:**
    *   Inspect Dio HTTP clients configurations, connect/receive timeouts, and retry logic.
    *   Verify JSON model serialization, error mapping, and pagination filters.

### Prompt 6: AI Review
Evaluate LLM prompt templates and configurations.
*   **Review Checkpoints:**
    *   Analyze prompt instructions quality, tone consistency, and hallucination preventions.
    *   Verify context sizes and cost-efficiency (reducing token overheads).

### Prompt 7: Voice Review
Audit voice WebRTC pipelines.
*   **Review Checkpoints:**
    *   Inspect LiveKit token handling, microphone permissions, audio reconnection flags, and echo cancelation configurations.

### Prompt 8: Database Review
Review PostgreSQL schemas.
*   **Review Checkpoints:**
    *   Verify that database indexes are configured on foreign keys and frequently queried columns.
    *   Check table design constraints and normalization.

### Prompt 9: Security Review
Audit codebase for vulnerabilities.
*   **Review Checkpoints:**
    *   Verify no hardcoded secrets or API keys are exposed.
    *   Check for SQL injection, cross-site scripting (XSS), prompt injection, and secure token keychain storage.

### Prompt 10: Performance Review
Analyze system latencies and resource usage.
*   **Review Checkpoints:**
    *   Evaluate app startup boot times, memory usage, API response times, and WebRTC latencies.

### Prompt 11: Accessibility Review
Audit accessibility levels.
*   **Review Checkpoints:**
    *   Verify WCAG AA compliance, touch target dimensions (>48x48dp), screen reader labels, dynamic text scaling, and color contrast.

### Prompt 12: Testing Review
Evaluate test coverage.
*   **Review Checkpoints:**
    *   Identify missing coverage across unit, widget, and integration tests.
    *   Assess mock quality for remote repositories.

### Prompt 13: Documentation Review
Check document updates.
*   **Review Checkpoints:**
    *   Verify public API docs, README updates, architecture guides, and PR changelogs.

### Prompt 14: UI/UX Review
Audit visual layout consistency.
*   **Review Checkpoints:**
    *   Ensure consistent fonts, spacing grids, empty list shimmers, error dialogs, and smooth page transitions.

### Prompt 15: Dependency Review
Check third-party packages.
*   **Review Checkpoints:**
    *   Review dependencies for security advisories, deprecated APIs, and license compatibility.

### Prompt 16: Cost Review
Optimize operational costs.
*   **Review Checkpoints:**
    *   Analyze token volumes, repeated request caches, and database read frequencies.

### Prompt 17: Release Review
Perform final pre-release checks.
*   **Review Checkpoints:**
    *   Confirm all unit tests pass, compiler warnings are resolved, and documentation is updated. Return a GO or NO-GO recommendation.

---

## 4. Standard Review Report Template

```text
## 1. Summary
Overall Quality Score: [Score / 100]
Production Ready: [Yes / No]

## 2. Critical Issues
*   [List of security, auth, or crash blocker issues]

## 3. High Issues
*   [List of performance, leaks, or architecture violations]

## 4. Medium Issues
*   [List of readability issues or missing test cases]

## 5. Low Issues
*   [List of style deviations or minor comments]

## 6. Positive Findings
*   [List of strong implementations or clean components]

## 7. Suggested Improvements
1.  [Actionable step 1]
2.  [Actionable step 2]

## 8. Final Recommendation
[GO / NO-GO]
Reason: [Summary of blockers or approval reasons]
```

---

## 5. Quality Score Rubric

```
+-----------------------------------+---------------------------+
| QUALITY DIMENSION                 | MAXIMUM SCORE VALUE       |
+-----------------------------------+---------------------------+
| Architecture Compliance           | 20 points                 |
+-----------------------------------+---------------------------+
| Security Audits                   | 20 points                 |
+-----------------------------------+---------------------------+
| Performance SLAs                  | 15 points                 |
+-----------------------------------+---------------------------+
| Testing Coverage                  | 15 points                 |
+-----------------------------------+---------------------------+
| Accessibility (WCAG)              | 10 points                 |
+-----------------------------------+---------------------------+
| Documentation                     | 10 points                 |
+-----------------------------------+---------------------------+
| Maintainability & Style           | 10 points                 |
+-----------------------------------+---------------------------+
| TOTAL MAXIMUM SCORE               | 100 points                |
+-----------------------------------+---------------------------+
```

---

## 6. Definition of Done (DoD)
A code review is complete only when:
1.  All identified **Critical** issues are fully resolved.
2.  **High** issues have defined mitigation plans in place.
3.  All tests pass successfully.
4.  A quality score is assigned according to the scoring rubric.
5.  The reviewer issues a clear **GO** or **NO-GO** decision.
