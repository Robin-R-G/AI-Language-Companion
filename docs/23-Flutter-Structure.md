# AI Language Coach
# Flutter Architecture Guide

Version: 1.0
Status: Production
Last Updated: July 2026

---

# 1. Purpose

This document defines the production architecture for the AI Language Coach Flutter application.

The architecture is designed to be:

- Scalable
- Modular
- Testable
- Maintainable
- Offline-capable
- Feature-driven
- AI-ready
- Multi-platform

This serves as the reference for every developer and AI coding agent.

---

# 2. Architecture Overview

```
Presentation Layer
        │
        ▼
Application Layer
        │
        ▼
Domain Layer
        │
        ▼
Data Layer
        │
        ▼
External Services
```

---

# 3. Technology Stack

Framework

- Flutter (Stable)

Language

- Dart

State Management

- Riverpod

Navigation

- GoRouter

Backend

- Supabase

Voice

- LiveKit

AI

- OpenAI
- Gemini

Payments

- RevenueCat

Analytics

- Firebase Analytics
- PostHog

Crash Reporting

- Firebase Crashlytics

Notifications

- Firebase Cloud Messaging

---

# 4. Folder Structure

```
lib/

core/
shared/
features/
config/
services/
routes/
models/
repositories/
providers/
utils/
generated/
main.dart
```

Feature structure

```
feature/

data/
domain/
presentation/
widgets/
providers/
services/
repositories/
```

---

# 5. Layer Responsibilities

Presentation

- UI
- Widgets
- Screens
- Navigation

Application

- State
- Use Cases
- Controllers

Domain

- Business Logic
- Entities
- Interfaces

Data

- APIs
- Local Storage
- Supabase
- AI Services

---

# 6. Dependency Rule

Allowed direction

```
Presentation

↓

Application

↓

Domain

↓

Data
```

Never import upward.

---

# 7. State Management

Use Riverpod.

State types

- Async
- Immutable
- Cached
- Derived

Avoid global mutable state.

---

# 8. Dependency Injection

Use Riverpod providers.

Inject

- Repositories
- Services
- API Clients
- AI Providers
- Storage
- Analytics

No manual singleton patterns.

---

# 9. Navigation

GoRouter handles:

- Deep links
- Authentication guards
- Nested routes
- Shell routes
- Bottom navigation

---

# 10. Feature Modules

Examples

Authentication

Home

Vocabulary

Grammar

Reading

Listening

Writing

Speaking

AI Chat

Voice

Mock Exams

Profile

Settings

Subscription

Notifications

Each module is isolated.

---

# 11. Repository Pattern

Repositories abstract:

- Supabase
- AI APIs
- Storage
- Cache

UI never calls APIs directly.

---

# 12. Services

Examples

AI Service

Voice Service

Notification Service

Analytics Service

Subscription Service

Storage Service

Auth Service

Exam Service

Services remain reusable.

---

# 13. Offline Support

Cache

- Lessons
- Vocabulary
- Progress
- Flashcards

Queue offline actions for synchronization.

---

# 14. Error Handling

Create unified error model.

Support

- Network errors
- Authentication
- Validation
- AI failures
- Timeout
- Storage errors

Show user-friendly messages.

---

# 15. Logging

Log

- Navigation
- API failures
- AI latency
- Voice events
- Purchases
- Authentication

Never log sensitive information.

---

# 16. Performance

Use

- const widgets
- lazy loading
- pagination
- image caching
- selective rebuilds
- isolates for heavy work

Target 60 FPS.

---

# 17. Security

Secure

- Tokens
- Local storage
- API keys
- User data

Use secure storage for secrets.

---

# 18. Testing Strategy

Unit Tests

Widget Tests

Integration Tests

Golden Tests

Performance Tests

Accessibility Tests

---

# 19. CI/CD

Pipeline

```
Analyze

↓

Format

↓

Test

↓

Build

↓

Deploy

↓

Smoke Test
```

---

# 20. Coding Standards

Follow Effective Dart.

Rules

- Small widgets
- Single responsibility
- Meaningful names
- Null safety
- Immutable models
- Consistent formatting

---

# 21. Documentation

Every feature includes

- README
- Architecture notes
- API contracts
- State diagram
- Testing guide

---

# 22. Scalability

Support

- New languages
- New exams
- New AI providers
- Additional platforms
- Plugin architecture
- Feature flags

---

# 23. Monitoring

Track

- Startup time
- Memory usage
- Frame rendering
- API latency
- Crash rate
- AI response time

---

# 24. Release Process

Development

↓

Testing

↓

Staging

↓

Production

↓

Monitoring

↓

Feedback

↓

Iteration

---

# 25. Definition of Done

The Flutter architecture is complete when:

- Every feature follows the defined layered architecture.
- Modules are isolated and reusable.
- Dependencies flow in one direction.
- State management is consistent.
- Navigation, repositories, and services are standardized.
- Testing, performance, security, and documentation are integrated into the development workflow.
- The architecture supports long-term growth with minimal refactoring.
