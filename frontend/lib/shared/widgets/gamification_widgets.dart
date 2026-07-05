import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

/// Gamification widgets for the AI Language Coach application.
/// Follows the Flutter Component Library specification.

/// XP progress bar.
class XPBar extends StatelessWidget {
  final int currentXP;
  final int requiredXP;
  final int level;

  const XPBar({
    super.key,
    required this.currentXP,
    required this.requiredXP,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = requiredXP > 0 ? currentXP / requiredXP : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$currentXP / $requiredXP XP',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Level badge display.
class LevelBadge extends StatelessWidget {
  final int level;
  final double size;

  const LevelBadge({
    super.key,
    required this.level,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$level',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}

/// Achievement badge display.
class AchievementBadgeWidget extends StatelessWidget {
  final String name;
  final String? iconUrl;
  final bool isUnlocked;
  final double size;

  const AchievementBadgeWidget({
    super.key,
    required this.name,
    this.iconUrl,
    this.isUnlocked = false,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isUnlocked
                ? theme.colorScheme.primary.withOpacity(0.1)
                : AppColors.textSecondary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked ? theme.colorScheme.primary : AppColors.textSecondary,
              width: 2,
            ),
          ),
          child: Center(
            child: iconUrl != null
                ? ClipOval(
                    child: Image.network(
                      iconUrl!,
                      width: size * 0.7,
                      height: size * 0.7,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.emoji_events,
                    color: isUnlocked ? theme.colorScheme.primary : AppColors.textSecondary,
                    size: size * 0.5,
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          name,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isUnlocked ? null : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Daily streak display.
class DailyStreak extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final bool isActiveToday;

  const DailyStreak({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.isActiveToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.1),
            AppColors.error.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActiveToday ? AppColors.warning : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak Day Streak',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Best: $longestStreak days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isActiveToday)
            Icon(
              Icons.check_circle,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}

/// Leaderboard tile.
class LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final String? avatarUrl;
  final int xp;
  final bool isCurrentUser;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    this.avatarUrl,
    required this.xp,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isCurrentUser ? theme.colorScheme.primary.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              _getRankDisplay(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getRankColor(theme),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 20,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    name[0].toUpperCase(),
                    style: theme.textTheme.titleMedium,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isCurrentUser ? FontWeight.bold : null,
              ),
            ),
          ),
          Text(
            '$xp XP',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getRankDisplay() {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  Color _getRankColor(ThemeData theme) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textSecondary;
    }
  }
}

/// Daily goal widget.
class DailyGoalWidget extends StatelessWidget {
  final int currentMinutes;
  final int goalMinutes;
  final int lessonsCompleted;
  final int targetLessons;

  const DailyGoalWidget({
    super.key,
    required this.currentMinutes,
    required this.goalMinutes,
    this.lessonsCompleted = 0,
    this.targetLessons = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutesProgress = goalMinutes > 0
        ? (currentMinutes / goalMinutes).clamp(0.0, 1.0)
        : 0.0;
    final lessonsProgress = targetLessons > 0
        ? (lessonsCompleted / targetLessons).clamp(0.0, 1.0)
        : 0.0;
    final isComplete = currentMinutes >= goalMinutes && lessonsCompleted >= targetLessons;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.success.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isComplete ? AppColors.success : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle : Icons.flag,
                color: isComplete ? AppColors.success : theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Daily Goal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                isComplete ? 'Complete!' : '${(minutesProgress * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isComplete ? AppColors.success : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          _buildProgressBar(
            context,
            'Study Time',
            currentMinutes,
            goalMinutes,
            'min',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildProgressBar(
            context,
            'Lessons',
            lessonsCompleted,
            targetLessons,
            '',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    String label,
    int current,
    int target,
    String unit,
  ) {
    final theme = Theme.of(context);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$current / $target$unit',
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
              progress >= 1.0 ? AppColors.success : theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Challenge widget.
class ChallengeWidget extends StatelessWidget {
  final String title;
  final String description;
  final int progress;
  final int target;
  final int xpReward;
  final VoidCallback? onTap;

  const ChallengeWidget({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.xpReward,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressValue = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
    final isComplete = progress >= target;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isComplete ? Icons.check_circle : Icons.emoji_events,
                    color: isComplete ? AppColors.success : AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '+$xpReward XP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$progress / $target',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(progressValue * 100).round()}%',
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
                  value: progressValue,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? AppColors.success : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Milestone widget.
class MilestoneWidget extends StatelessWidget {
  final String title;
  final String description;
  final bool isAchieved;
  final IconData icon;

  const MilestoneWidget({
    super.key,
    required this.title,
    required this.description,
    this.isAchieved = false,
    this.icon = Icons.flag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: isAchieved
            ? AppColors.success.withOpacity(0.1)
            : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isAchieved
              ? AppColors.success.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isAchieved ? AppColors.success : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isAchieved ? null : AppColors.textSecondary,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isAchieved)
            Icon(
              Icons.check_circle,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}
