# Master Build Prompt & AI Architect System Rules (38-MASTER_BUILD_PROMPT)
**Version:** 1.0  
**Status:** Production  
**Target Environment:** AI Coding Agents (Gemini, Claude, GPT-4)  
**Last Updated:** July 2026  

---

## 1. Purpose
This prompt defines the absolute architectural rules, directory structures, code boundaries, database schema models, lint constraints, and development workflows that **every AI agent** must adhere to when generating, editing, or auditing code in the **AI Language Coach** codebase.

---

## 2. Core Technology Stack Reference
*   **Mobile Frontend:** Flutter (Stable), Dart with Sound Null Safety.
*   **State Management:** Riverpod (with code generation: `@riverpod`).
*   **Navigation:** GoRouter (with redirect route guards).
*   **Local Caching:** Isar / Hive.
*   **Backend Services:** Supabase DB (PostgreSQL 15), Auth, Storage, Realtime, Deno Edge Functions.
*   **Streaming Voice:** LiveKit Cloud SDK (WebRTC).
*   **Billing Gateway:** RevenueCat SDK.
*   **Telemetry:** Firebase FCM, Crashlytics, and PostHog.

---

## 3. Strict Clean Architecture Directory Rules

The codebase strictly isolates components:
```text
lib/
├── core/                  # Global utilities, design tokens, client configurations
└── features/
    └── [feature_name]/
        ├── domain/        # Entities, failure cases, repository interfaces (PURE DART)
        ├── data/          # Repositories implementations, DB data sources, models (JSON)
        └── presentation/  # Widgets, pages, controllers (Riverpod providers)
```

> [!CAUTION]
> The domain layer must remain **100% pure Dart**. Importing Flutter UI packages (e.g. `material.dart`) inside the domain folder is strictly forbidden.

---

## 4. State Management Conventions (Riverpod)
*   Use code generation syntax exclusively (`@riverpod` annotated classes).
*   Controllers must inherit from `AutoDisposeAsyncNotifier` or `Notifier` to avoid memory leaks.
*   Keep controllers separated from UI layouts. UI widgets must only call `ref.watch()` or `ref.read()`.

---

## 5. Backend Database Constraints
*   All tables must enforce **Row-Level Security (RLS)**. Security policies must validate:
    ```sql
    auth.uid() = auth_user_id
    ```
*   Deno Edge Functions must handle CORS and JWT verification middleware securely (JWT checks are disabled *only* on webhooks or anonymous endpoints).

---

## 6. How to Run Audits & Verifications
Before presenting code edits, ensure the generation:
1.  Passes linter rules (`flutter analyze`).
2.  Adheres to sound null safety (no dynamic types, no raw `!`, utilize optional chains).
3.  Includes unit tests targeting repositories and controller states.
