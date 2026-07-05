import 'package:flutter/material.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/progress_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/stat_row.dart';

/// Progress/Analytics screen with charts and statistics.
class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  bool _isLoading = false;
  bool _hasError = false;
  String _selectedPeriod = 'Week';

  final List<String> _periods = ['Week', 'Month', '3 Months', 'Year'];

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
        title: const Text('Progress'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => _periods
                .map((p) => PopupMenuItem(value: p, child: Text(p)))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod, style: theme.textTheme.bodyMedium),
                  const Icon(Icons.arrow_drop_down),
                ],
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
    if (_isLoading) return _buildLoading();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: [
          // Exam Score Predictor
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withAlpha(25),
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '7.0',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              'IELTS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Projected Exam Score',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Based on your recent performance',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(25),
                              borderRadius: AppRadius.smAll,
                            ),
                            child: Text(
                              '+0.5 from last month',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Stats Row
          const StatRow(
            stats: [
              StatItem(
                icon: Icons.access_time,
                value: '12.5h',
                label: 'Study Time',
                color: AppColors.info,
              ),
              StatItem(
                icon: Icons.local_fire_department,
                value: '14',
                label: 'Day Streak',
                color: AppColors.warning,
              ),
              StatItem(
                icon: Icons.star,
                value: '2,450',
                label: 'XP Earned',
                color: AppColors.primary500,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),

          // Weekly Activity
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                SizedBox(height: 200, child: _WeeklyChart()),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Score Breakdown
          Text(
            'Score Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const ProgressCard(
            label: 'Speaking',
            value: '7.5',
            icon: Icons.mic,
            progress: 0.75,
            trend: '+0.3',
          ),
          const SizedBox(height: AppSpacing.sm),
          const ProgressCard(
            label: 'Grammar',
            value: '6.8',
            icon: Icons.auto_fix_high,
            progress: 0.68,
            trend: '+0.5',
          ),
          const SizedBox(height: AppSpacing.sm),
          const ProgressCard(
            label: 'Vocabulary',
            value: '1,240',
            subtitle: 'words learned',
            icon: Icons.menu_book,
            progress: 0.62,
            trend: '+120',
          ),
          const SizedBox(height: AppSpacing.sm),
          const ProgressCard(
            label: 'Listening',
            value: '7.0',
            icon: Icons.hearing,
            progress: 0.70,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerCard(),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = [0.6, 0.8, 0.4, 0.9, 0.7, 0.3, 0.5];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: values[index],
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: index == 3
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withAlpha(77),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  days[index],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
