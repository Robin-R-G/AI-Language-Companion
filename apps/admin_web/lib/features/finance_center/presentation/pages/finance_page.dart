import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/data_table_widget.dart';
import '../widgets/revenue_breakdown_chart.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  final _supabase = Supabase.instance.client;
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _numberFormat = NumberFormat.compact();
  String _selectedPeriod = 'Month';
  bool _isLoading = true;

  double _revenueToday = 0;
  double _revenueWeek = 0;
  double _revenueMonth = 0;
  double _revenueYear = 0;
  double _revenueLifetime = 0;
  double _aiCosts = 0;
  double _infraCosts = 0;
  double _paymentFees = 0;
  double _taxes = 0;
  double _refunds = 0;
  double _tutorPayouts = 0;
  double _platformCommission = 0;

  List<Map<String, dynamic>> _revenueByCountry = [];
  List<Map<String, dynamic>> _revenueByPlan = [];
  List<Map<String, dynamic>> _revenueByPlatform = [];
  List<Map<String, dynamic>> _revenueBySource = [];
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadFinanceData();
  }

  Future<void> _loadFinanceData() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);
      final yearStart = DateTime(now.year, 1, 1);

      final paymentsRes = await _supabase
          .from('payments')
          .select('amount, currency, country, plan_id, platform, source, status, created_at')
          .eq('status', 'completed');

      final payments = List<Map<String, dynamic>>.from(paymentsRes);

      for (final p in payments) {
        final amount = (p['amount'] as num?)?.toDouble() ?? 0;
        final createdAt = DateTime.tryParse(p['created_at'] ?? '') ?? DateTime.now();

        if (createdAt.isAfter(todayStart)) _revenueToday += amount;
        if (createdAt.isAfter(weekStart)) _revenueWeek += amount;
        if (createdAt.isAfter(monthStart)) _revenueMonth += amount;
        if (createdAt.isAfter(yearStart)) _revenueYear += amount;
        _revenueLifetime += amount;
      }

      final countryMap = <String, double>{};
      final platformMap = <String, double>{};
      final sourceMap = <String, double>{};
      for (final p in payments) {
        final amount = (p['amount'] as num?)?.toDouble() ?? 0;
        final country = p['country'] ?? 'Unknown';
        final platform = p['platform'] ?? 'Unknown';
        final source = p['source'] ?? 'subscriptions';
        countryMap[country] = (countryMap[country] ?? 0) + amount;
        platformMap[platform] = (platformMap[platform] ?? 0) + amount;
        sourceMap[source] = (sourceMap[source] ?? 0) + amount;
      }
      _revenueByCountry = countryMap.entries
          .map((e) => {'name': e.key, 'value': e.value})
          .toList()
        ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
      _revenueByPlatform = platformMap.entries
          .map((e) => {'name': e.key, 'value': e.value})
          .toList()
        ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
      _revenueBySource = sourceMap.entries
          .map((e) => {'name': e.key, 'value': e.value})
          .toList()
        ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

      final aiCostRes = await _supabase
          .from('ai_usage_logs')
          .select('cost')
          .gte('created_at', monthStart.toIso8601String());
      final aiCosts = List<Map<String, dynamic>>.from(aiCostRes);
      _aiCosts = aiCosts.fold(0, (sum, e) => sum + ((e['cost'] as num?)?.toDouble() ?? 0));

      final costRes = await _supabase.from('platform_costs').select('*');
      final costs = List<Map<String, dynamic>>.from(costRes);
      for (final c in costs) {
        final amount = (c['amount'] as num?)?.toDouble() ?? 0;
        final type = c['type'] ?? '';
        switch (type) {
          case 'infrastructure':
            _infraCosts += amount;
            break;
          case 'payment_gateway':
            _paymentFees += amount;
            break;
          case 'tax':
            _taxes += amount;
            break;
        }
      }

      final refundRes = await _supabase
          .from('payments')
          .select('amount')
          .eq('status', 'refunded');
      final refunds = List<Map<String, dynamic>>.from(refundRes);
      _refunds = refunds.fold(0, (sum, e) => sum + ((e['amount'] as num?)?.toDouble() ?? 0));

      final payoutRes = await _supabase
          .from('tutor_payouts')
          .select('amount')
          .eq('status', 'completed')
          .gte('created_at', monthStart.toIso8601String());
      final payouts = List<Map<String, dynamic>>.from(payoutRes);
      _tutorPayouts = payouts.fold(0, (sum, e) => sum + ((e['amount'] as num?)?.toDouble() ?? 0));

      _platformCommission = _revenueMonth * 0.15;

      final txRes = await _supabase
          .from('payments')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);
      _recentTransactions = List<Map<String, dynamic>>.from(txRes);

      final plansRes = await _supabase.from('subscription_plans').select('*');
      final plans = List<Map<String, dynamic>>.from(plansRes);
      final planMap = <String, double>{};
      for (final p in payments) {
        final planId = p['plan_id'] ?? 'unknown';
        final matchingPlan = plans.where((pl) => pl['id'] == planId).firstOrNull;
        final planName = matchingPlan?['name'] ?? planId;
        final amount = (p['amount'] as num?)?.toDouble() ?? 0;
        planMap[planName] = (planMap[planName] ?? 0) + amount;
      }
      _revenueByPlan = planMap.entries
          .map((e) => {'name': e.key, 'value': e.value})
          .toList()
        ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _grossProfit => _revenueMonth - _refunds;
  double get _netProfit => _grossProfit - _aiCosts - _infraCosts - _paymentFees - _taxes - _tutorPayouts;
  double get _cashFlow => _revenueMonth - _tutorPayouts - _paymentFees;
  double get _profitMargin => _revenueMonth > 0 ? (_netProfit / _revenueMonth) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Finance Center',
          subtitle: 'Comprehensive financial overview and analytics',
          trailing: Row(
            children: [
              _buildPeriodSelector(),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _loadFinanceData,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
              ),
            ],
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
          _buildRevenueCards(isDesktop),
          const SizedBox(height: 24),
          _buildRevenueBreakdownSection(isDesktop),
          const SizedBox(height: 24),
          _buildCostsSection(isDesktop),
          const SizedBox(height: 24),
          _buildProfitSection(isDesktop),
          const SizedBox(height: 24),
          _buildTransactionsSection(),
        ],
      ],
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Today', 'Week', 'Month', 'Year', 'Lifetime'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: periods.map((p) {
          final isSelected = _selectedPeriod == p;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ChoiceChip(
              label: Text(p, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedPeriod = p),
              selectedColor: AdminTheme.primary.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? AdminTheme.primary : Theme.of(context).colorScheme.onBackground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRevenueCards(bool isDesktop) {
    final currentRevenue = switch (_selectedPeriod) {
      'Today' => _revenueToday,
      'Week' => _revenueWeek,
      'Month' => _revenueMonth,
      'Year' => _revenueYear,
      _ => _revenueLifetime,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isDesktop ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isDesktop ? 1.6 : 1.4,
          children: [
            StatCard(
              title: 'Revenue Today',
              value: _currencyFormat.format(_revenueToday),
              subtitle: 'Daily revenue',
              icon: Icons.today_rounded,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'Revenue Week',
              value: _currencyFormat.format(_revenueWeek),
              subtitle: 'Weekly revenue',
              icon: Icons.date_range_rounded,
              color: AdminTheme.secondary,
            ),
            StatCard(
              title: 'Revenue Month',
              value: _currencyFormat.format(_revenueMonth),
              subtitle: 'Monthly revenue',
              icon: Icons.calendar_month_rounded,
              color: AdminTheme.tertiary,
            ),
            StatCard(
              title: 'Revenue Year',
              value: _currencyFormat.format(_revenueYear),
              subtitle: 'Yearly revenue',
              icon: Icons.show_chart_rounded,
              color: AdminTheme.warning,
            ),
            StatCard(
              title: 'Lifetime Revenue',
              value: _currencyFormat.format(_revenueLifetime),
              subtitle: 'All time revenue',
              icon: Icons.stars_rounded,
              color: AdminTheme.success,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRevenueBreakdownSection(bool isDesktop) {
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
            RevenueBreakdownChart(
              title: 'Revenue by Country',
              data: _revenueByCountry,
              currencyFormat: _currencyFormat,
            ),
            RevenueBreakdownChart(
              title: 'Revenue by Plan',
              data: _revenueByPlan,
              currencyFormat: _currencyFormat,
            ),
            RevenueBreakdownChart(
              title: 'Revenue by Platform',
              data: _revenueByPlatform,
              currencyFormat: _currencyFormat,
            ),
            RevenueBreakdownChart(
              title: 'Revenue Sources',
              data: _revenueBySource,
              currencyFormat: _currencyFormat,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCostsSection(bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Costs & Expenses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.5,
                  children: [
                    _buildCostItem('AI Provider Costs', _aiCosts, AdminTheme.secondary, Icons.smart_toy_rounded),
                    _buildCostItem('Infrastructure', _infraCosts, AdminTheme.warning, Icons.dns_rounded),
                    _buildCostItem('Payment Gateway Fees', _paymentFees, AdminTheme.info, Icons.credit_card_rounded),
                    _buildCostItem('Taxes', _taxes, AdminTheme.error, Icons.receipt_rounded),
                    _buildCostItem('Refunds', _refunds, AdminTheme.error, Icons.undo_rounded),
                    _buildCostItem('Tutor Payouts', _tutorPayouts, AdminTheme.tertiary, Icons.school_rounded),
                    _buildCostItem('Platform Commission', _platformCommission, AdminTheme.primary, Icons.handshake_rounded),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            _buildCostBarChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildCostItem(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _currencyFormat.format(amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostBarChart() {
    final costData = [
      _BarData('AI Costs', _aiCosts, AdminTheme.secondary),
      _BarData('Infra', _infraCosts, AdminTheme.warning),
      _BarData('Payments', _paymentFees, AdminTheme.info),
      _BarData('Taxes', _taxes, AdminTheme.error),
      _BarData('Refunds', _refunds, AdminTheme.error),
      _BarData('Payouts', _tutorPayouts, AdminTheme.tertiary),
    ];

    final maxY = costData.map((e) => e.amount).fold<double>(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  _currencyFormat.format(rod.toY),
                  const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
                  if (value.toInt() < costData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        costData[value.toInt()].label,
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
            horizontalInterval: maxY > 0 ? maxY / 5 : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          barGroups: costData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.amount,
                  color: entry.value.color,
                  width: 32,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProfitSection(bool isDesktop) {
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
              title: 'Gross Profit',
              value: _currencyFormat.format(_grossProfit),
              subtitle: 'Revenue minus refunds',
              icon: Icons.account_balance_wallet_rounded,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Net Profit',
              value: _currencyFormat.format(_netProfit),
              subtitle: 'After all expenses',
              icon: Icons.savings_rounded,
              color: _netProfit >= 0 ? AdminTheme.success : AdminTheme.error,
            ),
            StatCard(
              title: 'Cash Flow',
              value: _currencyFormat.format(_cashFlow),
              subtitle: 'Net cash movement',
              icon: Icons.payments_rounded,
              color: _cashFlow >= 0 ? AdminTheme.info : AdminTheme.warning,
            ),
            StatCard(
              title: 'Profit Margin',
              value: '${_profitMargin.toStringAsFixed(1)}%',
              subtitle: 'Net profit / revenue',
              icon: Icons.percent_rounded,
              color: _profitMargin >= 20 ? AdminTheme.success : (_profitMargin >= 0 ? AdminTheme.warning : AdminTheme.error),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionsSection() {
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
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Export CSV'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdminDataTable(
              columns: ['ID', 'User', 'Amount', 'Plan', 'Platform', 'Status', 'Date'],
              rows: _recentTransactions.map((tx) {
                final status = tx['status'] ?? 'pending';
                final badgeType = switch (status) {
                  'completed' => BadgeType.success,
                  'failed' => BadgeType.error,
                  'refunded' => BadgeType.warning,
                  _ => BadgeType.neutral,
                };
                return [
                  Text(
                    (tx['id'] ?? '').toString().substring(0, 8),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(tx['user_email'] ?? 'N/A'),
                  Text(_currencyFormat.format((tx['amount'] as num?)?.toDouble() ?? 0)),
                  Text(tx['plan_name'] ?? 'N/A'),
                  Text(tx['platform'] ?? 'N/A'),
                  StatusBadge(label: status, type: badgeType),
                  Text(
                    DateFormat('MMM d, yyyy').format(
                      DateTime.tryParse(tx['created_at'] ?? '') ?? DateTime.now(),
                    ),
                  ),
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarData {
  final String label;
  final double amount;
  final Color color;

  const _BarData(this.label, this.amount, this.color);
}
