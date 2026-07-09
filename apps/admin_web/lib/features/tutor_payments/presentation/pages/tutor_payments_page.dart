import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/data_table_widget.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../widgets/payout_action_dialog.dart';

class TutorPaymentsPage extends StatefulWidget {
  const TutorPaymentsPage({super.key});

  @override
  State<TutorPaymentsPage> createState() => _TutorPaymentsPageState();
}

class _TutorPaymentsPageState extends State<TutorPaymentsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _payoutRequests = [];
  List<Map<String, dynamic>> _filteredPayouts = [];
  Map<String, dynamic>? _commissionSettings;

  double _totalPayouts = 0;
  double _pendingPayouts = 0;
  double _thisMonthPayouts = 0;
  double _commissionEarned = 0;

  final _statusFilters = ['All', 'pending', 'approved', 'processing', 'completed', 'rejected'];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _supabase
            .from('payout_requests')
            .select('*, user_profiles(full_name, email)')
            .order('created_at', ascending: false),
        _supabase.from('commission_settings').select().maybeSingle(),
      ]);

      final payouts = List<Map<String, dynamic>>.from(results[0] as List);
      final commission = results[1] as Map<String, dynamic>?;

      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      _totalPayouts = payouts
          .where((p) => (p['status'] ?? '') == 'completed')
          .fold<double>(
              0,
              (sum, p) => sum + (double.tryParse(p['amount'].toString()) ?? 0));

      _pendingPayouts = payouts
          .where((p) => (p['status'] ?? '') == 'pending')
          .fold<double>(
              0,
              (sum, p) => sum + (double.tryParse(p['amount'].toString()) ?? 0));

      _thisMonthPayouts = payouts.where((p) {
        final status = p['status'] ?? '';
        final createdAt = DateTime.tryParse(p['created_at'] ?? '') ?? DateTime.now();
        return status == 'completed' && createdAt.isAfter(monthStart);
      }).fold<double>(
          0,
          (sum, p) => sum + (double.tryParse(p['amount'].toString()) ?? 0));

      _commissionEarned = payouts
          .where((p) => (p['status'] ?? '') == 'completed')
          .fold<double>(
              0,
              (sum, p) =>
                  sum + (double.tryParse(p['commission_amount'].toString()) ?? 0));

      setState(() {
        _payoutRequests = payouts;
        _commissionSettings = commission;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load payments: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    var results = List<Map<String, dynamic>>.from(_payoutRequests);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = results.where((p) {
        final name =
            (p['user_profiles']?['full_name'] ?? '').toString().toLowerCase();
        final email =
            (p['user_profiles']?['email'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q);
      }).toList();
    }

    if (_statusFilter != 'All') {
      results = results
          .where((p) =>
              (p['status'] ?? '').toString().toLowerCase() ==
              _statusFilter.toLowerCase())
          .toList();
    }

    setState(() => _filteredPayouts = results);
  }

  Future<void> _handleApprove(Map<String, dynamic> payout) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => PayoutActionDialog(
        payout: payout,
        action: PayoutAction.approve,
      ),
    );

    if (result == null) return;

    try {
      await _supabase.from('payout_requests').update({
        'status': 'approved',
        'approved_at': DateTime.now().toIso8601String(),
        'approved_by': Supabase.instance.client.auth.currentUser?.id,
        'notes': result['notes'],
      }).eq('id', payout['id']);

      await _loadPayments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payout approved'),
            backgroundColor: AdminTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
        );
      }
    }
  }

  Future<void> _handleReject(Map<String, dynamic> payout) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => PayoutActionDialog(
        payout: payout,
        action: PayoutAction.reject,
      ),
    );

    if (result == null) return;

    try {
      await _supabase.from('payout_requests').update({
        'status': 'rejected',
        'rejected_at': DateTime.now().toIso8601String(),
        'rejected_by': Supabase.instance.client.auth.currentUser?.id,
        'rejection_reason': result['notes'],
      }).eq('id', payout['id']);

      await _loadPayments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payout rejected'),
            backgroundColor: AdminTheme.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
        );
      }
    }
  }

  Future<void> _handleDelay(Map<String, dynamic> payout) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delay Payout',
      content: 'Delay this payout by 7 days? The tutor will be notified.',
      confirmLabel: 'Delay',
      confirmColor: AdminTheme.warning,
    );
    if (!confirmed) return;

    try {
      final currentDeadline = payout['deadline'];
      final deadline =
          DateTime.tryParse(currentDeadline ?? '') ?? DateTime.now();
      final newDeadline = deadline.add(const Duration(days: 7));

      await _supabase.from('payout_requests').update({
        'deadline': newDeadline.toIso8601String(),
        'delayed_at': DateTime.now().toIso8601String(),
        'delayed_by': Supabase.instance.client.auth.currentUser?.id,
      }).eq('id', payout['id']);

      await _loadPayments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payout delayed by 7 days'),
            backgroundColor: AdminTheme.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    final val = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(symbol: '\$').format(val);
  }

  BadgeType _statusBadge(String? status) {
    return switch (status) {
      'approved' => BadgeType.success,
      'completed' => BadgeType.success,
      'pending' => BadgeType.warning,
      'processing' => BadgeType.info,
      'rejected' => BadgeType.error,
      _ => BadgeType.neutral,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Tutor Payments',
          subtitle: 'Manage payout requests and commission settings',
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AdminTheme.error),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AdminTheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadPayments,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildCommissionCard(),
          const SizedBox(height: 24),
          _buildFiltersAndSearch(),
          const SizedBox(height: 16),
          _buildPayoutsTable(),
        ],
      ],
    );
  }

  Widget _buildStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            StatCard(
              title: 'Total Payouts',
              value: _formatCurrency(_totalPayouts),
              subtitle: 'All-time completed',
              icon: Icons.account_balance_wallet_rounded,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Pending Payouts',
              value: _formatCurrency(_pendingPayouts),
              subtitle: 'Awaiting approval',
              icon: Icons.hourglass_top_rounded,
              color: AdminTheme.warning,
            ),
            StatCard(
              title: 'This Month',
              value: _formatCurrency(_thisMonthPayouts),
              subtitle: 'Current month payouts',
              icon: Icons.calendar_month_rounded,
              color: AdminTheme.primary,
              trend: 12.5,
            ),
            StatCard(
              title: 'Commission Earned',
              value: _formatCurrency(_commissionEarned),
              subtitle: 'Platform commission',
              icon: Icons.payments_rounded,
              color: AdminTheme.tertiary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommissionCard() {
    final commissionRate = _commissionSettings?['commission_rate'] ?? 20;
    final minPayout = _commissionSettings?['minimum_payout'] ?? 50;
    final payoutSchedule = _commissionSettings?['payout_schedule'] ?? 'weekly';
    final paymentMethods = _commissionSettings?['payment_methods'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_rounded,
                    size: 18, color: AdminTheme.primary),
                const SizedBox(width: 8),
                Text('Commission Settings',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 500;
                return isWide
                    ? Row(
                        children: [
                          _buildSettingItem(
                              'Commission Rate', '$commissionRate%'),
                          const SizedBox(width: 32),
                          _buildSettingItem(
                              'Minimum Payout', _formatCurrency(minPayout)),
                          const SizedBox(width: 32),
                          _buildSettingItem(
                              'Payout Schedule',
                              payoutSchedule.toString()[0].toUpperCase() +
                                  payoutSchedule.toString().substring(1)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSettingItem(
                              'Commission Rate', '$commissionRate%'),
                          const SizedBox(height: 12),
                          _buildSettingItem(
                              'Minimum Payout', _formatCurrency(minPayout)),
                          const SizedBox(height: 12),
                          _buildSettingItem(
                              'Payout Schedule',
                              payoutSchedule.toString()[0].toUpperCase() +
                                  payoutSchedule.toString().substring(1)),
                        ],
                      );
              },
            ),
            if (paymentMethods.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Accepted Payment Methods',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (paymentMethods as List).map<Widget>((method) {
                  return Chip(
                    label: Text(method.toString(),
                        style: const TextStyle(fontSize: 11)),
                    backgroundColor: AdminTheme.primary.withOpacity(0.06),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildFiltersAndSearch() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(
              controller: _searchController,
              hintText: 'Search by tutor name or email...',
              onChanged: (value) {
                _searchQuery = value;
                _applyFilter();
              },
            ),
            const SizedBox(height: 12),
            isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusFilterChips(),
                    ],
                  )
                : _buildStatusFilterChips(),
          ],
        );
      },
    );
  }

  Widget _buildStatusFilterChips() {
    return Wrap(
      spacing: 6,
      children: _statusFilters.map((status) {
        final isActive = _statusFilter == status;
        final label = status == 'All'
            ? 'All'
            : status[0].toUpperCase() + status.substring(1);
        return ChoiceChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          selected: isActive,
          onSelected: (_) {
            setState(() => _statusFilter = status);
            _applyFilter();
          },
          selectedColor: AdminTheme.primary.withOpacity(0.1),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive
                ? AdminTheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPayoutsTable() {
    final columns = [
      'Tutor',
      'Amount',
      'Commission',
      'Net Payout',
      'Status',
      'Requested',
      'Actions',
    ];

    final rows = _filteredPayouts.map((payout) {
      final tutorName = payout['user_profiles']?['full_name'] ?? 'Unknown';
      final tutorEmail = payout['user_profiles']?['email'] ?? '';
      final amount = payout['amount'] ?? 0;
      final commission = payout['commission_amount'] ?? 0;
      final netPayout = (double.tryParse(amount.toString()) ?? 0) -
          (double.tryParse(commission.toString()) ?? 0);
      final status = payout['status'] ?? 'pending';
      final createdAt = payout['created_at'];
      final avatarLetter =
          tutorName.toString().isNotEmpty ? tutorName.toString()[0].toUpperCase() : '?';

      return [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AdminTheme.primary.withOpacity(0.1),
              child: Text(
                avatarLetter,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.primary),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tutorName.toString(),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(tutorEmail.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        Text(_formatCurrency(amount),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(_formatCurrency(commission),
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.6))),
        Text(_formatCurrency(netPayout),
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AdminTheme.success)),
        StatusBadge(
          label: status.toString().toUpperCase(),
          type: _statusBadge(status),
        ),
        Text(_formatDate(createdAt)),
        _buildActionsMenu(payout),
      ];
    }).toList();

    return AdminDataTable(
      columns: columns,
      rows: rows,
    );
  }

  Widget _buildActionsMenu(Map<String, dynamic> payout) {
    final status = payout['status'] ?? '';

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18),
      onSelected: (action) {
        switch (action) {
          case 'approve':
            _handleApprove(payout);
            break;
          case 'reject':
            _handleReject(payout);
            break;
          case 'delay':
            _handleDelay(payout);
            break;
        }
      },
      itemBuilder: (context) => [
        if (status == 'pending') ...[
          const PopupMenuItem(
            value: 'approve',
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 16, color: AdminTheme.success),
                SizedBox(width: 8),
                Text('Approve', style: TextStyle(color: AdminTheme.success)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delay',
            child: Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 16, color: AdminTheme.warning),
                SizedBox(width: 8),
                Text('Delay 7 Days',
                    style: TextStyle(color: AdminTheme.warning)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'reject',
            child: Row(
              children: [
                Icon(Icons.cancel_rounded,
                    size: 16, color: AdminTheme.error),
                SizedBox(width: 8),
                Text('Reject', style: TextStyle(color: AdminTheme.error)),
              ],
            ),
          ),
        ] else
          const PopupMenuItem(
            value: 'approve',
            enabled: false,
            child: Text('No actions available'),
          ),
      ],
    );
  }
}
