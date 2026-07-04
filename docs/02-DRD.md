# Development Requirements Document (DRD): AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Author:** Robin R G  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the engineering standards, architecture designs, coding conventions, development workflows, and quality assurance protocols for developing the **AI Language Coach** mobile platform. 

Every software engineer, backend developer, and AI coding agent working on this codebase must adhere strictly to these guidelines. The objectives are to guarantee:
-   **Architectural Consistency:** Uniformity across feature divisions.
-   **Code Scalability:** Ease of expansion as new language exams or AI engines are added.
-   **Maintainability:** Code that is easily readable, testable, and refactored by both humans and AI models.
-   **High Performance:** Low-latency responsiveness, particularly in voice-streaming connections.

---

## 2. Technology Stack

### 2.1 Mobile Client
*   **Framework:** Flutter SDK (Stable Channel, version 3.22.x or higher)
*   **Language:** Dart (version 3.4.x or higher, enforcing strict null safety and linter profiles)
*   **Target Minimum SDKs:**
    *   *Android:* SDK Level 28 (Android 9.0 Pie) and above.
    *   *iOS:* iOS 15.0 and above.

### 2.2 Backend Infrastructure
*   **Provider:** Supabase
*   **Database:** PostgreSQL 15 (hosted via Supabase, integrating Vector Extensions for semantic searches)
*   **Authentication:** Supabase Auth (providing JWT session management and OAuth providers)
*   **File Storage:** Supabase Storage (for user voice recordings, profiles, and documents)
*   **Edge Logic:** Supabase Edge Functions (deployed via Deno/TypeScript for third-party API orchestration)

### 2.3 AI Systems
*   **Standard Prompting/Core Dialogue:** Google Gemini (Gemini 1.5 Flash for conversational pipelines)
*   **Advanced Evaluation & Mock Tests:** OpenAI API (GPT-4o for essay evaluations, pronunciation diagnostics, and score grading)
*   **Future Models:** Anthropic Claude (Claude 3.5 Sonnet to be integrated for complex reasoning tasks)

### 2.4 Voice & Audio Engine
*   **Connection Layer:** LiveKit SDK (providing WebSockets and WebRTC audio channels)
*   **Speech-to-Text (STT):** OpenAI Whisper (Whisper-large-v3 API or LiveKit integrated translation endpoints)
*   **Text-to-Speech (TTS):** OpenAI TTS (standard API) / Cartesia TTS (for ultra-low latency calls) / Piper TTS (compiled locally for offline voice generation in post-MVP scope)

### 2.5 Monitoring & Notification Telemetry
*   **Firebase Analytics:** Event tracking and funnel reporting.
*   **Firebase Crashlytics:** Crash detection and runtime error logging.
*   **Firebase Cloud Messaging (FCM):** Push notifications, streak reminders, and weekly progress alerts.

---

## 3. Flutter Clean Architecture

The application enforces **Clean Architecture** patterns. The project code is divided into three distinct layers (Domain, Data, and Presentation) with the dependency flow pointing strictly inwards toward the core business logic.

```
       PRESENTATION LAYER (UI, Widgets, Riverpod Controllers)
                  |
                  v
       APPLICATION / USE CASE LAYER (Coordinates actions)
                  |
                  v
       DOMAIN LAYER (Entities, Repository Interfaces) <--- CORE (No dependencies)
                  ^
                  |
       DATA LAYER (Models, DataSources, Repository Implementations)
                  ^
                  |
       INFRASTRUCTURE LAYER (Supabase, LiveKit, Local Cache APIs)
```

### Layer Core Directives:
*   **Domain Layer:** The core of the app. Contains pure business logic, Entities (plain Dart objects), and abstract Repository Interfaces. It has *zero* dependencies on external packages, UI frameworks, or database layers.
*   **Data Layer:** Responsible for database interactions and network communications. Contains Models (data structures with serialization logic), DataSource implementations, and concrete Repository Implementations that fulfill Domain repository definitions.
*   **Presentation Layer:** Encompasses widgets, state managers (controllers/notifiers), and routing layers. Controls how details are shown to the user and forwards user interactions to the Use Cases/Repositories.

