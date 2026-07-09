import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/data_table_widget.dart';

class AuditLogsPage extends StatefulWidget {
  const AuditLogsPage({super.key});

  @override
  State<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends State<AuditLogsPage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  RealtimeChannel? _realtimeChannel;
  StreamSubscription<List<Map<String, dynamic>>>? _logSubscription;

  String _selectedAdminFilter = 'All';
  String _selectedActionFilter = 'All';
  String _selectedTargetFilter = 'All';

  final _actionOptions = [
    'All',
    'create',
    'update',
    'delete',
    'login',
    'logout',
    'export',
    'approve',
  ];
  final _targetOptions = [
    'All',
    'user',
    'course',
    'exam',
    'payment',
    'settings',
    'notification',
  ];

  List<String> _adminOptions = ['All'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupRealtime();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _realtimeChannel?.unsubscribe();
    _logSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtime() {
    _realtimeChannel = _supabase
        .channel('audit_logs_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'audit_logs',
          callback: (payload) {
            if (mounted) {
              final newLog = payload.newRecord;
              setState(() {
                _logs.insert(0, newLog);
                _applyFilters();
              });
            }
          },
        )
        .subscribe();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final logsRes = await _supabase
          .from('audit_logs')
          .select('*')
          .order('created_at', ascending: false)
          .limit(500);

      final logs = List<Map<String, dynamic>>.from(logsRes);
      final admins = logs
          .map((l) => (l['admin_email'] ?? l['admin_name'] ?? '').toString())
          .where((a) => a.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      if (mounted) {
        setState(() {
          _logs = logs;
          _adminOptions = ['All', ...admins];
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load audit logs: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    final dateFrom = DateTime.tryParse(_dateFromController.text);
    final dateTo = DateTime.tryParse(_dateToController.text);

    setState(() {
      _filteredLogs = _logs.where((log) {
        final matchesSearch = query.isEmpty ||
            (log['action'] ?? '').toString().toLowerCase().contains(query) ||
            (log['target_type'] ?? '').toString().toLowerCase().contains(query) ||
            (log['admin_email'] ?? '').toString().toLowerCase().contains(query) ||
            (log['details'] ?? '').toString().toLowerCase().contains(query);
        final matchesAdmin = _selectedAdminFilter == 'All' ||
            (log['admin_email'] ?? log['admin_name'] ?? '') == _selectedAdminFilter;
        final matchesAction = _selectedActionFilter == 'All' ||
            log['action'] == _selectedActionFilter;
        final matchesTarget = _selectedTargetFilter == 'All' ||
            log['target_type'] == _selectedTargetFilter;

        bool matchesDate = true;
        if (dateFrom != null || dateTo != null) {
          final logDate = DateTime.tryParse(log['created_at'] ?? '');
          if (logDate == null) {
            matchesDate = false;
          } else {
            if (dateFrom != null && logDate.isBefore(dateFrom)) matchesDate = false;
            if (dateTo != null && logDate.isAfter(dateTo.add(const Duration(days: 1)))) {
              matchesDate = false;
            }
          }
        }

        return matchesSearch &&
            matchesAdmin &&
            matchesAction &&
            matchesTarget &&
            matchesDate;
      }).toList();
    });
  }

  void _exportLogs() {
    final csv = StringBuffer();
    csv.writeln('ID,Timestamp,Admin,Action,Target Type,Target ID,Details');
    for (final log in _filteredLogs) {
      csv.writeln(
        '"${log['id']}","${log['created_at']}","${log['admin_email'] ?? ''}",'
        '"${log['action']}","${log['target_type']}","${log['target_id'] ?? ''}",'
        '"${log['details']}"',
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audit logs exported'),
        backgroundColor: AdminTheme.success,
      ),
    );
  }

  BadgeType _actionBadgeType(String? action) {
    switch (action) {
      case 'delete':
        return BadgeType.error;
      case 'create':
        return BadgeType.success;
      case 'update':
        return BadgeType.warning;
      case 'login':
      case 'logout':
        return BadgeType.info;
      default:
        return BadgeType.neutral;
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
            title: 'Audit Logs',
            subtitle: 'Track all admin actions and system events',
            actions: [
              OutlinedButton.icon(
                onPressed: _exportLogs,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Export'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
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
                  _buildFilters(),
                  const SizedBox(height: 16),
                  _buildTable(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 250,
              child: SearchField(
                hintText: 'Search logs...',
                controller: _searchController,
              ),
            ),
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<String>(
                value: _selectedAdminFilter,
                isDense: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _adminOptions
                    .map((a) => DropdownMenuItem(value: a, child: Text(a, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedAdminFilter = v ?? 'All');
                  _applyFilters();
                },
              ),
            ),
            SizedBox(
              width: 140,
              child: DropdownButtonFormField<String>(
                value: _selectedActionFilter,
                isDense: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _actionOptions
                    .map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(a == 'All' ? 'All Actions' : a),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedActionFilter = v ?? 'All');
                  _applyFilters();
                },
              ),
            ),
            SizedBox(
              width: 140,
              child: DropdownButtonFormField<String>(
                value: _selectedTargetFilter,
                isDense: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _targetOptions
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t == 'All' ? 'All Targets' : t),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedTargetFilter = v ?? 'All');
                  _applyFilters();
                },
              ),
            ),
            SizedBox(
              width: 140,
              child: TextField(
                controller: _dateFromController,
                decoration: const InputDecoration(
                  hintText: 'From Date',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 30)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dateFromController.text = date.toIso8601String().substring(0, 10);
                    _applyFilters();
                  }
                },
                readOnly: true,
              ),
            ),
            SizedBox(
              width: 140,
              child: TextField(
                controller: _dateToController,
                decoration: const InputDecoration(
                  hintText: 'To Date',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dateToController.text = date.toIso8601String().substring(0, 10);
                    _applyFilters();
                  }
                },
                readOnly: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Expanded(
      child: AdminDataTable(
        columns: ['Timestamp', 'Admin', 'Action', 'Target', 'Details'],
        rows: _filteredLogs.map((log) {
          final date = DateTime.tryParse(log['created_at'] ?? '');
          final details = log['details'];
          final detailsStr = details is String ? details : details?.toString() ?? '-';
          return [
            Text(
              date != null ? date.toString().substring(0, 19) : '-',
              style: const TextStyle(fontSize: 12),
            ),
            Text(log['admin_email'] ?? log['admin_name'] ?? '-',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            StatusBadge(
              label: log['action'] ?? '-',
              type: _actionBadgeType(log['action']),
            ),
            Text(log['target_type'] ?? '-'),
            Text(
              detailsStr.length > 60 ? '${detailsStr.substring(0, 60)}...' : detailsStr,
              style: const TextStyle(fontSize: 12),
            ),
          ];
        }).toList(),
        emptyState: const Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: AdminTheme.primaryLight),
                SizedBox(height: 16),
                Text('No audit logs found', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
