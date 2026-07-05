// lib/features/reading/presentation/screens/reading_lesson_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_language_coach/shared/theme/app_theme.dart';
import '../controllers/reading_controller.dart';

class ReadingLessonScreen extends ConsumerStatefulWidget {
  final String? topic;

  const ReadingLessonScreen({super.key, this.topic});

  @override
  ConsumerState<ReadingLessonScreen> createState() => _ReadingLessonScreenState();
}

class _ReadingLessonScreenState extends ConsumerState<ReadingLessonScreen> {
  String _selectedTopic = '';
  final List<int> _selectedAnswers = [];
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    if (widget.topic != null) {
      _selectedTopic = widget.topic!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(readingControllerProvider.notifier).generateLesson(_selectedTopic);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonState = ref.watch(readingControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Lesson'),
        backgroundColor: AppColors.surface,
      ),
      body: lessonState.when(
        data: (lesson) {
          if (lesson == null) return _buildTopicSelection();
          return _buildLessonContent(lesson);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error: $error', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(readingControllerProvider.notifier).generateLesson(_selectedTopic);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicSelection() {
    final topics = [
      'Daily Life', 'Travel', 'Food & Culture', 'Technology',
      'Environment', 'Health', 'Education', 'Business',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Topic',
            style: AppTextStyles.headingLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Select a topic for your reading lesson',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topics.map((topic) {
              final isSelected = _selectedTopic == topic;
              return ChoiceChip(
                label: Text(topic),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedTopic = topic);
                },
                selectedColor: AppColors.primary.withOpacity(0.1),
                labelStyle: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          if (_selectedTopic.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(readingControllerProvider.notifier).generateLesson(_selectedTopic);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Start Lesson',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonContent(dynamic lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and metadata
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title ?? 'Reading Lesson',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMetaChip(Icons.book, '${lesson.wordCount ?? 0} words'),
                    const SizedBox(width: 12),
                    _buildMetaChip(Icons.school, lesson.cefrLevel ?? 'A1'),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 24),

          // Passage
          Text(
            'Reading Passage',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              lesson.passage ?? '',
              style: AppTextStyles.bodyLarge.copyWith(
                height: 1.8,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Vocabulary
          if (lesson.vocabulary != null && lesson.vocabulary.isNotEmpty) ...[
            Text(
              'Key Vocabulary',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 12),
            ...lesson.vocabulary.map((v) => _buildVocabularyItem(v)),
            const SizedBox(height: 24),
          ],

          // Comprehension Questions
          if (lesson.comprehensionQuestions != null &&
              lesson.comprehensionQuestions.isNotEmpty) ...[
            Text(
              'Comprehension Questions',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 12),
            ...lesson.comprehensionQuestions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestion(question, index);
            }),
            const SizedBox(height: 16),
            if (!_showResults)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAnswers.length ==
                          lesson.comprehensionQuestions.length
                      ? () => setState(() => _showResults = true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Check Answers',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (_showResults) ...[
              _buildResults(lesson.comprehensionQuestions),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(readingControllerProvider.notifier).clearLesson();
                    setState(() {
                      _selectedAnswers.clear();
                      _showResults = false;
                    });
                  },
                  child: const Text('Try Another Topic'),
                ),
              ),
            ],
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyItem(dynamic vocab) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vocab.word ?? '',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vocab.definition ?? '',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(dynamic question, int index) {
    final options = question.options as List? ?? [];
    final selected = _selectedAnswers.length > index ? _selectedAnswers[index] : -1;
    final correctIndex = question.correctIndex ?? 0;
    final showCorrect = _showResults;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showCorrect
              ? (selected == correctIndex ? AppColors.success : AppColors.error)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${index + 1}',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.question ?? '',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final isSelected = selected == optionIndex;
            final isCorrect = optionIndex == correctIndex;

            Color? backgroundColor;
            Color? borderColor;

            if (showCorrect) {
              if (isCorrect) {
                backgroundColor = AppColors.success.withOpacity(0.1);
                borderColor = AppColors.success;
              } else if (isSelected && !isCorrect) {
                backgroundColor = AppColors.error.withOpacity(0.1);
                borderColor = AppColors.error;
              }
            } else if (isSelected) {
              backgroundColor = AppColors.primary.withOpacity(0.1);
              borderColor = AppColors.primary;
            }

            return GestureDetector(
              onTap: showCorrect
                  ? null
                  : () {
                      setState(() {
                        if (_selectedAnswers.length > index) {
                          _selectedAnswers[index] = optionIndex;
                        } else {
                          _selectedAnswers.add(optionIndex);
                        }
                      });
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor ?? AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + optionIndex),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.toString(),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    if (showCorrect && isCorrect)
                      Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    if (showCorrect && isSelected && !isCorrect)
                      Icon(Icons.cancel, color: AppColors.error, size: 20),
                  ],
                ),
              ),
            );
          }),
          if (showCorrect && question.explanation != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResults(List questions) {
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (i < _selectedAnswers.length &&
          _selectedAnswers[i] == questions[i].correctIndex) {
        correct++;
      }
    }

    final percentage = ((correct / questions.length) * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: percentage >= 70
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: percentage >= 70 ? AppColors.success : AppColors.warning,
        ),
      ),
      child: Column(
        children: [
          Icon(
            percentage >= 70 ? Icons.emoji_events : Icons.info,
            size: 48,
            color: percentage >= 70 ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(height: 12),
          Text(
            '$percentage% Correct',
            style: AppTextStyles.headingMedium.copyWith(
              color: percentage >= 70 ? AppColors.success : AppColors.warning,
            ),
          ),
          Text(
            '$correct out of ${questions.length} questions',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
