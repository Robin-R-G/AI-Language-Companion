import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> _logs = [];
  bool _isLoading = true;
  String? _error;
  String _selectedAction = 'All';
  int _currentPage = 1;
  int _totalLogs = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchAuditLogs();
  }

  Future<void> _fetchAuditLogs() async {
    setState(() => _isLoading = true);
    try {
      var query = supabase.from('audit_logs').select('*, user_profiles(full_name)');

      if (_selectedAction != 'All') {
        query = query.eq('action', _selectedAction);
      }

      final start = (_currentPage - 1) * _pageSize;
      final end = start + _pageSize - 1;

      final res = await query
          .order('created_at', ascending: false)
          .range(start, end)
          .count(CountOption.exact);

      setState(() {
        _logs = res.data ?? [];
        _totalLogs = res.count ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load audit logs: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Auditing Logs',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Immutable logs detailing system parameter alterations and administrative access',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Filter by Action: ', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedAction,
                  items: ['All', 'profile_updated', 'profile_deleted', 'subscription_created', 'subscription_updated', 'lesson_created', 'lesson_updated', 'lesson_deleted']
                      .map((act) => DropdownMenuItem(value: act, child: Text(act)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedAction = val ?? 'All';
                      _currentPage = 1;
                    });
                    _fetchAuditLogs();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Timestamp')),
                                DataColumn(label: Text('Actor (Admin)')),
                                DataColumn(label: Text('Action')),
                                DataColumn(label: Text('Target Entity')),
                                DataColumn(label: Text('Values Difference')),
                              ],
                              rows: _logs.map((log) {
                                final actor = log['user_profiles'] != null ? log['user_profiles']['full_name'] ?? 'System' : 'System';
                                final oldVal = log['old_values'] != null ? log['old_values'].toString() : 'None';
                                final newVal = log['new_values'] != null ? log['new_values'].toString() : 'None';

                                return DataRow(
                                  cells: [
                                    DataCell(Text(log['created_at'].toString().replaceFirst('T', ' ').substring(0, 19))),
                                    DataCell(Text(actor)),
                                    DataCell(Text(log['action'] ?? 'Unknown')),
                                    DataCell(Text(log['entity_type'] ?? 'Unknown')),
                                    DataCell(
                                      Tooltip(
                                        message: 'Old: $oldVal\nNew: $newVal',
                                        child: Text(
                                          'Old: ${oldVal.length > 25 ? '${oldVal.substring(0, 22)}...' : oldVal} | New: ${newVal.length > 25 ? '${newVal.substring(0, 22)}...' : newVal}',
                                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Showing ${((_currentPage - 1) * _pageSize) + 1} to ${((_currentPage - 1) * _pageSize) + _logs.length} of $_totalLogs logs',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left_rounded),
                                  onPressed: _currentPage > 1
                                      ? () {
                                          setState(() => _currentPage--);
                                          _fetchAuditLogs();
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right_rounded),
                                  onPressed: (_currentPage * _pageSize) < _totalLogs
                                      ? () {
                                          setState(() => _currentPage++);
                                          _fetchAuditLogs();
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
