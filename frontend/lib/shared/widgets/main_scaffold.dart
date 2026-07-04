import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../features/home/presentation/widgets/streak_fab.dart';

/// Main scaffold with bottom navigation bar.
/// Used for the main app shell with tab navigation.
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: const StreakFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              route: RouteNames.home,
              context: context,
            ),
            _NavItem(
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'Practice',
              route: RouteNames.chat,
              context: context,
            ),
            const SizedBox(width: 48), // Space for FAB
            _NavItem(
              icon: Icons.book_outlined,
              activeIcon: Icons.book,
              label: 'Lessons',
              route: RouteNames.lessons,
              context: context,
            ),
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              route: RouteNames.profile,
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final BuildContext context;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final isActive = currentPath == route;

    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      child: IconButton(
        onPressed: () => context.go(route),
        icon: Icon(
          isActive ? activeIcon : icon,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        tooltip: label,
      ),
    );
  }
}
