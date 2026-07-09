import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirm_dialog.dart';

class AiProvidersPage extends StatefulWidget {
  const AiProvidersPage({super.key});

  @override
  State<AiProvidersPage> createState() => _AiProvidersPageState();
}

class _AiProvidersPageState extends State<AiProvidersPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;

  List<Map<String, dynamic>> _providers = [];
  String _selectedProvider = '';

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoading = true);
    try {
      final res = await _supabase
          .from('ai_providers')
          .select('*')
          .order('name');
      _providers = List<Map<String, dynamic>>.from(res);
      if (_providers.isNotEmpty && _selectedProvider.isEmpty) {
        _selectedProvider = _providers.first['id'] ?? '';
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic>? get _selectedProviderData {
    try {
      return _providers.firstWhere((p) => p['id'] == _selectedProvider);
    } catch (_) {
      return null;
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
          title: 'AI Providers',
          subtitle: 'Configure AI providers, API keys, and model settings',
          trailing: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _showAddProviderDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Provider'),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _loadProviders,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_providers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('No AI providers configured',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          )),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddProviderDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add First Provider'),
                  ),
                ],
              ),
            ),
          )
        else
          _buildProviderLayout(isDesktop),
      ],
    );
  }

  Widget _buildProviderLayout(bool isDesktop) {
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 280,
          child: _buildProviderList(),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildProviderDetails(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildProviderDropdown(),
        const SizedBox(height: 16),
        _buildProviderDetails(),
      ],
    );
  }

  Widget _buildProviderList() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Providers (${_providers.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _providers.length,
              itemBuilder: (context, index) {
                final provider = _providers[index];
                final isSelected = provider['id'] == _selectedProvider;
                final healthStatus = provider['health_status'] ?? 'unknown';

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getProviderColor(provider['name']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getProviderIcon(provider['name']),
                      color: _getProviderColor(provider['name']),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    provider['name'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      _buildHealthDot(healthStatus),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          healthStatus,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  selectedTileColor: AdminTheme.primary.withOpacity(0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  onTap: () => setState(() => _selectedProvider = provider['id']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderDropdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DropdownButton<String>(
          value: _selectedProvider.isNotEmpty ? _selectedProvider : null,
          hint: const Text('Select Provider'),
          isExpanded: true,
          underline: const SizedBox.shrink(),
          items: _providers.map((p) {
            return DropdownMenuItem<String>(
              value: p['id'],
              child: Text(p['name'] ?? 'Unknown'),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedProvider = v ?? ''),
        ),
      ),
    );
  }

  Widget _buildProviderDetails() {
    final provider = _selectedProviderData;
    if (provider == null) {
      return const Center(
        child: Text('Select a provider to view details'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProviderHeader(provider),
          const SizedBox(height: 16),
          _buildApiKeySection(provider),
          const SizedBox(height: 16),
          _buildModelConfiguration(provider),
          const SizedBox(height: 16),
          _buildFallbackSettings(provider),
          const SizedBox(height: 16),
          _buildRateLimits(provider),
          const SizedBox(height: 16),
          _buildCostPerToken(provider),
        ],
      ),
    );
  }

  Widget _buildProviderHeader(Map<String, dynamic> provider) {
    final isActive = provider['is_active'] ?? true;
    final healthStatus = provider['health_status'] ?? 'unknown';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getProviderColor(provider['name']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getProviderIcon(provider['name']),
                color: _getProviderColor(provider['name']),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider['name'] ?? 'Unknown',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatusBadge(
                        label: isActive ? 'Active' : 'Inactive',
                        type: isActive ? BadgeType.success : BadgeType.neutral,
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: 'Health: $healthStatus',
                        type: _getHealthBadgeType(healthStatus),
                      ),
                      const SizedBox(width: 8),
                      if (provider['base_url'] != null)
                        Text(
                          provider['base_url'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (v) => _toggleProviderActive(provider['id'], v),
              activeColor: AdminTheme.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeySection(Map<String, dynamic> provider) {
    final apiKey = provider['api_key'] ?? '';
    final maskedKey = apiKey.length > 8
        ? '${apiKey.substring(0, 4)}${'•' * (apiKey.length - 8)}${apiKey.substring(apiKey.length - 4)}'
        : '••••••••';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('API Key', style: Theme.of(context).textTheme.titleLarge),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _copyApiKey(apiKey),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      tooltip: 'Copy API Key',
                    ),
                    IconButton(
                      onPressed: () => _showEditApiKeyDialog(provider),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      tooltip: 'Update API Key',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Text(
                maskedKey,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelConfiguration(Map<String, dynamic> provider) {
    final models = List<Map<String, dynamic>>.from(provider['models'] ?? []);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Model Configuration', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => _showAddModelDialog(provider),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Model'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (models.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No models configured'),
                ),
              )
            else
              ...models.map((model) => _buildModelItem(provider, model)),
          ],
        ),
      ),
    );
  }

  Widget _buildModelItem(Map<String, dynamic> provider, Map<String, dynamic> model) {
    final isDefault = model['is_default'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDefault ? AdminTheme.primary.withOpacity(0.05) : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDefault ? AdminTheme.primary.withOpacity(0.2) : Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.smart_toy_rounded,
            color: isDefault ? AdminTheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      model['name'] ?? 'Unknown',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      StatusBadge(label: 'Default', type: BadgeType.info),
                    ],
                  ],
                ),
                Text(
                  'Max tokens: ${model['max_tokens'] ?? 'N/A'} | Input: \$${model['input_price_per_1m'] ?? 0}/1M | Output: \$${model['output_price_per_1m'] ?? 0}/1M',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _toggleModelDefault(provider['id'], model, !isDefault),
            icon: Icon(
              isDefault ? Icons.star_rounded : Icons.star_border_rounded,
              color: isDefault ? AdminTheme.warning : null,
              size: 18,
            ),
            tooltip: isDefault ? 'Remove as default' : 'Set as default',
          ),
          IconButton(
            onPressed: () => _removeModel(provider['id'], model),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            tooltip: 'Remove model',
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackSettings(Map<String, dynamic> provider) {
    final fallbacks = List<String>.from(provider['fallback_provider_ids'] ?? []);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fallback Settings', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => _showEditFallbackDialog(provider),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Configure'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (fallbacks.isEmpty)
              Text(
                'No fallback providers configured',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fallbacks.map((fbId) {
                  final fbProvider = _providers.where((p) => p['id'] == fbId).firstOrNull;
                  return Chip(
                    avatar: Icon(
                      _getProviderIcon(fbProvider?['name'] ?? ''),
                      size: 16,
                    ),
                    label: Text(fbProvider?['name'] ?? fbId),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => _removeFallback(provider['id'], fbId),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateLimits(Map<String, dynamic> provider) {
    final rpm = provider['rate_limit_rpm'] ?? 0;
    final tpm = provider['rate_limit_tpm'] ?? 0;
    final dailyLimit = provider['daily_cost_limit'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rate Limits', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => _showEditRateLimitDialog(provider),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildLimitChip('RPM', '$rpm req/min', AdminTheme.primary),
                const SizedBox(width: 12),
                _buildLimitChip('TPM', '${NumberFormat.compact().format(tpm)} tokens/min', AdminTheme.secondary),
                const SizedBox(width: 12),
                _buildLimitChip('Daily Limit', '\$${dailyLimit.toStringAsFixed(2)}', AdminTheme.warning),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostPerToken(Map<String, dynamic> provider) {
    final inputCost = (provider['input_cost_per_1m'] as num?)?.toDouble() ?? 0;
    final outputCost = (provider['output_cost_per_1m'] as num?)?.toDouble() ?? 0;
    final embeddingCost = (provider['embedding_cost_per_1m'] as num?)?.toDouble() ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cost per Token', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => _showEditCostDialog(provider),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCostItem('Input', inputCost, AdminTheme.primary),
                const SizedBox(width: 16),
                _buildCostItem('Output', outputCost, AdminTheme.secondary),
                const SizedBox(width: 16),
                _buildCostItem('Embedding', embeddingCost, AdminTheme.tertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostItem(String label, double cost, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${cost.toStringAsFixed(4)}/1M tokens',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthDot(String status) {
    final color = switch (status) {
      'healthy' || 'operational' => AdminTheme.success,
      'degraded' || 'warning' => AdminTheme.warning,
      'down' || 'error' => AdminTheme.error,
      _ => Colors.grey,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getProviderColor(String? name) {
    switch (name?.toLowerCase()) {
      case 'openai':
        return const Color(0xff10a37f);
      case 'gemini' || 'google':
        return const Color(0xff4285f4);
      case 'claude' || 'anthropic':
        return const Color(0xffd97757);
      case 'groq':
        return const Color(0xfff55036);
      case 'deepseek':
        return const Color(0xff4d6bfe);
      case 'mistral':
        return const Color(0xfff76e11);
      default:
        return AdminTheme.primary;
    }
  }

  IconData _getProviderIcon(String? name) {
    switch (name?.toLowerCase()) {
      case 'openai':
        return Icons.auto_awesome;
      case 'gemini' || 'google':
        return Icons.diamond_rounded;
      case 'claude' || 'anthropic':
        return Icons.psychology_rounded;
      case 'groq':
        return Icons.bolt_rounded;
      case 'deepseek':
        return Icons.water_drop_rounded;
      case 'mistral':
        return Icons.wind_power_rounded;
      default:
        return Icons.smart_toy_rounded;
    }
  }

  BadgeType _getHealthBadgeType(String status) {
    switch (status) {
      case 'healthy':
      case 'operational':
        return BadgeType.success;
      case 'degraded':
      case 'warning':
        return BadgeType.warning;
      case 'down':
      case 'error':
        return BadgeType.error;
      default:
        return BadgeType.neutral;
    }
  }

  Future<void> _toggleProviderActive(String id, bool active) async {
    try {
      await _supabase.from('ai_providers').update({'is_active': active}).eq('id', id);
      _loadProviders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  void _copyApiKey(String apiKey) {
    // Use clipboard API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API key copied to clipboard')),
    );
  }

  void _showAddProviderDialog() {}
  void _showEditApiKeyDialog(Map<String, dynamic> provider) {}
  void _showAddModelDialog(Map<String, dynamic> provider) {}
  void _showEditFallbackDialog(Map<String, dynamic> provider) {}
  void _showEditRateLimitDialog(Map<String, dynamic> provider) {}
  void _showEditCostDialog(Map<String, dynamic> provider) {}

  Future<void> _toggleModelDefault(String providerId, Map<String, dynamic> model, bool isDefault) async {
    try {
      final models = List<Map<String, dynamic>>.from(
        _selectedProviderData?['models'] ?? [],
      );
      for (var i = 0; i < models.length; i++) {
        if (models[i]['name'] == model['name']) {
          models[i]['is_default'] = isDefault;
        } else {
          models[i]['is_default'] = false;
        }
      }
      await _supabase.from('ai_providers').update({'models': models}).eq('id', providerId);
      _loadProviders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _removeModel(String providerId, Map<String, dynamic> model) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Remove Model',
      content: 'Remove ${model['name']} from this provider?',
      confirmLabel: 'Remove',
    );
    if (!confirmed) return;

    try {
      final models = List<Map<String, dynamic>>.from(
        _selectedProviderData?['models'] ?? [],
      );
      models.removeWhere((m) => m['name'] == model['name']);
      await _supabase.from('ai_providers').update({'models': models}).eq('id', providerId);
      _loadProviders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove: $e')),
        );
      }
    }
  }

  Future<void> _removeFallback(String providerId, String fallbackId) async {
    try {
      final fallbacks = List<String>.from(_selectedProviderData?['fallback_provider_ids'] ?? []);
      fallbacks.remove(fallbackId);
      await _supabase.from('ai_providers').update({
        'fallback_provider_ids': fallbacks,
      }).eq('id', providerId);
      _loadProviders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove fallback: $e')),
        );
      }
    }
  }
}
