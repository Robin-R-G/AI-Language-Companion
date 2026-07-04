# Monitoring, Analytics & Telemetry Guide (45-MONITORING_AND_ANALYTICS)
**Version:** 1.0  
**Status:** Production  
**Target Environment:** Firebase Console, PostHog dashboards, Sentry triggers, Supabase logs  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the monitoring, observability, metrics, alerts triggers, and reporting strategies for **AI Language Coach**. 

Following this guide keeps backend services reliable, alerts developers to database outages, measures AI costs, and tracks conversion rates.

---

## 2. Observability & Monitoring Stack
We use separate utilities to cover different levels of the application:
*   **Mobile Crash & ANR Tracking:** Firebase Crashlytics.
*   **User Action Event Analytics:** Firebase Analytics and PostHog.
*   **Backend & API Logs:** Supabase Logs and PostgreSQL Query Analyzer.
*   **Service Availability Uptime:** Automated health checks querying Edge Function ping endpoints.

---

## 3. Core Monitoring Metrics

To maintain the system health SLAs, the following parameters are tracked continuously:

### 3.1 Mobile App Crash Monitoring
*   **Attributes:** Crash frequency, device model configurations, OS versions, stack traces, and session state logs.
*   **Target SLA:** Maintain a crash-free users rate above **99.5%**.

### 3.2 Performance Observability
*   **Attributes:** Cold/warm app boot launch times, screen load times, API request latencies, LiveKit connection pings, frame drops, and battery usage rates.

### 3.3 AI Usage & Latency Observability
*   **Attributes:** Total LLM requests per day, response latencies, token consumption counts, connection timeouts, and estimated API expenditure.

### 3.4 Spoken Audio Observability (LiveKit)
*   **Attributes:** Voice calls started, call completions, average call duration, connection dropped events, and packet loss audio metrics.

---

## 4. Product & Business Analytics

We analyze user engagement and business health across three dashboards:

### 4.1 Learning Analytics (Engagement)
*   **Engagement KPIs:** Daily Active Users (DAU), Weekly Active Users (WAU), Monthly Active Users (MAU), session length, retention rate, and streak continuation rate.
*   **Learning Progress:** Lessons completed, vocabulary review card masteries, grammar corrections logged, and mock exam completion counts.

### 4.2 Financial & Monetization Analytics
*   **Business KPIs:** Premium subscription conversions, Monthly Recurring Revenue (MRR), Annual Recurring Revenue (ARR), Customer Lifetime Value (LTV), Customer Acquisition Cost (CAC), and trial conversion rates.

### 4.3 App Install-to-Upgrade Funnel
*   **Funnel Steps:**
    ```
    App Install ---> Account Creation ---> Onboarding Complete ---> First Lesson ---> First Chat ---> 7-Day Retention ---> Pro Upgrade
    ```

---

## 5. Error Classification & Alerts Triggers

Errors logged in the system are categorized by severity:
*   **Critical (Alerts triggered immediately):** Edge Function API downtime, PostgreSQL database outages, Stripe checkout processing failures, or crash rate spikes (>0.5%).
*   **High (Slack notifications sent):** LiveKit token allocation failures, recurrent LLM API timeouts, or push notification delivery drops.
*   **Medium:** Validation failures, layout rendering issues, or offline sync timeouts.
*   **Low:** Minor layout warnings or transient networking retries.

---

## 6. Incident Management Lifecycle

We handle outages and service degradations systematically:

```
  [1. Event Detection]
  - Alerts trigger on database downtime or crash surges.
          |
          v
  [2. Impact Assessment]
  - Identify severity (Critical, High, Medium, Low).
          |
          v
  [3. Outage Containment]
  - Switch to backup LLMs (Gemini), pause rollout, or rollback builds.
          |
          v
  [4. Resolution & Patching]
  - Fix root cause, deploy code updates to production.
          |
          v
  [5. Verification & Audit]
  - Verify metrics recover, confirm analytics are logging.
          |
          v
  [6. Post-Mortem Documentation]
  - Document root cause analysis and future prevention plans.
```

---

## 7. Data Privacy & Logs Compliance
*   **GDPR Access Controls:** User deletion requests must trigger cascading PostgreSQL database deletes to remove all personal user records.
*   **PII Logging Restrictions:** Never log user passwords, API authorization tokens, credit card details, or personal voice transcripts in analytics events.
*   **Log Retention:** Rotate raw server logs every 30 days.

---

## 8. Analytics & Telemetry QA Checklist

Verify telemetry setups against this checklist before production release:
*   [ ] Do all custom events conform to the `category_action_object` naming convention?
*   [ ] Does the logging framework mask passwords, tokens, and personal transcripts?
*   [ ] Are Firebase FCM certificate mappings active?
*   [ ] Are Sentry / Crashlytics SDKs configured to upload symbols?
*   [ ] Have custom alerts thresholds been verified on server outages?
*   [ ] Have funnels been verified to track onboarding drop-off rates?
*   [ ] Are GDPR cascades deletes tables verified?
