import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/status_badge.dart';

class SubscriptionDetailDialog extends StatefulWidget {
  final Map<String, dynamic> subscription;

  const SubscriptionDetailDialog({super.key, required this.subscription});

  @override
  State<SubscriptionDetailDialog> createState() =>
      _SubscriptionDetailDialogState();
}

class _SubscriptionDetailDialogState extends State<SubscriptionDetailDialog> {
  List<Map<String, dynamic>> _paymentHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _loadPaymentHistory() async {
    try {
      final response = await _supabase
          .from('payment_history')
          .select()
          .eq('subscription_id', widget.subscription['id'] ?? '')
          .order('created_at', ascending: false)
          .limit(20);

      setState(() {
        _paymentHistory = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
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
      'active' => BadgeType.success,
      'cancelled' => BadgeType.error,
      'expired' => BadgeType.warning,
      'trialing' => BadgeType.info,
      _ => BadgeType.neutral,
    };
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.subscription;
    final userName = sub['user_profiles']?['full_name'] ?? 'Unknown User';
    final userEmail = sub['user_profiles']?['email'] ?? '';
    final plan = sub['plan'] ?? 'Free';
    final status = sub['status'] ?? 'unknown';
    final amount = sub['amount'] ?? 0;
    final billingCycle = sub['billing_cycle'] ?? 'monthly';
    final startDate = sub['start_date'] ?? sub['created_at'];
    final nextBilling = sub['next_billing_date'];
    final cancelledAt = sub['cancelled_at'];
    final cancelReason = sub['cancel_reason'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width > 800
            ? 640
            : MediaQuery.of(context).size.width * 0.95,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(sub),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(userName, userEmail),
                  const SizedBox(height: 24),
                  _buildSubscriptionInfo(
                      plan, status, amount, billingCycle, startDate, nextBilling),
                  if (cancelledAt != null) ...[
                    const SizedBox(height: 24),
                    _buildCancellationInfo(cancelledAt, cancelReason),
                  ],
                  const SizedBox(height: 24),
                  _buildPaymentHistorySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> sub) {
    final plan = sub['plan'] ?? 'Free';
    final status = sub['status'] ?? 'unknown';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.card_membership_rounded,
                color: AdminTheme.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$plan Plan',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StatusBadge(
                      label: status.toString().toUpperCase(),
                      type: _statusBadge(status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      billingCycleLabel(sub['billing_cycle']),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(String name, String email) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AdminTheme.primary.withOpacity(0.1),
          child: Text(
            name.toString().isNotEmpty ? name.toString()[0].toUpperCase() : '?',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AdminTheme.primary),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name.toString(),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            Text(email.toString(),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscriptionInfo(String plan, String status, dynamic amount,
      String billingCycle, String? startDate, String? nextBilling) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subscription Details',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _buildDetailRow('Plan', plan),
            _buildDetailRow('Status', status.toUpperCase()),
            _buildDetailRow('Amount', _formatCurrency(amount)),
            _buildDetailRow('Billing Cycle', billingCycleLabel(billingCycle)),
            _buildDetailRow('Start Date', _formatDate(startDate)),
            _buildDetailRow('Next Billing', _formatDate(nextBilling)),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationInfo(String cancelledAt, String? cancelReason) {
    return Card(
      color: AdminTheme.error.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cancel_rounded,
                    color: AdminTheme.error, size: 16),
                const SizedBox(width: 8),
                Text('Cancellation',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AdminTheme.error,
                        )),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Cancelled On', _formatDate(cancelledAt)),
            if (cancelReason != null && cancelReason.isNotEmpty)
              _buildDetailRow('Reason', cancelReason),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment History',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_paymentHistory.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No payment history',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          )
        else
          ..._paymentHistory.map((payment) {
            final amount = payment['amount'] ?? 0;
            final createdAt = payment['created_at'];
            final paymentStatus = payment['status'] ?? 'completed';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    paymentStatus == 'completed'
                        ? Icons.check_circle_rounded
                        : Icons.error_rounded,
                    size: 16,
                    color: paymentStatus == 'completed'
                        ? AdminTheme.success
                        : AdminTheme.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatCurrency(amount),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(_formatDate(createdAt),
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: paymentStatus.toString().toUpperCase(),
                    type: paymentStatus == 'completed'
                        ? BadgeType.success
                        : BadgeType.error,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.5))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  String billingCycleLabel(dynamic cycle) {
    final c = (cycle ?? 'monthly').toString();
    return c[0].toUpperCase() + c.substring(1);
  }
}
