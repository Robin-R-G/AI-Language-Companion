# Security Architecture & Compliance Guide: RLS, Vaults & Defenses (43-SECURITY_GUIDE)
**Version:** 1.0  
**Status:** Production  
**Target Environment:** Deno Edge Functions, Supabase PostgreSQL, Mobile Secure Keychains  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the security architecture, data protection standards, threat mitigations, and compliance rules for **AI Language Coach**. 

Following this guide protects user personal data (PII), blocks prompt injection attacks, audits database accesses, and ensures GDPR compliance.

---

## 2. Core Security Principles
Every software contribution must align with these six pillars of defense:
*   **Least Privilege:** Restrict user and database connection permissions to the minimum necessary actions.
*   **Defense in Depth:** Stack multiple verification layers (e.g. client check, gateway rate limits, database RLS policies).
*   **Secure by Default:** Initialize all tables and storage buckets with public access disabled.
*   **Zero Trust:** Authenticate and authorize every incoming API request on the server-side.
*   **Fail Securely:** Ensure exceptions (timeouts, crashes) block traffic instead of exposing debug logs or bypassing access controls.
*   **Privacy by Design:** Collect only the metadata required to run learning logs.

---

## 3. Threat Model & Mitigations
*   **Account Takeover:** Mitigated using Supabase secure social logins (Google/Apple) and automatic session refreshes.
*   **Token Leakage:** Session tokens are stored strictly inside the device's secure keychains (`flutter_secure_storage`).
*   **Prompt Injection:** Mitigated by wrapping user inputs in system templates and using gateway moderation filters.
*   **Database SQL Injection:** Prevented by using PostgreSQL parameterized queries and object-relational mapping (ORM) abstractions inside migrations.
*   **Denial of Service (DoS):** Mitigated by rate limiting endpoints to **100 requests per minute per IP address**.

---

## 4. Authentication, Authorization & Session Management
*   **Auth Methods:** Email + Password, Google, Apple. Enforce email verification and secure password resets.
*   **Server-Side Access Control (RLS):** All Postgres tables must enable Row-Level Security:
    ```sql
    ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
    ```
    *   *Example policy:* Ensure read/write actions validate the active authenticated user ID:
        ```sql
        CREATE POLICY "Users can edit own profile" 
        ON public.user_profiles 
        FOR ALL 
        TO authenticated 
        USING (auth.uid() = auth_user_id);
        ```
*   **Device Session Revocation:** Support immediate user logout, revoking refresh tokens on the server-side.

---

## 5. Input & Output Validation Standards
*   **Input Validation:** Sanitize user strings, emails, and passwords before database execution. Reject malformed JSON schemas or scripts early.
*   **Output Validation:** Verify LLM responses are well-formed JSON or clean markdown. Filter out links, harmful phrases, or unexpected tokens. Display a friendly fallback message if validation checks fail.

---

## 6. Infrastructure Security (Storage, Networks & Vaults)
*   **Supabase Storage:** Restrict storage buckets to authenticated read/write access. Enforce file upload size limits (audio <25MB, images <10MB).
*   **Network Transport:** Enforce TLS 1.2+ protocols for all HTTPS/WSS channels. Reject unencrypted HTTP requests.
*   **Key Rotation:** Rotate API secrets and database passwords regularly. Store production keys in the Supabase Secrets Vault:
    ```bash
    supabase secrets set OPENAI_API_KEY=your_key --project-ref your_ref
    ```

---

## 7. Data Privacy, Compliance & GDPR
*   **Data Minimization:** Keep user profiles, progress logs, and weak points cached but exclude PII data from analytics logs.
*   **User Rights:** Build user settings triggers enabling profile exports and immediate cascading account deletions.
*   **Auditing Cycles:** Run dependency security scans before every release. Update packages with identified vulnerabilities.

---

## 8. Incident Response Escalation
If a security vulnerability or credentials exposure is detected:
1.  **Isolate & Contain:** Disable affected endpoints or pause active phased store rollouts.
2.  **Credentials Rotation:** Immediately rotate leaked API secrets and update configuration values in secret managers.
3.  **Vulnerability Patch:** Deploy a hotfix to patch the vulnerability. Verify the fix in staging.
4.  **Audit Logs:** Review Postgres transaction histories to verify if unauthorized access occurred.
5.  **Post-Mortem:** Document root causes and prevention steps.

---

## 9. Production Launch Security Checklist

Verify the application security setup against this checklist before production release:
*   [ ] Is HTTPS/WSS enforced for all network connections?
*   [ ] Have RLS policies been enabled on all user-owned tables?
*   [ ] Are API keys and secrets stored securely in vault configurations?
*   [ ] Do input fields reject scripts, SQL queries, or injection payloads?
*   [ ] Are file uploads gated to 25MB limits?
*   [ ] Does the logging framework mask passwords, tokens, and personal transcripts?
*   [ ] Have user deletion actions been verified to trigger cascading deletes?
*   [ ] Have dependencies been scanned for vulnerabilities?
*   [ ] Has the incident response path been assigned to the team?
