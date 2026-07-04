import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/design_tokens.dart';

/// Achievements page showing badges and league standings.
class AchievementsPage extends ConsumerStatefulWidget {
  const AchievementsPage({super.key});

  @override
  ConsumerState<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends ConsumerState<AchievementsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Achievements'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Badges'),
              Tab(text: 'League'),
            ],
          ),
        ),
        body: const TabBarView(children: [_BadgesTab(), _LeagueTab()]),
      ),
    );
  }
}

class _BadgesTab extends StatelessWidget {
  const _BadgesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Summary
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.base),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Total XP',
                    value: '2,450',
                    icon: Icons.star,
                    color: AppColors.warning,
                  ),
                  _StatItem(
                    label: 'Badges',
                    value: '12/50',
                    icon: Icons.emoji_events,
                    color: AppColors.info,
                  ),
                  _StatItem(
                    label: 'Rank',
                    value: '#45',
                    icon: Icons.leaderboard,
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Recent Badges
          Text(
            'Recent Badges',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _BadgeCard(
                  icon: Icons.local_fire_department,
                  label: '7-Day Streak',
                  color: AppColors.warning,
                  isUnlocked: true,
                ),
                _BadgeCard(
                  icon: Icons.star,
                  label: '1000 XP',
                  color: AppColors.info,
                  isUnlocked: true,
                ),
                _BadgeCard(
                  icon: Icons.mic,
                  label: 'First Voice Call',
                  color: AppColors.success,
                  isUnlocked: true,
                ),
                _BadgeCard(
                  icon: Icons.quiz,
                  label: 'Exam Master',
                  color: AppColors.primary500,
                  isUnlocked: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // All Badges
          Text(
            'All Badges',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
            ),
            itemCount: 20,
            itemBuilder: (context, index) {
              final isUnlocked = index < 12;
              return _BadgeGridItem(isUnlocked: isUnlocked, index: index);
            },
          ),
        ],
      ),
    );
  }
}

class _LeagueTab extends StatelessWidget {
  const _LeagueTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Current Rank Card
        Container(
          margin: const EdgeInsets.all(AppSpacing.base),
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withOpacity(0.2),
                AppColors.primary500.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.warning,
                child: Icon(Icons.emoji_events, color: Colors.white, size: 32),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Rank',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '#45',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '2,450 XP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                  Text(
                    'This Week',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Leaderboard
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            itemCount: 20,
            itemBuilder: (context, index) {
              return _LeaderboardItem(
                rank: index + 1,
                name: _getRandomName(index),
                xp: 3000 - (index * 100),
                isCurrentUser: index == 44,
              );
            },
          ),
        ),
      ],
    );
  }

  String _getRandomName(int index) {
    final names = [
      'Arjun',
      'Priya',
      'Anoop',
      'Rahul',
      'Meera',
      'Vikram',
      'Lakshmi',
      'Ravi',
      'Deepa',
      'Suresh',
    ];
    return names[index % names.length];
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isUnlocked;

  const _BadgeCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: isUnlocked ? color : Colors.grey),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isUnlocked
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeGridItem extends StatelessWidget {
  final bool isUnlocked;
  final int index;

  const _BadgeGridItem({required this.isUnlocked, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 28,
              color: isUnlocked
                  ? AppColors.warning
                  : Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final bool isCurrentUser;

  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isCurrentUser
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank <= 3
              ? (rank == 1
                    ? AppColors.warning
                    : rank == 2
                    ? Colors.grey
                    : const Color(0xFFCD7F32))
              : Theme.of(context).colorScheme.surface,
          child: Text(
            rank <= 3 ? _getMedalEmoji(rank) : '$rank',
            style: TextStyle(
              fontSize: rank <= 3 ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: rank <= 3 ? Colors.white : null,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(
          '$xp XP',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}
