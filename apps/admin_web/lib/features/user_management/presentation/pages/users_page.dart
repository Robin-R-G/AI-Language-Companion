import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/audit_service.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/stat_card.dart';
import '../widgets/user_detail_dialog.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  int _totalCount = 0;
  int _studentCount = 0;
  int _tutorCount = 0;
  int _adminCount = 0;

  String _searchQuery = '';
  String _roleFilter = 'all';
  String _statusFilter = 'all';
  int _currentPage = 0;
  final int _pageSize = 20;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final supabase = SupabaseService.instance.client;

      final result = await supabase
          .from('user_profiles')
          .select('*')
          .order('created_at', ascending: false);

      final users = List<Map<String, dynamic>>.from(result);

      final totalFuture = supabase.from('user_profiles').select('id').count();
      final studentFuture = supabase
          .from('user_profiles')
          .select('id')
          .eq('role', 'student')
          .count();
      final tutorFuture = supabase
          .from('user_profiles')
          .select('id')
          .eq('role', 'tutor')
          .count();
      final adminFuture = supabase
          .from('user_profiles')
          .select('id')
          .eq('role', 'admin')
          .count();

      final counts = await Future.wait([totalFuture, studentFuture, tutorFuture, adminFuture]);

      if (mounted) {
        setState(() {
          _users = users;
          _filteredUsers = users;
          _totalCount = counts[0].count;
          _studentCount = counts[1].count;
          _tutorCount = counts[2].count;
          _adminCount = counts[3].count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load users: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = _searchQuery.isEmpty ||
            (user['email'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (user['full_name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesRole = _roleFilter == 'all' || user['role'] == _roleFilter;

        final isActive = user['is_active'] ?? true;
        final matchesStatus = _statusFilter == 'all' ||
            (_statusFilter == 'active' && isActive) ||
            (_statusFilter == 'suspended' && !isActive);

        return matchesSearch && matchesRole && matchesStatus;
      }).toList();
      _currentPage = 0;
    });
  }

  List<Map<String, dynamic>> get _paginatedUsers {
    final start = _currentPage * _pageSize;
    if (start >= _filteredUsers.length) return [];
    final end = start + _pageSize;
    return _filteredUsers.sublist(start, end.clamp(0, _filteredUsers.length));
  }

  int get _totalPages => (_filteredUsers.length / _pageSize).ceil();

  Future<void> _toggleUserStatus(Map<String, dynamic> user) async {
    final isActive = user['is_active'] ?? true;
    final action = isActive ? 'suspend' : 'activate';

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: '${isActive ? 'Suspend' : 'Activate'} User',
      content:
          'Are you sure you want to $action ${user['full_name'] ?? user['email']}?',
      confirmLabel: isActive ? 'Suspend' : 'Activate',
      confirmColor: isActive ? AdminTheme.error : AdminTheme.success,
    );

    if (!confirmed) return;

    try {
      final supabase = SupabaseService.instance.client;
      await supabase.from('user_profiles').update({
        'is_active': !isActive,
      }).eq('id', user['id']);

      await AuditService.instance.log(
        action: isActive ? 'user_suspend' : 'user_activate',
        targetType: 'user',
        targetId: user['id'],
        details: {'email': user['email']},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${isActive ? 'suspended' : 'activated'} successfully',
            ),
            backgroundColor: isActive ? AdminTheme.error : AdminTheme.success,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update user status'),
            backgroundColor: AdminTheme.error,
          ),
        );
      }
    }
  }

  void _showUserDetail(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => UserDetailDialog(user: user),
    );
  }

  Future<void> _showCreateOrEditUserDialog({Map<String, dynamic>? user}) async {
    final isEdit = user != null;
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final passwordController = TextEditingController();
    final nameController = TextEditingController(text: user?['full_name'] ?? '');
    final phoneController = TextEditingController(text: user?['phone'] ?? '');
    final countryController = TextEditingController(text: user?['country'] ?? '');
    String role = user?['role'] ?? 'student';
    bool isActive = user?['is_active'] ?? true;
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEdit ? 'Edit User' : 'Create User'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: emailController,
                        enabled: !isEdit,
                        decoration: const InputDecoration(labelText: 'Email Address'),
                        validator: (v) => v == null || v.isEmpty ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 12),
                      if (!isEdit) ...[
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                          validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        validator: (v) => v == null || v.isEmpty ? 'Full Name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(value: 'student', child: Text('Student')),
                          DropdownMenuItem(value: 'tutor', child: Text('Tutor')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => role = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: countryController,
                        decoration: const InputDecoration(labelText: 'Country'),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Is Active'),
                        value: isActive,
                        onChanged: (v) => setDialogState(() => isActive = v),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSaving = true);
                          try {
                            final supabase = SupabaseService.instance.client;
                            if (isEdit) {
                              await supabase.from('user_profiles').update({
                                'full_name': nameController.text,
                                'role': role,
                                'phone_number': phoneController.text,
                                'country': countryController.text,
                                'is_active': isActive,
                              }).eq('id', user['id']);

                              await AuditService.instance.log(
                                action: 'user_update',
                                targetType: 'user',
                                targetId: user['id'],
                                details: {'email': user['email']},
                              );
                            } else {
                              final result = await supabase.functions.invoke(
                                'admin-create-user',
                                body: {
                                  'email': emailController.text.trim(),
                                  'password': passwordController.text,
                                  'full_name': nameController.text,
                                  'role': role,
                                  'phone': phoneController.text,
                                  'country': countryController.text,
                                  'is_active': isActive,
                                },
                              );

                              if (result.status != 200) {
                                final data = result.data;
                                throw Exception(data?['error'] ?? 'User creation failed');
                              }
                            }
                            
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEdit ? 'User updated successfully' : 'User created successfully'),
                                  backgroundColor: AdminTheme.success,
                                ),
                              );
                              _loadUsers();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AdminTheme.error,
                                ),
                              );
                            }
                          } finally {
                            setDialogState(() => isSaving = false);
                          }
                        },
                  child: isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEdit ? 'Save' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _exportUsers() {
    final csv = StringBuffer();
    csv.writeln('ID,Email,Name,Role,Status,Created At');
    for (final user in _filteredUsers) {
      csv.writeln(
        '${user['id'] ?? ''},'
        '${user['email'] ?? ''},'
        '${user['full_name'] ?? ''},'
        '${user['role'] ?? ''},'
        '${(user['is_active'] ?? true) ? 'Active' : 'Suspended'},'
        '${user['created_at'] ?? ''}',
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${_filteredUsers.length} users'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Never';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 'Unknown';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(date);
  }

  BadgeType _getRoleBadge(String role) {
    switch (role) {
      case 'admin':
        return BadgeType.error;
      case 'tutor':
        return BadgeType.info;
      case 'student':
        return BadgeType.success;
      default:
        return BadgeType.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AdminTheme.error),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AdminTheme.error), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'User Management',
                  subtitle: 'Manage all platform users',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: _exportUsers,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Export'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateOrEditUserDialog(),
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('Add User'),
                    ),
                  ],
                ),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildFiltersRow(context),
                const SizedBox(height: 16),
                _buildDataTable(context),
                const SizedBox(height: 16),
                _buildPagination(context),
                const SizedBox(height: 32),
              ],
            ),
          );
  }

  Widget _buildStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.0,
          children: [
            StatCard(
              title: 'Total Users',
              value: _totalCount.toString(),
              subtitle: 'All registered',
              icon: Icons.people_rounded,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'Students',
              value: _studentCount.toString(),
              subtitle: 'Active learners',
              icon: Icons.school_rounded,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Tutors',
              value: _tutorCount.toString(),
              subtitle: 'Verified tutors',
              icon: Icons.person_rounded,
              color: AdminTheme.secondary,
            ),
            StatCard(
              title: 'Admins',
              value: _adminCount.toString(),
              subtitle: 'Platform admins',
              icon: Icons.admin_panel_settings_rounded,
              color: AdminTheme.warning,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltersRow(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: SearchField(
                controller: _searchController,
                hintText: 'Search by name or email...',
                onChanged: (value) {
                  _searchQuery = value;
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _roleFilter,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Roles')),
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'tutor', child: Text('Tutor')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  _roleFilter = value ?? 'all';
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _statusFilter,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Status')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                ],
                onChanged: (value) {
                  _statusFilter = value ?? 'all';
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final columns = [
      'User',
      'Role',
      'Status',
      'Joined',
      'Last Active',
      'Actions',
    ];

    final rows = _paginatedUsers.map((user) {
      final isActive = user['is_active'] ?? true;
      return [
        _buildUserCell(context, user),
        StatusBadge(
          label: (user['role'] ?? 'unknown').toString().toUpperCase(),
          type: _getRoleBadge(user['role'] ?? ''),
        ),
        StatusBadge(
          label: isActive ? 'Active' : 'Suspended',
          type: isActive ? BadgeType.success : BadgeType.error,
        ),
        Text(
          _formatDate(user['created_at']),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          _formatDate(user['last_login_at']),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        _buildActionsCell(context, user),
      ];
    }).toList();

    return Card(
      child: _filteredUsers.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline_rounded,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text('No users found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            )),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: columns
                    .map((c) => DataColumn(
                          label: Text(c,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
                rows: List.generate(rows.length, (i) {
                  final user = _paginatedUsers[i];
                  return DataRow(
                    cells: rows[i].map((w) => DataCell(w)).toList(),
                    onSelectChanged: (_) => _showUserDetail(user),
                  );
                }),
              ),
            ),
    );
  }

  Widget _buildUserCell(BuildContext context, Map<String, dynamic> user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AdminTheme.primary.withOpacity(0.1),
          child: Text(
            ((user['full_name'] ?? user['email'] ?? '?')[0] as String)
                .toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AdminTheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user['full_name'] ?? 'Unknown',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              user['email'] ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsCell(BuildContext context, Map<String, dynamic> user) {
    final isActive = user['is_active'] ?? true;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility_rounded, size: 16),
              SizedBox(width: 8),
              Text('View Details'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 16),
              SizedBox(width: 8),
              Text('Edit User'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                size: 16,
                color: isActive ? AdminTheme.error : AdminTheme.success,
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? 'Suspend' : 'Activate',
                style: TextStyle(
                  color: isActive ? AdminTheme.error : AdminTheme.success,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'view') {
          _showUserDetail(user);
        } else if (value == 'edit') {
          _showCreateOrEditUserDialog(user: user);
        } else if (value == 'toggle') {
          _toggleUserStatus(user);
        }
      },
    );
  }

  Widget _buildPagination(BuildContext context) {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Showing ${_currentPage * _pageSize + 1}-${((_currentPage + 1) * _pageSize).clamp(0, _filteredUsers.length)} of ${_filteredUsers.length}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: _currentPage > 0
              ? () => setState(() => _currentPage--)
              : null,
          icon: const Icon(Icons.chevron_left_rounded, size: 20),
        ),
        ...List.generate(_totalPages, (index) {
          final isSelected = index == _currentPage;
          if (_totalPages > 7 &&
              index > 2 &&
              index < _totalPages - 3 &&
              (index - _currentPage).abs() > 1) {
            if (index == 3 || index == _totalPages - 4) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('...'),
              );
            }
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: IconButton(
              onPressed: () => setState(() => _currentPage = index),
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AdminTheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        IconButton(
          onPressed: _currentPage < _totalPages - 1
              ? () => setState(() => _currentPage++)
              : null,
          icon: const Icon(Icons.chevron_right_rounded, size: 20),
        ),
      ],
    );
  }
}
