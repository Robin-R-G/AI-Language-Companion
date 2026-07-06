import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';

/// Exam components for the AI Language Coach application.
/// Follows the Flutter Component Library specification.

/// Exam timer with visual countdown.
class ExamTimer extends StatelessWidget {
  final Duration remaining;
  final Duration total;
  final bool isWarning;

  const ExamTimer({
    super.key,
    required this.remaining,
    required this.total,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total.inMilliseconds > 0
        ? remaining.inMilliseconds / total.inMilliseconds
        : 0.0;
    final color = isWarning ? AppColors.error : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                _formatDuration(remaining),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Time Remaining',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Question navigator for exam overview.
class QuestionNavigator extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestion;
  final Map<int, QuestionStatus> questionStatuses;
  final ValueChanged<int>? onQuestionTap;

  const QuestionNavigator({
    super.key,
    required this.totalQuestions,
    required this.currentQuestion,
    this.questionStatuses = const {},
    this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(totalQuestions, (index) {
        final status = questionStatuses[index] ?? QuestionStatus.unanswered;
        final isCurrent = index == currentQuestion;

        return GestureDetector(
          onTap: () => onQuestionTap?.call(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(theme, status, isCurrent),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: isCurrent
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _getStatusTextColor(theme, status, isCurrent),
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Color _getStatusColor(ThemeData theme, QuestionStatus status, bool isCurrent) {
    if (isCurrent) return theme.colorScheme.primary.withOpacity(0.2);
    switch (status) {
      case QuestionStatus.answered:
        return AppColors.success.withOpacity(0.2);
      case QuestionStatus.flagged:
        return AppColors.warning.withOpacity(0.2);
      case QuestionStatus.unanswered:
        return theme.colorScheme.surfaceVariant;
    }
  }

  Color _getStatusTextColor(ThemeData theme, QuestionStatus status, bool isCurrent) {
    if (isCurrent) return theme.colorScheme.primary;
    switch (status) {
      case QuestionStatus.answered:
        return AppColors.success;
      case QuestionStatus.flagged:
        return AppColors.warning;
      case QuestionStatus.unanswered:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}

enum QuestionStatus {
  unanswered,
  answered,
  flagged,
}

/// Band score display for IELTS-style exams.
class BandScoreCard extends StatelessWidget {
  final double bandScore;
  final String? section;
  final bool showDescription;

  const BandScoreCard({
    super.key,
    required this.bandScore,
    this.section,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getBandColor(bandScore);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          children: [
            if (section != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  section!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      bandScore.toStringAsFixed(1),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (showDescription) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _getBandDescription(bandScore),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBandColor(double score) {
    if (score >= 8.0) return AppColors.success;
    if (score >= 7.0) return AppColors.info;
    if (score >= 6.0) return AppColors.warning;
    return AppColors.error;
  }

  String _getBandDescription(double score) {
    if (score >= 9.0) return 'Expert User';
    if (score >= 8.0) return 'Very Good User';
    if (score >= 7.0) return 'Good User';
    if (score >= 6.0) return 'Competent User';
    if (score >= 5.0) return 'Modest User';
    if (score >= 4.0) return 'Limited User';
    if (score >= 3.0) return 'Extremely Limited User';
    if (score >= 2.0) return 'Intermittent User';
    return 'Non User';
  }
}

/// Exam progress indicator.
class ExamProgress extends StatelessWidget {
  final int answeredQuestions;
  final int totalQuestions;
  final int flaggedQuestions;

  const ExamProgress({
    super.key,
    required this.answeredQuestions,
    required this.totalQuestions,
    this.flaggedQuestions = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$answeredQuestions of $totalQuestions answered',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (flaggedQuestions > 0)
              Row(
                children: [
                  Icon(
                    Icons.flag,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '$flaggedQuestions flagged',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? AppColors.success : theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Exam result summary.
class ExamResult extends StatelessWidget {
  final String examType;
  final double overallScore;
  final Map<String, double> sectionScores;
  final DateTime completedAt;

  const ExamResult({
    super.key,
    required this.examType,
    required this.overallScore,
    required this.sectionScores,
    required this.completedAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    examType,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            Center(
              child: BandScoreCard(
                bandScore: overallScore,
                section: 'Overall Score',
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Section Scores',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...sectionScores.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    BandScoreCard(
                      bandScore: entry.value,
                      showDescription: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Divider(),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Completed: ${_formatDate(completedAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Exam section header.
class ExamSectionHeader extends StatelessWidget {
  final String sectionName;
  final int timeLimitMinutes;
  final int questionCount;

  const ExamSectionHeader({
    super.key,
    required this.sectionName,
    required this.timeLimitMinutes,
    required this.questionCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.view_list,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$questionCount questions • $timeLimitMinutes minutes',
                  style: theme.textTheme.bodySmall?.copyWith(
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
}
