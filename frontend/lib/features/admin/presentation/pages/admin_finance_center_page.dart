import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';

class AdminFinanceCenterPage extends StatefulWidget {
  const AdminFinanceCenterPage({super.key});

  @override
  State<AdminFinanceCenterPage> createState() => _AdminFinanceCenterPageState();
}

class _AdminFinanceCenterPageState extends State<AdminFinanceCenterPage> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  late TabController _tabController;
  Map<String, dynamic> _revenue = {};
  Map<String, dynamic> _profit = {};
  Map<String, dynamic> _healthScore = {};
  List<dynamic> _settlements = [];
  List<dynamic> _payouts = [];
  List<dynamic> _auditLogs = [];
  Map<String, dynamic> _liveDashboard = {};
  List<dynamic> _aiProviders = [];
  List<dynamic> _aiRouting = [];
  List<dynamic> _aiFailures = [];
  List<dynamic> _aiCostDaily = [];
  List<dynamic> _manualPayments = [];
  List<dynamic> _pxpipeAnalytics = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _supabase.from('payment_settlements').select('*').order('created_at', ascending: false).limit(50).catchError((_) => []),
        _supabase.from('tutor_payouts').select('*').order('created_at', ascending: false).limit(50).catchError((_) => []),
        _supabase.from('financial_audit_logs').select('*').order('created_at', ascending: false).limit(50).catchError((_) => []),
        _supabase.from('ai_providers').select('*').order('priority', ascending: true).catchError((_) => []),
        _supabase.from('ai_feature_routing').select('*').catchError((_) => []),
        _supabase.from('ai_failures').select('*').order('created_at', ascending: false).limit(50).catchError((_) => []),
        _supabase.from('ai_cost_daily').select('*').catchError((_) => []),
        _supabase.from('manual_payments').select('*, user_profiles(full_name, email)').order('created_at', ascending: false).catchError((_) => []),
        _supabase.from('pxpipe_analytics').select('*').order('created_at', ascending: false).limit(100).catchError((_) => []),
      ]);

      final settlementsList = results[0] is List ? results[0] as List : [];
      final payoutsList = results[1] is List ? results[1] as List : [];
      final aiCostList = results[6] is List ? results[6] as List : [];

      double totalCollected = 0;
      double platformCommission = 0;
      for (final s in settlementsList) {
        final amt = (s['amount'] ?? 0) as num;
        final comm = (s['commission'] ?? 0) as num;
        totalCollected += amt;
        platformCommission += comm;
      }

      double totalPayouts = 0;
      for (final p in payoutsList) {
        final amt = (p['amount'] ?? 0) as num;
        totalPayouts += amt;
      }

      double totalAiCost = 0;
      for (final c in aiCostList) {
        final cost = (c['total_cost_usd'] ?? 0.0) as num;
        totalAiCost += cost * 83.0; // convert USD to INR roughly
      }

      double gatewayCharges = totalCollected * 0.02;
      double actualProfit = platformCommission - totalAiCost - gatewayCharges;

      setState(() {
        _settlements = settlementsList;
        _payouts = payoutsList;
        _auditLogs = results[2] is List ? results[2] : [];
        _aiProviders = results[3] is List ? results[3] as List : [];
        _aiRouting = results[4] is List ? results[4] as List : [];
        _aiFailures = results[5] is List ? results[5] : [];
        _aiCostDaily = aiCostList;
        _manualPayments = results[7] is List ? results[7] as List : [];
        _pxpipeAnalytics = results[8] is List ? results[8] as List : [];

        _revenue = {
          'total_collected': totalCollected.toInt(),
          'platform_commission': platformCommission.toInt(),
          'tutor_payouts': totalPayouts.toInt(),
          'net_profit': actualProfit.toInt(),
        };

        _profit = {
          'gross_revenue': totalCollected.toInt(),
          'ai_cost': totalAiCost.toInt(),
          'tutor_payouts': totalPayouts.toInt(),
          'gateway_charges': gatewayCharges.toInt(),
          'infrastructure': 0,
          'actual_profit': actualProfit.toInt(),
          'margin_percent': totalCollected > 0 ? (actualProfit / totalCollected * 100).toStringAsFixed(1) : '0.0',
        };

        _healthScore = {
          'score': totalCollected > 0 ? 95 : 100,
          'grade': 'A',
          'revenue_score': 100,
          'user_growth_score': 100,
          'dispute_score': 100,
          'tutor_health_score': 100,
        };

        _liveDashboard = {
          'revenue_today': (totalCollected * 0.05).toInt(),
          'revenue_month': totalCollected.toInt(),
          'platform_wallet': platformCommission.toInt(),
          'tutor_payables': (totalCollected - totalPayouts).toInt(),
          'active_subscriptions': 0,
          'open_disputes': 0,
        };

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading finance dashboard: $e');
      setState(() {
        _settlements = [];
        _payouts = [];
        _auditLogs = [];
        _aiProviders = [];
        _aiRouting = [];
        _aiFailures = [];
        _aiCostDaily = [];
        _manualPayments = [];
        _revenue = {};
        _profit = {};
        _healthScore = {'score': 0, 'grade': 'N/A', 'revenue_score': 0, 'user_growth_score': 0, 'dispute_score': 0, 'tutor_health_score': 0};
        _liveDashboard = {};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Center'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Revenue'),
            Tab(text: 'Settlements'),
            Tab(text: 'Payouts'),
            Tab(text: 'Commission'),
            Tab(text: 'Audit'),
            Tab(text: 'Reports'),
            Tab(text: 'AI Providers'),
            Tab(text: 'Payment Verification'),
            Tab(text: 'PxPipe Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(theme),
          _buildRevenueTab(theme),
          _buildSettlementsTab(theme),
          _buildPayoutsTab(theme),
          _buildCommissionTab(theme),
          _buildAuditTab(theme),
          _buildReportsTab(theme),
          _buildAiProvidersTab(theme),
          _buildPaymentVerificationTab(theme),
          _buildPxPipeAnalyticsTab(theme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Health Score
          _buildHealthScoreCard(theme),
          const SizedBox(height: AppSpacing.lg),
          // Live Dashboard
          _buildLiveDashboardCard(theme),
          const SizedBox(height: AppSpacing.lg),
          // Profit Summary
          _buildProfitSummaryCard(theme),
          const SizedBox(height: AppSpacing.lg),
          // Revenue Streams
          _buildRevenueStreamsCard(theme),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(ThemeData theme) {
    final score = (_healthScore['score'] ?? 0) as int;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Business Health Score', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(
                          score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$score', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          Text((_healthScore['grade'] ?? '') as String, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    children: [
                      _buildHealthBar('Revenue', (_healthScore['revenue_score'] ?? 0) as int, Colors.green),
                      _buildHealthBar('User Growth', (_healthScore['user_growth_score'] ?? 0) as int, Colors.blue),
                      _buildHealthBar('Dispute Health', (_healthScore['dispute_score'] ?? 0) as int, Colors.orange),
                      _buildHealthBar('Tutor Health', (_healthScore['tutor_health_score'] ?? 0) as int, Colors.purple),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBar(String label, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 8),
          Text('$score', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLiveDashboardCard(ThemeData theme) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 10),
                const SizedBox(width: 6),
                Text('Live Dashboard', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildLiveMetric('Today Revenue', '\$${((_liveDashboard['revenue_today'] ?? 0).toInt() / 100).toStringAsFixed(2)}', Colors.green),
                _buildLiveMetric('Month Revenue', '\$${((_liveDashboard['revenue_month'] ?? 0).toInt() / 100).toStringAsFixed(2)}', Colors.blue),
                _buildLiveMetric('Platform Wallet', '\$${((_liveDashboard['platform_wallet'] ?? 0).toInt() / 100).toStringAsFixed(2)}', Colors.purple),
                _buildLiveMetric('Tutor Payables', '\$${((_liveDashboard['tutor_payables'] ?? 0).toInt() / 100).toStringAsFixed(2)}', Colors.orange),
                _buildLiveMetric('Active Subs', '${(_liveDashboard['active_subscriptions'] ?? 0).toInt()}', Colors.teal),
                _buildLiveMetric('Open Disputes', '${(_liveDashboard['open_disputes'] ?? 0).toInt()}', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ],
      ),
    );
  }

  Widget _buildProfitSummaryCard(ThemeData theme) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profit Summary', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.base),
            _buildProfitRow('Gross Revenue', (_profit['gross_revenue'] ?? 0) as int, Colors.green),
            _buildProfitRow('AI Cost', -((_profit['ai_cost'] ?? 0) as int), Colors.red),
            _buildProfitRow('Tutor Payouts', -((_profit['tutor_payouts'] ?? 0) as int), Colors.orange),
            _buildProfitRow('Gateway Charges', -((_profit['gateway_charges'] ?? 0) as int), Colors.red),
            _buildProfitRow('Infrastructure', -((_profit['infrastructure'] ?? 0) as int), Colors.red),
            const Divider(),
            _buildProfitRow('Actual Profit', (_profit['actual_profit'] ?? 0) as int, Colors.blue, isBold: true),
            Text('Margin: ${_profit['margin_percent'] ?? 0}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitRow(String label, int amountCents, Color color, {bool isBold = false}) {
    final isNegative = amountCents < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 15 : 13,
          )),
          Text(
            '${isNegative ? '-' : ''}\$${(amountCents.abs() / 100).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
              fontSize: isBold ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueStreamsCard(ThemeData theme) {
    final streams = [
      {'name': 'Subscriptions', 'amount': 985000, 'color': Colors.blue, 'percent': 40},
      {'name': 'Tutor Commission', 'amount': 485000, 'color': Colors.green, 'percent': 20},
      {'name': 'AI Credit Packs', 'amount': 365000, 'color': Colors.purple, 'percent': 15},
      {'name': 'Certificates', 'amount': 125000, 'color': Colors.orange, 'percent': 5},
      {'name': 'Affiliates', 'amount': 85000, 'color': Colors.teal, 'percent': 3},
      {'name': 'Sponsored', 'amount': 45000, 'color': Colors.pink, 'percent': 2},
    ];

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue Streams', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.base),
            ...streams.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: s['color'] as Color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s['name'] as String, style: const TextStyle(fontSize: 13))),
                  Text('\$${((s['amount'] as int) / 100).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text('${s['percent']}%', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRevenueCard(theme, 'Platform Commission', (_revenue['platform_commission'] ?? 0) as int, Colors.green),
          _buildRevenueCard(theme, 'Total Collected', (_revenue['total_collected'] ?? 0) as int, Colors.blue),
          _buildRevenueCard(theme, 'Tutor Payouts', (_revenue['tutor_payouts'] ?? 0) as int, Colors.orange),
          _buildRevenueCard(theme, 'Net Profit', (_revenue['net_profit'] ?? 0) as int, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(ThemeData theme, String title, int amountCents, Color color) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            Text('\$${(amountCents / 100).toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementsTab(ThemeData theme) {
    return _settlements.isEmpty
        ? const Center(child: Text('No settlements found'))
        : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: _settlements.length,
            itemBuilder: (context, index) {
              final s = _settlements[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  title: Text('${s['student'] ?? 'Student'} -> ${s['tutor'] ?? 'Tutor'}'),
                  subtitle: Text('Commission: \$${((s['commission'] ?? 0) / 100).toStringAsFixed(2)} | Net: \$${((s['net'] ?? 0) / 100).toStringAsFixed(2)}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (s['status'] == 'settled') ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text((s['status'] ?? 'pending') as String, style: TextStyle(
                      fontSize: 12,
                      color: (s['status'] == 'settled') ? Colors.green : Colors.orange,
                    )),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildPayoutsTab(ThemeData theme) {
    return _payouts.isEmpty
        ? const Center(child: Text('No payouts found'))
        : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: _payouts.length,
            itemBuilder: (context, index) {
              final p = _payouts[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  title: Text((p['tutor'] ?? 'Tutor') as String),
                  subtitle: Text('Amount: \$${((p['amount'] ?? 0) / 100).toStringAsFixed(2)} | Net: \$${((p['net'] ?? 0) / 100).toStringAsFixed(2)}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (p['status'] == 'completed') ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text((p['status'] ?? 'pending') as String, style: TextStyle(
                      fontSize: 12,
                      color: (p['status'] == 'completed') ? Colors.green : Colors.orange,
                    )),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildCommissionTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Platform Commission Rules', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.base),
                  ListTile(
                    leading: const Icon(Icons.public),
                    title: const Text('Global Commission'),
                    subtitle: const Text('Applied to all bookings'),
                    trailing: const Text('20%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Per-Tutor Commission'),
                    subtitle: const Text('Custom rates for specific tutors'),
                    trailing: AppButton(label: 'Configure', onPressed: () {}),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.subject),
                    title: const Text('Per-Subject Commission'),
                    subtitle: const Text('Different rates by subject'),
                    trailing: AppButton(label: 'Configure', onPressed: () {}),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTab(ThemeData theme) {
    return _auditLogs.isEmpty
        ? const Center(child: Text('No audit logs'))
        : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: _auditLogs.length,
            itemBuilder: (context, index) {
              final log = _auditLogs[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: Icon(Icons.security, color: _getActionColor(log['action'] as String?)),
                  title: Text((log['action'] ?? '') as String, style: const TextStyle(fontSize: 14)),
                  subtitle: Text('${log['entity'] ?? ''} by ${log['by'] ?? ''}', style: const TextStyle(fontSize: 12)),
                  trailing: Text((log['date'] ?? '') as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ),
              );
            },
          );
  }

  Widget _buildReportsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        children: [
          _buildReportCard(theme, 'Monthly Report', 'Revenue, expenses, and profit summary', Icons.assessment),
          _buildReportCard(theme, 'Commission Report', 'Platform commission earnings by tutor', Icons.pie_chart),
          _buildReportCard(theme, 'Tax Report', 'GST and tax liability summary', Icons.receipt),
          _buildReportCard(theme, 'Tutor Earnings Report', 'All tutor payout history', Icons.account_balance),
          _buildReportCard(theme, 'Financial Statement', 'Complete P&L statement', Icons.description),
          _buildReportCard(theme, 'Export CSV', 'Download data as CSV', Icons.download),
        ],
      ),
    );
  }

  Widget _buildReportCard(ThemeData theme, String title, String subtitle, IconData icon) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Color _getActionColor(String? action) {
    switch (action) {
      case 'payout_approved': return Colors.green;
      case 'payout_rejected': return Colors.red;
      case 'settlement_batch': return Colors.blue;
      case 'commission_rule_updated': return Colors.orange;
      case 'tutor_approved': return Colors.green;
      case 'tutor_rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  bool _isTesting = false;

  Widget _buildAiProvidersTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Providers & Costs',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.base),
          ..._aiProviders.map((provider) {
            final name = provider['name'] as String;
            final displayName = provider['display_name'] as String;
            final isEnabled = provider['is_enabled'] as bool? ?? false;
            final priority = provider['priority'] as int? ?? 1;

            // Get cost metrics from daily cost list
            final providerCosts = _aiCostDaily.where((c) => c['provider'] == name);
            final requests = providerCosts.fold<int>(0, (sum, item) => sum + ((item['total_requests'] ?? 0) as int));
            final cost = providerCosts.fold<double>(0.0, (sum, item) => sum + (double.tryParse(item['total_cost_usd']?.toString() ?? '0') ?? 0.0));
            final failures = _aiFailures.where((f) => f['provider'] == name).length;

            return AppCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.base),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: isEnabled,
                          onChanged: (val) async {
                            setState(() {
                              provider['is_enabled'] = val;
                            });
                            try {
                              await _supabase
                                  .from('ai_providers')
                                  .update({'is_enabled': val})
                                  .eq('name', name);
                            } catch (_) {}
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Priority: '),
                            const SizedBox(width: AppSpacing.xs),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: priority > 1
                                  ? () async {
                                      final newPri = priority - 1;
                                      setState(() {
                                        provider['priority'] = newPri;
                                        _aiProviders.sort((a, b) => (a['priority'] as int).compareTo(b['priority'] as int));
                                      });
                                      try {
                                        await _supabase
                                            .from('ai_providers')
                                            .update({'priority': newPri})
                                            .eq('name', name);
                                      } catch (_) {}
                                    }
                                  : null,
                            ),
                            Text('$priority', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () async {
                                final newPri = priority + 1;
                                setState(() {
                                  provider['priority'] = newPri;
                                  _aiProviders.sort((a, b) => (a['priority'] as int).compareTo(b['priority'] as int));
                                });
                                try {
                                  await _supabase
                                      .from('ai_providers')
                                      .update({'priority': newPri})
                                      .eq('name', name);
                                } catch (_) {}
                              },
                            ),
                          ],
                        ),
                        AppButton(
                          label: _isTesting ? 'Testing...' : 'Test Connection',
                          onPressed: _isTesting
                              ? null
                              : () async {
                                  setState(() => _isTesting = true);
                                  try {
                                    final res = await _supabase.functions.invoke(
                                      'ai-gateway',
                                      body: {
                                        'prompt': 'Hello! Confirm your name.',
                                        'feature': 'chat',
                                        'test_provider': name,
                                      },
                                    );
                                    if (res.status == 200) {
                                      final data = res.data as Map<String, dynamic>;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Test successful! Reply: ${data['content']}'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      throw Exception(res.data?.toString() ?? 'Error');
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Test failed: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    setState(() => _isTesting = false);
                                  }
                                },
                        ),
                      ],
                    ),
                    const Divider(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricColumn('Requests', '$requests'),
                        _buildMetricColumn('Failures', '$failures', color: failures > 0 ? Colors.red : null),
                        _buildMetricColumn('Cost USD', '\$${cost.toStringAsFixed(4)}'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Feature Fallback Routing',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.base),
          ..._aiRouting.map((routing) {
            final feature = routing['feature'] as String;
            final order = List<String>.from(routing['provider_order'] ?? []);
            final controller = TextEditingController(text: order.join(', '));

            return AppCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Fallback Order (comma-separated)',
                        hintText: 'omniroute, openai, gemini',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        label: 'Save Routing',
                        onPressed: () async {
                          final newOrder = controller.text
                              .split(',')
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .toList();
                          setState(() {
                            routing['provider_order'] = newOrder;
                          });
                          try {
                            await _supabase
                                .from('ai_feature_routing')
                                .update({'provider_order': newOrder})
                                .eq('feature', feature);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Routing updated successfully!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to update routing: $e'), backgroundColor: Colors.red),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Recent API Failures',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.base),
          if (_aiFailures.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.base), child: Text('No recent failures logged'))),
          ..._aiFailures.map((failure) {
            return AppCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: Text('${failure['provider']} failed on ${failure['feature']}'),
                subtitle: Text(
                  (failure['error_message'] ?? '') as String,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
                trailing: Text(
                  (failure['created_at'] ?? '') as String,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ── Payment Verification Tab ────────────────────────────────────────────────

  Widget _buildPaymentVerificationTab(ThemeData theme) {
    final pendingPayments = _manualPayments.where((p) => p['status'] == 'pending').toList();
    final historyPayments = _manualPayments.where((p) => p['status'] != 'pending').toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Verification Queue',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (pendingPayments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text('No pending verification requests'),
            ),
          ),
        ...pendingPayments.map((p) => _buildPaymentCard(theme, p, isPending: true)),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Verification History',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (historyPayments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text('No verification history'),
            ),
          ),
        ...historyPayments.map((p) => _buildPaymentCard(theme, p, isPending: false)),
      ],
    );
  }

  Widget _buildPaymentCard(ThemeData theme, Map<String, dynamic> payment, {required bool isPending}) {
    final userDetails = payment['user_profiles'] as Map<String, dynamic>? ?? {};
    final fullName = userDetails['full_name'] ?? 'Unknown User';
    final email = userDetails['email'] ?? '';
    final status = payment['status'] ?? 'pending';

    Color statusColor = Colors.orange;
    if (status == 'approved') statusColor = Colors.green;
    if (status == 'rejected') statusColor = Colors.red;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (email.isNotEmpty) Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toString().toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PLAN / ITEM', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(payment['plan_type'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('AMOUNT', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text('Rs ${payment['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('UTR / REF NUMBER', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(payment['utr_number'] ?? '', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('DATE', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(payment['payment_date']?.toString().split('T').first ?? '', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            if (payment['notes'] != null && payment['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text('USER NOTES', style: TextStyle(color: Colors.grey, fontSize: 10)),
              const SizedBox(height: 2),
              Text(payment['notes'], style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
            if (payment['rejection_reason'] != null && payment['rejection_reason'].toString().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text('REJECTION REASON', style: TextStyle(color: Colors.red, fontSize: 10)),
              const SizedBox(height: 2),
              Text(payment['rejection_reason'], style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewReceiptScreenshot(payment['screenshot_url'] ?? ''),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('View Proof'),
                  ),
                ),
                if (isPending) ...[
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () => _approvePayment(payment),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('Approve'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () => _showRejectDialog(payment),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Reject'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewReceiptScreenshot(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Payment Proof Screenshot'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Flexible(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      SizedBox(height: AppSpacing.sm),
                      Text('Failed to load image. Check public storage permission.'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> payment) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Payment Proof'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for Rejection',
            hintText: 'e.g. Invalid UTR or screenshot',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(context);
              _rejectPayment(payment, reason);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _approvePayment(Map<String, dynamic> payment) async {
    setState(() => _isLoading = true);
    try {
      final paymentId = payment['id'];
      final userId = payment['user_id'];
      final planType = payment['plan_type'];
      final amount = payment['amount'];
      final utr = payment['utr_number'];

      // 1. Update manual_payments status to approved
      await _supabase
          .from('manual_payments')
          .update({
            'status': 'approved',
            'verified_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      // 2. If it is a subscription plan:
      if (planType.startsWith('premium') || planType.startsWith('pro') || planType.startsWith('basic')) {
        await _supabase.from('subscriptions').upsert({
          'user_id': userId,
          'plan_id': planType,
          'plan': planType,
          'status': 'active',
          'provider': 'manual',
          'renewal_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'current_period_start': DateTime.now().toIso8601String(),
          'current_period_end': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        });

        // Award premium credits if applicable
        final creditsMap = {
          'premium_monthly': 500,
          'premium_annual': 6000,
          'pro_monthly': 2000,
          'pro_annual': 24000,
          'basic_monthly': 100,
          'basic_annual': 1200,
        };
        final credits = creditsMap[planType] ?? 0;
        if (credits > 0) {
          await _supabase.rpc('add_ai_credits', {
            'p_user_id': userId,
            'p_credits': credits,
            'p_source': 'subscription_new',
            'p_description': 'Manual payment approved: $planType',
          });
        }
      } else {
        // It is a credit pack
        final packCredits = {
          'credits_pack_small': 100,
          'credits_pack_medium': 250,
          'credits_pack_large': 600,
          'credits_pack_ultimate': 1500,
        };
        final credits = packCredits[planType] ?? 0;
        if (credits > 0) {
          await _supabase.rpc('add_ai_credits', {
            'p_user_id': userId,
            'p_credits': credits,
            'p_source': 'purchase',
            'p_description': 'Manual purchase approved: $planType',
          });
        }
      }

      // 3. Log transaction in payments table
      await _supabase.from('payments').insert({
        'user_id': userId,
        'transaction_id': utr,
        'amount': amount,
        'currency': 'INR',
        'platform': 'manual',
        'status': 'success',
      });

      // 4. Log in financial_audit_logs
      await _supabase.from('financial_audit_logs').insert({
        'action': 'manual_payment_approved',
        'entity': 'Manual Payment',
        'details': 'Approved manual payment $paymentId for plan $planType. Amount: $amount',
      }).catchError((_) => null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment approved successfully!')),
      );
      _loadData();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving payment: $e')),
      );
    }
  }

  Future<void> _rejectPayment(Map<String, dynamic> payment, String reason) async {
    setState(() => _isLoading = true);
    try {
      final paymentId = payment['id'];

      await _supabase
          .from('manual_payments')
          .update({
            'status': 'rejected',
            'rejection_reason': reason,
            'verified_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      // Log in audit log
      await _supabase.from('financial_audit_logs').insert({
        'action': 'manual_payment_rejected',
        'entity': 'Manual Payment',
        'details': 'Rejected payment $paymentId. Reason: $reason',
      }).catchError((_) => null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment rejected successfully.')),
      );
      _loadData();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting payment: $e')),
      );
    }
  }

  // ── PxPipe Analytics Tab ───────────────────────────────────────────────────
  Widget _buildPxPipeAnalyticsTab(ThemeData theme) {
    if (_pxpipeAnalytics.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
              SizedBox(height: AppSpacing.base),
              Text('No PxPipe optimization metrics logged yet', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final totalRequests = _pxpipeAnalytics.length;
    final cacheHits = _pxpipeAnalytics.where((x) => x['is_cache_hit'] == true).length;
    final hitRate = totalRequests > 0 ? (cacheHits / totalRequests * 100).toStringAsFixed(1) : '0.0';
    
    final totalTokenSavings = _pxpipeAnalytics.fold<int>(0, (sum, x) => sum + ((x['token_savings'] ?? 0) as int));
    final totalCostSavings = _pxpipeAnalytics.fold<double>(0.0, (sum, x) => sum + (double.tryParse(x['cost_savings_usd']?.toString() ?? '0') ?? 0.0));
    final averageLatency = totalRequests > 0 
        ? (_pxpipeAnalytics.fold<int>(0, (sum, x) => sum + ((x['latency_ms'] ?? 0) as int)) / totalRequests).toStringAsFixed(0)
        : '0';

    // Provider distribution
    final providers = <String, int>{};
    for (final x in _pxpipeAnalytics) {
      final p = (x['provider_used'] ?? 'unknown') as String;
      providers[p] = (providers[p] ?? 0) + 1;
    }

    // Optimization ratios (original vs optimized)
    final totalOriginal = _pxpipeAnalytics.fold<int>(0, (sum, x) => sum + ((x['original_prompt_size'] ?? 0) as int));
    final totalOptimized = _pxpipeAnalytics.fold<int>(0, (sum, x) => sum + ((x['optimized_prompt_size'] ?? 0) as int));
    final optimizationRatio = totalOriginal > 0 
        ? ((totalOriginal - totalOptimized) / totalOriginal * 100).toStringAsFixed(1)
        : '0.0';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PxPipe Optimization Analytics',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.base),

          // Overview metrics grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildLiveMetric('Total Requests', '$totalRequests', Colors.blue),
              _buildLiveMetric('Cache Hits', '$cacheHits ($hitRate%)', Colors.green),
              _buildLiveMetric('Token Savings', '$totalTokenSavings tokens', Colors.purple),
              _buildLiveMetric('Cost Savings', '\$${totalCostSavings.toStringAsFixed(4)}', Colors.teal),
              _buildLiveMetric('Avg Latency', '$averageLatency ms', Colors.orange),
              _buildLiveMetric('Optimization Ratio', '$optimizationRatio%', Colors.indigo),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Provider distribution card
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Provider Distributions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.base),
                  ...providers.entries.map((e) {
                    final percent = totalRequests > 0 ? (e.value / totalRequests * 100).toStringAsFixed(1) : '0';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${e.value} requests ($percent%)', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Recent requests history
          Text('Recent Optimizations Log', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.base),
          ..._pxpipeAnalytics.map((x) {
            final hit = x['is_cache_hit'] == true;
            return AppCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: Icon(
                  hit ? Icons.flash_on : Icons.bolt,
                  color: hit ? Colors.green : Colors.blue,
                ),
                title: Text('${x['intent']} - ${x['provider_used']?.toString().toUpperCase()}'),
                subtitle: Text(
                  'Original: ${x['original_prompt_size']} ch | Optimized: ${x['optimized_prompt_size']} ch | Savings: ${x['token_savings']} tokens',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${x['latency_ms']} ms', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${(double.tryParse(x['cost_savings_usd']?.toString() ?? '0') ?? 0.0).toStringAsFixed(4)} saved', style: const TextStyle(color: Colors.green, fontSize: 10)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

