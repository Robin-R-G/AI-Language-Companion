// lib/features/home/presentation/widgets/study_planner_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_language_coach/shared/theme/app_theme.dart';
import '../controllers/home_controller.dart';

class StudyPlannerWidget extends ConsumerWidget {
  const StudyPlannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(homeControllerProvider);

    return dashboardState.when(
      data: (data) {
        final activities = data['today_activities'] as List? ?? [];
        final estimatedMinutes = data['estimated_minutes'] as int? ?? 0;
        final focusArea = data['focus_area'] as String? ?? 'Grammar';

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
                    color: AppColors.primary.withOpacity(0.1),
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
              return _buildActivityCard(activity);
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

  Widget _buildActivityCard(Map<String, dynamic> activity) {
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
        color = AppColors.writing;
        break;
      case 'reading':
        icon = Icons.menu_book;
        color = AppColors.reading;
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
            ? AppColors.success.withOpacity(0.05)
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
              color: color.withOpacity(0.1),
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
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * (activities.length - 1)));
  }
}