---

## 4. Directory & Folder Structure

All client application files must map to the following structural outline:

```text
lib/
│
├── core/                         # Core components shared across multiple features
│   ├── config/                   # Global configuration (environment variables)
│   ├── constants/                # Global constants (colors, layouts, assets)
│   ├── extensions/               # Dart extension classes (BuildContext, String, etc.)
│   ├── services/                 # Global services (Analytics, Secure Storage, Logging)
│   ├── theme/                    # Material 3 styling themes and definitions
│   └── utils/                    # Helper functions (date formatters, validators)
│
├── features/                     # Feature modules organized by functional domains
│   ├── authentication/           # Signup, Login, Password recovery logic
│   ├── onboarding/               # Goal selection, L1 setup, target exam targets
│   ├── home/                     # Home Dashboard, daily tasks lists
│   ├── chat/                     # AI Text chat interfaces
│   ├── voice/                    # LiveKit voice call audio interfaces
│   ├── grammar/                  # Review screens for logged grammar mistakes
│   ├── reading/                  # Reading practice modules
│   ├── listening/                # Listening practice players
│   ├── writing/                  # Writing exam inputs and essay evaluations
│   ├── speaking/                 # Mock timed oral tests
│   ├── dashboard/                # Analytics charts, score predictions
│   ├── subscription/             # Subscription payment screens
│   └── profile/                  # User profile, history, achievements
│
├── shared/                       # Shared components used strictly by UI layers
│   ├── models/                   # Common entities/models (e.g., UserEntity)
│   ├── providers/                # Global Riverpod state providers
│   ├── routes/                   # Navigation configurations (GoRouter setup)
│   └── widgets/                  # Generic UI widgets (buttons, loaders, fields)
│
├── main.dart                     # Application bootstrap and initialization
└── main_dev.dart                 # Development environment setup
```

Each feature folder inside `lib/features/` must follow the sub-architecture layout below:
```text
features/<feature_name>/
│
├── data/
│   ├── datasources/             # Remote API interfaces and local database queries
│   ├── models/                  # JSON serialization classes (extends Entities)
│   └── repositories/            # Concrete implementations of Domain repositories
│
├── domain/
│   ├── entities/                # Pure business logic objects
│   └── repositories/            # Abstract interfaces defining data actions
│
└── presentation/
    ├── controllers/             # Riverpod Notifiers managing state changes
    ├── screens/                 # Primary full-screen view layers
    └── widgets/                 # Feature-specific reusable UI components
```

---

## 5. State Management Rules (Riverpod)

The codebase utilizes **Flutter Riverpod** (version 2.5.x or higher) with code generation (`@riverpod`) for managing reactive state.

### 5.1 Critical State Management Rules:
*   **Prohibited Packages:** Do *not* import `provider`, `get_x` (GetX), or `flutter_bloc` into the application dependencies.
*   **Decoupled Widgets:** Keep UI files strictly presentation-only. Widgets must never contain asynchronous operations, file queries, or business logic. They must read state from Providers and dispatch operations to Notifiers.
*   **Use Generated Notifiers:** Enforce code generation by using the `@riverpod` decorator. Prefer `AsyncNotifier` (for asynchronous actions containing loading/error states) and `Notifier` (for synchronous logic) over legacy `StateNotifier` classes.
*   **Immutability:** UI state classes must be marked as immutable using `@freezed` annotation interfaces.

### 5.2 AsyncNotifier Code Template Example
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_state.freezed.dart';
part 'chat_state.g.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required List<String> messages,
    required bool isRecording,
  }) = _ChatState;
}

@riverpod
class ChatController extends _$ChatController {
  @override
  FutureOr<ChatState> build() async {
    // Initialize state asynchronously
    return const ChatState(messages: [], isRecording: false);
  }

