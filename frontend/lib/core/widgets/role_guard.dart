import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/user_role.dart';
import '../providers/auth_state_provider.dart';

/// A widget that conditionally renders [child] only if the current user's
/// role satisfies [allowedRoles]. Otherwise shows [fallback] or navigates
/// to [redirectPath].
///
/// Example:
/// ```dart
/// RoleGuard(
///   allowedRoles: {UserRole.superAdmin, UserRole.admin},
///   child: AdminDashboard(),
///   fallback: UnauthorizedPage(),
/// )
/// ```
class RoleGuard extends ConsumerWidget {
  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  final Set<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);
    if (allowedRoles.contains(role)) return child;
    return fallback ?? const _UnauthorizedView();
  }
}

/// Shown when a user tries to access a page they don't have permission for.
class _UnauthorizedView extends StatelessWidget {
  const _UnauthorizedView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 72,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You don't have permission to view this page.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A convenience mixin to check permissions inline.
extension RoleCheck on UserRole {
  bool isOneOf(Set<UserRole> roles) => roles.contains(this);
}
