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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
      ]);

      setState(() {
        _settlements = results[0] is List ? results[0] : [];
        _payouts = results[1] is List ? results[1] : [];
        _auditLogs = results[2] is List ? results[2] : [];
        _isLoading = false;
      });
    } catch (e) {
      // Mock fallback
      setState(() {
        _revenue = {
          'total_collected': 4850000,
          'platform_commission': 970000,
          'tutor_payouts': 3880000,
          'net_profit': 125000,
        };
        _profit = {
          'gross_revenue': 4850000,
          'ai_cost': 245000,
          'tutor_payouts': 3880000,
          'gateway_charges': 140650,
          'infrastructure': 85000,
          'actual_profit': 499350,
          'margin_percent': 10.3,
        };
        _healthScore = {
          'score': 82,
          'grade': 'A',
          'revenue_score': 85,
          'user_growth_score': 78,
          'dispute_score': 95,
          'tutor_health_score': 72,
        };
        _liveDashboard = {
          'revenue_today': 15200,
          'revenue_month': 485000,
          'platform_wallet': 1250000,
          'tutor_payables': 325000,
          'active_subscriptions': 520,
          'open_disputes': 3,
        };
        _settlements = [
          {'student': 'Alice M.', 'tutor': 'Prof. Sarah', 'amount': 2500, 'commission': 500, 'net': 2000, 'status': 'settled', 'date': '2026-07-06'},
          {'student': 'Raj K.', 'tutor': 'David V.', 'amount': 1800, 'commission': 360, 'net': 1440, 'status': 'settled', 'date': '2026-07-06'},
          {'student': 'Chen W.', 'tutor': 'Prof. Sarah', 'amount': 2500, 'commission': 500, 'net': 2000, 'status': 'pending', 'date': '2026-07-05'},
        ];
        _payouts = [
          {'tutor': 'Prof. Sarah', 'amount': 8500, 'charges': 170, 'net': 8330, 'status': 'completed', 'date': '2026-07-05'},
          {'tutor': 'David V.', 'amount': 5200, 'charges': 104, 'net': 5096, 'status': 'pending', 'date': '2026-07-04'},
        ];
        _auditLogs = [
          {'action': 'payout_approved', 'entity': 'Tutor Payout', 'by': 'Admin', 'date': '2026-07-06 14:30'},
          {'action': 'settlement_batch', 'entity': 'Settlement Batch', 'by': 'System', 'date': '2026-07-06 00:00'},
          {'action': 'commission_rule_updated', 'entity': 'Commission Rule', 'by': 'Admin', 'date': '2026-07-05 11:20'},
        ];
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
}