  Future<void> addMessage(String messageText) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final current = state.value!;
      // Execute background repository action
      final updatedList = [...current.messages, messageText];
      return current.copyWith(messages: updatedList);
    });
  }
}
```

---

## 6. Navigation Specifications (GoRouter)

The platform utilizes **GoRouter** to manage routing layouts, nested menus, and deep links.

### 6.1 Routing Requirements:
*   **Typed Routing:** Use `go_router_builder` to support type-safe route paths (`GoRouteData`).
*   **Authentication Guards:** Integrate redirect hooks to inspect Supabase JWT validity. Redirect unauthenticated users back to the Login Screen.
*   **Onboarding Completion Guard:** Users who have not finished their L1/L2 onboarding must be redirected to the Onboarding wizard upon logging in.
*   **Nested Navigation:** Implement ShellRoute patterns to retain UI navigation shells (like persistent bottom navigation menus) across sub-features.

### 6.2 Router Redirect Guard Interface Concept
```dart
String? authRedirectGuard(BuildContext context, GoRouterState state) {
  final session = Supabase.instance.client.auth.currentSession;
  final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

  if (session == null) {
    return isLoggingIn ? null : '/login';
  }

  if (isLoggingIn) {
    return '/home';
  }
  
  return null;
}
```

---

## 7. Dependency Injection (DI)

Dependency Injection must be handled natively using **Riverpod Providers**.
*   **No Service Locators:** Do not use `get_it` or static singletons for managing repositories.
*   **Provider Scoping:** Declare repositories as global read-only providers. Use dependency overrides within testing modules to mock external integrations.

```dart
@riverpod
ChatRepository chatRepository(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ChatRepositoryImpl(supabaseDataSource: ChatRemoteDataSource(supabaseClient));
}
```

---

## 8. API Communication Protocols

*   **Repository Isolation:** The UI must never initiate requests to database services (Supabase) or external LLM pipelines directly. It must query Repositories, which interact with Remote Data Sources.
*   **Serialization Safety:** Models mapping network payloads must inherit from entities, define custom `fromJson` and `toJson` methods, and handle missing parameters using default null fallback bounds. Enforce `@freezed` or `json_serializable` packages.

---

## 9. Repository Pattern Standard

Every feature must implement clear boundary contracts:
1.  **Entity:** Simple plain Dart model in `domain/entities/`.
2.  **Model:** Data translation mapping object in `data/models/`.
3.  **Domain Repository Interface:** Abstract definition contract in `domain/repositories/`.
4.  **Data Repository Implementation:** Concrete code parsing remote events in `data/repositories/`.

### 9.1 Repository Skeleton Example

```dart
// domain/entities/grammar_error.dart
class GrammarError {
  final String id;
  final String original;
  final String correction;

  const GrammarError({required this.id, required this.original, required this.correction});
}

// domain/repositories/grammar_repository.dart
abstract class GrammarRepository {
  Future<List<GrammarError>> fetchUserErrors(String userId);
}

// data/models/grammar_error_model.dart
class GrammarErrorModel extends GrammarError {
  GrammarErrorModel({required super.id, required super.original, required super.correction});

  factory GrammarErrorModel.fromJson(Map<String, dynamic> json) {
    return GrammarErrorModel(
      id: json['id'] as String,
      original: json['original_text'] as String,
      correction: json['corrected_text'] as String,
    );
  }
}

// data/repositories/grammar_repository_impl.dart
class GrammarRepositoryImpl implements GrammarRepository {
  final SupabaseClient _client;
  GrammarRepositoryImpl(this._client);

