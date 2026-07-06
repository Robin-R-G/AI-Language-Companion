import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivityWidget({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (activities.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No recent activity',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(activities.length, (index) {
                final activity = activities[index];
                return _ActivityTile(activity: activity);
              }),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Map<String, dynamic> activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final action = activity['action'] ?? '';
    final createdAt = DateTime.tryParse(activity['created_at'] ?? '') ?? DateTime.now();
    final timeAgo = _getTimeAgo(createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getActionColor(action).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActionIcon(action),
              size: 18,
              color: _getActionColor(action),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActionLabel(action),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (activity['admin_email'] != null)
                  Text(
                    activity['admin_email'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'user_suspend':
        return 'User suspended';
      case 'user_activate':
        return 'User activated';
      case 'user_create':
        return 'User created';
      case 'subscription_update':
        return 'Subscription updated';
      case 'subscription_cancel':
        return 'Subscription cancelled';
      case 'tutor_approve':
        return 'Tutor approved';
      case 'tutor_reject':
        return 'Tutor rejected';
      case 'payout_process':
        return 'Payout processed';
      case 'payout_complete':
        return 'Payout completed';
      case 'settings_update':
        return 'Settings updated';
      case 'feature_flag_toggle':
        return 'Feature flag toggled';
      case 'ticket_create':
        return 'Support ticket created';
      case 'ticket_resolve':
        return 'Support ticket resolved';
      default:
        return action.replaceAll('_', ' ');
    }
  }

  IconData _getActionIcon(String action) {
    if (action.startsWith('user_')) return Icons.person_rounded;
    if (action.startsWith('subscription_')) return Icons.card_membership_rounded;
    if (action.startsWith('tutor_')) return Icons.school_rounded;
    if (action.startsWith('payout_')) return Icons.payments_rounded;
    if (action.startsWith('settings_')) return Icons.settings_rounded;
    if (action.startsWith('feature_')) return Icons.flag_rounded;
    if (action.startsWith('ticket_')) return Icons.support_agent_rounded;
    return Icons.info_outline_rounded;
  }

  Color _getActionColor(String action) {
    if (action.contains('suspend') || action.contains('cancel') || action.contains('reject')) {
      return AdminTheme.error;
    }
    if (action.contains('activate') || action.contains('approve') || action.contains('create')) {
      return AdminTheme.success;
    }
    if (action.contains('payout')) return AdminTheme.warning;
    if (action.contains('update') || action.contains('toggle')) return AdminTheme.info;
    return AdminTheme.primary;
  }
}
