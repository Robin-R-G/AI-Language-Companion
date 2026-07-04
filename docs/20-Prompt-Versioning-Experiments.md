# Prompt Versioning & Experiments Guide: AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Target Environment:** GitHub Prompt Repository, Supabase Configuration Vaults  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the storage structures, metadata configurations, versioning strategies, feature flag controls, A/B testing methodologies, rollback procedures, and security guardrails for managing AI prompts. 

It ensures that prompt updates do not introduce behavioral regressions, maintain low API latency, and run securely without exposing system instructions to users.

---

## 2. Prompt Repository Architecture

System prompts must be decoupled from the application source code. They are version-controlled in the following folder structure:

```text
prompts/
│
├── system/
│   └── global_system.txt          # Shared baseline system prompt wrapper
│
├── tutors/
│   ├── emma_persona.txt           # Friendly English ESL tutor
│   ├── david_persona.txt          # Strict IELTS oral examiner
│   └── sophia_persona.txt         # Goethe German case tutor
│
├── grammar/
│   └── standard_check.txt         # JSON-enforced grammar parser
│
├── translation/
│   └── standard_translate.txt     # L1 Malayalam translation scaffold
│
├── vocabulary/
│   └── vocabulary_srs.txt         # Daily SRS card queue compiler
│
├── speaking/
│   └── pronunciation_tip.txt      # Phoneme speech analytics feedback
│
└── safety/
    └── prompt_injection_shield.txt # Input sanitize regular expression rules
```

---

## 3. Prompt Metadata YAML Schema

Every prompt file in the repository must include a YAML metadata header defining configuration boundaries:

```yaml
id: grammar_check_v2
name: Enforced JSON Grammar Parser
version: 2.1.0
owner: Linguistic AI Team
status: production
created_date: 2026-07-01
updated_date: 2026-07-04
supported_providers:
  - Gemini
  - OpenAI
tags:
  - grammar
  - translation
  - json-output
changelog:
  v2.1.0: Added Malayalam explanation (explanation_l1) in JSON response envelope.
  v2.0.0: Initial release of Deno-Edge compatible JSON parser.
```

---

## 4. Semantic Versioning Strategy

Prompts are version-tracked using Semantic Versioning (SemVer) guidelines:
*   **MAJOR (e.g., v1.0.0 -> v2.0.0):** Breaking changes to response configurations (e.g., modifying JSON keys, changing output formats, or shifting target CEFR focus).
*   **MINOR (e.g., v1.0.0 -> v1.1.0):** Non-breaking additions (e.g., adding a new tutor persona voice parameter, introducing secondary synonym suggestions).
*   **PATCH (e.g., v1.0.0 -> v1.0.1):** Minor revisions (e.g., correcting spelling, adjusting explanation adjectives, or minor tone adjustments).

---

## 5. Prompt Lifecycle Stages

Prompts progress through the following stages:

```
  [1. Draft]
  - Prompt written in the local dev branch
                 |
                 v
  [2. Review]
  - Audited by AI engineers and language teachers
                 |
                 v
  [3. Testing]
  - Run regression test sets locally
                 |
                 v
  [4. Staging]
  - Deployed to the STAGE Edge Function project for QA validation
                 |
                 v
  [5. Production]
  - Gradual release to users via Feature Flags
                 |
                 v
  [6. Audit & Monitoring]
  - Track user feedback and token costs weekly
```

---

## 6. Prompt Variables Registry
Variables are injected into prompt templates dynamically at the Edge Function level:
*   `{{user_name}}`: User's display name.
*   `{{native_language}}`: Native L1 language (Malayalam).
*   `{{target_language}}`: Target L2 language.
*   `{{learning_level}}`: CEFR level (A1 to C2).
*   `{{exam}}`: Target exam (IELTS, PTE, TOEFL, Goethe).
*   `{{recent_errors}}`: Prior grammar mistakes history list.
*   `{{conversation_history}}`: Paginated array of recent chat logs.
*   `{{learning_memory}}`: Interests and memory flags.

---

## 7. Storage Strategy
*   **Version Control:** Prompts are version-controlled in the main Git repository.
*   **Database Caching:** Production prompts are cached in a Supabase table (`prompt_templates`) with version IDs and content strings, allowing Edge Functions to fetch updates instantly without redeploying code.

