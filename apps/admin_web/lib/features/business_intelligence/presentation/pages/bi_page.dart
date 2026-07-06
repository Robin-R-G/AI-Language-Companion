import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';

class BIPage extends StatefulWidget {
  const BIPage({super.key});

  @override
  State<BIPage> createState() => _BIPageState();
}

class _BIPageState extends State<BIPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _error;

  double _businessHealthScore = 72.5;
  double _revenueGrowth = 15.3;
  double _profitGrowth = 8.7;
  double _subscriptionGrowth = 22.1;
  double _retentionRate = 85.0;
  double _conversionRate = 12.5;
  double _aiCostEfficiency = 0.78;
  double _clv = 156.0;
  double _arpu = 18.5;

  List<FlSpot> _revenueForecast = [];
  List<FlSpot> _expenseForecast = [];
  List<FlSpot> _cashFlowForecast = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final revenueRes = await _supabase.from('payments').select('amount, created_at');
      final usersRes = await _supabase.from('user_profiles').select('id, created_at');
      final subsRes = await _supabase.from('subscriptions').select('id, status');

      final revenue = List<Map<String, dynamic>>.from(revenueRes);
      final users = List<Map<String, dynamic>>.from(usersRes);

      final totalRev =
          revenue.fold<double>(0, (s, r) => s + ((r['amount'] ?? 0) as num).toDouble());
      final activeSubs = subsRes.where((s) => s['status'] == 'active').length;
      final totalUsers = users.length;

      if (mounted) {
        setState(() {
          _arpu = totalUsers > 0 ? totalRev / totalUsers : 0;
          _clv = _arpu * 12 * (_retentionRate / 100);
          _businessHealthScore = (((_retentionRate / 100) * 30) +
                  ((_conversionRate / 100) * 30) +
                  (_aiCostEfficiency * 40))
              .clamp(0, 100);

          _revenueForecast = _generateForecast(8, totalRev / 6, 1.12);
          _expenseForecast = _generateForecast(8, totalRev * 0.6 / 6, 1.05);
          _cashFlowForecast = _generateCashFlow(_revenueForecast, _expenseForecast);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load BI data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<FlSpot> _generateForecast(int months, double startValue, double growthRate) {
    final spots = <FlSpot>[];
    double value = startValue;
    for (int i = 0; i < months; i++) {
      spots.add(FlSpot(i.toDouble(), value));
      value *= growthRate;
    }
    return spots;
  }

  List<FlSpot> _generateCashFlow(
      List<FlSpot> revenue, List<FlSpot> expenses) {
    return List.generate(
      revenue.length,
      (i) => FlSpot(i.toDouble(), revenue[i].y - expenses[i].y),
    );
  }

  Color _healthColor(double score) {
    if (score >= 75) return AdminTheme.success;
    if (score >= 50) return AdminTheme.warning;
    return AdminTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Business Intelligence',
            subtitle: 'Comprehensive business analytics and forecasting',
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopSection(),
                    const SizedBox(height: 24),
                    _buildGrowthCharts(),
                    const SizedBox(height: 24),
                    _buildPerformanceSection(),
                    const SizedBox(height: 24),
                    _buildFinancialSection(),
                    const SizedBox(height: 24),
                    _buildForecastSection(),
                    const SizedBox(height: 24),
                    _buildMetricsSection(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.0,
          children: [
            _healthScoreCard(),
            StatCard(
              title: 'Revenue Growth',
              value: '${_revenueGrowth.toStringAsFixed(1)}%',
              subtitle: 'Month over month',
              icon: Icons.trending_up_rounded,
              color: AdminTheme.success,
              trend: _revenueGrowth,
            ),
            StatCard(
              title: 'Profit Growth',
              value: '${_profitGrowth.toStringAsFixed(1)}%',
              subtitle: 'Month over month',
              icon: Icons.savings_outlined,
              color: AdminTheme.info,
              trend: _profitGrowth,
            ),
            StatCard(
              title: 'Subscription Growth',
              value: '${_subscriptionGrowth.toStringAsFixed(1)}%',
              subtitle: 'New subscribers',
              icon: Icons.card_membership_outlined,
              color: AdminTheme.secondary,
              trend: _subscriptionGrowth,
            ),
          ],
        );
      },
    );
  }

  Widget _healthScoreCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Business Health',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: _businessHealthScore / 100,
                          strokeWidth: 10,
                          backgroundColor: AdminTheme.lightBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _healthColor(_businessHealthScore),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_businessHealthScore.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            _businessHealthScore >= 75
                                ? 'Healthy'
                                : _businessHealthScore >= 50
                                    ? 'Moderate'
                                    : 'At Risk',
                            style: TextStyle(
                              fontSize: 11,
                              color: _healthColor(_businessHealthScore),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthCharts() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return isWide
            ? Row(
                children: [
                  Expanded(child: _revenueChart()),
                  const SizedBox(width: 16),
                  Expanded(child: _retentionChart()),
                ],
              )
            : Column(
                children: [
                  _revenueChart(),
                  const SizedBox(height: 16),
                  _retentionChart(),
                ],
              );
      },
    );
  }

  Widget _revenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue Growth', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _revenueForecast,
                      isCurved: true,
                      color: AdminTheme.success,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AdminTheme.success.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _retentionChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Retention & Conversion Funnel',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const labels = ['Visit', 'Signup', 'Trial', 'Paid', 'Retain'];
                          return v.toInt() < labels.length
                              ? Text(labels[v.toInt()], style: const TextStyle(fontSize: 10))
                              : const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: [
                    _barGroup(0, 100, AdminTheme.primary),
                    _barGroup(1, 65, AdminTheme.info),
                    _barGroup(2, 35, AdminTheme.secondary),
                    _barGroup(3, _conversionRate, AdminTheme.warning),
                    _barGroup(4, _retentionRate, AdminTheme.success),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 32,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildPerformanceSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return isWide
            ? Row(
                children: [
                  Expanded(child: _tutorPerformanceCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _aiCostCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _featureProfitabilityCard()),
                ],
              )
            : Column(
                children: [
                  _tutorPerformanceCard(),
                  const SizedBox(height: 16),
                  _aiCostCard(),
                  const SizedBox(height: 16),
                  _featureProfitabilityCard(),
                ],
              );
      },
    );
  }

  Widget _tutorPerformanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tutor Performance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _perfMetric('Avg Sessions/Week', '12.4'),
            _perfMetric('Student Rating', '4.7/5.0'),
            _perfMetric('Completion Rate', '89%'),
            _perfMetric('Revenue Generated', '\$12,400'),
          ],
        ),
      ),
    );
  }

  Widget _aiCostCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Cost Efficiency', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _perfMetric('Cost per Query', '\$0.008'),
            _perfMetric('Monthly AI Cost', '\$342'),
            _perfMetric('Revenue per AI \$', '\$8.20'),
            _perfMetric('Efficiency Score', '${(_aiCostEfficiency * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }

  Widget _featureProfitabilityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feature Profitability', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _perfMetric('Most Profitable', 'Premium Courses'),
            _perfMetric('Revenue', '\$8,200'),
            _perfMetric('Least Profitable', 'Free Tier'),
            _perfMetric('Revenue', '\$0'),
          ],
        ),
      ),
    );
  }

  Widget _perfMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFinancialSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Break-even Analysis', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                _financialMetric('Monthly Costs', '\$4,200'),
                const SizedBox(width: 32),
                _financialMetric('Monthly Revenue', '\$8,400'),
                const SizedBox(width: 32),
                _financialMetric('Break-even Point', '2 months'),
                const SizedBox(width: 32),
                _financialMetric('Profit Margin', '50%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _financialMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildForecastSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue / Expense / Cash Flow Forecast',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _revenueForecast,
                      isCurved: true,
                      color: AdminTheme.success,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _expenseForecast,
                      isCurved: true,
                      color: AdminTheme.error,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _cashFlowForecast,
                      isCurved: true,
                      color: AdminTheme.info,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(AdminTheme.success, 'Revenue'),
                const SizedBox(width: 16),
                _legendDot(AdminTheme.error, 'Expenses'),
                const SizedBox(width: 16),
                _legendDot(AdminTheme.info, 'Cash Flow'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMetricsSection() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Customer Lifetime Value',
            value: '\$${_clv.toStringAsFixed(0)}',
            subtitle: 'Per customer',
            icon: Icons.person_outline,
            color: AdminTheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Avg Revenue Per User',
            value: '\$${_arpu.toStringAsFixed(2)}',
            subtitle: 'Monthly',
            icon: Icons.attach_money,
            color: AdminTheme.tertiary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Conversion Rate',
            value: '${_conversionRate.toStringAsFixed(1)}%',
            subtitle: 'Trial to paid',
            icon: Icons.swap_horiz_rounded,
            color: AdminTheme.warning,
          ),
        ),
      ],
    );
  }
}
