import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/data_table_widget.dart';
import '../widgets/ai_cost_chart.dart';

class AiCostPage extends StatefulWidget {
  const AiCostPage({super.key});

  @override
  State<AiCostPage> createState() => _AiCostPageState();
}

class _AiCostPageState extends State<AiCostPage> {
  final _supabase = Supabase.instance.client;
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _numberFormat = NumberFormat.compact();
  bool _isLoading = true;

  double _costToday = 0;
  double _costMonth = 0;
  double _forecastedBill = 0;
  double _estimatedProfit = 0;
  double _revenueMonth = 0;
  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _failedRequests = 0;

  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _costByProvider = [];
  List<Map<String, dynamic>> _costByUser = [];
  List<Map<String, dynamic>> _costByFeature = [];
  List<Map<String, dynamic>> _costByCountry = [];
  List<Map<String, dynamic>> _costBySubscription = [];

  @override
  void initState() {
    super.initState();
    _loadAiCostData();
  }

  Future<void> _loadAiCostData() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      final logsRes = await _supabase
          .from('ai_usage_logs')
          .select('*')
          .order('created_at', ascending: false)
          .limit(500);
      final logs = List<Map<String, dynamic>>.from(logsRes);
      _requests = logs;

      for (final log in logs) {
        final cost = (log['cost'] as num?)?.toDouble() ?? 0;
        final createdAt = DateTime.tryParse(log['created_at'] ?? '') ?? DateTime.now();
        final status = log['status'] ?? 'success';

        if (createdAt.isAfter(todayStart)) _costToday += cost;
        if (createdAt.isAfter(monthStart)) _costMonth += cost;
        _totalRequests++;
        if (status == 'success' || status == 'completed') {
          _successfulRequests++;
        } else {
          _failedRequests++;
        }
      }

      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final daysPassed = now.day;
      _forecastedBill = daysPassed > 0 ? (_costMonth / daysPassed) * daysInMonth : 0;

      final revRes = await _supabase
          .from('payments')
          .select('amount')
          .eq('status', 'completed')
          .gte('created_at', monthStart.toIso8601String());
      final payments = List<Map<String, dynamic>>.from(revRes);
      _revenueMonth = payments.fold(0, (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0));
      _estimatedProfit = _revenueMonth - _costMonth;

      final providerMap = <String, double>{};
      final featureMap = <String, double>{};
      for (final log in logs) {
        final cost = (log['cost'] as num?)?.toDouble() ?? 0;
        final provider = log['provider'] ?? 'unknown';
        final feature = log['feature'] ?? 'chat';
        providerMap[provider] = (providerMap[provider] ?? 0) + cost;
        featureMap[feature] = (featureMap[feature] ?? 0) + cost;
      }
      _costByProvider = providerMap.entries
          .map((e) => {'name': e.key, 'value': e.value})
          .toList()
        ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
      _costByFeature = featureMap.entries
          .map((e) => {'name': e.key, 'value': e.value})
          .toList()
        ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

      final userMap = <String, double>{};
      for (final log in logs) {
        final cost = (log['cost'] as num?)?.toDouble() ?? 0;
        final userId = log['user_id'] ?? 'unknown';
        userMap[userId] = (userMap[userId] ?? 0) + cost;
      }
      _costByUser = userMap.entries
          .map((e) => {'name': e.key, 'value': e.value})
          .toList()
        ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
      _costByUser = _costByUser.take(10).toList();

      final countryMap = <String, double>{};
      for (final log in logs) {
        final cost = (log['cost'] as num?)?.toDouble() ?? 0;
        final country = log['country'] ?? 'Unknown';
        countryMap[country] = (countryMap[country] ?? 0) + cost;
      }
      _costByCountry = countryMap.entries
          .map((e) => {'name': e.key, 'value': e.value})
          .toList()
        ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

