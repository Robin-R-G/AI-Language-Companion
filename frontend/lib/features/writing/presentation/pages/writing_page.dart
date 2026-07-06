import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../controllers/writing_controller.dart';
import '../../data/datasources/writing_remote_datasource.dart';

/// Writing Evaluation screen for essay submission and AI scoring.
class WritingPage extends ConsumerStatefulWidget {
  const WritingPage({super.key});

  @override
  ConsumerState<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends ConsumerState<WritingPage> {
  bool _isLoading = false;
  bool _hasError = false;
  final TextEditingController _essayController = TextEditingController();
  final int _targetWords = 250;

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

  Future<void> _submitEssay() async {
    final text = _essayController.text.trim();
    if (text.isEmpty) return;
    await ref.read(writingControllerProvider.notifier).evaluateEssay(text);
  }

  @override
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Writing Practice')),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    final state = ref.watch(writingControllerProvider);

    if (_hasError) return ErrorView(onRetry: _loadData);
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.base),
        itemCount: 3,
        itemBuilder: (context, index) => const ShimmerCard(),
      );
    }

    return state.when(
      data: (evaluation) {
        if (evaluation != null) {
          return _buildResult(theme, evaluation);
        }
        return _buildEditor(theme, false);
      },
      loading: () => _buildEditor(theme, true),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => _submitEssay(),
      ),
    );
  }

  Widget _buildEditor(ThemeData theme, bool isSubmitting) {
    final wordCount = _essayController.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        // Topic card
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
                      'IELTS Task 2',
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
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '40 minutes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Topic',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Some people believe that technology has made our lives more complex. To what extent do you agree or disagree?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Write at least 250 words. Give reasons for your answer and include any relevant examples.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Text editor
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _essayController,
                hintText: 'Write your essay here...',
                maxLines: 15,
                onChanged: (text) {
                  setState(() {});
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$wordCount / $_targetWords words',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Timer: 35:00',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        AppButton(
          label: 'Submit Essay',
          onPressed: _submitEssay,
          isLoading: isSubmitting,
          icon: Icons.send,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildResult(ThemeData theme, WritingEvaluation evaluation) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        // Band Score
        AppCard(
          child: Column(
            children: [
              Text(
                'Estimated Band Score',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withAlpha(25),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    evaluation.estimatedBand,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Score breakdown
        Text(
          'Score Breakdown',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ScoreBar(label: 'Grammar', score: evaluation.grammarScore.toDouble()),
        _ScoreBar(label: 'Vocabulary', score: evaluation.vocabularyScore.toDouble()),
        _ScoreBar(label: 'Organization', score: evaluation.organizationScore.toDouble()),
        _ScoreBar(label: 'Clarity', score: evaluation.clarityScore.toDouble()),
        const SizedBox(height: AppSpacing.base),

        // Strengths & Recommendations
        if (evaluation.strengths.isNotEmpty) ...[
          Text(
            'Strengths',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...evaluation.strengths.map((s) => ListTile(
            leading: const Icon(Icons.check, color: AppColors.success),
            title: Text(s),
          )),
          const SizedBox(height: AppSpacing.base),
        ],

        if (evaluation.recommendations.isNotEmpty) ...[
          Text(
            'Recommendations',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...evaluation.recommendations.map((r) => ListTile(
            leading: const Icon(Icons.lightbulb_outline, color: AppColors.warning),
            title: Text(r),
          )),
          const SizedBox(height: AppSpacing.base),
        ],

        if (evaluation.improvedVersion.isNotEmpty) ...[
          Text(
            'Improved Version',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            child: Text(
              evaluation.improvedVersion,
              style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
        ],

        AppButton(
          label: 'Write Another Essay',
          onPressed: () {
            ref.read(writingControllerProvider.notifier).clearResult();
            _essayController.clear();
          },
          isSecondary: true,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double score;

  const _ScoreBar({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.smAll,
              child: LinearProgressIndicator(
                value: score / 9.0,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 32,
            child: Text(
              '$score',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
