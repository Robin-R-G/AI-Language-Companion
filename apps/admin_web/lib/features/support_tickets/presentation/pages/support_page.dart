import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirm_dialog.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _tickets = [];
  String _searchQuery = '';
  String _statusFilter = 'all';
  int _totalTickets = 0;
  int _openTickets = 0;
  int _inProgressTickets = 0;
  int _resolvedTickets = 0;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('support_tickets')
          .select()
          .order('created_at', ascending: false);

      final tickets = List<Map<String, dynamic>>.from(res);
      setState(() {
        _tickets = tickets;
        _totalTickets = tickets.length;
        _openTickets = tickets.where((t) => t['status'] == 'open').length;
        _inProgressTickets = tickets.where((t) => t['status'] == 'in_progress').length;
        _resolvedTickets = tickets.where((t) => t['status'] == 'resolved').length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load support tickets: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredTickets {
    var filtered = _tickets;
    if (_statusFilter != 'all') {
      filtered = filtered.where((t) => t['status'] == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
          (t['subject'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t['user_email'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return filtered;
  }

  BadgeType _statusBadge(String status) {
    return switch (status) {
      'open' => BadgeType.warning,
      'in_progress' => BadgeType.info,
      'resolved' => BadgeType.success,
      'closed' => BadgeType.neutral,
      _ => BadgeType.neutral,
    };
  }

  BadgeType _priorityBadge(String priority) {
    return switch (priority) {
      'urgent' => BadgeType.error,
      'high' => BadgeType.warning,
      'medium' => BadgeType.info,
      _ => BadgeType.neutral,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Support Tickets',
          subtitle: 'Manage customer support requests and knowledge base',
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AdminTheme.error),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AdminTheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchTickets,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width >= 1024 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              StatCard(title: 'Total Tickets', value: '$_totalTickets', subtitle: 'All time', icon: Icons.support_agent_rounded, color: AdminTheme.primary),
              StatCard(title: 'Open', value: '$_openTickets', subtitle: 'Needs attention', icon: Icons.circle_outlined, color: AdminTheme.warning),
              StatCard(title: 'In Progress', value: '$_inProgressTickets', subtitle: 'Being handled', icon: Icons.pending_rounded, color: AdminTheme.info),
              StatCard(title: 'Resolved', value: '$_resolvedTickets', subtitle: 'Completed', icon: Icons.check_circle_rounded, color: AdminTheme.success),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 300,
                child: SearchField(
                  hintText: 'Search tickets...',
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'open', label: Text('Open')),
                  ButtonSegment(value: 'in_progress', label: Text('In Progress')),
                  ButtonSegment(value: 'resolved', label: Text('Resolved')),
                  ButtonSegment(value: 'closed', label: Text('Closed')),
                ],
                selected: {_statusFilter},
                onSelectionChanged: (v) => setState(() => _statusFilter = v.first),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Subject')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Priority')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Assigned To')),
                  DataColumn(label: Text('Created')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _filteredTickets.map((ticket) {
                  return DataRow(cells: [
                    DataCell(Text(ticket['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text(ticket['user_email'] ?? '')),
                    DataCell(StatusBadge(label: ticket['priority'] ?? 'low', type: _priorityBadge(ticket['priority'] ?? 'low'))),
                    DataCell(StatusBadge(label: (ticket['status'] ?? '').replaceAll('_', ' ').toUpperCase(), type: _statusBadge(ticket['status'] ?? ''))),
                    DataCell(Text(ticket['assigned_to'] ?? 'Unassigned')),
                    DataCell(Text(_formatDate(ticket['created_at']))),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_rounded, size: 18),
                          onPressed: () => _showTicketDetail(ticket),
                          tooltip: 'View',
                        ),
                        if (ticket['status'] == 'open')
                          IconButton(
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            onPressed: () => _updateTicketStatus(ticket['id'], 'in_progress'),
                            tooltip: 'Start',
                          ),
                        if (ticket['status'] == 'in_progress')
                          IconButton(
                            icon: const Icon(Icons.check_rounded, size: 18),
                            onPressed: () => _updateTicketStatus(ticket['id'], 'resolved'),
                            tooltip: 'Resolve',
                          ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _updateTicketStatus(String id, String status) async {
    try {
      await Supabase.instance.client
          .from('support_tickets')
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      _fetchTickets();
    } catch (_) {
      setState(() {
        final idx = _tickets.indexWhere((t) => t['id'] == id);
        if (idx != -1) _tickets[idx]['status'] = status;
      });
    }
  }

  void _showTicketDetail(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ticket['subject'] ?? 'Ticket'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('User', ticket['user_email'] ?? ''),
              _detailRow('Status', (ticket['status'] ?? '').replaceAll('_', ' ').toUpperCase()),
              _detailRow('Priority', (ticket['priority'] ?? '').toUpperCase()),
              _detailRow('Assigned To', ticket['assigned_to'] ?? 'Unassigned'),
              _detailRow('Created', _formatDate(ticket['created_at'])),
              const SizedBox(height: 16),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(ticket['description'] ?? 'No description provided.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
