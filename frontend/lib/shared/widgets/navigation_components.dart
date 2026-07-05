import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

/// Navigation components for the AI Language Coach application.
/// Follows the Flutter Component Library specification.

/// Bottom navigation bar with consistent styling.
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Search app bar with consistent styling.
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final List<Widget>? actions;

  const SearchAppBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onFilterTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: AppSpacing.base,
        right: AppSpacing.base,
        bottom: AppSpacing.sm,
      ),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText ?? 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    theme.colorScheme.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: onFilterTap,
              icon: Icon(
                Icons.tune,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
          if (actions != null) ...[
            const SizedBox(width: AppSpacing.sm),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

/// Top app bar with consistent styling.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const AppTopBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : leading,
      actions: actions,
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }
}

/// Tab navigation with consistent styling.
class AppTabNavigation extends StatelessWidget {
  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppTabNavigation({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: TabBar(
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        controller: TabController(
          length: tabs.length,
          initialIndex: currentIndex,
          vsync: Navigator.of(context),
        ),
        onTap: onTap,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Breadcrumb navigation.
class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final ValueChanged<String>? onItemTap;

  const Breadcrumb({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == items.length - 1;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index > 0) ...[
              Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            GestureDetector(
              onTap: isLast ? null : () => onItemTap?.call(item.route),
              child: Text(
                item.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isLast
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.primary,
                  fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class BreadcrumbItem {
  final String label;
  final String route;

  const BreadcrumbItem({
    required this.label,
    required this.route,
  });
}

/// Floating menu for quick actions.
class FloatingMenu extends StatelessWidget {
  final List<MenuItem> items;
  final VoidCallback? onClose;

  const FloatingMenu({
    super.key,
    required this.items,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppElevation.level3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onClose != null)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
              ),
            ),
          ...items.map(
            (item) => ListTile(
              leading: Icon(item.icon, color: item.color),
              title: Text(item.label),
              subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
              onTap: () {
                onClose?.call();
                item.onTap?.call();
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;

  const MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.color,
    this.onTap,
  });
}
