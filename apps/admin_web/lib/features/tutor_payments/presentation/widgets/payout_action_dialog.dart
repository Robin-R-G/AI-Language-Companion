import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';

enum PayoutAction { approve, reject }

class PayoutActionDialog extends StatefulWidget {
  final Map<String, dynamic> payout;
  final PayoutAction action;

  const PayoutActionDialog({
    super.key,
    required this.payout,
    required this.action,
  });

  @override
  State<PayoutActionDialog> createState() => _PayoutActionDialogState();
}

class _PayoutActionDialogState extends State<PayoutActionDialog> {
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    final val = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(symbol: '\$').format(val);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isApprove = widget.action == PayoutAction.approve;
    final tutorName =
        widget.payout['user_profiles']?['full_name'] ?? 'Unknown Tutor';
    final amount = widget.payout['amount'] ?? 0;
    final commission = widget.payout['commission_amount'] ?? 0;
    final netPayout = (double.tryParse(amount.toString()) ?? 0) -
        (double.tryParse(commission.toString()) ?? 0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(maxWidth: 480),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isApprove
                    ? AdminTheme.success.withOpacity(0.04)
                    : AdminTheme.error.withOpacity(0.04),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isApprove ? AdminTheme.success : AdminTheme.error)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isApprove
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color:
                          isApprove ? AdminTheme.success : AdminTheme.error,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isApprove ? 'Approve Payout' : 'Reject Payout',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'To $tutorName',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildAmountRow('Gross Amount', _formatCurrency(amount)),
                        const SizedBox(height: 8),
                        _buildAmountRow(
                            'Commission',
                            '-${_formatCurrency(commission)}',
                            isNegative: true),
                        const Divider(height: 16),
                        _buildAmountRow(
                          'Net Payout',
                          _formatCurrency(netPayout),
                          isBold: true,
                          color: AdminTheme.success,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isApprove ? 'Admin Notes (Optional)' : 'Rejection Reason',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    validator: isApprove
                        ? null
                        : (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please provide a rejection reason';
                            }
                            return null;
                          },
                    decoration: InputDecoration(
                      hintText: isApprove
                          ? 'Add any notes about this payout...'
                          : 'Explain why this payout is being rejected...',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.of(context).pop({
                                'notes': _notesController.text.trim(),
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isApprove ? AdminTheme.success : AdminTheme.error,
                          ),
                          child: Text(
                            isApprove ? 'Approve Payout' : 'Reject Payout',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, String value,
      {bool isBold = false, bool isNegative = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: color)),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color ??
                (isNegative
                    ? AdminTheme.error
                    : Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}
