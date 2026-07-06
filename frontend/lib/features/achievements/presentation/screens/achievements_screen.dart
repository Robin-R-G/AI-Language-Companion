// lib/features/achievements/presentation/screens/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_language_coach/shared/theme/app_theme.dart';
import 'package:ai_language_coach/shared/models/gamification.dart';
import '../controllers/achievements_controller.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(achievementsControllerProvider.notifier).loadAchievements();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievementsState = ref.watch(achievementsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: AppTextStyles.headingSmall,
        ),
        backgroundColor: AppColors.surface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Badges'),
            Tab(text: 'Stats'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: achievementsState.when(
        data: (achievements) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBadgesTab(achievements),
              _buildStatsTab(achievements),
              _buildLeaderboardTab(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: AppTextStyles.bodyMedium),
        ),
      ),
    );
  }

  Widget _buildBadgesTab(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No achievements yet',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start learning to earn badges!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Badges', '${achievements.length}'),
                _buildStatItem('Total XP', '${achievements.fold(0, (sum, a) => sum + (a.xpReward ?? 0))}'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...achievements.map((achievement) => _buildAchievementCard(achievement)),
        ],
      ),
    );
  }

  Widget _buildStatsTab(List<Achievement> achievements) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard(
            'Total Achievements',
            '${achievements.length}',
            Icons.emoji_events,
            AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Total XP Earned',
            '${achievements.fold(0, (sum, a) => sum + (a.xpReward ?? 0))}',
            Icons.star,
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Latest Achievement',
            achievements.isNotEmpty ? achievements.first.achievementName ?? 'N/A' : 'None',
            Icons.new_releases,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    final leaderboard = [
      {'rank': 1, 'name': 'Priya S.', 'xp': 12500, 'level': 45},
      {'rank': 2, 'name': 'Rahul M.', 'xp': 11200, 'level': 42},
      {'rank': 3, 'name': 'Ananya K.', 'xp': 10800, 'level': 40},
      {'rank': 4, 'name': 'You', 'xp': 9500, 'level': 38, 'isYou': true},
      {'rank': 5, 'name': 'Vikram R.', 'xp': 8900, 'level': 36},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: leaderboard.map((entry) {
          final isYou = entry['isYou'] == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isYou ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isYou ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    '#${entry['rank']}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['name'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isYou ? AppColors.primary : null,
                        ),
                      ),
                      Text(
                        'Level ${entry['level']}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${entry['xp']} XP',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn();
        }).toList(),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.headingMedium,
                ),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                achievement.badge ?? '⭐',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.achievementName ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '+${achievement.xpReward ?? 0} XP',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 24,
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
