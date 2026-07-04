import 'package:flutter/material.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Notifications screen showing reminders and updates.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = false;
  bool _hasError = false;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Daily Study Reminder',
      'message': 'Don\'t forget to complete your 20-minute study goal today!',
      'time': '2 hours ago',
      'icon': Icons.alarm,
      'color': AppColors.warning,
      'read': false,
    },
    {
      'title': 'Vocabulary Review Ready',
      'message': '15 words are due for review in your SRS queue.',
      'time': '5 hours ago',
      'icon': Icons.menu_book,
      'color': AppColors.info,
      'read': false,
    },
    {
      'title': 'Weekly Report Available',
      'message': 'Your weekly progress report is ready. Check your scores!',
      'time': '1 day ago',
      'icon': Icons.bar_chart,
      'color': AppColors.success,
      'read': true,
    },
    {
      'title': 'Streak Milestone',
      'message': 'Congratulations! You\'ve reached a 14-day streak!',
      'time': '2 days ago',
      'icon': Icons.local_fire_department,
      'color': AppColors.warning,
      'read': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n['read'] = true;
                }
              });
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_hasError) return ErrorView(onRetry: _loadData);
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.base),
        itemCount: 5,
        itemBuilder: (context, index) => const ShimmerCard(),
      );
    }

    if (_notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none,
        title: 'No Notifications',
        message: 'You\'re all caught up! Study reminders and updates will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.base),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _NotificationCard(
            title: notification['title'] as String,
            message: notification['message'] as String,
            time: notification['time'] as String,
            icon: notification['icon'] as IconData,
            color: notification['color'] as Color,
            isRead: notification['read'] as bool,
            onTap: () {
              setState(() => notification['read'] = true);
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    required this.isRead,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: EdgeInsets.zero,
      color: isRead ? null : theme.colorScheme.primary.withAlpha(8),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
