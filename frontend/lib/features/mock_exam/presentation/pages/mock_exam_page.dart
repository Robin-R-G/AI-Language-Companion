import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/design_tokens.dart';

/// Mock exam page for IELTS/PTE practice tests.
class MockExamPage extends ConsumerStatefulWidget {
  const MockExamPage({super.key});

  @override
  ConsumerState<MockExamPage> createState() => _MockExamPageState();
}

class _MockExamPageState extends ConsumerState<MockExamPage> {
  Timer? _examTimer;

  @override
  void dispose() {
    _examTimer?.cancel();
    super.dispose();
  }

  String? _selectedExam;
  String? _selectedSection;
  bool _isStarted = false;
  int _timeRemaining = 600; // 10 minutes in seconds
  bool _isTimerRunning = false;

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
          // Header
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

          // Exam Type Selection
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

          // Section Selection
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

          // Start Button
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

          // Recent Exams
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
        // Exam Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Card
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

                // Recording Area
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

        // Bottom Actions
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
                    // TODO: Skip question
                  },
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Submit answer
                  },
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
    // TODO: Replace with actual data
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.success.withOpacity(0.1),
                child: const Icon(Icons.check_circle, color: AppColors.success),
              ),
              title: const Text('IELTS Speaking - Part 2'),
              subtitle: const Text('2 days ago'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text(
                  '7.0',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.warning.withOpacity(0.1),
                child: const Icon(Icons.check_circle, color: AppColors.warning),
              ),
              title: const Text('IELTS Writing - Task 2'),
              subtitle: const Text('5 days ago'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text(
                  '6.5',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
      case 'pte':
        return [
          {'code': 'speaking', 'name': 'Speaking'},
          {'code': 'writing', 'name': 'Writing'},
          {'code': 'reading', 'name': 'Reading'},
          {'code': 'listening', 'name': 'Listening'},
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
      default:
        return [
          {'code': 'speaking', 'name': 'Speaking'},
          {'code': 'writing', 'name': 'Writing'},
        ];
    }
  }

  void _startExam() {
    setState(() {
      _isStarted = true;
      _isTimerRunning = true;
    });
    _startTimer();
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

  void _submitExam() {
    setState(() {
      _isTimerRunning = false;
    });
    // TODO: Submit exam and show results
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exam Complete!'),
        content: const Text('Your results are being processed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('View Results'),
          ),
        ],
      ),
    );
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
              context.pop();
            },
            child: const Text('Exit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
