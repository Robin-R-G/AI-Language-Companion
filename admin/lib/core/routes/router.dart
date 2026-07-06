import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/widgets/admin_scaffold.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/exams/presentation/pages/exams_page.dart';
import '../../features/ai_settings/presentation/pages/ai_settings_page.dart';
import '../../features/voice_monitor/presentation/pages/voice_monitor_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/security/presentation/pages/security_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/monetization/presentation/pages/monetization_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) async {
      final session = supabase.auth.currentSession;
      final loggingIn = state.uri.toString() == '/login';

      if (session == null) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/dashboard';
      }

      // Check admin privileges via token role claim or simple local check
      // In production, we read the role claim from JWT
      // For now, let user pass through if authenticated
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AdminScaffold(
            currentRoute: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: '/courses',
            builder: (context, state) => const CoursesPage(),
          ),
          GoRoute(
            path: '/exams',
            builder: (context, state) => const ExamsPage(),
          ),
          GoRoute(
            path: '/ai-settings',
            builder: (context, state) => const AISettingsPage(),
          ),
          GoRoute(
            path: '/voice',
            builder: (context, state) => const VoiceMonitorPage(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: '/security',
            builder: (context, state) => const SecurityPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/monetization',
            builder: (context, state) => const MonetizationPage(),
          ),
        ],
      ),
    ],
  );
});
