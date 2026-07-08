import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class ManualPaymentPage extends StatefulWidget {
  final String planType;
  final String planName;
  final String amount;

  const ManualPaymentPage({
    super.key,
    required this.planType,
    required this.planName,
    required this.amount,
  });

  @override
  State<ManualPaymentPage> createState() => _ManualPaymentPageState();
}

class _ManualPaymentPageState extends State<ManualPaymentPage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _utrController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  File? _screenshotFile;
  bool _isLoading = false;
  Map<String, dynamic> _upiDetails = {};
  Map<String, dynamic> _bankDetails = {};

  @override
  void initState() {
    super.initState();
    // Default amount matching package
    _amountController.text = widget.amount.replaceAll(RegExp(r'[^\d.]'), '');
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _utrController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final results = await _supabase.from('payment_methods').select('*');
      for (final method in results) {
        if (method['method_type'] == 'upi') {
          setState(() {
            _upiDetails = method['details'] as Map<String, dynamic>? ?? {};
          });
        } else if (method['method_type'] == 'bank') {
          setState(() {
            _bankDetails = method['details'] as Map<String, dynamic>? ?? {};
          });
        }
      }
    } catch (_) {
      // Fallbacks
      setState(() {
        _upiDetails = {
          'upi_id': 'pay@companion',
          'payee_name': 'AI Language Companion Ltd',
        };
        _bankDetails = {
          'bank_name': 'Global Bank',
          'account_number': '9876543210',
          'ifsc': 'GLB0000123',
          'account_name': 'AI Language Companion Ltd',
        };
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _screenshotFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_screenshotFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a payment screenshot proof.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // 1. Fetch user profile primary key id
      final profile = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('auth_user_id', user.id)
          .single();

      final profileId = profile['id'];

      // 2. Upload screenshot to Supabase Storage
      final fileExt = _screenshotFile!.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_proof.$fileExt';
      // Structure inside folder of user to match foldername auth RLS check
      final storagePath = '${user.id}/$fileName';

      await _supabase.storage
          .from('payment-receipts')
          .upload(storagePath, _screenshotFile!);

      final screenshotUrl = _supabase.storage
          .from('payment-receipts')
          .getPublicUrl(storagePath);

      // 3. Write row to public.manual_payments
      await _supabase.from('manual_payments').insert({
        'user_id': profileId,
        'plan_type': widget.planType,
        'payment_method': 'upi', // Default UPI, or based on user tab selection
        'utr_number': _utrController.text.trim(),
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'screenshot_url': screenshotUrl,
        'payment_date': DateTime.now().toIso8601String(),
        'notes': _notesController.text.trim(),
        'status': 'pending',
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('🎉 Receipt Submitted!'),
            content: const Text(
              'Your payment proof has been successfully submitted. Our team will verify and activate your credits/subscription shortly.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // return to paywall
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit payment: ${e.toString().contains('duplicate key') ? 'UTR/Reference number already submitted' : e}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Manual Payment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchase: ${widget.planName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // ── Payment Details ──────────────────────────────────────
                    AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.base),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Details',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Divider(height: AppSpacing.lg),
                            if (_upiDetails.isNotEmpty) ...[
                              const Text('UPI ID', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text((_upiDetails['upi_id'] as String?) ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: AppSpacing.xs),
                              const Text('Payee Name', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text((_upiDetails['payee_name'] as String?) ?? '', style: const TextStyle(fontSize: 14)),
                              const Divider(),
                            ],
                            if (_bankDetails.isNotEmpty) ...[
                              const Text('Bank Account Details', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: AppSpacing.xs),
                              Text('Bank: ${_bankDetails['bank_name'] ?? ''}'),
                              Text('Account Name: ${_bankDetails['account_name'] ?? ''}'),
                              Text('Account Number: ${_bankDetails['account_number'] ?? ''}'),
                              Text('IFSC: ${_bankDetails['ifsc'] ?? ''}'),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    // ── Form Inputs ──────────────────────────────────────────
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount Paid',
                        prefixText: 'Rs ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Please enter amount paid';
                        if (double.tryParse(value) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.base),
                    TextFormField(
                      controller: _utrController,
                      decoration: const InputDecoration(
                        labelText: 'UTR / Transaction Reference Number',
                        hintText: '12-digit number (unique)',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'UTR/Reference number required';
                        if (value.trim().length < 6) return 'Enter a valid reference number';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.base),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.base),
                    // ── Screenshot Picker ────────────────────────────────────
                    const Text(
                      'Upload Screenshot Proof',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade100,
                        ),
                        child: _screenshotFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_screenshotFile!, fit: fitCoverImage()),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                  SizedBox(height: AppSpacing.xs),
                                  Text('Tap to pick screenshot from Gallery', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // ── Submit Button ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Submit for Verification',
                        onPressed: _submitVerification,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  BoxFit fitCoverImage() {
    return BoxFit.cover;
  }
}
