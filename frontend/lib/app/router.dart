import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/storage/local_storage.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/ai_chat/presentation/pages/chat_page.dart';
import '../features/vocabulary/presentation/pages/vocabulary_page.dart';
import '../features/lessons/presentation/pages/lessons_page.dart';
import '../features/lesson_detail/presentation/pages/lesson_detail_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/voice/presentation/pages/voice_page.dart';
import '../features/mock_exam/presentation/pages/mock_exam_page.dart';
import '../features/achievements/presentation/pages/achievements_page.dart';
import '../features/grammar/presentation/pages/grammar_page.dart';
import '../features/progress/presentation/pages/progress_page.dart';
import '../features/reading/presentation/pages/reading_page.dart';
import '../features/listening/presentation/pages/listening_page.dart';
import '../features/writing/presentation/pages/writing_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/subscription/presentation/pages/subscription_page.dart';
import '../shared/widgets/main_scaffold.dart';

/// Route names for named navigation.
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String vocabulary = '/vocabulary';
  static const String lessons = '/lessons';
  static const String lessonDetail = '/lesson-detail';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String voice = '/voice';
  static const String mockExam = '/mock-exam';
  static const String achievements = '/achievements';
  static const String grammar = '/grammar';
  static const String progress = '/progress';
  static const String reading = '/reading';
  static const String listening = '/listening';
  static const String writing = '/writing';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
}

/// Custom page transition builder.
class AppPageTransitions {
  AppPageTransitions._();

  static CustomTransitionPage<void> slideUp(BuildContext context, GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage<void> fadeThrough(BuildContext context, GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

/// Global key for navigation context.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Main router provider.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final bool isLoggedIn = LocalStorage.getUserToken() != null;
      final bool onboardingDone = LocalStorage.isOnboardingComplete();
      final String location = state.matchedLocation;

      if (location == RouteNames.splash) {
        if (!isLoggedIn) return RouteNames.login;
        if (!onboardingDone) return RouteNames.onboarding;
        return RouteNames.home;
      }

      if (isLoggedIn &&
          (location == RouteNames.login ||
              location == RouteNames.signup ||
              location == RouteNames.forgotPassword)) {
        if (!onboardingDone) return RouteNames.onboarding;
        return RouteNames.home;
      }

      if (!isLoggedIn &&
          location != RouteNames.login &&
          location != RouteNames.signup &&
          location != RouteNames.forgotPassword) {
        return RouteNames.login;
      }

      if (isLoggedIn && !onboardingDone && location != RouteNames.onboarding) {
        return RouteNames.onboarding;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context,
          state,
          const SplashScreen(),
        ),
      ),

      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context,
          state,
          const LoginPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.signup,
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context,
          state,
          const SignupPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context,
          state,
          const ForgotPasswordPage(),
        ),
      ),

      // Onboarding
      GoRoute(
        path: RouteNames.onboarding,
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context,
          state,
          const OnboardingPage(),
        ),
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: RouteNames.chat,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ChatPage()),
          ),
          GoRoute(
            path: RouteNames.vocabulary,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: VocabularyPage()),
          ),
          GoRoute(
            path: RouteNames.lessons,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LessonsPage()),
          ),
          GoRoute(
            path: RouteNames.profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),

      // Full Screen Routes
      GoRoute(
        path: RouteNames.voice,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const VoicePage(),
        ),
      ),
      GoRoute(
        path: RouteNames.mockExam,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const MockExamPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.achievements,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const AchievementsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.lessonDetail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const LessonDetailPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.grammar,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const GrammarPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.progress,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const ProgressPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.reading,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const ReadingPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.listening,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const ListeningPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.writing,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const WritingPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const NotificationsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const SettingsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.subscription,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const SubscriptionPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          const EditProfilePage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.error}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ),
  );
});
