import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../controllers/listening_controller.dart';
import '../../data/datasources/listening_remote_datasource.dart';

/// Listening Practice screen with audio exercises and comprehension checks.
class ListeningPage extends ConsumerStatefulWidget {
  const ListeningPage({super.key});

  @override
  ConsumerState<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends ConsumerState<ListeningPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _topicController = TextEditingController();
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  double _progress = 0.0;
  late AnimationController _waveController;
  bool _showQuiz = false;
  final Map<int, int> _selectedAnswers = {};
  bool _quizChecked = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _waveController.repeat();
      } else {
        _waveController.stop();
      }
    });
  }

  void _generateExercise() {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;
    ref.read(listeningControllerProvider.notifier).generateExercise(topic);
    setState(() {
      _showQuiz = false;
      _selectedAnswers.clear();
      _quizChecked = false;
      _isPlaying = false;
      _progress = 0.0;
      _waveController.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(listeningControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening Practice'),
        actions: state.whenOrNull(
              data: (exercise) {
                if (exercise == null) return null;
                return [
                  TextButton(
                    onPressed: () => setState(() => _showQuiz = !_showQuiz),
                    child: Text(
                      _showQuiz ? 'Player' : 'Quiz',
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

  Widget _buildBody(ThemeData theme, AsyncValue<ListeningExercise?> state) {
    return state.when(
      data: (exercise) {
        if (exercise == null) return _buildTopicInput(theme, false);
        if (_showQuiz) return _buildQuiz(theme, exercise);
        return _buildPlayer(theme, exercise);
      },
      loading: () => _buildTopicInput(theme, true),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => _generateExercise(),
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
                Icons.headphones,
                size: 72,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'AI Listening Generator',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Type a topic you want to hear, and our AI will write a listening script, generate voice audio, and prepare a comprehension quiz.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _topicController,
                decoration: InputDecoration(
                  hintText: 'e.g., Ordering Food, Airport Check-in, Medical Consultation',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  prefixIcon: const Icon(Icons.topic_outlined),
                ),
                enabled: !isGenerating,
              ),
              const SizedBox(height: AppSpacing.base),
              AppButton(
                label: 'Generate Audio Exercise',
                onPressed: _generateExercise,
                isLoading: isGenerating,
                icon: Icons.auto_awesome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer(ThemeData theme, ListeningExercise exercise) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        // Audio Player Card
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(25),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(
                      Icons.headphones,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${exercise.cefrLevel} • Speed: ${exercise.speedNotes}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              // Waveform visualization
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(20, (index) {
                        final height = _isPlaying
                            ? (12.0 +
                                  (index % 3) * 8.0 +
                                  (_waveController.value * 16))
                            : 8.0;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 3,
                          height: height.clamp(8.0, 40.0),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(
                              _isPlaying ? 200 : 77,
                            ),
                            borderRadius: AppRadius.roundAll,
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              // Progress bar
              Row(
                children: [
                  Text(
                    '0:00',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _progress,
                      onChanged: (val) => setState(() => _progress = val),
                    ),
                  ),
                  Text(
                    '1:30',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    onPressed: () {
                      setState(() {
                        _progress = (_progress - 0.1).clamp(0.0, 1.0);
                      });
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlay,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.forward_10),
                    onPressed: () {
                      setState(() {
                        _progress = (_progress + 0.1).clamp(0.0, 1.0);
                      });
                    },
                  ),
                  const SizedBox(width: AppSpacing.base),
                  // Speed control
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: DropdownButton<double>(
                      value: _playbackSpeed,
                      underline: const SizedBox.shrink(),
                      isDense: true,
                      items: [0.75, 1.0, 1.25].map((speed) {
                        return DropdownMenuItem(
                          value: speed,
                          child: Text(
                            '${speed}x',
                            style: theme.textTheme.labelMedium,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _playbackSpeed = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Transcript
        Text(
          'Transcript',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Text(
            exercise.script,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
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
          label: 'Try Another Topic',
          onPressed: () => ref.read(listeningControllerProvider.notifier).clearExercise(),
          isSecondary: true,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildQuiz(ThemeData theme, ListeningExercise exercise) {
    final questions = exercise.comprehensionQuestions;

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
            label: 'Back to Player',
            onPressed: () => setState(() => _showQuiz = false),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Try New Topic',
            onPressed: () => ref.read(listeningControllerProvider.notifier).clearExercise(),
            isSecondary: true,
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
