// lib/shared/widgets/achievement_badge.dart
import 'package:flutter/material.dart';

class AchievementBadge extends StatelessWidget {
  final String name;
  final String badge;
  final bool unlocked;
  final int xpReward;

  const AchievementBadge({
    super.key,
    required this.name,
    required this.badge,
    this.unlocked = false,
    this.xpReward = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: unlocked
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: unlocked
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 24,
                    color: unlocked
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (unlocked)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            if (!unlocked)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.lock,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (xpReward > 0)
          Text(
            '+$xpReward XP',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.amber,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
