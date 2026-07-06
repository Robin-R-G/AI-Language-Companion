import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/data_table_widget.dart';

class AiBillingPage extends StatefulWidget {
  const AiBillingPage({super.key});

  @override
  State<AiBillingPage> createState() => _AiBillingPageState();
}

class _AiBillingPageState extends State<AiBillingPage> {
  final _supabase = Supabase.instance.client;
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _numberFormat = NumberFormat.compact();
  bool _isLoading = true;

  double _totalAiSpend = 0;
  double _totalCreditsUsed = 0;
  int _totalRequests = 0;
  double _avgCostPerRequest = 0;

  List<Map<String, dynamic>> _billingHistory = [];
  List<Map<String, dynamic>> _creditCosts = [];
  List<Map<String, dynamic>> _providerPricing = [];

  @override
  void initState() {
    super.initState();
    _loadBillingData();
  }

  Future<void> _loadBillingData() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      final logsRes = await _supabase
          .from('ai_usage_logs')
          .select('*')
          .gte('created_at', monthStart.toIso8601String());
      final logs = List<Map<String, dynamic>>.from(logsRes);

      for (final log in logs) {
        _totalAiSpend += (log['cost'] as num?)?.toDouble() ?? 0;
        _totalCreditsUsed += (log['credits_used'] as num?)?.toDouble() ?? 0;
        _totalRequests++;
      }
      _avgCostPerRequest = _totalRequests > 0 ? _totalAiSpend / _totalRequests : 0;

      final billingRes = await _supabase
          .from('ai_billing_history')
          .select('*')
          .order('created_at', ascending: false)
          .limit(100);
      _billingHistory = List<Map<String, dynamic>>.from(billingRes);

      final creditsRes = await _supabase.from('ai_credit_costs').select('*');
      _creditCosts = List<Map<String, dynamic>>.from(creditsRes);

      final pricingRes = await _supabase.from('ai_provider_pricing').select('*');
      _providerPricing = List<Map<String, dynamic>>.from(pricingRes);

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
          title: 'AI Billing',
          subtitle: 'Track AI costs, credit configurations, and billing history',
          trailing: IconButton(
            onPressed: _loadBillingData,
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
          _buildCreditCostsSection(),
          const SizedBox(height: 24),
          _buildProviderPricingSection(),
          const SizedBox(height: 24),
          _buildBillingHistorySection(),
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
              title: 'Total AI Spend',
              value: _currencyFormat.format(_totalAiSpend),
              subtitle: 'This month',
              icon: Icons.attach_money_rounded,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'Credits Used',
              value: _numberFormat.format(_totalCreditsUsed),
              subtitle: 'AI credits consumed',
              icon: Icons.token_rounded,
              color: AdminTheme.secondary,
            ),
            StatCard(
              title: 'Total Requests',
              value: _numberFormat.format(_totalRequests),
              subtitle: 'API calls made',
              icon: Icons.api_rounded,
              color: AdminTheme.tertiary,
            ),
            StatCard(
              title: 'Avg Cost/Request',
              value: _currencyFormat.format(_avgCostPerRequest),
              subtitle: 'Per API call',
              icon: Icons.speed_rounded,
              color: AdminTheme.warning,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreditCostsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Credit Cost Configuration', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => _showEditCreditCostDialog(),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit Costs'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdminDataTable(
              columns: ['Feature', 'Credits per Request', 'Description', 'Status'],
              rows: _creditCosts.map((cost) {
                final isActive = cost['is_active'] ?? true;
                return [
                  Text(
                    cost['feature'] ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('${(cost['credits'] as num?)?.toInt() ?? 0}'),
                  Flexible(
                    child: Text(
                      cost['description'] ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(
                    label: isActive ? 'Active' : 'Inactive',
                    type: isActive ? BadgeType.success : BadgeType.neutral,
                  ),
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderPricingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider Pricing Comparison', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_providerPricing.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No pricing data available'),
                ),
              )
            else
              _buildPricingTable(),
            const SizedBox(height: 20),
            _buildPricingChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Provider', style: TextStyle(fontWeight: FontWeight.w600))),
          const DataColumn(label: Text('Model', style: TextStyle(fontWeight: FontWeight.w600))),
          const DataColumn(label: Text('Input \$/1M', style: TextStyle(fontWeight: FontWeight.w600))),
          const DataColumn(label: Text('Output \$/1M', style: TextStyle(fontWeight: FontWeight.w600))),
          const DataColumn(label: Text('Latency (avg)', style: TextStyle(fontWeight: FontWeight.w600))),
          const DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
        rows: _providerPricing.map((pricing) {
          return DataRow(cells: [
            DataCell(Text(pricing['provider'] ?? 'N/A')),
            DataCell(Text(pricing['model'] ?? 'N/A')),
            DataCell(Text(_currencyFormat.format((pricing['input_price'] as num?)?.toDouble() ?? 0))),
            DataCell(Text(_currencyFormat.format((pricing['output_price'] as num?)?.toDouble() ?? 0))),
            DataCell(Text('${(pricing['avg_latency_ms'] as num?)?.toInt() ?? 0}ms')),
            DataCell(StatusBadge(
              label: (pricing['is_available'] ?? false) ? 'Available' : 'Unavailable',
              type: (pricing['is_available'] ?? false) ? BadgeType.success : BadgeType.error,
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildPricingChart() {
    if (_providerPricing.isEmpty) return const SizedBox.shrink();

    final providerCosts = <String, double>{};
    for (final p in _providerPricing) {
      final provider = p['provider'] ?? 'Unknown';
      final inputPrice = (p['input_price'] as num?)?.toDouble() ?? 0;
      providerCosts[provider] = inputPrice;
    }

    final entries = providerCosts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      AdminTheme.primary,
      AdminTheme.secondary,
      AdminTheme.tertiary,
      AdminTheme.warning,
      AdminTheme.error,
    ];

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (entries.isNotEmpty ? entries.first.value : 0) * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${_currencyFormat.format(rod.toY)}/1M tokens',
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
                  if (value.toInt() < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entries[value.toInt()].key,
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
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compact().format(value),
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
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          barGroups: entries.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value,
                  color: colors[entry.key % colors.length],
                  width: 36,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBillingHistorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Billing History', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Export'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdminDataTable(
              columns: ['Date', 'Period', 'Provider', 'Requests', 'Tokens', 'Cost', 'Status'],
              rows: _billingHistory.map((bill) {
                final status = bill['status'] ?? 'paid';
                final badgeType = switch (status) {
                  'paid' => BadgeType.success,
                  'pending' => BadgeType.warning,
                  'failed' => BadgeType.error,
                  _ => BadgeType.neutral,
                };
                return [
                  Text(
                    DateFormat('MMM d, yyyy').format(
                      DateTime.tryParse(bill['created_at'] ?? '') ?? DateTime.now(),
                    ),
                  ),
                  Text(bill['period'] ?? 'N/A'),
                  StatusBadge(label: bill['provider'] ?? 'N/A', type: BadgeType.info),
                  Text(_numberFormat.format((bill['requests'] as num?)?.toInt() ?? 0)),
                  Text(_numberFormat.format((bill['tokens'] as num?)?.toInt() ?? 0)),
                  Text(
                    _currencyFormat.format((bill['cost'] as num?)?.toDouble() ?? 0),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  StatusBadge(label: status, type: badgeType),
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditCreditCostDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Credit Costs'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _creditCosts.map((cost) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        cost['feature'] ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: '${(cost['credits'] as num?)?.toInt() ?? 0}',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true) _loadBillingData();
  }
}