  @override
  Future<List<GrammarError>> fetchUserErrors(String userId) async {
    try {
      final response = await _client
          .from('grammar_errors')
          .select()
          .eq('user_id', userId);
      return response.map((json) => GrammarErrorModel.fromJson(json)).toList();
    } catch (e) {
      throw Failure("Failed to retrieve grammar errors: ${e.toString()}");
    }
  }
}
```

---

## 10. Database Regulations (Supabase & PostgreSQL)

All relational tables and configurations inside Supabase must comply with these engineering rules:

*   **UUID Primary Keys:** All tables must utilize `UUID` formats generated via standard database functions (e.g., `gen_random_uuid()`) for primary keys.
*   **Enforce Row-Level Security (RLS):** Every PostgreSQL table must have Row-Level Security active. Write strict database policy files checking that request inputs map to the active session key: `auth.uid() = user_id`.
*   **Audit Fields:** All tables must maintain:
    *   `created_at` (TIMESTAMPTZ, default: `now()`)
    *   `updated_at` (TIMESTAMPTZ, updated via standard database triggers)
*   **Indexes:** Searchable columns (such as `user_id`, `created_at`, or foreign keys) must be indexed to maintain sub-10ms query evaluations.

### 10.1 Database Update Trigger Template
```sql
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_profile_modtime
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();
```

---

## 11. Authentication Protocol

*   **Supported Logins:** Native Email signups + SSO providers (Google & Apple logins).
*   **Session Maintenance:** The client app must listen to authentication changes using Supabase auth listener channels:
    ```dart
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      // Dispatch state updates to GoRouter and state providers
    });
    ```
*   **Token Refreshing:** Tokens must be refreshed automatically in the background by the Supabase SDK client package.

---

## 12. Exception & Error Handling

*   **No Raw Exception Displays:** Never expose raw API exceptions or network logs to the UI.
*   **Sealed Class Failures:** Return error states encapsulated using sealed functional structures. Ensure all user-facing errors display customized, user-friendly help text while logging stack traces to Firebase Crashlytics.

```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
```

---

## 13. Logging Standards

*   **PII Restrictions:** Never print passwords, access tokens, API credentials, or personal user profiles to standard system logs.
*   **Structured Logs:** Use the `logger` package to generate clean, categorized trace outputs:
    *   `logger.d()`: Verbose diagnostic operations (disabled in release builds).
    *   `logger.w()`: Non-breaking alerts or recoverable issues.
    *   `logger.e()`: Critical errors (which must trigger Firebase crash logs).

---

## 14. Security Hardening

*   **HTTPS Enforcement:** All traffic must operate exclusively over encrypted TLS 1.3 channels.
*   **Secure Device Caches:** Use **Flutter Secure Storage** (which uses Keychain on iOS and Keystore on Android) to store JWTs, access credentials, and cryptographic keys.
*   **Environment Secret Storage:** Do not commit API credentials to the repository. Inject configurations dynamically using `--dart-define-from-file` configurations.

---

## 15. Coding Standards & Conventions

Enforce strict analysis profiles. Include a root-level `analysis_options.yaml` configuration checking the following:
*   Enforce `camelCase` for variables, methods, parameters, and properties.
*   Enforce `PascalCase` for classes, mixins, extension signatures, and enums.
*   Enforce `UPPER_SNAKE_CASE` for global constant declarations.
*   Enforce `snake_case.dart` for files and folders.
*   Use `dart format` before committing.

---

## 16. Structural Naming Conventions

Maintain strict naming suffixes to map components accurately:
*   **Screen Widgets:** `<Name>Screen` (e.g., `ChatScreen.dart`)
*   **Controller Providers:** `<Name>Controller` (e.g., `ChatController.dart`)
*   **Repository Interfaces:** `<Name>Repository` (e.g., `ChatRepository.dart`)
*   **Repository Classes:** `<Name>RepositoryImpl` (e.g., `ChatRepositoryImpl.dart`)
*   **Data Models:** `<Name>Model` (e.g., `ChatModel.dart`)
*   **State Objects:** `<Name>State` (e.g., `ChatState.dart`)

---

## 17. Widget Construction Guidelines

*   **Maximum Lines Limit:** Individual widget files must not exceed **200 lines**. If a UI file becomes too long, extract sub-elements into private, helper widgets in local directories.
*   **Composition Over Inheritance:** Avoid deeply nested widget trees. Prefer creating clean, reusable components instead of duplicating layouts.
*   **Keep Build Methods Pure:** Never execute network operations or local storage writes inside Flutter `build()` functions.

---

## 18. User Interface (UI) Standards

*   **Material 3:** Enforce dynamic styling using Material 3 design tokens.
*   **Frame Budget:** All screen animations, overlays, and transformations must execute within a **16ms window** to target consistent 60fps/120fps outputs.
*   **Responsive Layouts:** Layout components must adapt dynamically using `LayoutBuilder` or relative scaling packages to ensure cross-device consistency across varying screen aspect ratios.

---

## 19. Performance Standards

*   **Launch Time:** Cold app boot to first interactive hub screen must complete in **under 3 seconds**.
*   **Voice Pipeline Latency:** Target response times for LiveKit WebSockets loops must remain **under 500ms** to prevent conversational drift.
*   **Asset Performance:** All network images must utilize `CachedNetworkImage` routines with memory limits set to avoid heap crashes.

---

## 20. Offline Operations & Caching

*   **Local Caches:** Selected assets (like vocabulary lists, daily practice histories, and current profiles) must cache locally using **Hive** or **Isar** databases.
*   **Auto-Sync Retry worker:** If a user completes offline exercises, the system must cache modifications and schedule background sync workers to submit updates once connection status returns.

---

## 21. AI Prompt Governance

*   **Prompt Decoupling:** Do not write prompts directly in Flutter code.
*   **Edge Prompts Storage:** Store prompt templates centrally inside Supabase Edge Functions. Manage version control updates on prompt variables to test updates without redeploying the mobile app.

---

## 22. Voice Call Pipeline (LiveKit WebSocket Loop)

```
  [Flutter Client Microphone] ---> [WebRTC Audio Channel] ---> [LiveKit Server Nodes]
                                                                        |
                                                                        v
  [Client Local VAD Trigger] <--- [Streaming Synthesized TTS] <--- [Whisper STT]
             |                                                          |
             v                                                          v
  [Interruption Event Signal] ------------------------------------> [Gemini/OpenAI LLM]
