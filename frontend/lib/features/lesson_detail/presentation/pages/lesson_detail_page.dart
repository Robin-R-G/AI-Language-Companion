import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../shared/models/lesson.dart';
import '../../../lessons/presentation/providers/lesson_providers.dart';
import '../../../lessons/presentation/controllers/lessons_controller.dart';

/// Lesson Detail screen showing lesson content and exercises.
class LessonDetailPage extends ConsumerStatefulWidget {
  final String? lessonId;

  const LessonDetailPage({super.key, this.lessonId});

  @override
  ConsumerState<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends ConsumerState<LessonDetailPage> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _showExplanation = false;
  final List<int?> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    if (widget.lessonId != null) {
      Future.microtask(() {
        ref.read(lessonDetailProvider.notifier).loadLesson(widget.lessonId!);
      });
    }
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (_userAnswers.length <= _currentQuestion) {
        _userAnswers.add(index);
      } else {
        _userAnswers[_currentQuestion] = index;
      }
    });
  }

  void _nextQuestion() {
    final lessonState = ref.read(lessonDetailProvider);
    final lesson = lessonState.valueOrNull;
    if (lesson == null) return;

    final quizzes = lesson.quizzes ?? [];
    if (_currentQuestion < quizzes.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
        _showExplanation = false;
      });
    } else {
      _completeLesson();
    }
  }

  Future<void> _completeLesson() async {
    if (widget.lessonId == null) return;

    final lessonState = ref.read(lessonDetailProvider);
    final lesson = lessonState.valueOrNull;
    if (lesson == null) return;

    final quizzes = lesson.quizzes ?? [];
    final totalQuestions = quizzes.length;
    if (totalQuestions == 0) return;

    int correctAnswers = 0;
    for (int i = 0; i < totalQuestions; i++) {
      final userAnswer = i < _userAnswers.length ? _userAnswers[i] : null;
      if (userAnswer != null && userAnswer == quizzes[i].correctOptionIndex) {
        correctAnswers++;
      }
    }

    final score = ((correctAnswers / totalQuestions) * 100).round();

    await ref.read(lessonDetailProvider.notifier).completeLesson(
      widget.lessonId!,
      score,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lesson completed! Score: $score%'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lessonState = ref.watch(lessonDetailProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(lessonState.valueOrNull?.title ?? 'Lesson'),
        actions: [
          lessonState.whenOrNull(
            data: (lesson) => lesson != null
                ? Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.base),
                    child: Center(
                      child: Text(
                        '${_currentQuestion + 1}/${(lesson.quizzes ?? []).length}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : null,
            loading: () => null,
            error: (_, __) => null,
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: lessonState.when(
        data: (lesson) {
          if (lesson == null) return _buildEmptyState(theme);
          return _buildLessonContent(theme, lesson);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(onRetry: () {
          if (widget.lessonId != null) {
            ref
                .read(lessonDetailProvider.notifier)
                .loadLesson(widget.lessonId!);
          }
        }),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Lesson not found',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This lesson may have been removed or is unavailable.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonContent(ThemeData theme, Lesson lesson) {
    final quizzes = lesson.quizzes as List<dynamic>? ?? [];
    if (quizzes.isEmpty) {
      return _buildNoQuestionsState(theme, lesson);
    }

    final question = quizzes[_currentQuestion];

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: LinearProgressIndicator(
            value: (_currentQuestion + 1) / quizzes.length,
            minHeight: 4,
            borderRadius: AppRadius.smAll,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              // Difficulty badge and category
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      lesson.difficulty,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    lesson.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              // Question
              AppCard(
                child: Text(
                  question.question as String,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Options
              ...List.generate(
                (question.options as List).length,
                (index) => _AnswerOption(
                  text: (question.options as List)[index] as String,
                  index: index,
                  isSelected: _selectedAnswer == index,
                  isCorrect: index == question.correctOptionIndex,
                  answered: _answered,
                  onTap: () => _selectAnswer(index),
                ),
              ),

              // Explanation
              if (_answered && _showExplanation && question.explanation != null) ...[
                const SizedBox(height: AppSpacing.base),
                AppCard(
                  color: theme.colorScheme.primaryContainer.withAlpha(77),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Explanation',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        question.explanation as String,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bottom buttons
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: _answered
                ? Row(
                    children: [
                      if (!_showExplanation)
                        Expanded(
                          child: AppButton(
                            label: 'Show Explanation',
                            isSecondary: true,
                            onPressed: () =>
                                setState(() => _showExplanation = true),
                          ),
                        ),
                      if (!_showExplanation)
                        const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          label: _currentQuestion < quizzes.length - 1
                              ? 'Next Question'
                              : 'Complete Lesson',
                          onPressed: _nextQuestion,
                        ),
                      ),
                    ],
                  )
                : AppButton(
                    label: 'Check Answer',
                    onPressed: _selectedAnswer != null
                        ? () => setState(() => _answered = true)
                        : null,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoQuestionsState(ThemeData theme, Lesson lesson) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      lesson.difficulty,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    lesson.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              if (lesson.content != null)
                AppCard(
                  child: Text(
                    lesson.content as String,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: AppButton(
              label: 'Complete Lesson',
              onPressed: _completeLesson,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool answered;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.answered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color borderColor = theme.colorScheme.outline;
    Color? bgColor;
    Color? textColor;

    if (answered) {
      if (isCorrect) {
        borderColor = AppColors.success;
        bgColor = AppColors.success.withAlpha(25);
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.error;
        bgColor = AppColors.error.withAlpha(25);
      }
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
      bgColor = theme.colorScheme.primary.withAlpha(25);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smAll,
          side: BorderSide(color: borderColor, width: 2),
        ),
        child: InkWell(
          onTap: answered ? null : onTap,
          borderRadius: AppRadius.smAll,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: borderColor.withAlpha(25),
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: answered && isCorrect
                        ? const Icon(
                            Icons.check,
                            size: 18,
                            color: AppColors.success,
                          )
                        : answered && isSelected && !isCorrect
                        ? const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.error,
                          )
                        : Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: borderColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
