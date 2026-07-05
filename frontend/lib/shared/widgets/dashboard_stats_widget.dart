// lib/shared/widgets/dashboard_stats_widget.dart
import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class DashboardStatsWidget extends StatelessWidget {
  final UserProgress? progress;
  final UserStreak? streak;

  const DashboardStatsWidget({
    super.key,
    this.progress,
    this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          icon: Icons.star,
          label: 'XP',
          value: '${progress?.xp ?? 0}',
          color: Colors.amber,
        ),
        _StatItem(
          icon: Icons.local_fire_department,
          label: 'Streak',
          value: '${streak?.currentStreak ?? 0}',
          color: Colors.orange,
        ),
        _StatItem(
          icon: Icons.leaderboard,
          label: 'Level',
          value: '${progress?.level ?? 1}',
          color: Colors.blue,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
