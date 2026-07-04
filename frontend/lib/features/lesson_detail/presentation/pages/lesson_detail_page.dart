import 'package:flutter/material.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Lesson Detail screen showing quiz questions and exercises.
class LessonDetailPage extends StatefulWidget {
  final String? lessonId;

  const LessonDetailPage({super.key, this.lessonId});

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  bool _isLoading = false;
  bool _hasError = false;
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _showExplanation = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Choose the correct form: "She ___ to school every day."',
      'options': ['go', 'goes', 'going', 'went'],
      'correctIndex': 1,
      'explanation': 'Third person singular subjects use "goes" in present simple tense.',
      'malayalam': 'She എന്ന ഏകവചന വിഷയത്തിന് "goes" ഉപയോഗിക്കണം.',
    },
    {
      'question': 'Which sentence is grammatically correct?',
      'options': [
        'I have been to Paris last year.',
        'I went to Paris last year.',
        'I go to Paris last year.',
        'I am going to Paris last year.',
      ],
      'correctIndex': 1,
      'explanation': 'Use past simple tense with specific past time expressions like "last year".',
      'malayalam': '"last year" എന്ന പ്രത്യേക സമയ സൂചനയ്ക്ക് past simple ഉപയോഗിക്കണം.',
    },
    {
      'question': 'Fill in the blank: "There ___ many students in the class."',
      'options': ['is', 'are', 'was', 'has'],
      'correctIndex': 1,
      'explanation': '"Students" is plural, so use "are".',
      'malayalam': '"students" ബഹുവചനമാണ്, അതിനാൽ "are" ഉപയോഗിക്കണം.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
        _showExplanation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar Basics'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.base),
            child: Center(
              child: Text(
                '${_currentQuestion + 1}/${_questions.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_hasError) return ErrorView(onRetry: _loadData);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final question = _questions[_currentQuestion];

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: LinearProgressIndicator(
            value: (_currentQuestion + 1) / _questions.length,
            minHeight: 4,
            borderRadius: AppRadius.smAll,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              // Difficulty badge
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
                    child: const Text(
                      'Beginner',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Grammar',
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
                  question['question'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Options
              ...List.generate(
                (question['options'] as List).length,
                (index) => _AnswerOption(
                  text: (question['options'] as List)[index] as String,
                  index: index,
                  isSelected: _selectedAnswer == index,
                  isCorrect: index == question['correctIndex'],
                  answered: _answered,
                  onTap: () => _selectAnswer(index),
                ),
              ),

              // Explanation
              if (_answered && _showExplanation) ...[
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
                        question['explanation'] as String,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        question['malayalam'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
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
                            onPressed: () => setState(() => _showExplanation = true),
                          ),
                        ),
                      if (!_showExplanation) const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          label: _currentQuestion < _questions.length - 1
                              ? 'Next Question'
                              : 'Complete Lesson',
                          onPressed: _nextQuestion,
                        ),
                      ),
                    ],
                  )
                : AppButton(
                    label: 'Check Answer',
                    onPressed: _selectedAnswer != null ? () => setState(() => _answered = true) : null,
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
                        ? const Icon(Icons.check, size: 18, color: AppColors.success)
                        : answered && isSelected && !isCorrect
                            ? const Icon(Icons.close, size: 18, color: AppColors.error)
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
