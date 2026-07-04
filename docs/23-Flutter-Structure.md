# Flutter Folder Structure & Clean Architecture Specifications: AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Target SDK:** Flutter Stable (Stable), Dart SDK  
**State Architecture:** Feature-First Clean Architecture with Riverpod & GoRouter  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the structural guidelines, package layouts, coding patterns, routing structures, and state management rules for the **AI Language Coach** mobile client. 

Adhering to these specifications guarantees decoupling, testability (Golden and unit tests), and smooth scaling when adding new L2 languages or exam modules.

---

## 2. Technology Stack Selection
*   **State Management:** Riverpod (using Riverpod generator for type-safe code generation).
*   **Routing:** GoRouter (supporting deep-linking, route guards, and redirections).
*   **Local Caching:** Isar/Hive database engines (for offline lessons storage and sync queues).
*   **API Client:** Dio (configured with token refresh interceptors and logging).
*   **Data Models:** Freezed and JSON Serializable (for immutable data structures).

---

## 3. Physical lib/ Directory Layout (ASCII Tree)

The `lib/` directory is organized into four top-level folders:

```text
lib/
├── app/                           # Global application initialization
│   ├── app.dart                   # Root MaterialApp widget
│   ├── router.dart                # GoRouter route definitions & guards
│   ├── theme.dart                 # Central light/dark themes configuration
│   └── bootstrap.dart             # App startup initialization (Firebase, Hive)
│
├── core/                          # Cross-cutting concerns & configurations
│   ├── network/                   # Dio clients, interceptors
│   ├── storage/                   # Hive/Isar database implementations
│   ├── errors/                    # Global Exception and Failure classes
│   ├── constants/                 # UI assets, API coordinates
│   └── widgets/                   # Generic cross-feature components
│
├── shared/                        # Shared domain entities & logic
│   ├── models/                    # Common data structures
│   └── widgets/                   # Common visual templates
│
├── features/                      # Domain features (feature-first)
│   ├── auth/                      # Authentications, signups
│   ├── onboarding/                # Initial goals & diagnostic tests
│   ├── ai_chat/                   # Conversational tutoring interfaces
│   ├── voice/                     # LiveKit audio call controllers
│   ├── lessons/                   # Educational quiz decks
│   ├── vocabulary/                # Spaced Repetition Flashcards
│   └── profile/                   # User configurations, deletions
│
└── main.dart                      # Launch execution endpoint
```

---

## 4. Feature Folder Layout

Individual features isolate their components into **domain**, **data**, and **presentation** layers:

```text
features/ai_chat/
├── data/
│   ├── datasources/
│   │   ├── chat_remote_datasource.dart   # Edge function API calls
│   │   └── chat_local_datasource.dart    # Offline cached chats (Hive)
│   ├── models/
│   │   └── chat_message_model.dart       # DTO mapping backend payload
│   └── repositories/
│       └── chat_repository_impl.dart     # Repository implementation
│
├── domain/
│   ├── entities/
│   │   └── chat_message.dart             # Pure domain entities (no serialization)
│   ├── repositories/
│   │   └── chat_repository.dart          # Abstract repository interface
│   └── usecases/
│       └── send_chat_message.dart        # Individual business use cases
│
└── presentation/
    ├── controllers/
    │   └── chat_controller.dart          # Riverpod state controller notifier
    ├── pages/
    │   └── chat_page.dart                # Full screen UI container
    └── widgets/
        └── chat_bubble.dart              # Specialized page UI component
```

---

## 5. Clean Architecture Layers

1.  **Presentation Layer:** Contains UI pages, widgets, and state controllers. Business logic is kept out of widgets, managed instead by state controllers.
2.  **Domain Layer:** The core of the feature. Contains pure business entities, repository interfaces, and use cases. This layer is completely independent of frameworks, databases, or network clients.
3.  **Data Layer:** Handles network calls and local storage. Contains repository implementations, database models, and remote data sources.

---

## 6. Routing & Redirection Guards

GoRouter coordinates app navigation. Route guards check session status to redirect users appropriately:

```dart
// lib/app/router.dart
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final bool loggedIn = checkUserSession();
    final bool onboardingDone = checkOnboardingStatus();
    
    // Redirect unauthenticated users to login
    if (!loggedIn && state.matchedLocation != '/login') {
      return '/login';
    }
    
    // Force authenticated users to finish onboarding
    if (loggedIn && !onboardingDone && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    
    return null; // Keep current route
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
  ],
);
```

---

## 7. Riverpod State Controller Skeleton

State controllers handle user interactions and update UI states:

```dart
// lib/features/ai_chat/presentation/controllers/chat_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_controller.g.dart';

@riverpod
class ChatController extends _$ChatController {
  @override
  AsyncValue<List<ChatMessage>> build() {
    return const AsyncValue.data([]); // Initial state
  }

  Future<void> dispatchMessage(String text) async {
    state = const AsyncValue.loading();
    
    final sendUseCase = ref.read(sendChatMessageProvider);
    final result = await sendUseCase.call(text);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (reply) => state = AsyncValue.data([...state.value ?? [], reply]),
    );
  }
}
```

---

## 8. Dependency Injection & Service Registries
Riverpod providers handle dependency injection, managing API clients, database engines, and repositories:
```dart
// lib/core/providers/network_providers.dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_providers.g.dart';

@riverpod
Dio dioClient(DioClientRef ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://api.yourdomain.com/v1',
    connectTimeout: const Duration(seconds: 10),
  ));
}
```

---

## 9. Core Services Index
The `core/services/` directory contains global helper classes:
*   `AuthenticationService`: Manages user credentials sessions and JWT tokens.
*   `VoiceService`: Interfaces with LiveKit WebRTC media transport channels.
*   `ConnectivityService`: Monitors network status to toggle offline/online database synchronization workflows.

---

## 10. Assets Folder structure

Assets are version-controlled in the project root:

```text
assets/
├── icons/                         # SVG icons
├── illustrations/                 # Vector illustrations
├── animations/                    # Lottie and Rive animations
└── fonts/                         # Custom fonts (Inter font files)
```

---

## 11. Localization Setup (Bilingual ARBs)

Bilingual translations are managed in the `lib/l10n/` directory:
*   `app_en.arb`: English primary translations.
*   `app_ml.arb`: Malayalam native-language scaffolding translations.
*   `app_de.arb`: German localized target translations.

---

## 12. Centralized Error Handling & Failure Classes
To prevent raw exceptions from crashing the UI, Edge failures map to domain Failure objects:
*   `AppException`: Base wrapper for network or database exceptions.
*   `Failure`: Domain-layer representations of errors (e.g., `NetworkFailure`, `AuthFailure`, `DatabaseFailure`) containing user-friendly error messages.

---

## 13. Flutter Folder Structure Checklist

Verify the directory setup against this checklist before production release:
*   [ ] Does the project structure follow feature-first Clean Architecture guidelines?
*   [ ] Are dependencies injected using type-safe Riverpod providers?
*   [ ] Do widgets update states using AsyncNotifier controllers?
*   [ ] Are routes and redirects guards configured using GoRouter?
*   [ ] Do model classes use Freezed for immutable data structures?
*   [ ] Are API keys and secrets excluded from the mobile client code?
*   [ ] Have assets been optimized and localized using ARB translation templates?
*   [ ] Does the local cache fallback configuration support offline lessons study?
*   [ ] Do tests match the feature-first file layout architecture?
