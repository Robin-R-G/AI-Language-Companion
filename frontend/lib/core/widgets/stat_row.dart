import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

/// Row of stat items with icons and values.
class StatRow extends StatelessWidget {
  final List<StatItem> stats;

  const StatRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Semantics(
            label: '${stat.label}: ${stat.value}',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  stat.icon,
                  color: stat.color ?? theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  stat.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  stat.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });
}
