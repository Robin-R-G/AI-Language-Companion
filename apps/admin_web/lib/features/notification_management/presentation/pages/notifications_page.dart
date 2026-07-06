import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/data_table_widget.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _templates = [];
  List<Map<String, dynamic>> _scheduled = [];
  List<Map<String, dynamic>> _filteredHistory = [];

  int _sentToday = 0;
  int _totalSent = 0;
  double _deliveryRate = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final historyRes = await _supabase
          .from('notification_history')
          .select('*')
          .order('created_at', ascending: false)
          .limit(100);

      final templatesRes = await _supabase
          .from('notification_templates')
          .select('*')
          .order('created_at', ascending: false);

      final scheduledRes = await _supabase
          .from('scheduled_notifications')
          .select('*')
          .order('scheduled_at', ascending: true);

      final history = List<Map<String, dynamic>>.from(historyRes);
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      if (mounted) {
        setState(() {
          _history = history;
          _templates = List<Map<String, dynamic>>.from(templatesRes);
          _scheduled = List<Map<String, dynamic>>.from(scheduledRes);
          _sentToday = history.where((h) {
            final createdAt = DateTime.tryParse(h['created_at'] ?? '');
            return createdAt != null && createdAt.isAfter(todayStart);
          }).length;
          _totalSent = history.length;
          _deliveryRate = history.isNotEmpty
              ? history.where((h) => h['delivered'] == true).length /
                  history.length *
                  100
              : 0;
          _applySearch();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load notifications: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHistory = _history.where((n) {
        return query.isEmpty ||
            (n['title'] ?? '').toString().toLowerCase().contains(query) ||
            (n['message'] ?? '').toString().toLowerCase().contains(query) ||
            (n['type'] ?? '').toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _showSendPushDialog() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String targetType = 'all';
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Send Push Notification'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: bodyController,
                      decoration: const InputDecoration(labelText: 'Message Body'),
                      maxLines: 3,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: targetType,
                      decoration: const InputDecoration(labelText: 'Target Audience'),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Users')),
                        DropdownMenuItem(value: 'active', child: Text('Active Users')),
                        DropdownMenuItem(value: 'premium', child: Text('Premium Users')),
                        DropdownMenuItem(value: 'inactive', child: Text('Inactive Users')),
                        DropdownMenuItem(value: 'students', child: Text('Students Only')),
                      ],
                      onChanged: (v) => setDialogState(() => targetType = v ?? 'all'),
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
            ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Send Now'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        await _supabase.from('notification_history').insert({
          'title': titleController.text.trim(),
          'message': bodyController.text.trim(),
          'type': 'push',
          'target': targetType,
          'delivered': true,
          'sent_by': _supabase.auth.currentUser?.id,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Push notification sent'),
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

  Future<void> _showEmailCampaignDialog() async {
    final subjectController = TextEditingController();
    final bodyController = TextEditingController();
    String audienceType = 'all';
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Email Campaign'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: subjectController,
                      decoration: const InputDecoration(labelText: 'Email Subject'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: bodyController,
                      decoration: const InputDecoration(labelText: 'Email Body (HTML)'),
                      maxLines: 6,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: audienceType,
                      decoration: const InputDecoration(labelText: 'Audience'),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Users')),
                        DropdownMenuItem(value: 'subscribers', child: Text('Subscribers')),
                        DropdownMenuItem(value: 'trial', child: Text('Trial Users')),
                        DropdownMenuItem(value: 'churned', child: Text('Churned Users')),
                      ],
                      onChanged: (v) => setDialogState(() => audienceType = v ?? 'all'),
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
            ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
              },
              icon: const Icon(Icons.email_outlined, size: 16),
              label: const Text('Send Campaign'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        await _supabase.from('notification_history').insert({
          'title': subjectController.text.trim(),
          'message': bodyController.text.trim(),
          'type': 'email',
          'target': audienceType,
          'delivered': true,
          'sent_by': _supabase.auth.currentUser?.id,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email campaign sent'),
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

  Future<void> _showTemplateDialog({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final nameController = TextEditingController(text: existing?['name'] ?? '');
    final subjectController = TextEditingController(text: existing?['subject'] ?? '');
    final bodyController = TextEditingController(text: existing?['body'] ?? '');
    String templateType = existing?['type'] ?? 'push';
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Template' : 'New Template'),
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
                      decoration: const InputDecoration(labelText: 'Template Name'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: templateType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const [
                        DropdownMenuItem(value: 'push', child: Text('Push Notification')),
                        DropdownMenuItem(value: 'email', child: Text('Email')),
                        DropdownMenuItem(value: 'sms', child: Text('SMS')),
                      ],
                      onChanged: (v) => setDialogState(() => templateType = v ?? 'push'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: subjectController,
                      decoration: const InputDecoration(labelText: 'Subject'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: bodyController,
                      decoration: const InputDecoration(labelText: 'Body'),
                      maxLines: 5,
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
              child: Text(isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final data = {
          'name': nameController.text.trim(),
          'type': templateType,
          'subject': subjectController.text.trim(),
          'body': bodyController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (isEdit) {
          await _supabase.from('notification_templates').update(data).eq('id', existing!['id']);
        } else {
          data['created_at'] = DateTime.now().toIso8601String();
          await _supabase.from('notification_templates').insert(data);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit ? 'Template updated' : 'Template created'),
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

  Future<void> _deleteTemplate(Map<String, dynamic> template) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Template',
      content: 'Delete template "${template['name']}"?',
      confirmLabel: 'Delete',
      confirmColor: AdminTheme.error,
    );

    if (confirmed) {
      try {
        await _supabase.from('notification_templates').delete().eq('id', template['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template deleted'), backgroundColor: AdminTheme.success),
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

  Future<void> _cancelScheduled(Map<String, dynamic> scheduled) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Cancel Scheduled Notification',
      content: 'Cancel this scheduled notification?',
      confirmLabel: 'Cancel',
      confirmColor: AdminTheme.warning,
    );

    if (confirmed) {
      try {
        await _supabase.from('scheduled_notifications').delete().eq('id', scheduled['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cancelled'), backgroundColor: AdminTheme.success),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Notifications',
            subtitle: 'Push notifications, email campaigns, and templates',
            actions: [
              OutlinedButton.icon(
                onPressed: _showEmailCampaignDialog,
                icon: const Icon(Icons.email_outlined, size: 18),
                label: const Text('Email Campaign'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showSendPushDialog,
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: const Text('Send Push'),
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
                  _buildStats(),
                  const SizedBox(height: 24),
                  _buildTabs(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 800 ? 3 : 1;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            StatCard(
              title: 'Sent Today',
              value: '$_sentToday',
              subtitle: 'Notifications sent',
              icon: Icons.send_outlined,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'Total Sent',
              value: '$_totalSent',
              subtitle: 'All time',
              icon: Icons.history_rounded,
              color: AdminTheme.secondary,
            ),
            StatCard(
              title: 'Delivery Rate',
              value: '${_deliveryRate.toStringAsFixed(1)}%',
              subtitle: 'Successfully delivered',
              icon: Icons.check_circle_outline,
              color: AdminTheme.success,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabs() {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'History'),
              Tab(text: 'Templates'),
              Tab(text: 'Scheduled'),
              Tab(text: 'Audience'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryTab(),
                _buildTemplatesTab(),
                _buildScheduledTab(),
                _buildAudienceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchField(
            hintText: 'Search notifications...',
            controller: _searchController,
          ),
        ),
        Expanded(
          child: AdminDataTable(
            columns: ['Title', 'Type', 'Target', 'Status', 'Date', 'Actions'],
            rows: _filteredHistory.map((n) {
              return [
                Text(n['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
                StatusBadge(
                  label: (n['type'] ?? 'push').toString().toUpperCase(),
                  type: n['type'] == 'email' ? BadgeType.info : BadgeType.success,
                ),
                Text((n['target'] ?? 'all').toString()),
                StatusBadge(
                  label: (n['delivered'] ?? false) ? 'Delivered' : 'Failed',
                  type: (n['delivered'] ?? false) ? BadgeType.success : BadgeType.error,
                ),
                Text(n['created_at'] != null
                    ? DateTime.parse(n['created_at']).toString().substring(0, 16)
                    : '-'),
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(n['title'] ?? 'Notification'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: ${n['type']}'),
                            Text('Target: ${n['target']}'),
                            const SizedBox(height: 8),
                            Text(n['message'] ?? 'No content'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ];
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplatesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(child: SizedBox()),
              ElevatedButton.icon(
                onPressed: () => _showTemplateDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Template'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _templates.isEmpty
              ? const Center(
                  child: Text('No templates yet', style: TextStyle(fontSize: 16)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _templates.length,
                  itemBuilder: (ctx, i) {
                    final t = _templates[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          t['type'] == 'email'
                              ? Icons.email_outlined
                              : Icons.notifications_outlined,
                          color: AdminTheme.primary,
                        ),
                        title: Text(t['name'] ?? ''),
                        subtitle: Text(t['subject'] ?? t['body'] ?? '',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge(
                              label: (t['type'] ?? 'push').toString().toUpperCase(),
                              type: BadgeType.info,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => _showTemplateDialog(existing: t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () => _deleteTemplate(t),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildScheduledTab() {
    return _scheduled.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_outlined, size: 64, color: AdminTheme.primaryLight),
                  SizedBox(height: 16),
                  Text('No scheduled notifications'),
                ],
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _scheduled.length,
            itemBuilder: (ctx, i) {
              final s = _scheduled[i];
              final scheduledAt = DateTime.tryParse(s['scheduled_at'] ?? '');
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.schedule_outlined, color: AdminTheme.warning),
                  title: Text(s['title'] ?? ''),
                  subtitle: Text(
                    'Scheduled: ${scheduledAt != null ? scheduledAt.toString().substring(0, 16) : 'Unknown'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(label: 'Scheduled', type: BadgeType.warning),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        onPressed: () => _cancelScheduled(s),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildAudienceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Audience Segments', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _audienceCard('All Users', 'Send to everyone', Icons.people_outlined),
              _audienceCard('Active Users', 'Active in last 7 days', Icons.person_outline),
              _audienceCard('Premium Users', 'Paid subscribers', Icons.star_outline),
              _audienceCard('Inactive Users', 'No activity in 30 days', Icons.person_off_outlined),
              _audienceCard('Trial Users', 'Currently on trial', Icons.access_time),
              _audienceCard('New Users', 'Joined this week', Icons.person_add_outlined),
              _audienceCard('Students', 'Learning accounts', Icons.school_outlined),
              _audienceCard('Tutors', 'Teaching accounts', Icons.work_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _audienceCard(String title, String subtitle, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Targeting: $title')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AdminTheme.primary, size: 28),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
