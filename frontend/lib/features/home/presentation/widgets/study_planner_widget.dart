// lib/features/home/presentation/widgets/study_planner_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_language_coach/shared/theme/app_theme.dart';
import 'package:ai_language_coach/core/constants/design_tokens.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../controllers/home_controller.dart';

class StudyPlannerWidget extends ConsumerWidget {
  const StudyPlannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(homeControllerProvider);

    return dashboardState.when(
      data: (data) {
        if (data == null) {
          return _buildEmptyState();
        }

        final recommendations = data.recommendations;
        final estimatedMinutes = data.todayMinutes;
        final focusArea = recommendations.isNotEmpty ? recommendations.first : 'Grammar';

        final activities = <Map<String, dynamic>>[
          for (final entry in data.skills.entries)
            {
              'type': entry.key,
              'title': entry.key[0].toUpperCase() + entry.key.substring(1),
              'estimated_minutes': ((entry.value as num) * 0.5).toInt().clamp(5, 30),
              'completed': (entry.value as num) >= 70,
            },
        ];

        if (activities.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Study Plan',
                  style: AppTextStyles.headingSmall,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$estimatedMinutes min',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Focus: $focusArea',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...activities.asMap().entries.map((entry) {
              final activity = entry.value;
              return _buildActivityCard(activity, activities.length);
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: AppTextStyles.bodyMedium),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.auto_awesome, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              'Your Study Plan',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your profile to get a personalized study plan',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, int totalActivities) {
    final type = activity['type'] as String? ?? '';
    final title = activity['title'] as String? ?? '';
    final minutes = activity['estimated_minutes'] as int? ?? 0;
    final completed = activity['completed'] as bool? ?? false;

    final IconData icon;
    final Color color;

    switch (type) {
      case 'grammar':
        icon = Icons.rule;
        color = AppColors.grammar;
        break;
      case 'vocabulary':
        icon = Icons.book;
        color = AppColors.vocabulary;
        break;
      case 'speaking':
        icon = Icons.mic;
        color = AppColors.speaking;
        break;
      case 'writing':
        icon = Icons.edit;
        color = AppColors.writingColor;
        break;
      case 'reading':
        icon = Icons.menu_book;
        color = AppColors.readingColor;
        break;
      case 'listening':
        icon = Icons.hearing;
        color = AppColors.listening;
        break;
      default:
        icon = Icons.star;
        color = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.success.withAlpha(13)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completed ? AppColors.success : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: completed ? TextDecoration.lineThrough : null,
                    color: completed ? AppColors.textTertiary : null,
                  ),
                ),
                Text(
                  '$minutes minutes',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (completed)
            Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * totalActivities));
  }
}