      final subMap = <String, double>{};
      for (final log in logs) {
        final cost = (log['cost'] as num?)?.toDouble() ?? 0;
        final sub = log['subscription_tier'] ?? 'free';
        subMap[sub] = (subMap[sub] ?? 0) + cost;
      }
      _costBySubscription = subMap.entries
          .map((e) => {'name': e.key, 'value': e.value})
          .toList()
        ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'AI Cost Monitor',
          subtitle: 'Track AI provider costs, usage patterns, and profitability',
          trailing: IconButton(
            onPressed: _loadAiCostData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          _buildStatsCards(isDesktop),
          const SizedBox(height: 24),
          _buildRequestsTable(),
          const SizedBox(height: 24),
          _buildChartsSection(isDesktop),
          const SizedBox(height: 24),
          _buildCostBySubscription(),
        ],
      ],
    );
  }

  Widget _buildStatsCards(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isDesktop ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isDesktop ? 1.8 : 1.6,
          children: [
            StatCard(
              title: 'AI Cost Today',
              value: _currencyFormat.format(_costToday),
              subtitle: 'Today\'s expenses',
              icon: Icons.today_rounded,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'AI Cost This Month',
              value: _currencyFormat.format(_costMonth),
              subtitle: 'Monthly expenses',
              icon: Icons.calendar_month_rounded,
              color: AdminTheme.secondary,
            ),
            StatCard(
              title: 'Forecasted Monthly',
              value: _currencyFormat.format(_forecastedBill),
              subtitle: 'Projected total',
              icon: Icons.show_chart_rounded,
              color: AdminTheme.warning,
            ),
            StatCard(
              title: 'Estimated Profit',
              value: _currencyFormat.format(_estimatedProfit),
              subtitle: 'Revenue minus AI costs',
              icon: Icons.savings_rounded,
              color: _estimatedProfit >= 0 ? AdminTheme.success : AdminTheme.error,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestsTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI Requests (${_numberFormat.format(_totalRequests)} total)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    StatusBadge(
                      label: 'Success: ${_successfulRequests}',
                      type: BadgeType.success,
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: 'Failed: $_failedRequests',
                      type: BadgeType.error,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdminDataTable(
              columns: ['Provider', 'Model', 'Tokens', 'Cost', 'Latency', 'Status', 'Date'],
              rows: _requests.take(50).map((req) {
                final status = req['status'] ?? 'success';
                final badgeType = switch (status) {
                  'success' || 'completed' => BadgeType.success,
                  'error' || 'failed' => BadgeType.error,
                  'timeout' => BadgeType.warning,
                  _ => BadgeType.neutral,
                };
                final tokens = ((req['input_tokens'] as num?)?.toInt() ?? 0) +
                    ((req['output_tokens'] as num?)?.toInt() ?? 0);
                final latency = (req['latency_ms'] as num?)?.toInt() ?? 0;

                return [
                  StatusBadge(label: req['provider'] ?? 'N/A', type: BadgeType.info),
                  Text(req['model'] ?? 'N/A'),
                  Text(_numberFormat.format(tokens)),
                  Text(_currencyFormat.format((req['cost'] as num?)?.toDouble() ?? 0)),
                  Text('${latency}ms'),
                  StatusBadge(label: status, type: badgeType),
                  Text(
                    DateFormat('MMM d HH:mm').format(
                      DateTime.tryParse(req['created_at'] ?? '') ?? DateTime.now(),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isDesktop ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isDesktop ? 1.2 : 1.0,
          children: [
            AiCostChart(
              title: 'Cost by Provider',
              data: _costByProvider,
              currencyFormat: _currencyFormat,
            ),
            AiCostChart(
              title: 'Cost by Feature',
              data: _costByFeature,
              currencyFormat: _currencyFormat,
            ),
            AiCostChart(
              title: 'Cost by Country',
              data: _costByCountry.take(8).toList(),
              currencyFormat: _currencyFormat,
            ),
            AiCostChart(
              title: 'Top Users by Cost',
              data: _costByUser.take(8).toList(),
              currencyFormat: _currencyFormat,
              showBar: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCostBySubscription() {
    if (_costBySubscription.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost by Subscription Tier',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _costBySubscription
                          .map((e) => (e['value'] as num?)?.toDouble() ?? 0)
                          .fold<double>(0, (a, b) => a > b ? a : b) *
                      1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          _currencyFormat.format(rod.toY),
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _costBySubscription.length) {
                            final name = _costBySubscription[value.toInt()]['name'] ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                name.toUpperCase(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _numberFormat.format(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: _costBySubscription.asMap().entries.map((entry) {
                    final colors = [
                      AdminTheme.primary,
                      AdminTheme.secondary,
                      AdminTheme.tertiary,
                      AdminTheme.warning,
                      AdminTheme.error,
                    ];
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: (entry.value['value'] as num?)?.toDouble() ?? 0,
                          color: colors[entry.key % colors.length],
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
