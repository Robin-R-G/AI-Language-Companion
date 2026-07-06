import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../controllers/reading_controller.dart';
import '../../data/datasources/reading_remote_datasource.dart';

/// Reading Practice screen with passages and comprehension questions.
class ReadingPage extends ConsumerStatefulWidget {
  const ReadingPage({super.key});

  @override
  ConsumerState<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends ConsumerState<ReadingPage> {
  final TextEditingController _topicController = TextEditingController();
  bool _showQuiz = false;
  final Map<int, int> _selectedAnswers = {};
  bool _quizChecked = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _generateLesson() {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;
    ref.read(readingControllerProvider.notifier).generateLesson(topic);
    setState(() {
      _showQuiz = false;
      _selectedAnswers.clear();
      _quizChecked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(readingControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Practice'),
        actions: state.whenOrNull(
              data: (lesson) {
                if (lesson == null) return null;
                return [
                  TextButton(
                    onPressed: () => setState(() => _showQuiz = !_showQuiz),
                    child: Text(
                      _showQuiz ? 'Passage' : 'Quiz',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  )
                ];
              },
            ) ??
            [],
      ),
      body: _buildBody(theme, state),
    );
  }

  Widget _buildBody(ThemeData theme, AsyncValue<ReadingLesson?> state) {
    return state.when(
      data: (lesson) {
        if (lesson == null) return _buildTopicInput(theme, false);
        if (_showQuiz) return _buildQuiz(theme, lesson);
        return _buildPassage(theme, lesson);
      },
      loading: () => _buildTopicInput(theme, true),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => _generateLesson(),
      ),
    );
  }

  Widget _buildTopicInput(ThemeData theme, bool isGenerating) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book,
                size: 72,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'AI Reading Generator',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter any topic you want to learn about, and our AI will generate a tailored reading passage and comprehension quiz.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _topicController,
                decoration: InputDecoration(
                  hintText: 'e.g., Space Exploration, History of Tea, Artificial Intelligence',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  prefixIcon: const Icon(Icons.topic_outlined),
                ),
                enabled: !isGenerating,
              ),
              const SizedBox(height: AppSpacing.base),
              AppButton(
                label: 'Generate Lesson',
                onPressed: _generateLesson,
                isLoading: isGenerating,
                icon: Icons.auto_awesome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassage(ThemeData theme, ReadingLesson lesson) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(25),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      lesson.cefrLevel,
                      style: const TextStyle(
                        color: AppColors.info,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${(lesson.wordCount / 200).ceil()} min read',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                lesson.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                lesson.passage,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        AppButton(
          label: 'Take Comprehension Quiz',
          onPressed: () => setState(() => _showQuiz = true),
          icon: Icons.quiz,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'New Topic',
          onPressed: () => ref.read(readingControllerProvider.notifier).clearLesson(),
          isSecondary: true,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildQuiz(ThemeData theme, ReadingLesson lesson) {
    final questions = lesson.comprehensionQuestions;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        ...List.generate(questions.length, (index) {
          final q = questions[index];
          final options = q['options'] as List<dynamic>? ?? [];
          final correctIdx = q['correct_index'] as int? ?? 0;
          final userSelected = _selectedAnswers[index];

          return AppCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q${index + 1}. ${q['question'] ?? ''}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...List.generate(options.length, (optIdx) {
                  final option = options[optIdx] as String;
                  Color? tileColor;
                  if (_quizChecked) {
                    if (optIdx == correctIdx) {
                      tileColor = Colors.green.withOpacity(0.1);
                    } else if (userSelected == optIdx) {
                      tileColor = Colors.red.withOpacity(0.1);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Container(
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        leading: Radio<int>(
                          value: optIdx,
                          groupValue: userSelected,
                          onChanged: _quizChecked ? null : (val) {
                            setState(() {
                              _selectedAnswers[index] = val!;
                            });
                          },
                        ),
                        title: Text(
                          option,
                          style: theme.textTheme.bodyMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.smAll,
                          side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
        const SizedBox(height: AppSpacing.base),
        if (!_quizChecked)
          AppButton(
            label: 'Check Answers',
            onPressed: _selectedAnswers.length < questions.length
                ? null
                : () => setState(() => _quizChecked = true),
            icon: Icons.check,
          )
        else ...[
          Text(
            'Score: ${_selectedAnswers.entries.where((e) => e.value == (questions[e.key]['correct_index'] as int? ?? 0)).length} / ${questions.length}',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.base),
          AppButton(
            label: 'Back to Passage',
            onPressed: () => setState(() => _showQuiz = false),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Try New Topic',
            onPressed: () => ref.read(readingControllerProvider.notifier).clearLesson(),
            isSecondary: true,
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