---

## 8. Feature Flags Rollouts Configurations

Gradual prompt rollouts are managed using database feature flag keys:

```json
{
  "features": {
    "grammar_prompt_v2_1": {
      "rollout_percentage": 10,
      "tier_gating": "Free",
      "target_exams": ["IELTS", "PTE"],
      "enabled": true
    },
    "voice_interruption_v3": {
      "rollout_percentage": 100,
      "tier_gating": "Premium",
      "target_exams": [],
      "enabled": true
    }
  }
}
```

---

## 9. A/B Testing & Experimentation Workflow

1.  **Group Division:** When users start a session, the Edge Function assigns them to a group based on their user ID hash:
    *   *Group A (Control):* Receives the stable prompt version (`v1.0.4`).
    *   *Group B (Test):* Receives the updated prompt candidate (`v1.1.0`).
2.  **Telemetry Collection:** Track user actions: Thumbs-up/down ratings, lesson completion rates, average conversational turn latency, and token count costs.
3.  **Audit Assessment:** Roll out the test prompt to 100% of users only if Group B shows a statistically significant improvement in metrics without exceeding latency limits.

---

## 10. Success Metrics for Prompts

```
+-----------------------------------+-----------------------------------+---------------------------+
| PROMPT METRIC                    | CALCULATION METHOD                | SUCCESS TARGET            |
+-----------------------------------+-----------------------------------+---------------------------+
| User Satisfaction Rate            | Sum (Thumbs Up) / Total Votes     | >95%                      |
+-----------------------------------+-----------------------------------+---------------------------+
| Conversational Loop Latency       | Roundtrip API execution time      | <2.0 seconds              |
+-----------------------------------+-----------------------------------+---------------------------+
| Token Efficiency Ratio            | Characters / Tokens               | >3.8 ratio                |
+-----------------------------------+-----------------------------------+---------------------------+
| Lesson Completion Rate            | Sum (Completed) / Sum (Started)   | >80%                      |
+-----------------------------------+-----------------------------------+---------------------------+
```

---

## 11. Automated Regression Checks
Automated PR checks run test sets:
*   *Output Parsing check:* Verify that JSON outputs match the expected schemas.
*   *Sanity check:* Ensure model replies do not exceed maximum character limits.
*   *Refusal check:* Submit unsafe prompts to verify safety filters block harmful requests.

---

## 12. Prompt Rollback Strategy
If a live prompt update degrades conversational performance:
1.  **Deactivate Feature Flag:** Update the database feature flag configuration, setting the rollout percentage to **0%**.
2.  **Fallback Trigger:** The Edge Function automatically falls back to the previous stable version.
3.  **Incident Audit:** Log the issue, run regression tests, and fix the prompt in the next development cycle.

---

## 13. Governance Review Process
Prompts must be reviewed and approved by the following roles before production deployment:
*   *Linguistic Expert:* Verifies grammar and translation accuracy.
*   *AI Engineer:* Checks prompt logic, token counts, and formatting.
*   *QA Engineer:* Reviews automated integration and safety test results.
*   *Product Owner:* Approves rollout based on roadmap milestones.

---

## 14. Multi-Provider Compatibility
Prompt templates must avoid provider-specific syntax (e.g., OpenAI-specific system role tags), using neutral formatting so prompts run consistently across Google Gemini, OpenAI, and Claude models.

---

## 15. Security & Prompt Injection Protection
*   **Input Sanitization:** Sanitize user input variables before injecting them into templates:
    *   *Escape brackets:* Strip potential command overrides like `{{` or `}}` from input text.
*   **System Privacy:** Prompts must explicitly instruct the model never to disclose internal rules or system configurations to users.

---

## 16. Prompt Quality Checklist

Verify prompt configurations against this checklist before production release:
*   [ ] Is the prompt template decoupled from mobile client code?
*   [ ] Does the file header contain valid YAML metadata?
*   [ ] Has semantic versioning (SemVer) been applied to version names?
*   [ ] Have A/B test groups and feature flags been configured in the database?
*   [ ] Does the prompt output conform to defined JSON schemas?
*   [ ] Have prompts been validated against injection attacks?
*   [ ] Are average loop response times under the 2-second latency SLA?
*   [ ] Has a rollback plan been documented and verified?
