import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  int _currentPage = 1;
  int _totalUsers = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);

    try {
      // Invoke extended Edge Function to list users
      final response = await supabase.functions.invoke(
        'admin-api',
        method: HttpMethod.get,
        headers: {
          'path': '/users',
        },
        queryParameters: {
          'limit': '$_pageSize',
          'offset': '${(_currentPage - 1) * _pageSize}',
          'search': _searchQuery.isNotEmpty ? _searchQuery : '',
        },
      );

      final responseBody = response.data;
      setState(() {
        _users = responseBody['data'] ?? [];
        _totalUsers = responseBody['meta'] != null ? responseBody['meta']['total'] ?? 0 : 0;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback query if edge function local mapping fails
      try {
        var query = supabase
            .from('user_profiles')
            .select('*');

        if (_searchQuery.isNotEmpty) {
          query = query.ilike('full_name', '%$_searchQuery%');
        }

        final res = await query
            .order('created_at', ascending: false)
            .range((_currentPage - 1) * _pageSize, _currentPage * _pageSize - 1)
            .count(CountOption.exact);

        setState(() {
          _users = res.data ?? [];
          _totalUsers = res.count ?? 0;
          _isLoading = false;
        });
      } catch (err) {
        setState(() {
          _error = 'Failed to load users: ${err.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleImpersonate(String authUserId) async {
    try {
      final res = await supabase.functions.invoke(
        'admin-api',
        method: HttpMethod.post,
        headers: {'path': '/impersonate'},
        body: {'user_id': authUserId},
      );

      final link = res.data['data']['link'] ?? '';
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Impersonate User Session'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Generate login token link generated successfully.'),
                const SizedBox(height: 16),
                SelectableText(
                  link,
                  style: TextStyle(
                    color: AdminTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to impersonation session: $e')),
      );
    }
  }

  Future<void> _handleDelete(String authUserId, bool isGdpr) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isGdpr ? 'GDPR Compliance Hard Delete' : 'Delete User Account'),
        content: Text(
          isGdpr
              ? 'This action will permanently erase all profile data, database entries, voice recording cache, and subscription transactions. This cannot be undone.'
              : 'Are you sure you want to delete this user profile?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      if (isGdpr) {
        await supabase.functions.invoke(
          'admin-api',
          method: HttpMethod.post,
          headers: {'path': '/gdpr-delete'},
          body: {'user_id': authUserId},
        );
      } else {
        await supabase.from('user_profiles').delete().eq('auth_user_id', authUserId);
      }
      _fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRoleToggle(String authUserId, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'user' : (currentRole == 'banned' ? 'user' : 'banned');
    setState(() => _isLoading = true);

    try {
      await supabase
          .from('user_profiles')
          .update({'role': newRole})
          .eq('auth_user_id', authUserId);
      _fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user role: $e')),
      );
      setState(() => _isLoading = false);
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
                  'User Management',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage subscriber permissions, learning states, and GDPR access logs',
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
                Expanded(
                  child: TextFormField(
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      _fetchUsers();
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Search by user full name...',
                      filled: true,
                    ),
                  ),
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
                                DataColumn(label: Text('Full Name')),
                                DataColumn(label: Text('Native Language')),
                                DataColumn(label: Text('Target Exam')),
                                DataColumn(label: Text('XP / Level')),
                                DataColumn(label: Text('Role State')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: _users.map((user) {
                                final isBanned = user['role'] == 'banned';
                                final isAdmin = user['role'] == 'admin';

                                return DataRow(
                                  cells: [
                                    DataCell(Text(user['full_name'] ?? 'Guest')),
                                    DataCell(Text(user['native_language'] ?? 'English')),
                                    DataCell(Text(user['target_exam'] ?? 'None')),
                                    DataCell(Text('Lvl ${user['level']} (${user['xp']} XP)')),
                                    DataCell(
                                      Chip(
                                        label: Text(
                                          (user['role'] ?? 'user').toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isBanned
                                                ? Colors.red[800]
                                                : (isAdmin ? AdminTheme.primary : Colors.green[800]),
                                          ),
                                        ),
                                        backgroundColor: isBanned
                                            ? Colors.red.withOpacity(0.1)
                                            : (isAdmin ? AdminTheme.primary.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            tooltip: 'Impersonate session',
                                            icon: Icon(Icons.login_rounded, color: AdminTheme.primary),
                                            onPressed: () => _handleImpersonate(user['auth_user_id']),
                                          ),
                                          IconButton(
                                            tooltip: isBanned ? 'Unban user' : 'Ban user',
                                            icon: Icon(
                                              isBanned ? Icons.gavel_rounded : Icons.block_rounded,
                                              color: isBanned ? Colors.green : Colors.orange,
                                            ),
                                            onPressed: () => _handleRoleToggle(user['auth_user_id'], user['role'] ?? 'user'),
                                          ),
                                          IconButton(
                                            tooltip: 'Wipe (GDPR)',
                                            icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                                            onPressed: () => _handleDelete(user['auth_user_id'], true),
                                          ),
                                        ],
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
                              'Showing ${((_currentPage - 1) * _pageSize) + 1} to ${((_currentPage - 1) * _pageSize) + _users.length} of $_totalUsers users',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left_rounded),
                                  onPressed: _currentPage > 1
                                      ? () {
                                          setState(() => _currentPage--);
                                          _fetchUsers();
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right_rounded),
                                  onPressed: (_currentPage * _pageSize) < _totalUsers
                                      ? () {
                                          setState(() => _currentPage++);
                                          _fetchUsers();
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
