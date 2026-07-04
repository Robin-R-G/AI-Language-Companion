import 'package:flutter/material.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Reading Practice screen with passages and comprehension questions.
class ReadingPage extends StatefulWidget {
  const ReadingPage({super.key});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  bool _isLoading = false;
  bool _hasError = false;
  bool _showQuiz = false;

  final String _passage = '''
The Benefits of Learning a New Language

Learning a new language is one of the most rewarding intellectual endeavors one can undertake. Beyond the obvious practical advantages of communicating with a wider range of people, research has shown that bilingualism offers significant cognitive benefits.

Studies at University College London found that people who speak more than one language have better memory, problem-solving skills, and creative thinking abilities. The mental exercise of switching between languages strengthens the brain's executive functions, much like physical exercise strengthens the body.

Furthermore, learning a new language opens doors to different cultures and perspectives. When you learn a language, you also learn about the values, traditions, and ways of thinking of the people who speak it. This cultural awareness fosters empathy and global understanding.

For students preparing for exams like IELTS or TOEFL, regular reading practice is essential. Reading comprehension requires not just vocabulary knowledge, but also the ability to understand context, make inferences, and identify the author's purpose and tone.
''';

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What did the University College London study find?',
      'options': [
        'Bilingual people earn more money',
        'Bilingual people have better cognitive skills',
        'Learning languages is easy',
        'Only children can learn languages',
      ],
      'correctIndex': 1,
    },
    {
      'question':
          'According to the passage, how does learning a language help culturally?',
      'options': [
        'It helps you travel cheaper',
        'It opens doors to different cultures and perspectives',
        'It guarantees a job',
        'It makes you smarter than others',
      ],
      'correctIndex': 1,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Practice'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _showQuiz = !_showQuiz),
            child: Text(_showQuiz ? 'Passage' : 'Quiz'),
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_hasError) return ErrorView(onRetry: _loadData);
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.base),
        itemCount: 5,
        itemBuilder: (context, index) => const ShimmerCard(),
      );
    }

    if (_showQuiz) return _buildQuiz(theme);
    return _buildPassage(theme);
  }

  Widget _buildPassage(ThemeData theme) {
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
                    child: const Text(
                      'Intermediate',
                      style: TextStyle(
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
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '5 min read',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'The Benefits of Learning a New Language',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                _passage,
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
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildQuiz(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final q = _questions[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Q${index + 1}. ${q['question']}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...(q['options'] as List).map((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    leading: Radio<int>(
                      value: (q['options'] as List).indexOf(option),
                      groupValue: null,
                      onChanged: (val) {},
                    ),
                    title: Text(
                      option as String,
                      style: theme.textTheme.bodyMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.smAll,
                      side: BorderSide(color: theme.colorScheme.outline),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
