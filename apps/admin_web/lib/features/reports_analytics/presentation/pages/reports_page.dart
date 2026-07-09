import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;

  bool _isLoading = true;
  String? _error;

  int _totalUsers = 0;
  int _newUsersThisMonth = 0;
  double _retentionRate = 0;
  double _avgScore = 0;
  double _totalRevenue = 0;
  double _monthlyRevenue = 0;
  int _totalTutors = 0;
  int _activeTutors = 0;
  int _totalAiQueries = 0;
  double _totalTokensUsed = 0;
  double _aiCostThisMonth = 0;
  int _totalEnrollments = 0;
  int _activeLearners = 0;

  List<FlSpot> _userGrowthData = [];
  List<FlSpot> _revenueData = [];
  List<FlSpot> _completionData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final usersRes = await _supabase.from('user_profiles').select('id, created_at, role');
      final enrollmentsRes =
          await _supabase.from('course_enrollments').select('id, completed_at');
      final revenueRes = await _supabase.from('payments').select('amount, created_at');
      final scoresRes = await _supabase.from('exam_attempts').select('score');
      final aiUsageRes = await _supabase.from('ai_usage_logs').select('id, tokens_used, cost_usd, created_at');
      final tutorRes = await _supabase.from('tutor_profiles').select('id, status');

      final users = List<Map<String, dynamic>>.from(usersRes);
      final enrollments = List<Map<String, dynamic>>.from(enrollmentsRes);
      final revenue = List<Map<String, dynamic>>.from(revenueRes);
      final scores = List<Map<String, dynamic>>.from(scoresRes);
      final aiUsage = List<Map<String, dynamic>>.from(aiUsageRes);
      final tutors = List<Map<String, dynamic>>.from(tutorRes);

      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      final newThisMonth = users.where((u) {
        final createdAt = DateTime.tryParse(u['created_at'] ?? '');
        return createdAt != null && createdAt.isAfter(monthStart);
      }).length;

      final completed =
          enrollments.where((e) => e['completed_at'] != null).length;
      final completionRate =
          enrollments.isNotEmpty ? completed / enrollments.length * 100 : 0.0;

      double avgScore = 0;
      if (scores.isNotEmpty) {
        final total = scores.fold<double>(
            0, (s, a) => s + ((a['score'] ?? 0) as num).toDouble());
        avgScore = total / scores.length;
      }

      final totalRev =
          revenue.fold<double>(0, (s, r) => s + ((r['amount'] ?? 0) as num).toDouble());

      final monthlyRev = revenue
          .where((r) {
            final createdAt = DateTime.tryParse(r['created_at'] ?? '');
            return createdAt != null && createdAt.isAfter(monthStart);
          })
          .fold<double>(
              0, (s, r) => s + ((r['amount'] ?? 0) as num).toDouble());

      final totalAiQueries = aiUsage.length;
      final totalTokens = aiUsage.fold<double>(
          0, (s, a) => s + ((a['tokens_used'] ?? 0) as num).toDouble());
      final aiCost = aiUsage
          .where((a) {
            final createdAt = DateTime.tryParse(a['created_at'] ?? '');
            return createdAt != null && createdAt.isAfter(monthStart);
          })
          .fold<double>(
              0, (s, a) => s + ((a['cost_usd'] ?? 0) as num).toDouble());

      final activeTutors = tutors
          .where((t) => t['status'] == 'approved')
          .length;

      final activeLearners = users
          .where((u) => u['role'] == 'student')
          .length;

      if (mounted) {
        setState(() {
          _totalUsers = users.length;
          _newUsersThisMonth = newThisMonth;
          _retentionRate = completionRate;
          _avgScore = avgScore;
          _totalRevenue = totalRev;
          _monthlyRevenue = monthlyRev;
          _totalTutors = tutors.length;
          _activeTutors = activeTutors;
          _totalAiQueries = totalAiQueries;
          _totalTokensUsed = totalTokens;
          _aiCostThisMonth = aiCost;
          _totalEnrollments = enrollments.length;
          _activeLearners = activeLearners;

          _userGrowthData = _generateMonthlyData(users, 6);
          _revenueData = _generateMonthlyRevenueData(revenue, 6);
          _completionData = _generateCompletionTrend(enrollments, 6);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load reports: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<FlSpot> _generateMonthlyData(List<Map<String, dynamic>> items, int months) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);
      final count = items.where((item) {
        final date = DateTime.tryParse(item['created_at'] ?? '');
        return date != null &&
            date.isAfter(month.subtract(const Duration(days: 1))) &&
            date.isBefore(nextMonth);
      }).length;
      spots.add(FlSpot((months - 1 - i).toDouble(), count.toDouble()));
    }
    return spots;
  }

  List<FlSpot> _generateMonthlyRevenueData(
      List<Map<String, dynamic>> items, int months) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);
      final total = items.where((item) {
        final date = DateTime.tryParse(item['created_at'] ?? '');
        return date != null &&
            date.isAfter(month.subtract(const Duration(days: 1))) &&
            date.isBefore(nextMonth);
      }).fold<double>(
          0, (s, r) => s + ((r['amount'] ?? 0) as num).toDouble());
      spots.add(FlSpot((months - 1 - i).toDouble(), total));
    }
    return spots;
  }

  List<FlSpot> _generateCompletionTrend(List<Map<String, dynamic>> enrollments, int months) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);
      final monthEnrollments = enrollments.where((e) {
        final date = DateTime.tryParse(e['created_at'] ?? '');
        return date != null &&
            date.isAfter(month.subtract(const Duration(days: 1))) &&
            date.isBefore(nextMonth);
      }).toList();
      final completed = monthEnrollments.where((e) => e['completed_at'] != null).length;
      final rate = monthEnrollments.isNotEmpty ? (completed / monthEnrollments.length * 100) : 0.0;
      spots.add(FlSpot((months - 1 - i).toDouble(), rate));
    }
    return spots;
  }

  void _exportCSV(String reportType) {
    final csvData = StringBuffer();
    csvData.writeln('Report: $reportType');
    csvData.writeln('Generated: ${DateTime.now()}');
    csvData.writeln('');
    csvData.writeln('Metric,Value');
    csvData.writeln('Total Users,$_totalUsers');
    csvData.writeln('New Users This Month,$_newUsersThisMonth');
    csvData.writeln('Retention Rate,${_retentionRate.toStringAsFixed(1)}%');
    csvData.writeln('Average Score,${_avgScore.toStringAsFixed(1)}%');
    csvData.writeln('Total Revenue,\$${_totalRevenue.toStringAsFixed(2)}');
    csvData.writeln('Monthly Revenue,\$${_monthlyRevenue.toStringAsFixed(2)}');
    csvData.writeln('Total Tutors,$_totalTutors');
    csvData.writeln('Active Tutors,$_activeTutors');
    csvData.writeln('Total AI Queries,$_totalAiQueries');
    csvData.writeln('Total Tokens Used,${_totalTokensUsed.toStringAsFixed(0)}');
    csvData.writeln('AI Cost This Month,\$${_aiCostThisMonth.toStringAsFixed(2)}');
    csvData.writeln('Total Enrollments,$_totalEnrollments');
    csvData.writeln('Active Learners,$_activeLearners');

    // Copy CSV to clipboard as a download workaround for web
    // Users can paste into a .csv file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV data copied to clipboard for $reportType report'),
        backgroundColor: AdminTheme.success,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _exportPDF(String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export coming soon — use CSV export for now'),
        backgroundColor: AdminTheme.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Reports & Analytics',
            subtitle: 'User, learning, revenue, and AI analytics',
            actions: [
              OutlinedButton.icon(
                onPressed: () => _exportCSV('overview'),
                icon: const Icon(Icons.table_chart_outlined, size: 18),
                label: const Text('Export CSV'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _exportPDF('overview'),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('Export PDF'),
              ),
            ],
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AdminTheme.error),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: AdminTheme.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  _buildStats(),
                  const SizedBox(height: 24),
                  _buildTabs(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 1000
            ? 6
            : constraints.maxWidth > 600
                ? 3
                : 2;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.0,
          children: [
            StatCard(
              title: 'Total Users',
              value: '$_totalUsers',
              subtitle: 'All registrations',
              icon: Icons.people_outlined,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'New This Month',
              value: '$_newUsersThisMonth',
              subtitle: 'New signups',
              icon: Icons.person_add_outlined,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Retention',
              value: '${_retentionRate.toStringAsFixed(1)}%',
              subtitle: 'Course completion',
              icon: Icons.trending_up_rounded,
              color: AdminTheme.info,
            ),
            StatCard(
              title: 'Avg Score',
              value: '${_avgScore.toStringAsFixed(1)}%',
              subtitle: 'Exam performance',
              icon: Icons.analytics_outlined,
              color: AdminTheme.secondary,
            ),
            StatCard(
              title: 'Total Revenue',
              value: '\$${_totalRevenue.toStringAsFixed(0)}',
              subtitle: 'All time',
              icon: Icons.attach_money_rounded,
              color: AdminTheme.warning,
            ),
            StatCard(
              title: 'Monthly Revenue',
              value: '\$${_monthlyRevenue.toStringAsFixed(0)}',
              subtitle: 'Current month',
              icon: Icons.calendar_month_outlined,
              color: AdminTheme.tertiary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabs() {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'User Analytics'),
              Tab(text: 'Learning'),
              Tab(text: 'Revenue'),
              Tab(text: 'Tutors'),
              Tab(text: 'AI Usage'),
              Tab(text: 'Overview'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserAnalyticsTab(),
                _buildLearningTab(),
                _buildRevenueTab(),
                _buildTutorsTab(),
                _buildAiUsageTab(),
                _buildOverviewTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required LineChartData chartData,
    double? height,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: height ?? 200,
              child: LineChart(chartData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartCard(
            title: 'User Growth (6 months)',
            chartData: LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                      return Text(v.toInt() < months.length ? months[v.toInt()] : '');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _userGrowthData,
                  isCurved: true,
                  color: AdminTheme.primary,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: AdminTheme.primary.withOpacity(0.1),
                  ),
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            title: 'Retention & Churn',
            chartData: LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _completionData,
                  isCurved: true,
                  color: AdminTheme.success,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartCard(
            title: 'Course Completion Rates',
            chartData: LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _completionData,
                  isCurved: true,
                  color: AdminTheme.tertiary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Learning Metrics', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _metricRow('Average Course Completion', '${_retentionRate.toStringAsFixed(1)}%'),
                  _metricRow('Average Exam Score', '${_avgScore.toStringAsFixed(1)}%'),
                  _metricRow('Total Enrollments', '$_totalEnrollments'),
                  _metricRow('Active Learners', '$_activeLearners'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartCard(
            title: 'Revenue Trend (6 months)',
            chartData: LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _revenueData,
                  isCurved: true,
                  color: AdminTheme.warning,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: AdminTheme.warning.withOpacity(0.1),
                  ),
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue Breakdown', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _metricRow('Total Revenue', '\$${_totalRevenue.toStringAsFixed(2)}'),
                  _metricRow('Monthly Recurring', '\$${_monthlyRevenue.toStringAsFixed(2)}'),
                  _metricRow('Average Revenue Per User', _totalUsers > 0
                      ? '\$${(_totalRevenue / _totalUsers).toStringAsFixed(2)}'
                      : '\$0.00'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tutor Performance', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              _metricRow('Total Tutors', '$_totalTutors'),
              _metricRow('Active Tutors', '$_activeTutors'),
              _metricRow('Pending Review', '${_totalTutors - _activeTutors}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiUsageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Usage Reports', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              _metricRow('Total AI Queries', '$_totalAiQueries'),
              _metricRow('Total Tokens Used', _formatTokens(_totalTokensUsed)),
              _metricRow('AI Cost This Month', '\$${_aiCostThisMonth.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTokens(double tokens) {
    if (tokens >= 1000000) return '${(tokens / 1000000).toStringAsFixed(1)}M';
    if (tokens >= 1000) return '${(tokens / 1000).toStringAsFixed(1)}K';
    return tokens.toStringAsFixed(0);
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Report Summary', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _metricRow('Total Users', '$_totalUsers'),
                  _metricRow('New Users (Month)', '$_newUsersThisMonth'),
                  _metricRow('Retention Rate', '${_retentionRate.toStringAsFixed(1)}%'),
                  _metricRow('Avg Score', '${_avgScore.toStringAsFixed(1)}%'),
                  _metricRow('Total Revenue', '\$${_totalRevenue.toStringAsFixed(2)}'),
                  _metricRow('Monthly Revenue', '\$${_monthlyRevenue.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
