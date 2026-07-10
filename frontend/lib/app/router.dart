import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/storage/local_storage.dart';
import '../core/providers/auth_state_provider.dart';
import '../core/enums/user_role.dart';

// ── Feature pages ─────────────────────────────────────────────────────────
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/role_selection_page.dart';
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
import '../features/wallet/presentation/pages/wallet_page.dart';
import '../features/referral/presentation/pages/referral_page.dart';
import '../features/tutor/presentation/pages/tutor_marketplace_page.dart';
import '../features/tutor/presentation/pages/tutor_dashboard_page.dart';
import '../features/tutor/presentation/pages/tutor_registration_page.dart';
import '../features/admin/presentation/pages/admin_finance_center_page.dart';
import '../features/affiliate/presentation/pages/affiliate_marketplace_page.dart';
import '../features/live_class/presentation/pages/live_class_page.dart';
import '../features/profile/presentation/pages/certificate_page.dart';
import '../shared/widgets/main_scaffold.dart';

// ── Route names ───────────────────────────────────────────────────────────────

class RouteNames {
  RouteNames._();

  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String roleSelection = '/role-selection';
  static const String onboarding = '/onboarding';

  // Student Shell
  static const String home = '/home';
  static const String chat = '/chat';
  static const String vocabulary = '/vocabulary';
  static const String lessons = '/lessons';
  static const String lessonDetail = '/lesson-detail';
  static const String profile = '/profile';

  // Full-screen Student
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
  static const String editProfile = '/edit-profile';
  static const String wallet = '/wallet';
  static const String referral = '/referral';
  static const String tutors = '/tutors';
  static const String affiliates = '/affiliates';
  static const String certificates = '/certificates';

  // Tutor
  static const String tutorDashboard = '/tutor-dashboard';
  static const String tutorRegister = '/tutor-register';

  // Live Class
  static const String liveClass = '/live-class';

  // Admin (all staff roles share this prefix)
  static const String adminFinance = '/admin-finance';
}

// ── Transitions ───────────────────────────────────────────────────────────────

class AppPageTransitions {
  AppPageTransitions._();

  static CustomTransitionPage<void> slideUp(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static CustomTransitionPage<void> fadeThrough(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

// ── Keys ──────────────────────────────────────────────────────────────────────

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

// ── Provider ──────────────────────────────────────────────────────────────────

final routerProvider = FutureProvider<GoRouter>((ref) async {
  final token = await LocalStorage.getUserToken();
  final bool isLoggedIn = token != null;

  // Watch auth state so the router rebuilds on role changes
  final authState = ref.watch(authStateProvider);
  final role = authState.role;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final String location = state.matchedLocation;
      final loggedIn = authState.isAuthenticated;
      final done = LocalStorage.isOnboardingComplete();
      final roleSelected = LocalStorage.getData('selected_role') != null;

      // ── Splash ──
      if (location == RouteNames.splash) {
        // Splash screen handles its own navigation
        return null;
      }

      // ── Already logged in trying to reach auth pages ──
      if (loggedIn &&
          (location == RouteNames.login ||
              location == RouteNames.signup ||
              location == RouteNames.forgotPassword ||
              location == RouteNames.roleSelection)) {
        if (!done) return RouteNames.onboarding;
        return _homeForRole(role);
      }

      // ── Not logged in, accessing protected pages ──
      final isPublic = location == RouteNames.login ||
          location == RouteNames.signup ||
          location == RouteNames.forgotPassword ||
          location == RouteNames.roleSelection ||
          location == RouteNames.tutorRegister;
      if (!loggedIn && !isPublic) return RouteNames.login;

      // ── Role selection on first launch (not authenticated) ──
      if (!loggedIn && location == RouteNames.login && !roleSelected) {
        return RouteNames.roleSelection;
      }

      // ── Onboarding gate ──
      if (loggedIn && !done && location != RouteNames.onboarding) {
        return RouteNames.onboarding;
      }

      // ── Staff trying to access student-only routes → send to their dashboard ──
      if (loggedIn && role.isStaff && location == RouteNames.home) {
        return _homeForRole(role);
      }

      return null;
    },
    routes: [
      // ── Splash ──────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        pageBuilder: (context, state) =>
            AppPageTransitions.fadeThrough(context, state, const SplashScreen()),
      ),

      // ── Auth ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (context, state) =>
            AppPageTransitions.fadeThrough(context, state, const LoginPage()),
      ),
      GoRoute(
        path: RouteNames.signup,
        pageBuilder: (context, state) =>
            AppPageTransitions.fadeThrough(context, state, const SignupPage()),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
            context, state, const ForgotPasswordPage()),
      ),
      GoRoute(
        path: RouteNames.roleSelection,
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
            context, state, const RoleSelectionPage()),
      ),