```

### Event Handling Requirements:
*   **Voice Activity Detection (VAD):** Client microphone monitors levels. If user voice inputs exceed dynamic decibel thresholds, the client immediately sends a payload signal to the LLM agent to stop the active audio output stream.
*   **Graceful Reconnections:** The application must monitor LiveKit socket status and automatically trigger connection updates if signal packets drop.

---

## 23. Testing Specifications & Quality SLAs

```
+------------------------------------+------------------------------------+----------------------------------+
| TEST SUITE CATEGORY                | TARGET SCOPE                       | MINIMUM REQUIRED QUALITY COVERAGE|
+------------------------------------+------------------------------------+----------------------------------+
| Unit Tests                         | Repositories, Notifiers, Models    | 80% coverage on features         |
+------------------------------------+------------------------------------+----------------------------------+
| Widget Tests                       | Buttons, Form inputs, Dialogs      | Enforced on core screen elements |
+------------------------------------+------------------------------------+----------------------------------+
| Integration Tests                  | Auth flows, LiveKit connection     | Validated on physical devices    |
+------------------------------------+------------------------------------+----------------------------------+
```

### Test execution commands:
*   Run unit/widget checks: `flutter test`
*   Run integration check suites: `flutter test integration_test/app_test.dart`

---

## 24. Git Branching Workflow

Enforce trunk-based development with these standard branch naming rules:
*   **Main (Production):** The production release code.
*   **Develop (Integration):** The main branch for integrating new features.
*   **Feature Branches:** Named `feature/<name>` (e.g., `feature/voice-livekit`).
*   **Bug Fixes:** Named `fix/<name>` (e.g., `fix/login-sso`).
*   **Release Branches:** Named `release/<version>` (e.g., `release/v1.0`).

---

## 25. Commit Conventions (Conventional Commits)

All commits must align with Conventional Commits specifications:
*   `feat: <description>`: Introducing new features (e.g., `feat: add LiveKit voice call`).
*   `fix: <description>`: Fixing bugs (e.g., `fix: correct Malayalam translation`).
*   `refactor: <description>`: Modifying code structure without changing features.
*   `docs: <description>`: Documentation changes.
*   `test: <description>`: Adding unit or widget tests.

---

## 26. Pull Request Protocol

Pull requests (PRs) must be reviewed and approved before merging into the `develop` branch.
*   **PR Template Checklist:**
    1.  Description of changes and linked development task.
    2.  Screenshots or screen recordings showing visual layouts (if UI elements are changed).
    3.  Confirmation that the Flutter analyzer passes (`flutter analyze`).
    4.  Confirmation that unit and widget tests pass.
    5.  Approval from at least one reviewer.

---

## 27. CI/CD Pipeline Stages

Every commit to `develop` or `main` branches must trigger a GitHub Actions workflow:
1.  **Format Check:** Verifies that code meets requirements (`dart format --output=none --set-exit-if-changed .`).
2.  **Lint Check:** Verifies that code meets style rules (`flutter analyze`).
3.  **Unit & Widget Testing:** Executes all tests (`flutter test`).
4.  **Build Verification:** Verifies successful builds on Android (`flutter build apk --analyze-size`) and iOS (`flutter build ios --no-codesign`).

---

## 28. Accessibility (WCAG 2.1 AA Compliance)

*   **Screen Reader Semantics:** Label interactive icons using the `Semantics` widget wrapper.
*   **Contrast Standards:** Ensure high contrast between text elements and backgrounds (meeting WCAG AA minimum 4.5:1 ratio).
*   **Dynamic Font Sizes:** Ensure layout bounds do not overflow when dynamic scale variables are changed on the OS.

---

## 29. Analytics Event Tracking

Telemetry must log key activities to Firebase:
*   `user_auth_signup`
*   `user_auth_login`
*   `voice_call_started`
*   `voice_call_completed`
*   `grammar_correction_viewed`
*   `exam_simulation_finished`
*   `streak_updated`

---

## 30. AI Agent Engineering Rules

All AI coding assistants generating code for this repository must follow these rules:
*   **No Code Duplication:** Reuse existing classes and widgets. Do not write duplicate logic.
*   **No Placeholder Code:** Never write dummy classes, stub methods, or comments like `// TODO: implement later`. Code must be fully implemented, syntactically correct, and ready to compile.
*   **Async Management:** Always provide loading indices and catch-error states for asynchronous calls.
*   **Avoid Logic in Widgets:** Keep widgets focused on presentation. Put business logic inside the Domain Use Case or Riverpod controller layer.

