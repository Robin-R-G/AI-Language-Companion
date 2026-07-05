// lib/features/listening/presentation/screens/listening_exercise_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/theme/app_theme.dart';
import '../controllers/listening_controller.dart';

class ListeningExerciseScreen extends ConsumerStatefulWidget {
  final String? topic;

  const ListeningExerciseScreen({super.key, this.topic});

  @override
  ConsumerState<ListeningExerciseScreen> createState() => _ListeningExerciseScreenState();
}

class _ListeningExerciseScreenState extends ConsumerState<ListeningExerciseScreen> {
  String _selectedTopic = '';
  final Map<int, String> _gapFillAnswers = {};
  final List<int> _selectedAnswers = [];
  bool _showResults = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.topic != null) {
      _selectedTopic = widget.topic!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(listeningControllerProvider.notifier).generateExercise(_selectedTopic);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final exerciseState = ref.watch(listeningControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening Exercise'),
        backgroundColor: AppColors.surface,
      ),
      body: exerciseState.when(
        data: (exercise) {
          if (exercise == null) return _buildTopicSelection();
          return _buildExerciseContent(exercise);
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
                  ref.read(listeningControllerProvider.notifier).generateExercise(_selectedTopic);
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
      'Airport Announcement', 'Restaurant Order', 'Shopping',
      'Doctor Visit', 'Job Interview', 'Weather Report',
      'Public Transport', 'Hotel Check-in',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Scenario',
            style: AppTextStyles.headingLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Select a listening scenario to practice',
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
                  ref.read(listeningControllerProvider.notifier).generateExercise(_selectedTopic);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Start Exercise',
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

  Widget _buildExerciseContent(dynamic exercise) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.listening, AppColors.listeningDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.title ?? 'Listening Exercise',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMetaChip(Icons.school, exercise.cefrLevel ?? 'A1'),
                    const SizedBox(width: 12),
                    _buildMetaChip(Icons.speed, exercise.speedNotes ?? 'normal'),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 24),

          // Audio Player
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(
                  'Listen to the audio',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Implement text-to-speech
                        setState(() => _isPlaying = !_isPlaying);
                      },
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle : Icons.play_circle,
                        size: 64,
                        color: AppColors.listening,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        // Replay audio
                      },
                      icon: const Icon(
                        Icons.replay,
                        size: 32,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _isPlaying ? 0.6 : 0.0,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.listening),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Script (toggle to show/hide)
          ExpansionTile(
            title: Text(
              'Show Script',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: const Icon(Icons.article),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exercise.script ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Gap Fill Exercise
          if (exercise.gapFill != null && exercise.gapFill.isNotEmpty) ...[
            Text(
              'Gap Fill',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 12),
            ...exercise.gapFill.asMap().entries.map((entry) {
              final index = entry.key;
              final gap = entry.value;
              return _buildGapFillItem(gap, index);
            }),
            const SizedBox(height: 24),
          ],

          // Comprehension Questions
          if (exercise.comprehensionQuestions != null &&
              exercise.comprehensionQuestions.isNotEmpty) ...[
            Text(
              'Comprehension Questions',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 12),
            ...exercise.comprehensionQuestions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestion(question, index);
            }),
            const SizedBox(height: 16),
            if (!_showResults)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _showResults = true),
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

  Widget _buildGapFillItem(Map<String, dynamic> gap, int index) {
    final answer = _gapFillAnswers[index] ?? '';
    final correctAnswer = gap['answer'] ?? '';
    final showCorrect = _showResults;
    final isCorrect = answer.toLowerCase() == correctAnswer.toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: showCorrect
              ? (isCorrect ? AppColors.success : AppColors.error)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${index + 1}. ',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  gap['sentence'] ?? '',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Your answer...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium,
                  onChanged: (value) {
                    _gapFillAnswers[index] = value;
                  },
                  enabled: !showCorrect,
                ),
              ),
              if (showCorrect && !isCorrect) ...[
                const SizedBox(width: 8),
                Text(
                  correctAnswer,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
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
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
