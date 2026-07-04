import 'package:flutter/material.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Grammar screen showing error log, corrections, and practice.
class GrammarPage extends StatefulWidget {
  const GrammarPage({super.key});

  @override
  State<GrammarPage> createState() => _GrammarPageState();
}

class _GrammarPageState extends State<GrammarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _hasError = false;

  // Mock grammar errors
  final List<Map<String, dynamic>> _grammarErrors = [
    {
      'original': 'Yesterday I go to school.',
      'corrected': 'Yesterday I went to school.',
      'rule': 'Past Simple Tense',
      'explanation':
          'Use "went" (past tense of "go") for actions completed in the past.',
      'malayalam':
          'കഴിഞ്ഞുപോയ കാര്യങ്ങൾ പറയാൻ "went" എന്ന ഭൂതകാല രൂപമാണ് ഉപയോഗിക്കേണ്ടത്.',
      'date': 'Today',
      'count': 5,
    },
    {
      'original': 'She don\'t like coffee.',
      'corrected': 'She doesn\'t like coffee.',
      'rule': 'Subject-Verb Agreement',
      'explanation':
          'Third person singular subjects (she, he, it) use "doesn\'t" instead of "don\'t".',
      'malayalam':
          'She, he, it എന്നിവയ്ക്ക് "doesn\'t" ഉപയോഗിക്കണം, "don\'t" അല്ല.',
      'date': 'Yesterday',
      'count': 3,
    },
    {
      'original': 'I have been to Paris last year.',
      'corrected': 'I went to Paris last year.',
      'rule': 'Present Perfect vs Past Simple',
      'explanation':
          'Use past simple with specific time expressions like "last year".',
      'malayalam':
          '"last year" പോലുള്ള നിശ്ചിത സമയ സൂചനകൾ ഉപയോഗിക്കുമ്പോൾ past simple ഉപയോഗിക്കണം.',
      'date': '2 days ago',
      'count': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    if (_hasError) {
      return ErrorView(onRetry: _loadData);
    }

    if (_isLoading) {
      return _buildLoading(theme);
    }

    return TabBarView(
      controller: _tabController,
      children: [_buildErrorLog(theme), _buildPracticeTab(theme)],
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 5,
      itemBuilder: (context, index) => const ShimmerCard(),
    );
  }

  Widget _buildErrorLog(ThemeData theme) {
    if (_grammarErrors.isEmpty) {
      return EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No Grammar Errors',
        message: 'Great job! You haven\'t made any grammar mistakes recently.',
        actionLabel: 'Start Practicing',
        onAction: () {
          _tabController.animateTo(1);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.base),
        itemCount: _grammarErrors.length,
        itemBuilder: (context, index) {
          final error = _grammarErrors[index];
          return _GrammarErrorCard(error: error);
        },
      ),
    );
  }

  Widget _buildPracticeTab(ThemeData theme) {
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
              AppButton(
                label: 'Start Practice',
                onPressed: () {},
                icon: Icons.play_arrow_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Common Rules',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _RuleTile(
          icon: Icons.timelapse,
          title: 'Tenses',
          subtitle: 'Past, Present, Future',
          count: 12,
        ),
        _RuleTile(
          icon: Icons.person,
          title: 'Subject-Verb Agreement',
          subtitle: 'Singular and Plural subjects',
          count: 8,
        ),
        _RuleTile(
          icon: Icons.article,
          title: 'Articles & Determiners',
          subtitle: 'a, an, the usage',
          count: 6,
        ),
        _RuleTile(
          icon: Icons.compare_arrows,
          title: 'Prepositions',
          subtitle: 'in, on, at, by',
          count: 10,
        ),
      ],
    );
  }
}

class _GrammarErrorCard extends StatelessWidget {
  final Map<String, dynamic> error;

  const _GrammarErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: AppSpacing.sm),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error['rule'] as String,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: error['original'] as String,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.error,
                      color: AppColors.error,
                    ),
                  ),
                  const TextSpan(text: '  →  '),
                  TextSpan(
                    text: error['corrected'] as String,
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
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
              borderRadius: AppRadius.smAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explanation',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  error['explanation'] as String,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Malayalam',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  error['malayalam'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${error['date']} • ${error['count']} occurrences',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;

  const _RuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
  });

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
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.roundAll,
          ),
          child: Text('$count', style: theme.textTheme.labelSmall),
        ),
        onTap: () {},
      ),
    );
  }
}
