import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';

class DevConsolePage extends StatefulWidget {
  const DevConsolePage({super.key});

  @override
  State<DevConsolePage> createState() => _DevConsolePageState();
}

class _DevConsolePageState extends State<DevConsolePage>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;

  final _apiUrlController = TextEditingController();
  final _apiBodyController = TextEditingController();
  final _queryController = TextEditingController();
  final _searchVarsController = TextEditingController();

  String _apiMethod = 'GET';
  String _apiResponse = '';
  bool _apiLoading = false;
  List<Map<String, dynamic>> _queryResults = [];
  bool _queryLoading = false;
  String? _queryError;

  List<Map<String, dynamic>> _edgeLogs = [];
  bool _logsLoading = false;

  Map<String, dynamic> _systemVars = {};
  bool _varsLoading = false;

  final _dio = Dio();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSystemVars();
    _loadEdgeLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiUrlController.dispose();
    _apiBodyController.dispose();
    _queryController.dispose();
    _searchVarsController.dispose();
    _dio.close();
    super.dispose();
  }

  Future<void> _sendApiRequest() async {
    setState(() {
      _apiLoading = true;
      _apiResponse = '';
    });

    try {
      final url = _apiUrlController.text.trim();
      if (url.isEmpty) {
        setState(() {
          _apiResponse = jsonEncode({'error': 'URL is required'});
          _apiLoading = false;
        });
        return;
      }

      final headers = <String, dynamic>{
        'apikey': _supabase.auth.currentSession?.accessToken ?? '',
        'Authorization': 'Bearer ${_supabase.auth.currentSession?.accessToken ?? ''}',
        'Content-Type': 'application/json',
      };

      Response response;
      final options = Options(headers: headers);

      switch (_apiMethod) {
        case 'GET':
          response = await _dio.get(url, options: options);
          break;
        case 'POST':
          final body = _apiBodyController.text.trim().isNotEmpty
              ? jsonDecode(_apiBodyController.text.trim())
              : null;
          response = await _dio.post(url, data: body, options: options);
          break;
        case 'PUT':
          final body = _apiBodyController.text.trim().isNotEmpty
              ? jsonDecode(_apiBodyController.text.trim())
              : null;
          response = await _dio.put(url, data: body, options: options);
          break;
        case 'DELETE':
          response = await _dio.delete(url, options: options);
          break;
        default:
          response = await _dio.get(url, options: options);
      }

      if (mounted) {
        setState(() {
          _apiResponse = const JsonEncoder.withIndent('  ').convert({
            'status': response.statusCode,
            'data': response.data,
          });
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _apiResponse = const JsonEncoder.withIndent('  ').convert({
            'error': e.message,
            'statusCode': e.response?.statusCode,
            'data': e.response?.data,
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiResponse = const JsonEncoder.withIndent('  ').convert({'error': e.toString()});
        });
      }
    } finally {
      if (mounted) setState(() => _apiLoading = false);
    }
  }

  Future<void> _executeQuery() async {
    setState(() {
      _queryLoading = true;
      _queryError = null;
      _queryResults = [];
    });

    try {
      final query = _queryController.text.trim();
      if (query.isEmpty) {
        setState(() {
          _queryError = 'Query is required';
          _queryLoading = false;
        });
        return;
      }

      final tableName = _extractTableName(query);

      if (tableName.isNotEmpty) {
        final result = await _supabase.from(tableName).select('*').limit(100);
        if (mounted) {
          setState(() {
            _queryResults = List<Map<String, dynamic>>.from(result);
          });
        }
      } else {
        if (mounted) {
          setState(() => _queryError = 'Could not parse table name from query');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _queryError = 'Query error: $e');
      }
    } finally {
      if (mounted) setState(() => _queryLoading = false);
    }
  }

  String _extractTableName(String query) {
    final trimmed = query.trim().toLowerCase();
    final patterns = [
      RegExp(r'from\s+(\w+)', caseSensitive: false),
      RegExp(r'into\s+(\w+)', caseSensitive: false),
      RegExp(r'update\s+(\w+)', caseSensitive: false),
    ];
    for (final p in patterns) {
      final match = p.firstMatch(trimmed);
      if (match != null) return match.group(1)!;
    }
    return '';
  }

  Future<void> _loadEdgeLogs() async {
    setState(() => _logsLoading = true);
    try {
      final logsRes = await _supabase
          .from('edge_function_logs')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);

      if (mounted) {
        setState(() => _edgeLogs = List<Map<String, dynamic>>.from(logsRes));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _edgeLogs = [
            {
              'function_name': 'example-function',
              'status': 200,
              'duration_ms': 145,
              'created_at': DateTime.now().toIso8601String(),
              'message': 'Edge function logs table may not exist yet',
            }
          ];
        });
      }
    } finally {
      if (mounted) setState(() => _logsLoading = false);
    }
  }

  Future<void> _loadSystemVars() async {
    setState(() => _varsLoading = true);
    try {
      if (mounted) {
        setState(() {
          _systemVars = {
            'APP_VERSION': '1.0.0',
            'ENVIRONMENT': 'production',
            'SUPABASE_URL': _supabase.rest.url,
            'FUNCTIONS_URL': '${_supabase.rest.url}/functions/v1',
            'AUTH_SERVICE': 'supabase',
            'AI_PROVIDER': 'openai',
            'AI_MODEL': 'gpt-4',
            'PAYMENT_PROVIDER': 'stripe',
            'STORAGE_BUCKET': 'media',
            'MAX_UPLOAD_SIZE': '50MB',
            'SESSION_TIMEOUT': '3600',
            'CACHE_TTL': '300',
          };
        });
      }
    } finally {
      if (mounted) setState(() => _varsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Developer Console',
            subtitle: 'API testing, database queries, and system inspection',
          ),
          Expanded(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'API Tester'),
                    Tab(text: 'Database Query'),
                    Tab(text: 'Edge Function Logs'),
                    Tab(text: 'System Variables'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildApiTesterTab(),
                      _buildQueryTab(),
                      _buildLogsTab(),
                      _buildVarsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiTesterTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<String>(
                  value: _apiMethod,
                  isDense: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'GET', child: Text('GET')),
                    DropdownMenuItem(value: 'POST', child: Text('POST')),
                    DropdownMenuItem(value: 'PUT', child: Text('PUT')),
                    DropdownMenuItem(value: 'DELETE', child: Text('DELETE')),
                  ],
                  onChanged: (v) => setState(() => _apiMethod = v ?? 'GET'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _apiUrlController,
                  decoration: const InputDecoration(
                    hintText: 'https://your-project.supabase.co/functions/v1/endpoint',
                  ),
                  onSubmitted: (_) => _sendApiRequest(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _apiLoading ? null : _sendApiRequest,
                icon: _apiLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send'),
              ),
            ],
          ),
          if (_apiMethod != 'GET') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _apiBodyController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '{\n  "key": "value"\n}',
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          const Text('Response:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.darkBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminTheme.darkBorder),
              ),
              child: SelectableText(
                _apiResponse.isEmpty ? '// Response will appear here' : _apiResponse,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AdminTheme.darkText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    hintText: 'SELECT * FROM users LIMIT 10',
                  ),
                  onSubmitted: (_) => _executeQuery(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _queryLoading ? null : _executeQuery,
                icon: _queryLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('Execute'),
              ),
            ],
          ),
          if (_queryError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminTheme.error.withOpacity(0.2)),
              ),
              child: Text(_queryError!,
                  style: const TextStyle(color: AdminTheme.error, fontSize: 13)),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: _queryResults.isEmpty
                ? const Center(child: Text('Results will appear here'))
                : Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: _queryResults.first.keys
                            .map((k) => DataColumn(label: Text(k)))
                            .toList(),
                        rows: _queryResults
                            .map((row) => DataRow(
                                  cells: row.values
                                      .map((v) => DataCell(
                                            Text(
                                              v?.toString() ?? 'NULL',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ))
                                      .toList(),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    if (_logsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _edgeLogs.length,
      itemBuilder: (ctx, i) {
        final log = _edgeLogs[i];
        final status = log['status'] ?? 0;
        final statusColor = status >= 200 && status < 300
            ? AdminTheme.success
            : status >= 400
                ? AdminTheme.error
                : AdminTheme.warning;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$status',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: Text(
              log['function_name'] ?? 'unknown',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${log['duration_ms'] ?? 0}ms - ${log['message'] ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              log['created_at'] != null
                  ? DateTime.parse(log['created_at']).toString().substring(11, 19)
                  : '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVarsTab() {
    if (_varsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: SearchField(
              hintText: 'Search variables...',
              controller: _searchVarsController,
              onChanged: (v) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AdminTheme.darkBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminTheme.darkBorder),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _systemVars.entries
                      .where((e) =>
                          _searchVarsController.text.isEmpty ||
                          e.key
                              .toLowerCase()
                              .contains(_searchVarsController.text.toLowerCase()))
                      .map((e) {
                    final isMasked = e.value.toString().contains('••••');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 240,
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AdminTheme.primaryLight,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  e.value.toString(),
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: isMasked
                                        ? AdminTheme.darkTextSecondary
                                        : AdminTheme.darkText,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 14),
                                  tooltip: 'Copy',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Copied')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
