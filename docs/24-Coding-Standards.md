# Coding Standards & Quality Guidelines: AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Target Environment:** Dart/Flutter Compiler, Static Analyzer pipelines  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the coding standards, style guides, architectural constraints, security controls, testing targets, and code review criteria for **AI Language Coach**. 

Adherence to these standards ensures code consistency, high testability (Golden and unit tests), and a scalable architecture across the mobile client and backend edge functions.

---

## 2. General Principles
All developers (and AI assistants) must apply these software design principles:
*   **SOLID Principles:** Ensure Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, and Dependency Inversion.
*   **DRY (Don't Repeat Yourself):** Extract common business logic into shared libraries.
*   **KISS (Keep It Simple):** Avoid over-engineering components before requirements are established.
*   **YAGNI (You Aren't Gonna Need It):** Build only what is required by current PR features.
*   **Composition over Inheritance:** Prioritize composing objects with dedicated widgets or behaviors instead of building deep class inheritance hierarchies.

---

## 3. Dart Style Guide
*   **Formatting:** Run `dart format .` before pushing commits.
*   **Type Safety:** Enforce strong typing. Avoid using `dynamic` unless parsing dynamic JSON fields.
*   **Null Safety:** Ensure sound null safety. Do not bypass compile-time checks using non-null assertion operators (`!`) unless safety has been explicitly validated.
*   **Nesting Limit:** Keep block nesting levels under **3 levels**. If nesting grows deeper, refactor blocks into separate methods.
*   **Method Length:** Methods must not exceed **50 lines of code**. Refactor long methods into smaller helper functions.

---

## 4. Naming Conventions

```
+---------------------------+---------------------------+-------------------------------------------+
| CLASS TYPE / SYMBOL       | CASE STYLE                | EXAMPLE FORMATS                           |
+---------------------------+---------------------------+-------------------------------------------+
| Files & Directories       | snake_case                | login_page.dart, chat_repository.dart     |
+---------------------------+---------------------------+-------------------------------------------+
| Classes, Mixins, Enums    | PascalCase                | LoginPage, ChatRepository, VoiceService   |
+---------------------------+---------------------------+-------------------------------------------+
| Variables & Methods       | camelCase                 | userProfile, getGrammarScore()            |
+---------------------------+---------------------------+-------------------------------------------+
| Constants (Global)        | camelCase                 | const maxRetryCount = 3;                  |
+---------------------------+---------------------------+-------------------------------------------+
| Private Fields / Methods  | _camelCase (prefixed)     | final _authSessionToken, void _syncUI()   |
+---------------------------+---------------------------+-------------------------------------------+
```

---

## 5. Folder Rules & Feature Isolation
*   Every feature must separate its logic into `data/`, `domain/`, and `presentation/` layers.
*   Features must remain isolated: a feature directory must not import files from another feature directory directly. Inter-feature communications must pass through shared repository interfaces or core service providers.
*   Global configurations, themes, network clients, and generic models belong in the `core/` or `shared/` directories.

---

## 6. Clean Architecture Import Restrictions
To prevent architectural regressions, dependency flows must only point inward:

```
  [Presentation Layer (UI, Pages, Controllers)]
                       |
                       v
  [Domain Layer (Entities, Use Cases, Interfaces)]  <--- MUST NOT import Flutter UI packages
                       ^
                       |
  [Data Layer (DTOs, Repositories, Caches, API)]
```

*   **Strict Rule:** The **Domain** layer must remain pure Dart. It is forbidden to import Flutter UI packages (such as `package:flutter/material.dart` or `package:flutter/widgets.dart`) into domain files.

---

## 7. State Management Guidelines (Riverpod)
*   **No UI Business Logic:** Widgets must only handle rendering and passing user gestures to controllers. All business logic must reside in Riverpod `Notifier` or `AsyncNotifier` controllers.
*   **Resource Disposals:** Use `autoDispose` on all transient providers (like chat sessions or page data providers) to release memory when widgets unmount.
*   **Immutability:** State objects must be immutable. Modify state values by generating copies using `copyWith` methods (e.g., using Freezed).

---

## 8. Networking Standards (Dio API Client)
*   **Explicit Timeouts:** Every network client must configure connection and receive timeouts:
    *   `connectTimeout: Duration(seconds: 10)`
    *   `receiveTimeout: Duration(seconds: 15)`
*   **Centralized Interceptors:** Handle token refreshes, rate limits, and network logging inside dedicated Dio interceptors.
*   **No Direct Calls:** Widgets must never call remote data sources or REST APIs directly. All network requests must pass through repository layers.

---

## 9. Standardized Error Handling Pattern

Every asynchronous transaction must return a functional `Result` containing either a `Failure` or the requested data. Avoid throwing raw exceptions up to the UI:

```dart
// lib/core/errors/failure.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

// lib/core/errors/result.dart
class Result<T> {
  final T? value;
  final Failure? failure;

  const Result.success(T val) : value = val, failure = null;
  const Result.error(Failure fail) : value = null, failure = fail;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  void fold(void Function(Failure) onError, void Function(T) onSuccess) {
    if (isFailure) {
      onError(failure!);
    } else {
      onSuccess(value as T);
    }
  }
}
```

---

## 10. Dependency Injection
*   Always program to abstract interfaces rather than concrete implementations.
*   Inject repository and service dependencies through class constructors, using Riverpod providers to manage resolutions.

---

## 11. Security Standards
*   **No Hardcoded Secrets:** Do not store API keys, service role keys, or database passwords in the frontend repository. Use backend gateways (Supabase Edge Functions) to proxy external API requests securely.
*   **PII Sanitization:** Do not print or log passwords, session tokens, or user transcripts in console logs.
*   **Secure Caching:** Cache sensitive credentials (such as user JWT tokens) in secure storage interfaces (like `flutter_secure_storage`).

---

## 12. Centralized Linting Configuration

Every project environment must configure this unified static analysis rule check set:

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_slow_async_io
    - cancel_subscriptions
    - close_sinks
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - unnecessary_null_checks
```

---

## 13. Git Commit Semantic Standards

Commit messages must follow the Conventional Commits specification:

> **Format:** `<type>(<scope>): <description>`

### Types List:
*   `feat`: Deploys a new feature.
*   `fix`: Solves a bug or regression.
*   `refactor`: Modifies code without changing behaviors.
*   `docs`: Updates documentation files.
*   `test`: Appends new unit or golden tests.
*   `chore`: Updates libraries versions or settings.

### Examples:
*   `feat(auth): add email verification routing link`
*   `fix(chat): solve keyboard rendering overlap in chat view`

---

## 14. Code Quality Checklists

### 14.1 Pull Request Checklist
*   [ ] Does the code compile successfully without warnings?
*   [ ] Do all automated unit, widget, and integration tests pass?
*   [ ] Has static code analysis (`flutter analyze`) run successfully?
*   [ ] Are all secrets, credentials, and API keys excluded from the changes?
*   [ ] Is the new code documented with clear comments?

### 14.2 Code Reviewer Checklist
*   [ ] Does the code follow Clean Architecture import separation rules?
*   [ ] Are exceptions caught and mapped to domain `Failure` objects?
*   [ ] Are expensive widgets cached using `const` constructors?
*   [ ] Are raw JSON properties validated against defined schemas?
*   [ ] Does the implementation prevent N+1 database queries?
