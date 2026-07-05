# AI Language Coach
# Backend Architecture Guide

Version: 1.0
Status: Production
Last Updated: July 2026

---

# 1. Purpose

This document defines the backend architecture for the AI Language Coach platform.

Objectives:

- Scalable
- Secure
- Event-driven
- AI-ready
- Multi-tenant capable
- Observable
- Cost-efficient
- Highly available

This document serves as the backend blueprint for all engineers and AI coding agents.

---

# 2. High-Level Architecture

```
                 Flutter App
                       │
                API Gateway / Edge
                       │
        ┌──────────────┼──────────────┐
        │              │              │
 Authentication   Business APIs   AI Gateway
        │              │              │
        └──────────────┼──────────────┐
                       │
                PostgreSQL (Supabase)
                       │
              Object Storage / CDN
                       │
         Analytics • Queue • Monitoring
```

---

# 3. Technology Stack

Backend Platform

- Supabase

Database

- PostgreSQL

Authentication

- Supabase Auth

Storage

- Supabase Storage

Realtime

- Supabase Realtime

Server Functions

- Supabase Edge Functions

Queue

- Background Workers

AI Providers

- OpenAI
- Google Gemini

Payments

- RevenueCat

Notifications

- Firebase Cloud Messaging

Monitoring

- Sentry
- PostHog
- Firebase Crashlytics

---

# 4. Backend Modules

Authentication

User Profile

Learning Engine

Vocabulary

Grammar

Reading

Listening

Writing

Speaking

Exam Engine

AI Gateway

Recommendation Engine

Progress Tracking

Achievements

Subscription

Notifications

Admin

Analytics

---

# 5. API Design

Follow REST conventions where appropriate.

Requirements

- Versioned endpoints
- Consistent response format
- Pagination
- Filtering
- Sorting
- Rate limiting
- Validation
- Idempotency for critical operations

---

# 6. Database Design

Core tables

- users
- profiles
- languages
- exams
- lessons
- vocabulary
- grammar_topics
- conversations
- speaking_sessions
- writing_submissions
- progress
- achievements
- subscriptions
- notifications
- analytics_events

Use UUID primary keys.

---

# 7. Authentication

Support

- Email
- Google
- Apple
- Anonymous guest mode (optional)

Features

- JWT
- Refresh tokens
- Secure sessions
- MFA-ready architecture

---

# 8. Authorization

Use Row Level Security (RLS).

Roles

- Student
- Premium Student
- Moderator
- Admin
- Super Admin

Grant minimum required permissions.

---

# 9. AI Gateway

Centralize all AI requests.

Responsibilities

- Provider routing
- Prompt injection
- Context assembly
- Streaming
- Safety checks
- Cost tracking
- Retry logic
- Fallback models

Applications never call AI providers directly.

---

# 10. File Storage

Store

- Audio recordings
- Profile images
- Certificates
- Reports
- Attachments

Use signed URLs for protected content.

---

# 11. Background Jobs

Examples

- Daily reminders
- Progress recalculation
- Badge generation
- Email delivery
- Analytics aggregation
- Cache refresh
- AI summarization

---

# 12. Caching

Cache

- User profile
- Lesson metadata
- Vocabulary lists
- AI prompts
- Exam templates

Use TTL-based invalidation.

---

# 13. Search

Support searching for

- Lessons
- Vocabulary
- Grammar topics
- Conversations
- Exam resources

Implement full-text search where appropriate.

---

# 14. Security

Protect against

- SQL Injection
- XSS
- CSRF
- Replay attacks
- Brute force
- Rate abuse

Encrypt sensitive data at rest and in transit.

---

# 15. Observability

Track

- API latency
- AI latency
- Database performance
- Queue health
- Storage usage
- Error rates
- Active users

Use centralized logging.

---

# 16. Backup Strategy

Database

- Daily automated backups
- Point-in-time recovery

Storage

- Versioning
- Redundant backups

Test restoration procedures regularly.

---

# 17. Scalability

Support

- Horizontal scaling
- Stateless services
- CDN
- Connection pooling
- Background workers
- Read replicas (future)

---

# 18. Performance Targets

Authentication

<300 ms

Standard API

<500 ms

AI Streaming Start

<1 second

Realtime Sync

<200 ms

---

# 19. Deployment

Environments

Development

↓

Testing

↓

Staging

↓

Production

Automate deployments with CI/CD.

---

# 20. Definition of Done

The backend architecture is complete when:

- Services are modular and secure.
- APIs follow consistent standards.
- AI interactions pass through a centralized gateway.
- Database security is enforced with RLS.
- Monitoring, backups, and observability are configured.
- The platform can scale to support future growth without major architectural changes.
