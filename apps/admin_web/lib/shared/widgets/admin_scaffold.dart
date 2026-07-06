import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/admin_theme.dart';

class NavItem {
  final IconData icon;
  final String title;
  final String route;
  final String? section;
  final List<NavItem>? children;

  const NavItem(this.icon, this.title, this.route, {this.section, this.children});
}

final List<NavItem> navItems = [
  NavItem(Icons.dashboard_rounded, 'Dashboard', '/dashboard', section: 'Overview'),
  NavItem(Icons.people_rounded, 'User Management', '/users', section: 'Management'),
  NavItem(Icons.school_rounded, 'Tutor Management', '/tutors'),
  NavItem(Icons.person_rounded, 'Student Management', '/students'),
  NavItem(Icons.card_membership_rounded, 'Subscriptions', '/subscriptions', section: 'Revenue'),
  NavItem(Icons.account_balance_wallet_rounded, 'Wallet & Credits', '/wallet'),
  NavItem(Icons.receipt_long_rounded, 'Finance Center', '/finance'),
  NavItem(Icons.payments_rounded, 'Payments', '/payments'),
  NavItem(Icons.attach_money_rounded, 'RevenueCat', '/revenuecat'),
  NavItem(Icons.analytics_rounded, 'AI Cost Monitor', '/ai-costs', section: 'AI'),
  NavItem(Icons.smart_toy_rounded, 'AI Providers', '/ai-providers'),
  NavItem(Icons.receipt_rounded, 'AI Billing', '/ai-billing'),
  NavItem(Icons.chat_rounded, 'Prompt Manager', '/prompts'),
  NavItem(Icons.store_rounded, 'Tutor Marketplace', '/marketplace', section: 'Platform'),
  NavItem(Icons.book_rounded, 'Courses', '/courses'),
  NavItem(Icons.quiz_rounded, 'Exams', '/exams'),
  NavItem(Icons.campaign_rounded, 'Notifications', '/notifications'),
  NavItem(Icons.card_giftcard_rounded, 'Referral Program', '/referrals'),
  NavItem(Icons.insights_rounded, 'Reports & Analytics', '/reports', section: 'Intelligence'),
  NavItem(Icons.psychology_rounded, 'Business Intelligence', '/bi'),
  NavItem(Icons.history_rounded, 'Audit Logs', '/audit-logs'),
  NavItem(Icons.settings_rounded, 'System Settings', '/settings', section: 'System'),
  NavItem(Icons.flag_rounded, 'Feature Flags', '/feature-flags'),
  NavItem(Icons.terminal_rounded, 'Developer Console', '/dev-console'),
  NavItem(Icons.bug_report_rounded, 'Support Tickets', '/support'),
  NavItem(Icons.dns_rounded, 'Infrastructure', '/infrastructure'),
];

class AdminScaffold extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const AdminScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  ConsumerState<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends ConsumerState<AdminScaffold> {
  bool _isCollapsed = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NavItem> get _filteredItems {
    if (_searchQuery.isEmpty) return navItems;
    return navItems
        .where((item) =>
            item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 640 && width < 1024;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyD, control: true): () {
          context.go('/dashboard');
        },
        const SingleActivator(LogicalKeyboardKey.keyU, control: true): () {
          context.go('/users');
        },
        const SingleActivator(LogicalKeyboardKey.keyT, control: true): () {
          context.go('/tutors');
        },
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          context.go('/finance');
        },
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          context.go('/settings');
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (!isDesktop) Navigator.of(context).pop();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          drawer: !isDesktop
              ? Drawer(
                  child: _buildSidebar(context, false),
                )
              : null,
          body: Row(
            children: [
              if (isDesktop)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isCollapsed ? 72 : 260,
                  child: _buildSidebar(context, _isCollapsed),
                )
              else if (isTablet)
                SizedBox(
                  width: 72,
                  child: _buildSidebar(context, true),
                ),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(context, isDesktop),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.background,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isDesktop ? 24 : 16),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          else
            IconButton(
              icon: Icon(_isCollapsed
                  ? Icons.chevron_right_rounded
                  : Icons.chevron_left_rounded),
              onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search modules... (Ctrl+K)',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background,
                ),
              ),
            ),
          ),
          const Spacer(),
          _topBarIcon(context, Icons.notifications_rounded, 'Notifications', () {}),
          const SizedBox(width: 4),
          _topBarIcon(context, Icons.help_outline_rounded, 'Help', () {}),
          const SizedBox(width: 8),
          _buildUserMenu(context),
        ],
      ),
    );
  }

  Widget _topBarIcon(
      BuildContext context, IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AdminTheme.primary.withOpacity(0.1),
            child: Text(
              (user?.email ?? 'A')[0].toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AdminTheme.primary),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Administrator',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
              ),
              Text(
                user?.email ?? 'admin@ailanguagecoach.com',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
          const Icon(Icons.arrow_drop_down_rounded, size: 18),
        ],
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: Text('My Profile')),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Text('Sign Out', style: TextStyle(color: Colors.red)),
        ),
      ],
      onSelected: (value) async {
        if (value == 'logout') {
          await Supabase.instance.client.auth.signOut();
          if (context.mounted) context.go('/login');
        } else if (value == 'settings') {
          context.go('/settings');
        }
      },
    );
  }

  Widget _buildSidebar(BuildContext context, bool collapsed) {
    final currentRoute = widget.currentRoute;
    String currentSection = '';

    return Container(
      color: Theme.of(context).cardTheme.color,
      child: Column(
        children: [
          Container(
            height: 56,
            padding: EdgeInsets.all(collapsed ? 12 : 16),
            child: collapsed
                ? const Icon(Icons.school_rounded, color: AdminTheme.primary, size: 28)
                : Row(
                    children: [
                      const Icon(Icons.school_rounded,
                          color: AdminTheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Coach',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Admin Portal',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const Divider(height: 1),
          if (!collapsed) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 16),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background,
                ),
              ),
            ),
          ],
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final isActive = currentRoute == item.route;
                final showSection =
                    item.section != null && item.section != currentSection;
                if (showSection) currentSection = item.section!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showSection)
                      Padding(
                        padding: EdgeInsets.only(
                          left: collapsed ? 8 : 16,
                          top: 16,
                          bottom: 4,
                          right: 16,
                        ),
                        child: collapsed
                            ? const SizedBox.shrink()
                            : Text(
                                item.section!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground
                                      .withOpacity(0.4),
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: collapsed ? 4 : 8,
                        vertical: 2,
                      ),
                      child: Tooltip(
                        message: collapsed ? item.title : '',
                        child: ListTile(
                          leading: Icon(
                            item.icon,
                            size: 20,
                            color: isActive
                                ? AdminTheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.6),
                          ),
                          title: collapsed
                              ? null
                              : Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        isActive ? FontWeight.w600 : FontWeight.w500,
                                    color: isActive
                                        ? AdminTheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onBackground
                                            .withOpacity(0.8),
                                  ),
                                ),
                          selected: isActive,
                          selectedTileColor: AdminTheme.primary.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: collapsed
                              ? const EdgeInsets.symmetric(horizontal: 8)
                              : const EdgeInsets.symmetric(horizontal: 12),
                          minVerticalPadding: 0,
                          dense: true,
                          onTap: () {
                            context.go(item.route);
                            if (MediaQuery.of(context).size.width < 1024) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          if (!collapsed)
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AdminTheme.secondary.withOpacity(0.1),
                        child: const Icon(Icons.admin_panel_settings_rounded,
                            color: AdminTheme.secondary, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Admin',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(
                              Supabase.instance.client.auth.currentUser?.email ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground
                                      .withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
