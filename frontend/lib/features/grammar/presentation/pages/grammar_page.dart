import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../providers/grammar_providers.dart';
import '../../data/datasources/grammar_remote_datasource.dart';

/// Grammar screen showing error log, corrections, and practice.
class GrammarPage extends ConsumerStatefulWidget {
  const GrammarPage({super.key});

  @override
  ConsumerState<GrammarPage> createState() => _GrammarPageState();
}

class _GrammarPageState extends ConsumerState<GrammarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    ref.read(grammarRulesProvider.notifier).load(language: _selectedLanguage);
    ref.read(grammarPracticeHistoryProvider.notifier).load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Error Log'),
            Tab(text: 'Practice'),
          ],
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return TabBarView(
      controller: _tabController,
      children: [_buildErrorLog(theme), _buildPracticeTab(theme)],
    );
  }

  Widget _buildErrorLog(ThemeData theme) {
    final practiceState = ref.watch(grammarPracticeHistoryProvider);

    return practiceState.when(
      data: (practices) {
        if (practices.isEmpty) {
          return EmptyState(
            icon: Icons.check_circle_outline,
            title: 'No Grammar Errors',
            message: "Great job! You haven't made any grammar mistakes recently.",
            actionLabel: 'Start Practicing',
            onAction: () {
              _tabController.animateTo(1);
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: practices.length,
            itemBuilder: (context, index) {
              final practice = practices[index];
              return _PracticeCard(practice: practice);
            },
          ),
        );
      },
      loading: () => _buildLoading(theme),
      error: (error, _) => ErrorView(
        onRetry: _loadData,
      ),
    );
  }

  Widget _buildPracticeTab(ThemeData theme) {
    final rulesState = ref.watch(grammarRulesProvider);

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
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(25),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: const Icon(
                      Icons.auto_fix_high,
                      color: AppColors.info,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grammar Practice',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Quick exercises based on your common mistakes',
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
              TextField(
                controller: _textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter text to check grammar...',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.smAll,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      hint: const Text('Language'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'ml', child: Text('Malayalam')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                        _loadData();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: 'Check Grammar',
                    onPressed: () => _checkGrammar(),
                    icon: Icons.send,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Grammar Rules',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        rulesState.when(
          data: (rules) {
            if (rules.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.base),
                  child: Text('No grammar rules found'),
                ),
              );
            }

            return Column(
              children: rules.map((rule) => _RuleTile(rule: rule)).toList(),
            );
          },
          loading: () => _buildLoading(theme),
          error: (error, _) => Center(
            child: Text('Error loading rules: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 5,
      itemBuilder: (context, index) => const ShimmerCard(),
    );
  }

  Future<void> _checkGrammar() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await ref.read(grammarCheckProvider.notifier).check(
      text,
      language: _selectedLanguage,
    );

    final result = ref.read(grammarCheckProvider);
    result.whenOrNull(
      data: (grammarResult) {
        if (grammarResult != null && !grammarResult.isCorrect) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found grammar errors. Check the Error Log tab.'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (grammarResult?.isCorrect == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Great! No grammar errors found.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );
  }
}

class _PracticeCard extends StatelessWidget {
  final GrammarPractice practice;

  const _PracticeCard({required this.practice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                practice.isCorrect ? Icons.check_circle : Icons.error,
                color: practice.isCorrect ? AppColors.success : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  practice.isCorrect ? 'Correct' : 'Needs Improvement',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: practice.isCorrect ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
              Text(
                _formatDate(practice.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: practice.originalText,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.error,
                    color: AppColors.error,
                  ),
                ),
                const TextSpan(text: '  →  '),
                TextSpan(
                  text: practice.correctedText,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _RuleTile extends StatelessWidget {
  final GrammarRule rule;

  const _RuleTile({required this.rule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(25),
            borderRadius: AppRadius.smAll,
          ),
          child: Icon(
            _getIconForCategory(rule.category),
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          rule.ruleName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(rule.description, style: theme.textTheme.bodySmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.roundAll,
          ),
          child: Text(rule.cefrLevel, style: theme.textTheme.labelSmall),
        ),
        onTap: () {
          // Could navigate to rule details
        },
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'tense':
      case 'tenses':
        return Icons.timelapse;
      case 'subject-verb agreement':
        return Icons.person;
      case 'articles':
      case 'determiners':
        return Icons.article;
      case 'prepositions':
        return Icons.compare_arrows;
      case 'vocabulary':
        return Icons.book;
      case 'pronouns':
        return Icons.person_outline;
      case 'verbs':
        return Icons.bolt;
      default:
        return Icons.help_outline;
    }
  }
}