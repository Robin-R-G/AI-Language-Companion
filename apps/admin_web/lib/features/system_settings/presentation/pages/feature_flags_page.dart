import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/data_table_widget.dart';

class FeatureFlagsPage extends StatefulWidget {
  const FeatureFlagsPage({super.key});

  @override
  State<FeatureFlagsPage> createState() => _FeatureFlagsPageState();
}

class _FeatureFlagsPageState extends State<FeatureFlagsPage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _flags = [];
  List<Map<String, dynamic>> _filteredFlags = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final flagsRes = await _supabase
          .from('feature_flags')
          .select('*')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _flags = List<Map<String, dynamic>>.from(flagsRes);
          _applySearch();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load feature flags: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFlags = _flags.where((f) {
        return query.isEmpty ||
            (f['name'] ?? '').toString().toLowerCase().contains(query) ||
            (f['description'] ?? '').toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _toggleFlag(Map<String, dynamic> flag, bool newValue) async {
    try {
      await _supabase
          .from('feature_flags')
          .update({
            'is_enabled': newValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', flag['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue
                  ? 'Flag "${flag['name']}" enabled'
                  : 'Flag "${flag['name']}" disabled',
            ),
            backgroundColor: AdminTheme.success,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
        );
      }
    }
  }

  Future<void> _showFlagDialog({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final nameController = TextEditingController(text: existing?['name'] ?? '');
    final descController = TextEditingController(text: existing?['description'] ?? '');
    final keyController = TextEditingController(text: existing?['flag_key'] ?? '');
    bool isEnabled = existing?['is_enabled'] ?? false;
    String percentage = (existing?['rollout_percentage'] ?? 100).toString();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Feature Flag' : 'New Feature Flag'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Flag Name'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: keyController,
                      decoration: const InputDecoration(
                        labelText: 'Flag Key',
                        helperText: 'Unique identifier (e.g., dark_mode_enabled)',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enabled'),
                      value: isEnabled,
                      onChanged: (v) => setDialogState(() => isEnabled = v),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: percentage,
                      decoration: const InputDecoration(
                        labelText: 'Rollout Percentage',
                        helperText: '0-100% of users who see this flag',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => percentage = v,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
              },
              child: Text(isEdit ? 'Save Changes' : 'Create Flag'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final data = {
          'name': nameController.text.trim(),
          'flag_key': keyController.text.trim(),
          'description': descController.text.trim(),
          'is_enabled': isEnabled,
          'rollout_percentage': int.tryParse(percentage) ?? 100,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (isEdit) {
          await _supabase.from('feature_flags').update(data).eq('id', existing!['id']);
        } else {
          data['created_at'] = DateTime.now().toIso8601String();
          data['usage_count'] = 0;
          await _supabase.from('feature_flags').insert(data);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit ? 'Flag updated' : 'Flag created'),
              backgroundColor: AdminTheme.success,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
          );
        }
      }
    }
  }

  Future<void> _deleteFlag(Map<String, dynamic> flag) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Feature Flag',
      content: 'Delete flag "${flag['name']}"? This may affect users currently using it.',
      confirmLabel: 'Delete',
      confirmColor: AdminTheme.error,
    );

    if (confirmed) {
      try {
        await _supabase.from('feature_flags').delete().eq('id', flag['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Flag deleted'), backgroundColor: AdminTheme.success),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
          );
        }
      }
    }
  }

  void _showTargetingRules(Map<String, dynamic> flag) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Targeting: ${flag['name']}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flag Key: ${flag['flag_key']}'),
              Text('Rollout: ${flag['rollout_percentage'] ?? 100}%'),
              const Divider(height: 24),
              const Text('Targeting Rules',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _targetRule('User Role', 'premium'),
              _targetRule('Country', 'US, UK, CA'),
              _targetRule('App Version', '>= 2.0'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Targeting editor')),
              );
            },
            child: const Text('Edit Rules'),
          ),
        ],
      ),
    );
  }

  Widget _targetRule(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          StatusBadge(label: label, type: BadgeType.info),
          const SizedBox(width: 12),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Feature Flags',
            subtitle: 'Toggle features, manage rollouts, and targeting',
            actions: [
              ElevatedButton.icon(
                onPressed: () => _showFlagDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Flag'),
              ),
            ],
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AdminTheme.error),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: AdminTheme.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SearchField(
                              hintText: 'Search flags...',
                              controller: _searchController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          StatusBadge(
                            label: '${_flags.where((f) => f['is_enabled'] == true).length} active',
                            type: BadgeType.success,
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(
                            label: '${_flags.where((f) => f['is_enabled'] != true).length} inactive',
                            type: BadgeType.neutral,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AdminDataTable(
                      columns: ['Name', 'Key', 'Status', 'Rollout', 'Usage', 'Actions'],
                      rows: _filteredFlags.map((flag) {
                        return [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(flag['name'] ?? '-',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (flag['description'] != null &&
                                  (flag['description'] as String).isNotEmpty)
                                Text(
                                  flag['description'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          Text(
                            flag['flag_key'] ?? '-',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                          Switch(
                            value: flag['is_enabled'] ?? false,
                            onChanged: (v) => _toggleFlag(flag, v),
                            activeColor: AdminTheme.success,
                          ),
                          Text('${flag['rollout_percentage'] ?? 100}%'),
                          Text('${flag['usage_count'] ?? 0}'),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                tooltip: 'Edit',
                                onPressed: () => _showFlagDialog(existing: flag),
                              ),
                              IconButton(
                                icon: const Icon(Icons.alt_route, size: 18),
                                tooltip: 'Targeting Rules',
                                onPressed: () => _showTargetingRules(flag),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                tooltip: 'Delete',
                                onPressed: () => _deleteFlag(flag),
                              ),
                            ],
                          ),
                        ];
                      }).toList(),
                      emptyState: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flag_outlined, size: 64, color: AdminTheme.primaryLight),
                              SizedBox(height: 16),
                              Text('No feature flags'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
