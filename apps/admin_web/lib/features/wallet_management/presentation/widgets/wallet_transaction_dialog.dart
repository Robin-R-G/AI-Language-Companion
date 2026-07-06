import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';

class WalletTransactionDialog extends StatefulWidget {
  final String type;
  final Map<String, dynamic>? data;

  const WalletTransactionDialog({
    super.key,
    required this.type,
    this.data,
  });

  @override
  State<WalletTransactionDialog> createState() => _WalletTransactionDialogState();
}

class _WalletTransactionDialogState extends State<WalletTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _creditsController;
  late TextEditingController _priceController;
  late TextEditingController _bonusController;
  late TextEditingController _descriptionController;
  bool _isPopular = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data?['name'] ?? '');
    _creditsController = TextEditingController(
      text: (widget.data?['credits'] ?? '').toString(),
    );
    _priceController = TextEditingController(
      text: (widget.data?['price'] ?? '').toString(),
    );
    _bonusController = TextEditingController(
      text: (widget.data?['bonus_credits'] ?? '0').toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.data?['description'] ?? '',
    );
    _isPopular = widget.data?['is_popular'] ?? false;
    _isActive = widget.data?['is_active'] ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditsController.dispose();
    _priceController.dispose();
    _bonusController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.type == 'edit_pack';

    return AlertDialog(
      title: Text(isEdit ? 'Edit Credit Pack' : 'Add Credit Pack'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(
                  label: 'Pack Name',
                  controller: _nameController,
                  hint: 'e.g., Starter Pack',
                  validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Credits',
                  controller: _creditsController,
                  hint: 'e.g., 100',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Credits is required';
                    if (int.tryParse(v) == null || int.parse(v) <= 0) {
                      return 'Must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Price (USD)',
                  controller: _priceController,
                  hint: 'e.g., 9.99',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefix: const Text('\$ '),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Price is required';
                    if (double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Must be a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Bonus Credits',
                  controller: _bonusController,
                  hint: 'e.g., 10',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      if (int.tryParse(v) == null || int.parse(v) < 0) {
                        return 'Must be a non-negative number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Description',
                  controller: _descriptionController,
                  hint: 'Pack description (optional)',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Popular', style: TextStyle(fontSize: 13)),
                        subtitle: Text(
                          'Mark as recommended',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                        value: _isPopular,
                        onChanged: (v) => setState(() => _isPopular = v),
                        activeColor: AdminTheme.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Active', style: TextStyle(fontSize: 13)),
                        subtitle: Text(
                          'Available for purchase',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        activeColor: AdminTheme.success,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Update Pack' : 'Add Pack'),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    Widget? prefix,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefix: prefix,
            isDense: true,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final packData = {
        'name': _nameController.text.trim(),
        'credits': int.parse(_creditsController.text.trim()),
        'price': double.parse(_priceController.text.trim()),
        'bonus_credits': int.tryParse(_bonusController.text.trim()) ?? 0,
        'description': _descriptionController.text.trim(),
        'is_popular': _isPopular,
        'is_active': _isActive,
      };

      if (widget.type == 'edit_pack' && widget.data != null) {
        await _supabase
            .from('credit_packs')
            .update(packData)
            .eq('id', widget.data!['id']);
      } else {
        await _supabase.from('credit_packs').insert(packData);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
