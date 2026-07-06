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
import '../../../../core/widgets/confirm_dialog.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _supabase = Supabase.instance.client;
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _numberFormat = NumberFormat.compact();
  final _searchController = TextEditingController();
  bool _isLoading = true;

  double _totalRevenue = 0;
  double _failedAmount = 0;
  double _refundedAmount = 0;
  int _totalTransactions = 0;

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  List<Map<String, dynamic>> _failedPayments = [];
  List<Map<String, dynamic>> _refunds = [];
  List<Map<String, dynamic>> _bankAccounts = [];

  Map<String, dynamic> _gatewayStatus = {};
  String _activeTab = 'transactions';

  @override
  void initState() {
    super.initState();
    _loadPaymentsData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentsData() async {
    setState(() => _isLoading = true);
    try {
      final txRes = await _supabase
          .from('payments')
          .select('*')
          .order('created_at', ascending: false)
          .limit(200);
      _transactions = List<Map<String, dynamic>>.from(txRes);
      _filteredTransactions = List.from(_transactions);

      for (final tx in _transactions) {
        final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
        final status = tx['status'] ?? '';
        _totalTransactions++;
        if (status == 'completed') _totalRevenue += amount;
        if (status == 'failed') _failedAmount += amount;
        if (status == 'refunded') _refundedAmount += amount;
      }

      _failedPayments = _transactions.where((tx) => tx['status'] == 'failed').toList();
      _refunds = _transactions.where((tx) => tx['status'] == 'refunded').toList();

      final bankRes = await _supabase.from('bank_accounts').select('*');
      _bankAccounts = List<Map<String, dynamic>>.from(bankRes);

      _gatewayStatus = {
        'razorpay': {'status': 'active', 'uptime': '99.9%', 'last_error': null},
        'stripe': {'status': 'active', 'uptime': '99.8%', 'last_error': null},
        'revenuecat': {'status': 'active', 'uptime': '99.7%', 'last_error': null},
        'google_play': {'status': 'active', 'uptime': '99.9%', 'last_error': null},
        'apple': {'status': 'active', 'uptime': '99.8%', 'last_error': null},
      };

      try {
        final gwRes = await _supabase.from('payment_gateways').select('*');
        final gateways = List<Map<String, dynamic>>.from(gwRes);
        for (final gw in gateways) {
          final name = (gw['name'] ?? '').toLowerCase().replaceAll(' ', '_');
          if (_gatewayStatus.containsKey(name)) {
            _gatewayStatus[name] = {
              'status': gw['status'] ?? 'active',
              'uptime': '${(gw['uptime'] as num?)?.toDouble() ?? 99.9}%',
              'last_error': gw['last_error'],
            };
          }
        }
      } catch (_) {}

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterData(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredTransactions = _transactions.where((tx) {
        final email = tx['user_email']?.toString().toLowerCase() ?? '';
        final id = tx['id']?.toString().toLowerCase() ?? '';
        final plan = tx['plan_name']?.toString().toLowerCase() ?? '';
        return email.contains(q) || id.contains(q) || plan.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Payment Management',
          subtitle: 'Track payments, refunds, and gateway status',
          trailing: IconButton(
            onPressed: _loadPaymentsData,
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
          _buildGatewayStatus(),
          const SizedBox(height: 24),
          _buildStatsCards(isDesktop),
          const SizedBox(height: 24),
          _buildTabBar(),
          const SizedBox(height: 16),
          _buildTabContent(),
        ],
      ],
    );
  }

  Widget _buildGatewayStatus() {
    final gateways = [
      ('Razorpay', 'razorpay', Icons.payment_rounded),
      ('Stripe', 'stripe', Icons.credit_card_rounded),
      ('RevenueCat', 'revenuecat', Icons.receipt_rounded),
      ('Google Play', 'google_play', Icons.shop_rounded),
      ('Apple', 'apple', Icons.phone_iphone_rounded),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Gateway Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 800 ? 5 : (constraints.maxWidth > 500 ? 3 : 2);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: gateways.map((gw) {
                    final status = _gatewayStatus[gw.$2] ?? {};
                    final isActive = status['status'] == 'active';
                    final uptime = status['uptime'] ?? 'N/A';

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AdminTheme.success.withOpacity(0.05)
                            : AdminTheme.error.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? AdminTheme.success.withOpacity(0.2)
                              : AdminTheme.error.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: (isActive ? AdminTheme.success : AdminTheme.error).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              gw.$3,
                              color: isActive ? AdminTheme.success : AdminTheme.error,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  gw.$1,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isActive ? AdminTheme.success : AdminTheme.error,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isActive ? 'Active' : 'Down',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isActive ? AdminTheme.success : AdminTheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Uptime: $uptime',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
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
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
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
              title: 'Total Revenue',
              value: _currencyFormat.format(_totalRevenue),
              subtitle: 'Completed payments',
              icon: Icons.attach_money_rounded,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Failed Payments',
              value: _currencyFormat.format(_failedAmount),
              subtitle: '${_failedPayments.length} failed',
              icon: Icons.error_outline_rounded,
              color: AdminTheme.error,
            ),
            StatCard(
              title: 'Refunded',
              value: _currencyFormat.format(_refundedAmount),
              subtitle: '${_refunds.length} refunds',
              icon: Icons.undo_rounded,
              color: AdminTheme.warning,
            ),
            StatCard(
              title: 'Total Transactions',
              value: _numberFormat.format(_totalTransactions),
              subtitle: 'All time',
              icon: Icons.receipt_long_rounded,
              color: AdminTheme.primary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      ('transactions', 'Transactions'),
      ('failed', 'Failed (${_failedPayments.length})'),
      ('refunds', 'Refunds (${_refunds.length})'),
      ('bank', 'Bank Accounts'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _activeTab == tab.$1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ChoiceChip(
                label: Text(tab.$2, style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                onSelected: (_) => setState(() => _activeTab = tab.$1),
                selectedColor: AdminTheme.primary.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: isSelected ? AdminTheme.primary : Theme.of(context).colorScheme.onBackground,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 'transactions':
        return _buildTransactionsTab();
      case 'failed':
        return _buildFailedPaymentsTab();
      case 'refunds':
        return _buildRefundsTab();
      case 'bank':
        return _buildBankAccountsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SearchField(
            hintText: 'Search transactions...',
            controller: _searchController,
            onChanged: _filterData,
          ),
        ),
        AdminDataTable(
          columns: ['ID', 'User', 'Amount', 'Plan', 'Gateway', 'Status', 'Date', 'Actions'],
          rows: _filteredTransactions.take(100).map((tx) {
            final status = tx['status'] ?? 'pending';
            final badgeType = switch (status) {
              'completed' => BadgeType.success,
              'failed' => BadgeType.error,
              'refunded' => BadgeType.warning,
              'pending' => BadgeType.info,
              _ => BadgeType.neutral,
            };

            return [
              Text(
                (tx['id'] ?? '').toString().substring(0, 8),
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              Text(tx['user_email'] ?? 'N/A'),
              Text(
                _currencyFormat.format((tx['amount'] as num?)?.toDouble() ?? 0),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: status == 'completed' ? AdminTheme.success : null,
                ),
              ),
              Text(tx['plan_name'] ?? 'N/A'),
              Text(tx['payment_gateway'] ?? 'N/A'),
              StatusBadge(label: status, type: badgeType),
              Text(
                DateFormat('MMM d, yyyy').format(
                  DateTime.tryParse(tx['created_at'] ?? '') ?? DateTime.now(),
                ),
                style: const TextStyle(fontSize: 12),
              ),
              _buildTransactionActions(tx),
            ];
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTransactionActions(Map<String, dynamic> tx) {
    final status = tx['status'] ?? '';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showTransactionDetails(tx),
          icon: const Icon(Icons.info_outline_rounded, size: 16),
          tooltip: 'Details',
        ),
        if (status == 'completed')
          IconButton(
            onPressed: () => _initiateRefund(tx),
            icon: const Icon(Icons.undo_rounded, size: 16),
            tooltip: 'Refund',
          ),
      ],
    );
  }

  Widget _buildFailedPaymentsTab() {
    if (_failedPayments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  size: 48,
                  color: AdminTheme.success.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('No failed payments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                      )),
            ],
          ),
        ),
      );
    }

    return AdminDataTable(
      columns: ['ID', 'User', 'Amount', 'Plan', 'Gateway', 'Error', 'Date', 'Actions'],
      rows: _failedPayments.map((tx) {
        return [
          Text(
            (tx['id'] ?? '').toString().substring(0, 8),
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
          Text(tx['user_email'] ?? 'N/A'),
          Text(
            _currencyFormat.format((tx['amount'] as num?)?.toDouble() ?? 0),
            style: const TextStyle(color: AdminTheme.error, fontWeight: FontWeight.w600),
          ),
          Text(tx['plan_name'] ?? 'N/A'),
          Text(tx['payment_gateway'] ?? 'N/A'),
          Flexible(
            child: Text(
              tx['error_message'] ?? 'Unknown error',
              style: const TextStyle(fontSize: 11, color: AdminTheme.error),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            DateFormat('MMM d, yyyy').format(
              DateTime.tryParse(tx['created_at'] ?? '') ?? DateTime.now(),
            ),
            style: const TextStyle(fontSize: 12),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _retryPayment(tx),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                tooltip: 'Retry',
              ),
              IconButton(
                onPressed: () => _showTransactionDetails(tx),
                icon: const Icon(Icons.info_outline_rounded, size: 16),
                tooltip: 'Details',
              ),
            ],
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildRefundsTab() {
    if (_refunds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text('No refunds processed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                      )),
            ],
          ),
        ),
      );
    }

    return AdminDataTable(
      columns: ['ID', 'User', 'Amount', 'Plan', 'Gateway', 'Refund Reason', 'Date'],
      rows: _refunds.map((tx) {
        return [
          Text(
            (tx['id'] ?? '').toString().substring(0, 8),
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
          Text(tx['user_email'] ?? 'N/A'),
          Text(
            _currencyFormat.format((tx['amount'] as num?)?.toDouble() ?? 0),
            style: const TextStyle(color: AdminTheme.warning, fontWeight: FontWeight.w600),
          ),
          Text(tx['plan_name'] ?? 'N/A'),
          Text(tx['payment_gateway'] ?? 'N/A'),
          Flexible(
            child: Text(
              tx['refund_reason'] ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            DateFormat('MMM d, yyyy').format(
              DateTime.tryParse(tx['created_at'] ?? '') ?? DateTime.now(),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildBankAccountsTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Business Bank Accounts', style: Theme.of(context).textTheme.titleLarge),
            ElevatedButton.icon(
              onPressed: _showAddBankAccountDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Account'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_bankAccounts.isEmpty)
          Card(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text('No bank accounts configured',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                            )),
                  ],
                ),
              ),
            ),
          )
        else
          ..._bankAccounts.map((account) => _buildBankAccountCard(account)),
      ],
    );
  }

  Widget _buildBankAccountCard(Map<String, dynamic> account) {
    final isActive = account['is_active'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AdminTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: AdminTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        account['bank_name'] ?? 'Unknown Bank',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: isActive ? 'Primary' : 'Secondary',
                        type: isActive ? BadgeType.success : BadgeType.neutral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Account: ••••${account['account_number']?.toString().substring(account['account_number'].toString().length - 4) ?? '0000'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'IFSC: ${account['ifsc_code'] ?? 'N/A'} | Swift: ${account['swift_code'] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currencyFormat.format((account['balance'] as num?)?.toDouble() ?? 0),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AdminTheme.primary,
                      ),
                ),
                Text(
                  'Available Balance',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(width: 16),
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'statement', child: Text('View Statement')),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: const Text('Remove', style: TextStyle(color: AdminTheme.error)),
                ),
              ],
              onSelected: (v) {
                if (v == 'edit') _showEditBankAccountDialog(account);
                if (v == 'delete') _deleteBankAccount(account['id']);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Transaction ID', tx['id'] ?? 'N/A'),
              _buildDetailRow('User', tx['user_email'] ?? 'N/A'),
              _buildDetailRow('Amount', _currencyFormat.format((tx['amount'] as num?)?.toDouble() ?? 0)),
              _buildDetailRow('Currency', tx['currency'] ?? 'USD'),
              _buildDetailRow('Plan', tx['plan_name'] ?? 'N/A'),
              _buildDetailRow('Gateway', tx['payment_gateway'] ?? 'N/A'),
              _buildDetailRow('Gateway ID', tx['gateway_transaction_id'] ?? 'N/A'),
              _buildDetailRow('Status', tx['status'] ?? 'N/A'),
              if (tx['error_message'] != null)
                _buildDetailRow('Error', tx['error_message']),
              if (tx['refund_reason'] != null)
                _buildDetailRow('Refund Reason', tx['refund_reason']),
              _buildDetailRow(
                'Created',
                DateFormat('MMM d, yyyy HH:mm:ss').format(
                  DateTime.tryParse(tx['created_at'] ?? '') ?? DateTime.now(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _initiateRefund(Map<String, dynamic> tx) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Initiate Refund',
      content: 'Refund ${_currencyFormat.format((tx['amount'] as num?)?.toDouble() ?? 0)} to ${tx['user_email']}?',
      confirmLabel: 'Refund',
      confirmColor: AdminTheme.warning,
    );
    if (!confirmed) return;

    try {
      await _supabase.from('payments').update({
        'status': 'refunded',
        'refund_reason': 'Admin initiated refund',
        'refunded_at': DateTime.now().toIso8601String(),
      }).eq('id', tx['id']);
      _loadPaymentsData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process refund: $e')),
        );
      }
    }
  }

  Future<void> _retryPayment(Map<String, dynamic> tx) async {
    try {
      await _supabase.functions.invoke('retry-payment', body: {
        'payment_id': tx['id'],
      });
      _loadPaymentsData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to retry: $e')),
        );
      }
    }
  }

  void _showAddBankAccountDialog() {}
  void _showEditBankAccountDialog(Map<String, dynamic> account) {}

  Future<void> _deleteBankAccount(String id) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Remove Account',
      content: 'Are you sure you want to remove this bank account?',
      confirmLabel: 'Remove',
    );
    if (!confirmed) return;

    try {
      await _supabase.from('bank_accounts').delete().eq('id', id);
      _loadPaymentsData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove: $e')),
        );
      }
    }
  }
}