      // ── Onboarding ───────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.onboarding,
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
            context, state, const OnboardingPage()),
      ),

      // ── Student Shell (bottom nav) ───────────────────────────────────────────
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

      // ── Full‑screen Student Routes ───────────────────────────────────────────
      GoRoute(
        path: RouteNames.voice,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const VoicePage()),
      ),
      GoRoute(
        path: RouteNames.mockExam,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const MockExamPage()),
      ),
      GoRoute(
        path: RouteNames.achievements,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const AchievementsPage()),
      ),
      GoRoute(
        path: '${RouteNames.lessonDetail}/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          context,
          state,
          LessonDetailPage(lessonId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: RouteNames.grammar,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const GrammarPage()),
      ),
      GoRoute(
        path: RouteNames.progress,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const ProgressPage()),
      ),
      GoRoute(
        path: RouteNames.reading,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const ReadingPage()),
      ),
      GoRoute(
        path: RouteNames.listening,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const ListeningPage()),
      ),
      GoRoute(
        path: RouteNames.writing,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const WritingPage()),
      ),
      GoRoute(
        path: RouteNames.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const NotificationsPage()),
      ),
      GoRoute(
        path: RouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const SettingsPage()),
      ),
      GoRoute(
        path: RouteNames.subscription,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const SubscriptionPage()),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const EditProfilePage()),
      ),
      GoRoute(
        path: RouteNames.wallet,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const WalletPage()),
      ),
      GoRoute(
        path: RouteNames.referral,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const ReferralPage()),
      ),
      GoRoute(
        path: RouteNames.tutors,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
            context, state, const TutorMarketplacePage()),
      ),
      GoRoute(
        path: RouteNames.affiliates,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
            context, state, const AffiliateMarketplacePage()),
      ),
      GoRoute(
        path: RouteNames.certificates,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(context, state, const CertificatePage()),
      ),

      // ── Tutor Routes ──────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.tutorDashboard,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
            context, state, const TutorDashboardPage()),
      ),
      GoRoute(
        path: RouteNames.tutorRegister,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
            context, state, const TutorRegistrationPage()),
      ),

      // ── Live Class ───────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.liveClass,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AppPageTransitions.slideUp(
            context,
            state,
            LiveClassPage(
              sessionId: extra?['sessionId'] ?? '',
              isHost: extra?['isHost'] ?? false,
              tutorName: extra?['tutorName'] ?? 'Tutor',
              subject: extra?['subject'],
            ),
          );
        },
      ),

      // ── Admin Routes ─────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.adminFinance,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
            context, state, const AdminFinanceCenterPage()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(state.error.toString()),
          ],
        ),
      ),
    ),
  );
});

/// Returns the initial home route based on user role.
String _homeForRole(UserRole role) {
  switch (role) {
    case UserRole.tutor:
      return RouteNames.tutorDashboard;
    case UserRole.superAdmin:
    case UserRole.admin:
    case UserRole.financeManager:
    case UserRole.tutorManager:
    case UserRole.supportManager:
    case UserRole.contentManager:
    case UserRole.marketingManager:
      return RouteNames.adminFinance; // Staff → Admin panel web
    case UserRole.student:
      return RouteNames.home;
  }
}
