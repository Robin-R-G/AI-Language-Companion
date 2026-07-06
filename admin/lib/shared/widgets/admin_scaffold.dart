import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/admin_theme.dart';

class AdminScaffold extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const AdminScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 640 && width < 1024;

    final navItems = [
      _NavItem(Icons.dashboard_rounded, 'Dashboard', '/dashboard'),
      _NavItem(Icons.people_rounded, 'Users', '/users'),
      _NavItem(Icons.book_rounded, 'Courses', '/courses'),
      _NavItem(Icons.assignment_rounded, 'Exams', '/exams'),
      _NavItem(Icons.psychology_rounded, 'AI Engine', '/ai-settings'),
      _NavItem(Icons.mic_rounded, 'Voice Logs', '/voice'),
      _NavItem(Icons.campaign_rounded, 'Broadcasts', '/notifications'),
      _NavItem(Icons.security_rounded, 'Security Audits', '/security'),
      _NavItem(Icons.monetization_on_rounded, 'Monetization', '/monetization'),
      _NavItem(Icons.settings_rounded, 'Settings', '/settings'),
    ];

    final activeIndex = navItems.indexWhere((item) => item.route == currentRoute);

    return Scaffold(
      appBar: !isDesktop
          ? AppBar(
              title: Text(
                'AI Coach Admin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              elevation: 0,
            )
          : null,
      drawer: !isDesktop
          ? Drawer(
              child: _SidebarContent(
                navItems: navItems,
                currentRoute: currentRoute,
                onSelect: (route) {
                  Navigator.pop(context);
                  context.go(route);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 260,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: _SidebarContent(
                navItems: navItems,
                currentRoute: currentRoute,
                onSelect: (route) => context.go(route),
              ),
            )
          else if (isTablet)
            NavigationRail(
              selectedIndex: activeIndex == -1 ? 0 : activeIndex,
              onDestinationSelected: (idx) => context.go(navItems[idx].route),
              labelType: NavigationRailLabelType.none,
              destinations: navItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.title),
                );
              }).toList(),
            ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String title;
  final String route;

  _NavItem(this.icon, this.title, this.route);
}

class _SidebarContent extends StatelessWidget {
  final List<_NavItem> navItems;
  final String currentRoute;
  final Function(String) onSelect;

  const _SidebarContent({
    required this.navItems,
    required this.currentRoute,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final email = supabase.auth.currentUser?.email ?? 'admin@ailanguagecoach.com';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24.0),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: AdminTheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Coach',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                'Platform Control',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: navItems.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (context, index) {
              final item = navItems[index];
              final isActive = item.route == currentRoute;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    item.icon,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                  selected: isActive,
                  selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () => onSelect(item.route),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AdminTheme.secondary.withOpacity(0.1),
                    child: Icon(Icons.admin_panel_settings_rounded, color: AdminTheme.secondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administrator',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await supabase.auth.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 16),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