---

## 31. Documentation Standards

*   **Document Public APIs:** Document all public methods, classes, and properties using triple-slash (`///`) Dart comments.
*   **Architecture Decision Records (ADRs):** Major architecture changes or dependencies additions must be logged as ADR markdown files inside the `docs/` folder.

---

## 32. Code Review Checklist
Before marking code as ready for review, check:
*   [ ] Does the analyzer pass without warning errors?
*   [ ] Do all tests execute successfully?
*   [ ] Are credentials and keys excluded from the code?
*   [ ] Have loading and error indicators been implemented?
*   [ ] Have accessibility tags been validated?

---

## 33. Definition of Done (DoD)
A task is complete only when:
-   The UI matches the design guidelines.
-   Database structures and API connections are implemented.
-   Code meets Clean Architecture standards.
-   All automated tests pass.
-   Change updates are documented.
-   The code has been reviewed and approved.

---

## 34. Future Scalability Designs
Ensure that feature layouts are built as isolated packages or independent modules. This modularity will allow expanding the application in future phases to support:
*   Web platforms and desktop environments.
*   More language pairs (e.g., Spanish to Japanese).
*   Additional standardized exams.
*   Offline AI model inference.

---

## 35. Final Development Principles
Implement codebase features that are **Modular, Testable, Secure, Performant, Accessible, and Maintainable**. Prioritize readability, explicit name structures, and test coverage to build a high-performance, robust platform.
