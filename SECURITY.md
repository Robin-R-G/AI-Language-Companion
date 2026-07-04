# Security Policy: AI Language Coach (SECURITY.md)

## Supported Versions

We actively issue security updates for the following versions:
*   Version **1.x** (Active Production Releases)

---

## Reporting a Vulnerability

If you discover a security vulnerability (such as exposed credentials, authentication bypass, or data leaks), please **do not open a public Github Issue**. Instead:
1.  Send a detailed email report to **security@ailanguagecoach.com**.
2.  Include reproduction steps, request logs, and affected files (such as database migrations or edge functions paths).
3.  Allow **72 hours** for the core engineering team to contain and patch the issue in the staging environments before coordinating public disclosures.

---

## Vulnerability Handling Pipeline

```
  [1. Report Received] ---> [2. Contain & Audit] ---> [3. Rotate Credentials & Patch] ---> [4. Verify & Deploy]
```
*   **Response SLA:** We verify vulnerabilities within **24 hours** and deploy security patches within **48 hours** of confirmation.
