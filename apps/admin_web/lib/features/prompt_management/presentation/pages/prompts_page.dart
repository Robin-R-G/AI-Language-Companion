import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirm_dialog.dart';

class PromptsPage extends StatefulWidget {
  const PromptsPage({super.key});

  @override
  State<PromptsPage> createState() => _PromptsPageState();
}

class _PromptsPageState extends State<PromptsPage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  bool _isLoading = true;

  List<Map<String, dynamic>> _prompts = [];
  List<Map<String, dynamic>> _filteredPrompts = [];
  List<Map<String, dynamic>> _categories = [];
  String _selectedCategory = 'all';
  String _selectedPrompt = '';

  @override
  void initState() {
    super.initState();
    _loadPrompts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrompts() async {
    setState(() => _isLoading = true);
    try {
      final promptsRes = await _supabase
          .from('prompts')
          .select('*')
          .order('created_at', ascending: false);
      _prompts = List<Map<String, dynamic>>.from(promptsRes);
      _filteredPrompts = List.from(_prompts);

      final catRes = await _supabase.from('prompt_categories').select('*');
      _categories = List<Map<String, dynamic>>.from(catRes);

      if (_prompts.isNotEmpty && _selectedPrompt.isEmpty) {
        _selectedPrompt = _prompts.first['id'] ?? '';
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterPrompts(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredPrompts = _prompts.where((p) {
        final name = p['name']?.toString().toLowerCase() ?? '';
        final content = p['content']?.toString().toLowerCase() ?? '';
        final category = p['category']?.toString().toLowerCase() ?? '';
        final matchesSearch = name.contains(q) || content.contains(q);
        final matchesCategory = _selectedCategory == 'all' || category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _filterByCategory(String category) {
    setState(() => _selectedCategory = category);
    _filterPrompts(_searchController.text);
  }

  Map<String, dynamic>? get _selectedPromptData {
    try {
      return _prompts.firstWhere((p) => p['id'] == _selectedPrompt);
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
          title: 'Prompt Manager',
          subtitle: 'Create, edit, and manage AI prompts and templates',
          trailing: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _showCreatePromptDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Prompt'),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _loadPrompts,
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
        else if (_prompts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('No prompts created yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          )),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showCreatePromptDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Create First Prompt'),
                  ),
                ],
              ),
            ),
          )
        else
          _buildContent(isDesktop),
      ],
    );
  }

  Widget _buildContent(bool isDesktop) {
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _buildFiltersRow(),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 360,
                child: _buildPromptList(),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildPromptDetails(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildFiltersRow(),
        const SizedBox(height: 16),
        _buildPromptDropdown(),
        const SizedBox(height: 16),
        _buildPromptDetails(),
      ],
    );
  }

  Widget _buildFiltersRow() {
    return Row(
      children: [
        Expanded(
          child: SearchField(
            hintText: 'Search prompts...',
            controller: _searchController,
            onChanged: _filterPrompts,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isDense: true,
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Categories')),
                ..._categories.map((c) {
                  return DropdownMenuItem(
                    value: c['name'],
                    child: Text(c['name'] ?? 'Unknown'),
                  );
                }),
              ],
              onChanged: (v) => _filterByCategory(v ?? 'all'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptList() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Prompts (${_filteredPrompts.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPrompts.length,
              itemBuilder: (context, index) {
                final prompt = _filteredPrompts[index];
                final isSelected = prompt['id'] == _selectedPrompt;
                final isActive = prompt['is_active'] ?? true;
                final usageCount = (prompt['usage_count'] as num?)?.toInt() ?? 0;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AdminTheme.success.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chat_rounded,
                      color: isActive ? AdminTheme.success : Colors.grey,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    prompt['name'] ?? 'Untitled',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        prompt['category'] ?? 'General',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.show_chart_rounded,
                        size: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$usageCount',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  selectedTileColor: AdminTheme.primary.withOpacity(0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  onTap: () => setState(() => _selectedPrompt = prompt['id']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptDropdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedPrompt.isNotEmpty ? _selectedPrompt : null,
            hint: const Text('Select Prompt'),
            isExpanded: true,
            items: _filteredPrompts.map((p) {
              return DropdownMenuItem<String>(
                value: p['id'],
                child: Text(p['name'] ?? 'Untitled'),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedPrompt = v ?? ''),
          ),
        ),
      ),
    );
  }

  Widget _buildPromptDetails() {
    final prompt = _selectedPromptData;
    if (prompt == null) {
      return const Center(
        child: Text('Select a prompt to view details'),
      );
    }

    final isActive = prompt['is_active'] ?? true;
    final usageCount = (prompt['usage_count'] as num?)?.toInt() ?? 0;
    final avgRating = (prompt['avg_rating'] as num?)?.toDouble() ?? 0;
    final versions = List<Map<String, dynamic>>.from(prompt['versions'] ?? []);
    final abTest = prompt['ab_test'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPromptHeader(prompt, isActive),
          const SizedBox(height: 16),
          _buildPromptContent(prompt),
          const SizedBox(height: 16),
          _buildUsageStats(prompt, usageCount, avgRating),
          const SizedBox(height: 16),
          _buildVersionHistory(versions),
          const SizedBox(height: 16),
          _buildABTestSection(abTest),
        ],
      ),
    );
  }

  Widget _buildPromptHeader(Map<String, dynamic> prompt, bool isActive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prompt['name'] ?? 'Untitled',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatusBadge(
                        label: prompt['category'] ?? 'General',
                        type: BadgeType.info,
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: isActive ? 'Active' : 'Inactive',
                        type: isActive ? BadgeType.success : BadgeType.neutral,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'v${prompt['version'] ?? 1}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (v) => _togglePromptActive(prompt['id'], v),
              activeColor: AdminTheme.success,
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _showEditPromptDialog(prompt),
              icon: const Icon(Icons.edit_rounded, size: 18),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: () => _deletePrompt(prompt['id']),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptContent(Map<String, dynamic> prompt) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prompt Content', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => _showEditPromptDialog(prompt),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Text(
                prompt['content'] ?? 'No content',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
            if (prompt['variables'] != null) ...[
              const SizedBox(height: 12),
              Text('Variables:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (List<String>.from(prompt['variables'] ?? [])).map((v) {
                  return Chip(
                    label: Text('{{$v}}', style: const TextStyle(fontSize: 12)),
                    backgroundColor: AdminTheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(color: AdminTheme.primary),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsageStats(
    Map<String, dynamic> prompt,
    int usageCount,
    double avgRating,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usage Statistics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem('Total Uses', '$usageCount', AdminTheme.primary),
                const SizedBox(width: 16),
                _buildStatItem('Avg Rating', avgRating.toStringAsFixed(1), AdminTheme.warning),
                const SizedBox(width: 16),
                _buildStatItem(
                  'Last Used',
                  prompt['last_used_at'] != null
                      ? DateFormat('MMM d').format(DateTime.parse(prompt['last_used_at']))
                      : 'Never',
                  AdminTheme.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
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
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionHistory(List<Map<String, dynamic>> versions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (versions.isEmpty)
              const Text('No version history available')
            else
              ...versions.take(5).map((v) {
                final createdAt = DateTime.tryParse(v['created_at'] ?? '') ?? DateTime.now();
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AdminTheme.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'v${v['version'] ?? '?'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AdminTheme.info,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          v['summary'] ?? 'Updated',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy').format(createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                      ),
                    ],
                  ),
                );
              }),
        ],
      ),
      ),
    );
  }

  Widget _buildABTestSection(dynamic abTest) {
    final hasTest = abTest != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('A/B Test Configuration', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => _showABTestDialog(),
                  icon: Icon(
                    hasTest ? Icons.edit_rounded : Icons.add_rounded,
                    size: 16,
                  ),
                  label: Text(hasTest ? 'Edit Test' : 'Start Test'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!hasTest)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.science_rounded,
                      size: 32,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No A/B test running',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminTheme.info.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AdminTheme.info.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge(label: 'Active Test', type: BadgeType.info),
                        const SizedBox(width: 8),
                        Text(
                          'Started: ${DateFormat('MMM d').format(DateTime.tryParse(abTest['started_at'] ?? '') ?? DateTime.now())}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildABVariant('A', abTest['variant_a_split'] ?? 50, abTest['variant_a_metric'] ?? 0),
                        const SizedBox(width: 16),
                        _buildABVariant('B', abTest['variant_b_split'] ?? 50, abTest['variant_b_metric'] ?? 0),
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

  Widget _buildABVariant(String label, int split, double metric) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Variant $label',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text('$split% traffic', style: const TextStyle(fontSize: 11)),
            Text(
              'Metric: ${metric.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 11,
                color: AdminTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePromptActive(String id, bool active) async {
    try {
      await _supabase.from('prompts').update({'is_active': active}).eq('id', id);
      _loadPrompts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _deletePrompt(String id) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Prompt',
      content: 'Are you sure you want to delete this prompt? This action cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;

    try {
      await _supabase.from('prompts').delete().eq('id', id);
      setState(() => _selectedPrompt = '');
      _loadPrompts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  void _showCreatePromptDialog() {}
  void _showEditPromptDialog(Map<String, dynamic> prompt) {}
  void _showABTestDialog() {}
}
