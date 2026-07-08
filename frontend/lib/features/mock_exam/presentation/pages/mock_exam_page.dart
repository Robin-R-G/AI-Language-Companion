import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/design_tokens.dart';
import '../providers/mock_exam_providers.dart';

class MockExamPage extends ConsumerStatefulWidget {
  const MockExamPage({super.key});

  @override
  ConsumerState<MockExamPage> createState() => _MockExamPageState();
}

class _MockExamPageState extends ConsumerState<MockExamPage> {
  Timer? _examTimer;
  String? _selectedExam;
  String? _selectedSection;
  bool _isStarted = false;
  int _timeRemaining = 600;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mockExamsListProvider.notifier).loadExams();
    });
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Exam'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isStarted) {
              _showExitDialog();
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          if (_isStarted)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.base),
              child: Center(
                child: Text(
                  _formatTime(_timeRemaining),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _timeRemaining < 120 ? AppColors.error : null,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isStarted ? _buildExamView() : _buildExamSelection(),
    );
  }

  Widget _buildExamSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Exam',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Select an exam type and section to practice.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            'Exam Type',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppConstants.exams
                .where((e) => e['code'] != 'general')
                .map((exam) {
                  final isSelected = _selectedExam == exam['code'];
                  return ChoiceChip(
                    label: Text(exam['name']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedExam = selected ? exam['code'] : null;
                        _selectedSection = null;
                      });
                    },
                  );
                })
                .toList(),
          ),

          const SizedBox(height: AppSpacing.xl),

          if (_selectedExam != null) ...[
            Text(
              'Section',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _getSectionsForExam(_selectedExam!).map((section) {
                final isSelected = _selectedSection == section['code'];
                return ChoiceChip(
                  label: Text(section['name']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSection = selected ? section['code'] : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedExam != null && _selectedSection != null)
                  ? _startExam
                  : null,
              child: const Text('Start Exam'),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            'Recent Exams',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildRecentExamsList(),
        ],
      ),
    );
  }

  Widget _buildExamView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'Question 1 of 5',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          'Describe a place you visited that you enjoyed.',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'You should say:\n• where it was\n• when you went there\n• what you did there\n• and explain why you enjoyed it',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.base),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Column(
                      children: [
                        Icon(
                          Icons.mic,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Tap to start recording',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Next question')),
                    );
                  },
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitExam,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExamsList() {
    final examsState = ref.watch(mockExamsListProvider);

    return examsState.when(
      data: (exams) {
        if (exams.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Center(
                child: Text(
                  'No exams taken yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: exams.take(5).map((exam) {
                final isLast = exam == exams.last;
                final examTitle = exam.title ?? exam.examType;
                final examSubtitle = exam.section ?? '';
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.success.withOpacity(0.1),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                        ),
                      ),
                      title: Text(examTitle),
                      subtitle: Text(examSubtitle),
                    ),
                    if (!isLast) const Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.base),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Center(child: Text('Failed to load exams: $error')),
        ),
      ),
    );
  }

  List<Map<String, String>> _getSectionsForExam(String examCode) {
    switch (examCode) {
      case 'ielts':
        return [
          {'code': 'speaking', 'name': 'Speaking'},
          {'code': 'writing', 'name': 'Writing'},
          {'code': 'reading', 'name': 'Reading'},
          {'code': 'listening', 'name': 'Listening'},
        ];
      case 'toefl':
        return [
          {'code': 'reading', 'name': 'Reading'},
          {'code': 'listening', 'name': 'Listening'},
          {'code': 'speaking', 'name': 'Speaking'},
          {'code': 'writing', 'name': 'Writing'},
        ];
      case 'pte':
        return [
          {'code': 'speaking', 'name': 'Speaking & Writing'},
          {'code': 'reading', 'name': 'Reading'},
          {'code': 'listening', 'name': 'Listening'},
        ];
      case 'oet':
        return [
          {'code': 'listening', 'name': 'Listening'},
          {'code': 'reading', 'name': 'Reading'},
          {'code': 'writing', 'name': 'Writing'},
          {'code': 'speaking', 'name': 'Speaking'},
        ];
      case 'toeic':
        return [
          {'code': 'listening', 'name': 'Listening'},
          {'code': 'reading', 'name': 'Reading'},
        ];
      case 'cambridge_a2_key':
      case 'cambridge_b1_preliminary':
      case 'cambridge_b2_first':
      case 'cambridge_c1_advanced':
      case 'cambridge_c2_proficiency':
        return [
          {'code': 'reading', 'name': 'Reading & Use of English'},
          {'code': 'writing', 'name': 'Writing'},
          {'code': 'listening', 'name': 'Listening'},
          {'code': 'speaking', 'name': 'Speaking'},
        ];
      case 'duolingo':
        return [
          {'code': 'reading', 'name': 'Reading & Writing'},
          {'code': 'listening', 'name': 'Listening & Speaking'},
        ];
      case 'celpip':
        return [
          {'code': 'listening', 'name': 'Listening'},
          {'code': 'reading', 'name': 'Reading'},
          {'code': 'writing', 'name': 'Writing'},
          {'code': 'speaking', 'name': 'Speaking'},
        ];
      case 'linguaskill':
        return [
          {'code': 'reading', 'name': 'Reading & Writing'},
          {'code': 'listening', 'name': 'Listening & Speaking'},
        ];
      case 'sat':
        return [
          {'code': 'reading', 'name': 'Reading & Writing'},
          {'code': 'math', 'name': 'Math'},
        ];
      case 'act':
        return [
          {'code': 'english', 'name': 'English'},
          {'code': 'reading', 'name': 'Reading'},
          {'code': 'math', 'name': 'Math'},
          {'code': 'science', 'name': 'Science'},
        ];
      case 'gre':
        return [
          {'code': 'verbal', 'name': 'Verbal Reasoning'},
          {'code': 'quantitative', 'name': 'Quantitative Reasoning'},
          {'code': 'analytical', 'name': 'Analytical Writing'},
        ];
      case 'gmat':
        return [
          {'code': 'verbal', 'name': 'Verbal'},
          {'code': 'quantitative', 'name': 'Quantitative'},
          {'code': 'data_insights', 'name': 'Data Insights'},
        ];
      case 'goethe_a1':
      case 'goethe_a2':
      case 'goethe_b1':
      case 'goethe_b2':
      case 'goethe_c1':
      case 'goethe_c2':
        return [
          {'code': 'lesen', 'name': 'Reading'},
          {'code': 'horen', 'name': 'Listening'},
          {'code': 'schreiben', 'name': 'Writing'},
          {'code': 'sprechen', 'name': 'Speaking'},
        ];
      case 'telc':
        return [
          {'code': 'lesen', 'name': 'Reading'},
          {'code': 'horen', 'name': 'Listening'},
          {'code': 'schreiben', 'name': 'Writing'},
          {'code': 'sprechen', 'name': 'Speaking'},
        ];
      case 'testdaf':
        return [
          {'code': 'lesen', 'name': 'Reading'},
          {'code': 'horen', 'name': 'Listening'},
          {'code': 'schreiben', 'name': 'Writing'},
          {'code': 'sprechen', 'name': 'Speaking'},
        ];
      case 'dsh':
        return [
          {'code': 'lesen', 'name': 'Reading'},
          {'code': 'horen', 'name': 'Listening'},
          {'code': 'schreiben', 'name': 'Writing'},
          {'code': 'sprechen', 'name': 'Speaking'},
        ];
      case 'delf_dalf':
        return [
          {'code': 'comprehension_orale', 'name': 'Listening'},
          {'code': 'comprehension_ecrite', 'name': 'Reading'},
          {'code': 'production_ecrite', 'name': 'Writing'},
          {'code': 'production_orale', 'name': 'Speaking'},
        ];
      case 'tcf':
        return [
          {'code': 'comprehension_orale', 'name': 'Listening'},
          {'code': 'comprehension_ecrite', 'name': 'Reading'},
          {'code': 'expression_ecrite', 'name': 'Writing'},
          {'code': 'expression_orale', 'name': 'Speaking'},
        ];
      case 'tef':
        return [
          {'code': 'comprehension_orale', 'name': 'Listening'},
          {'code': 'comprehension_ecrite', 'name': 'Reading'},
          {'code': 'production_ecrite', 'name': 'Writing'},
          {'code': 'production_orale', 'name': 'Speaking'},
        ];
      case 'dele':
        return [
          {'code': 'comprension_lectora', 'name': 'Reading'},
          {'code': 'comprension_auditiva', 'name': 'Listening'},
          {'code': 'expresion_escrita', 'name': 'Writing'},
          {'code': 'expresion_oral', 'name': 'Speaking'},
        ];
      case 'siele':
        return [
          {'code': 'comprension_lectora', 'name': 'Reading'},
          {'code': 'comprension_auditiva', 'name': 'Listening'},
          {'code': 'expresion_escrita', 'name': 'Writing'},
          {'code': 'expresion_oral', 'name': 'Speaking'},
        ];
      case 'jlpt':
        return [
          {
            'code': 'kanji_vocabulary',
            'name': 'Language Knowledge (Kanji/Vocabulary)',
          },
          {
            'code': 'grammar_reading',
            'name': 'Language Knowledge (Grammar) & Reading',
          },
          {'code': 'listening', 'name': 'Listening'},
        ];
      case 'topik':
        return [
          {'code': 'listening', 'name': 'Listening'},
          {'code': 'reading', 'name': 'Reading'},
          {'code': 'writing', 'name': 'Writing'},
        ];
      case 'hsk':
        return [
          {'code': 'listening', 'name': 'Listening'},
          {'code': 'reading', 'name': 'Reading'},
        ];
      default:
        return [
          {'code': 'speaking', 'name': 'Speaking'},
          {'code': 'writing', 'name': 'Writing'},
        ];
    }
  }

  void _startExam() async {
    setState(() {
      _isStarted = true;
      _isTimerRunning = true;
    });
    _startTimer();

    final activeExamNotifier = ref.read(activeExamProvider.notifier);
    await activeExamNotifier.startExam(_selectedExam!);
  }

  void _startTimer() {
    _examTimer?.cancel();
    _examTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _examTimer?.cancel();
        return;
      }
      if (_isTimerRunning && _timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _examTimer?.cancel();
        if (_timeRemaining == 0) _submitExam();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _submitExam() async {
    setState(() {
      _isTimerRunning = false;
    });

    final activeExamNotifier = ref.read(activeExamProvider.notifier);
    await activeExamNotifier.submitExam(_selectedExam!, []);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exam Complete!'),
          content: const Text('Your results are being processed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isStarted = false;
                  _selectedExam = null;
                  _selectedSection = null;
                  _timeRemaining = 600;
                });
                ref.read(mockExamsListProvider.notifier).loadExams();
              },
              child: const Text('View Results'),
            ),
          ],
        ),
      );
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Exam?'),
        content: const Text('Your progress will be lost. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Exam'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isStarted = false;
                _selectedExam = null;
                _selectedSection = null;
                _timeRemaining = 600;
              });
              context.pop();
            },
            child: const Text('Exit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
