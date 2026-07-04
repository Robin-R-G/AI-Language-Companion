# Diagnostic & Debug Prompts Guide: AI Language Coach (40-DEBUG_PROMPTS)
**Version:** 1.0  
**Status:** Production  
**Target Environment:** Debugging Subagents, Workspace Developers, QA Engineers  
**Last Updated:** July 2026  

---

## 1. Purpose
This document provides reusable templates and checklists for AI coding agents to debug, optimize, refactor, and troubleshoot errors in the **AI Language Coach** codebase. It defines core rules and structured prompt templates for diagnosing specific modules.

### Global Debugging Rules
*   **Minimal Changes:** Fix issues within the smallest possible scope. Never rewrite unaffected components.
*   **Purity of Architecture:** Maintain Clean Architecture and SOLID principles during bug fixes.
*   **Backward Compatibility:** Keep APIs backward compatible unless explicitly instructed otherwise.
*   **Secrets Exposure:** Never log or expose API keys, passwords, or personal credentials.
*   **Verification:** Every fix must be accompanied by regression tests and verify that no new analyzer warnings are introduced.

---

## 2. Reusable Debug Prompts

### Prompt 1: General Bug Fix
*   **Task:** Reproduce the bug, isolate the root cause, implement the fix with minimal changes, and add regression tests.
*   **Output Structure:**
    *   Root Cause Analysis
    *   Files Changed & Code Diff
    *   Tests Added
    *   Verification Steps

### Prompt 2: Flutter Performance
*   **Task:** Analyze Flutter rendering pipelines for unnecessary rebuilds, expensive layouts, missing const constructors, or animation jank. Return comparative metrics.

### Prompt 3: Riverpod Review
*   **Task:** Audit Riverpod provider lifecycles. Check for memory leaks, dependency graphs, circular dependencies, and unclosed listeners.

### Prompt 4: Supabase Debugging
*   **Task:** Analyze backend access issues. Review auth session flows, Row-Level Security (RLS) tables policies, missing indexes, and Edge Functions logs.

### Prompt 5: AI Response Quality
*   **Task:** Evaluate AI behavior for accuracy, hallucinations, grammar feedback, translation scaffolding, and prompt efficiency.

### Prompt 6: Voice Calling
*   **Task:** Debug LiveKit Cloud WebRTC voice calling issues (connection timeouts, echo, packet loss, or credentials expiry).

### Prompt 7: Speech-to-Text (STT)
*   **Task:** Review the STT pipeline. Check transcription accuracy, background noise filters, and error recovery limits.

### Prompt 8: Text-to-Speech (TTS)
*   **Task:** Analyze TTS performance (pronunciation accuracy, pacing speed, speech interruptions, and voice streaming).

### Prompt 9: Networking
*   **Task:** Audit the API layer. Check Dio request interceptors, retry strategies, and offline request queues.

### Prompt 10: Authentication
*   **Task:** Audit authentication flow security (session refreshes, password resets, and secure token storage keychains).

### Prompt 11: UI Review
*   **Task:** Audit layout responsiveness, Material 3 configurations, and color contrasts.

### Prompt 12: Accessibility Review
*   **Task:** Evaluate layouts against WCAG AA compliance (48x48dp targets, screen reader labels).

### Prompt 13: Security Review
*   **Task:** Audit for hardcoded secrets, database SQL injections, and prompt injections. Assign severity ratings.

### Prompt 14: Database Optimization
*   **Task:** Analyze slow PostgreSQL queries, missing database indexes, and query plans.

### Prompt 15: AI Cost Optimization
*   **Task:** Optimize token usage, prompt sizes, and cache hits.

### Prompt 16: Battery Optimization
*   **Task:** Audit background polling tasks, wake locks, and audio sessions to improve battery usage.

### Prompt 17: Crash Investigation
*   **Task:** Analyze stack traces, identify root causes, and write regression tests to prevent crashes.

### Prompt 18: Code Refactoring
*   **Task:** Refactor code to improve readability and remove duplication while preserving external APIs.

### Prompt 19: Dependency Audit
*   **Task:** Check dependencies for security advisories, outdated packages, and license compatibility.

### Prompt 20: Release Readiness
*   **Task:** Validate linter checks, test executions, and document updates before making store uploads. Return a Go/No-Go recommendation.

---

## 3. Debug Report Template

When logging fixes, fill out the following template:
```text
Issue Description:
Severity Rating:
Target Environment:
Steps to Reproduce:
Expected Behavior:
Actual Behavior:
Isolated Root Cause:
Files Affected:
Implemented Code Changes:
Tests Added:
Verification Checklist:
Deployment Risk:
Follow-up Actions:
```

---

## 4. Definition of Done (DoD)
A debugging task is complete only when:
1.  The root cause has been identified and fixed.
2.  Regression tests have been written and run successfully.
3.  No new analyzer warnings are introduced.
4.  Documentation has been updated (if functional changes were made).
5.  CI build passes successfully.
