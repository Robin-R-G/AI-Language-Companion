// lib/features/achievements/presentation/screens/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_theme.dart';
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
            Tab(text: 'Streaks'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: achievementsState.when(
        data: (data) {
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBadgesTab(data),
              _buildStreaksTab(data),
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

  Widget _buildBadgesTab(Map<String, dynamic> data) {
    final achievements = data['achievements'] as List? ?? [];

    // Group achievements by category
    final categories = {
      'Learning': achievements.where((a) =>
          ['First Steps', 'Vocabulary Master', 'Grammar Guru'].contains(a['achievement_name'])).toList(),
      'Streaks': achievements.where((a) =>
          ['Week Warrior', 'Monthly Master', 'Year Legend'].contains(a['achievement_name'])).toList(),
      'Social': achievements.where((a) =>
          ['Chat Champion', 'Speaking Star', 'Writing Wizard'].contains(a['achievement_name'])).toList(),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total XP', '${data['total_xp'] ?? 0}'),
                _buildStatItem('Level', '${data['level'] ?? 1}'),
                _buildStatItem('Badges', '${achievements.length}'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Achievement categories
          ...categories.entries.map((entry) {
            if (entry.value.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: AppTextStyles.headingMedium,
                ),
                const SizedBox(height: 12),
                ...entry.value.map((achievement) => _buildAchievementCard(achievement)),
                const SizedBox(height: 24),
              ],
            );
          }),

          // Locked achievements
          Text(
            'Locked',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 12),
          _buildLockedAchievements(),
        ],
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

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
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
                achievement['badge'] ?? '⭐',
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
                  achievement['achievement_name'] ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '+${achievement['xp_reward'] ?? 0} XP',
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

  Widget _buildLockedAchievements() {
    final lockedAchievements = [
      {'name': 'Language Master', 'badge': '🏆', 'description': 'Reach level 50'},
      {'name': 'Perfect Score', 'badge': '💯', 'description': 'Score 100% on an exam'},
      {'name': 'Conversation King', 'badge': '👑', 'description': 'Complete 100 conversations'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: lockedAchievements.map((achievement) {
        return Container(
          width: (MediaQuery.of(context).size.width - 40) / 3,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text(
                achievement['badge']!,
                style: const TextStyle(
                  fontSize: 32,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement['name']!,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                achievement['description']!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStreaksTab(Map<String, dynamic> data) {
    final streaks = data['streaks'] as Map<String, dynamic>? ?? {};
    final currentStreak = streaks['current_streak'] ?? 0;
    final longestStreak = streaks['longest_streak'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current streak
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warning, AppColors.warningDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  '🔥',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currentStreak Days',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Current Streak',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStreakStat(
                  'Longest Streak',
                  '$longestStreak days',
                  Icons.emoji_events,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStreakStat(
                  'This Week',
                  '${data['lessons_this_week'] ?? 0} lessons',
                  Icons.calendar_today,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Calendar view
          Text(
            'This Month',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 12),
          _buildCalendarView(),
        ],
      ),
    );
  }

  Widget _buildStreakStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfWeek = DateTime(now.year, now.month, 1).weekday % 7;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Day headers
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Days
          for (var week = 0; week < 5; week++) ...[
            Row(
              children: List.generate(7, (dayIndex) {
                final day = week * 7 + dayIndex - firstDayOfWeek + 1;
                if (day < 1 || day > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 32));
                }

                final isToday = day == now.day;
                final isPast = day < now.day;
                final isStreakDay = isPast && (day % 3 != 0); // Simulated streak

                return Expanded(
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isStreakDay
                          ? AppColors.warning.withOpacity(0.2)
                          : isToday
                              ? AppColors.primary.withOpacity(0.1)
                              : null,
                      borderRadius: BorderRadius.circular(6),
                      border: isToday
                          ? Border.all(color: AppColors.primary)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isToday
                              ? AppColors.primary
                              : isStreakDay
                                  ? AppColors.warning
                                  : AppColors.textPrimary,
                          fontWeight: isToday ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    // Mock leaderboard data
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
        children: [
          // Top 3 podium
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.surface,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2nd place
                _buildPodiumItem(leaderboard[1], 80),
                const SizedBox(width: 8),
                // 1st place
                _buildPodiumItem(leaderboard[0], 120),
                const SizedBox(width: 8),
                // 3rd place
                _buildPodiumItem(leaderboard[2], 60),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Rest of leaderboard
          ...leaderboard.skip(3).map((entry) {
            return _buildLeaderboardRow(entry);
          }),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> entry, double height) {
    final isYou = entry['isYou'] ?? false;

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: entry['rank'] == 1
                ? AppColors.warning
                : entry['rank'] == 2
                    ? AppColors.textSecondary
                    : Color(0xFFCD7F32),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              entry['rank'] == 1 ? '🥇' : entry['rank'] == 2 ? '🥈' : '🥉',
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry['name'],
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isYou ? AppColors.primary : null,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: entry['rank'] == 1
                ? AppColors.warning.withOpacity(0.2)
                : entry['rank'] == 2
                    ? AppColors.textSecondary.withOpacity(0.2)
                    : Color(0xFFCD7F32).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${entry['xp']}',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(Map<String, dynamic> entry) {
    final isYou = entry['isYou'] ?? false;

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
                  entry['name'],
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
  }
}
