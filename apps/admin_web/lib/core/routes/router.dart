import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/widgets/admin_scaffold.dart';
import '../config/admin_config.dart';
import '../../features/login/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/user_management/presentation/pages/users_page.dart';
import '../../features/tutor_management/presentation/pages/tutors_page.dart';
import '../../features/student_management/presentation/pages/students_page.dart';
import '../../features/subscription_management/presentation/pages/subscriptions_page.dart';
import '../../features/wallet_management/presentation/pages/wallet_page.dart';
import '../../features/finance_center/presentation/pages/finance_page.dart';
import '../../features/payment_management/presentation/pages/payments_page.dart';
import '../../features/tutor_payments/presentation/pages/tutor_payments_page.dart';
import '../../features/ai_cost_monitor/presentation/pages/ai_cost_page.dart';
import '../../features/ai_provider_config/presentation/pages/ai_providers_page.dart';
import '../../features/ai_billing/presentation/pages/ai_billing_page.dart';
import '../../features/prompt_management/presentation/pages/prompts_page.dart';
import '../../features/tutor_marketplace/presentation/pages/marketplace_page.dart';
import '../../features/content_management/presentation/pages/courses_page.dart';
import '../../features/exam_management/presentation/pages/exams_page.dart';
import '../../features/notification_management/presentation/pages/notifications_page.dart';
import '../../features/referral_program/presentation/pages/referrals_page.dart';
import '../../features/reports_analytics/presentation/pages/reports_page.dart';
import '../../features/business_intelligence/presentation/pages/bi_page.dart';
import '../../features/audit_logs/presentation/pages/audit_logs_page.dart';
import '../../features/system_settings/presentation/pages/settings_page.dart';
import '../../features/system_settings/presentation/pages/feature_flags_page.dart';
import '../../features/system_settings/presentation/pages/dev_console_page.dart';
import '../../features/support_tickets/presentation/pages/support_page.dart';
import '../../features/infrastructure/presentation/pages/infrastructure_page.dart';
import '../../features/voice_monitor/presentation/pages/voice_monitor_page.dart';
import '../../features/pxpipe_analytics/presentation/pages/pxpipe_analytics_page.dart';

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

      // Verify admin role from database profiles to prevent loop issues with default JWT claims
      try {
        final profileRes = await supabase
            .from('user_profiles')
            .select('role')
            .eq('auth_user_id', session.user.id)
            .maybeSingle();

        if (profileRes == null) {
          await supabase.auth.signOut();
          return '/login';
        }

        final role = profileRes['role'] as String?;
        if (!AdminConfig.adminRoles.contains(role)) {
          await supabase.auth.signOut();
          return '/login';
        }
      } catch (_) {
        await supabase.auth.signOut();
        return '/login';
      }
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
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
          GoRoute(path: '/users', builder: (_, __) => const UsersPage()),
          GoRoute(path: '/tutors', builder: (_, __) => const TutorsPage()),
          GoRoute(path: '/students', builder: (_, __) => const StudentsPage()),
          GoRoute(path: '/subscriptions', builder: (_, __) => const SubscriptionsPage()),
          GoRoute(path: '/wallet', builder: (_, __) => const WalletPage()),
          GoRoute(path: '/finance', builder: (_, __) => const FinancePage()),
          GoRoute(path: '/payments', builder: (_, __) => const PaymentsPage()),
          GoRoute(path: '/tutor-payments', builder: (_, __) => const TutorPaymentsPage()),
          GoRoute(path: '/revenuecat', builder: (_, __) => const SubscriptionsPage()),
          GoRoute(path: '/ai-costs', builder: (_, __) => const AiCostPage()),
          GoRoute(path: '/ai-providers', builder: (_, __) => const AiProvidersPage()),
          GoRoute(path: '/ai-billing', builder: (_, __) => const AiBillingPage()),
          GoRoute(path: '/prompts', builder: (_, __) => const PromptsPage()),
          GoRoute(path: '/marketplace', builder: (_, __) => const MarketplacePage()),
          GoRoute(path: '/courses', builder: (_, __) => const CoursesPage()),
          GoRoute(path: '/exams', builder: (_, __) => const ExamsPage()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
          GoRoute(path: '/referrals', builder: (_, __) => const ReferralsPage()),
          GoRoute(path: '/reports', builder: (_, __) => const ReportsPage()),
          GoRoute(path: '/bi', builder: (_, __) => const BIPage()),
          GoRoute(path: '/audit-logs', builder: (_, __) => const AuditLogsPage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/feature-flags', builder: (_, __) => const FeatureFlagsPage()),
          GoRoute(path: '/dev-console', builder: (_, __) => const DevConsolePage()),
          GoRoute(path: '/support', builder: (_, __) => const SupportPage()),
          GoRoute(path: '/infrastructure', builder: (_, __) => const InfrastructurePage()),
          GoRoute(path: '/voice', builder: (_, __) => const VoiceMonitorPage()),
          GoRoute(path: '/pxpipe', builder: (_, __) => const PxPipeAnalyticsPage()),
        ],
      ),
    ],
  );
});
