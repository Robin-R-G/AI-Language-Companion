import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

/// Profile widgets for the AI Language Coach application.

/// Profile header with avatar, name, and stats.
class ProfileHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final int totalXP;
  final int currentLevel;
  final String cefrLevel;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.totalXP,
    required this.currentLevel,
    required this.cefrLevel,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null
                        ? Text(
                            name[0].toUpperCase(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: CEFRBadge(
                        level: cefrLevel,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.star,
                          label: '$totalXP XP',
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatChip(
                          icon: Icons.leaderboard,
                          label: 'Lvl $currentLevel',
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onEditPressed != null)
                IconButton(
                  onPressed: onEditPressed,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Profile',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Statistics grid for profile page.
class StatisticsGrid extends StatelessWidget {
  final List<StatisticItem> stats;

  const StatisticsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat.icon,
                color: stat.color ?? theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                stat.value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                stat.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// CEFR level badge.
class CEFRBadge extends StatelessWidget {
  final String level;
  final double size;
  final bool showLabel;

  const CEFRBadge({
    super.key,
    required this.level,
    this.size = 32,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getCEFRColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? AppSpacing.sm : 0,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel)
            Text(
              'CEFR',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (showLabel) const SizedBox(width: AppSpacing.xs),
          Text(
            level.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCEFRColor() {
    switch (level.toUpperCase()) {
      case 'A1':
        return AppColors.levelBeginner;
      case 'A2':
        return AppColors.levelElementary;
      case 'B1':
        return AppColors.levelIntermediate;
      case 'B2':
        return AppColors.levelUpperIntermediate;
      case 'C1':
        return AppColors.levelAdvanced;
      case 'C2':
        return AppColors.levelMastery;
      default:
        return AppColors.textSecondary;
    }
  }
}

/// Learning history item.
class LearningHistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime dateTime;
  final IconData icon;
  final int? xpEarned;

  const LearningHistoryItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dateTime,
    this.icon = Icons.school,
    this.xpEarned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: xpEarned != null
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '+$xpEarned XP',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}

/// Settings section component.
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

/// Settings tile component.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Data class for statistics.
class StatisticItem {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const StatisticItem({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });
}

/// Skill level display.
class SkillLevelDisplay extends StatelessWidget {
  final String skillName;
  final double level;
  final int? maxLevel;

  const SkillLevelDisplay({
    super.key,
    required this.skillName,
    required this.level,
    this.maxLevel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = maxLevel ?? 100;
    final progress = (level / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skillName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${level.round()} / $max',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getSkillColor(theme, progress),
            ),
          ),
        ),
      ],
    );
  }

  Color _getSkillColor(ThemeData theme, double progress) {
    if (progress >= 0.8) return AppColors.success;
    if (progress >= 0.5) return theme.colorScheme.primary;
    if (progress >= 0.3) return AppColors.warning;
    return AppColors.error;
  }
}

/// Achievement popup.
class AchievementPopup extends StatelessWidget {
  final String title;
  final String description;
  final String? badgeUrl;
  final VoidCallback? onDismiss;

  const AchievementPopup({
    super.key,
    required this.title,
    required this.description,
    this.badgeUrl,
    this.onDismiss,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String description,
    String? badgeUrl,
  }) {
    showDialog(
      context: context,
      builder: (context) => AchievementPopup(
        title: title,
        description: description,
        badgeUrl: badgeUrl,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: badgeUrl != null
                  ? ClipOval(
                      child: Image.network(
                        badgeUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: AppColors.warning,
                    ),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Achievement Unlocked!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onDismiss,
                child: const Text('Awesome!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Level up popup.
class LevelUpPopup extends StatelessWidget {
  final int newLevel;
  final VoidCallback? onDismiss;

  const LevelUpPopup({
    super.key,
    required this.newLevel,
    this.onDismiss,
  });

  static void show(BuildContext context, {required int newLevel}) {
    showDialog(
      context: context,
      builder: (context) => LevelUpPopup(
        newLevel: newLevel,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$newLevel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Level Up!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You reached Level $newLevel',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onDismiss,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
