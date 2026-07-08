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
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/admin_config.dart';
import '../widgets/student_detail_dialog.dart';

class StudentsPage extends ConsumerStatefulWidget {
  const StudentsPage({super.key});

  @override
  ConsumerState<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends ConsumerState<StudentsPage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  int _totalStudents = 0;
  int _activeStudents = 0;
  int _subscribedStudents = 0;
  int _trialStudents = 0;

  String _searchQuery = '';
  String _statusFilter = 'all';
  String _subscriptionFilter = 'all';
  int _currentPage = 0;
  final int _pageSize = 20;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final supabase = SupabaseService.instance.client;

      final result = await supabase
          .from('user_profiles')
          .select('*, wallet(balance)')
          .eq('role', 'student')
          .order('created_at', ascending: false);

      final students = List<Map<String, dynamic>>.from(result);

      final totalFuture = supabase
          .from('user_profiles')
          .select('id')
          .eq('role', 'student')
          .count();

      final activeFuture = supabase
          .from('user_profiles')
          .select('id')
          .eq('role', 'student')
          .eq('is_active', true)
          .count();

      final counts = await Future.wait([totalFuture, activeFuture]);

      int subscribedCount = 0;
      try {
        final subResult = await supabase
            .from('subscriptions')
            .select('user_id, status')
            .eq('status', 'active');
        subscribedCount = subResult.length;
      } catch (_) {}

      if (mounted) {
        setState(() {
          _students = students;
          _filteredStudents = students;
          _totalStudents = counts[0].count;
          _activeStudents = counts[1].count;
          _subscribedStudents = subscribedCount;
          _trialStudents = students.length > subscribedCount
              ? students.length - subscribedCount
              : 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load students: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _mockStudents() => List.generate(
        40,
        (i) => {
          'id': 'student_$i',
          'auth_user_id': 'auth_$i',
          'email': 'student$i@example.com',
          'full_name': [
            'Emma Wilson',
            'Liam Davis',
            'Olivia Brown',
            'Noah Garcia',
            'Sophia Martinez',
            'Mason Anderson',
            'Isabella Taylor',
            'Lucas Thomas',
          ][i % 8],
          'role': 'student',
          'is_active': i % 6 != 0,
          'phone': '+1 555 0${200 + i}',
          'country': ['US', 'UK', 'JP', 'DE', 'FR', 'IT', 'ES', 'BR'][i % 8],
          'created_at': DateTime.now()
              .subtract(Duration(days: 365 - i * 9))
              .toIso8601String(),
          'last_login_at': i % 4 == 0
              ? null
              : DateTime.now()
                  .subtract(Duration(hours: i * 3))
                  .toIso8601String(),
          'credits': [500, 1200, 800, 200, 1500, 0, 300, 1000][i % 8],
          'subscription_status': ['active', 'trial', 'expired', 'none'][i % 4],
          'learning_hours': (i * 3.5 + 10).toStringAsFixed(1),
          'lessons_completed': i * 5 + 12,
          'current_level': ['A1', 'A2', 'B1', 'B2', 'C1', 'A2', 'B1', 'B2'][i % 8],
          'target_language': ['English', 'Spanish', 'Japanese', 'French', 'German', 'Italian', 'Portuguese', 'Korean'][i % 8],
        },
      );

  void _applyFilters() {
    setState(() {
      _filteredStudents = _students.where((student) {
        final matchesSearch = _searchQuery.isEmpty ||
            (student['email'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (student['full_name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

        final isActive = student['is_active'] ?? true;
        final matchesStatus = _statusFilter == 'all' ||
            (_statusFilter == 'active' && isActive) ||
            (_statusFilter == 'suspended' && !isActive);

        final subStatus = student['subscription_status'] ?? 'none';
        final matchesSubscription = _subscriptionFilter == 'all' ||
            subStatus == _subscriptionFilter;

        return matchesSearch && matchesStatus && matchesSubscription;
      }).toList();
      _currentPage = 0;
    });
  }

  List<Map<String, dynamic>> get _paginatedStudents {
    final start = _currentPage * _pageSize;
    if (start >= _filteredStudents.length) return [];
    final end = start + _pageSize;
    return _filteredStudents.sublist(start, end.clamp(0, _filteredStudents.length));
  }

  int get _totalPages => (_filteredStudents.length / _pageSize).ceil();

  Future<void> _toggleStudentStatus(Map<String, dynamic> student) async {
    final isActive = student['is_active'] ?? true;
    final action = isActive ? 'suspend' : 'activate';

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: '${isActive ? 'Suspend' : 'Activate'} Student',
      content:
          'Are you sure you want to $action ${student['full_name'] ?? student['email']}?',
      confirmLabel: isActive ? 'Suspend' : 'Activate',
      confirmColor: isActive ? AdminTheme.error : AdminTheme.success,
    );

    if (!confirmed) return;

    try {
      final supabase = SupabaseService.instance.client;
      await supabase.from('user_profiles').update({
        'is_active': !isActive,
      }).eq('id', student['id']);

      await AuditService.instance.log(
        action: isActive ? 'student_suspend' : 'student_activate',
        targetType: 'student',
        targetId: student['id'],
        details: {'email': student['email']},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Student ${isActive ? 'suspended' : 'activated'} successfully',
            ),
            backgroundColor: isActive ? AdminTheme.error : AdminTheme.success,
          ),
        );
        _loadStudents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update student status'),
            backgroundColor: AdminTheme.error,
          ),
        );
      }
    }
  }

  void _showStudentDetail(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (_) => StudentDetailDialog(student: student),
    );
  }

  Future<void> _showCreateOrEditStudentDialog({Map<String, dynamic>? student}) async {
    final isEdit = student != null;
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController(text: student?['email'] ?? '');
    final passwordController = TextEditingController();
    final nameController = TextEditingController(text: student?['full_name'] ?? '');
    final phoneController = TextEditingController(text: student?['phone'] ?? '');
    final countryController = TextEditingController(text: student?['country'] ?? '');
    final creditsController = TextEditingController(
      text: student?['wallet'] != null
          ? (student?['wallet']['balance'] ?? 0).toString()
          : '0',
    );
    bool isActive = student?['is_active'] ?? true;
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEdit ? 'Edit Student' : 'Create Student'),
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
                      TextFormField(
                        controller: creditsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Credits Balance'),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Credits must be a number' : null,
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
                            final credits = int.parse(creditsController.text);
                            
                            if (isEdit) {
                              await supabase.from('user_profiles').update({
                                'full_name': nameController.text,
                                'phone_number': phoneController.text,
                                'country': countryController.text,
                                'is_active': isActive,
                              }).eq('id', student['id']);

                              await supabase.from('wallet').upsert({
                                'user_id': student['auth_user_id'],
                                'balance': credits,
                              }, onConflict: 'user_id');

                              await AuditService.instance.log(
                                action: 'student_update',
                                targetType: 'student',
                                targetId: student['id'],
                                details: {'email': student['email']},
                              );
                            } else {
                              final result = await supabase.functions.invoke(
                                'admin-create-user',
                                body: {
                                  'email': emailController.text.trim(),
                                  'password': passwordController.text,
                                  'full_name': nameController.text,
                                  'role': 'student',
                                  'phone': phoneController.text,
                                  'country': countryController.text,
                                  'is_active': isActive,
                                },
                              );

                              if (result.status != 200) {
                                final data = result.data;
                                throw Exception(data?['error'] ?? 'Student creation failed');
                              }

                              final userId = result.data?['user_id'];
                              if (userId != null) {
                                await supabase.from('wallet').upsert({
                                  'user_id': userId,
                                  'balance': credits,
                                }, onConflict: 'user_id');
                              }
                            }
                            
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEdit ? 'Student updated successfully' : 'Student created successfully'),
                                  backgroundColor: AdminTheme.success,
                                ),
                              );
                              _loadStudents();
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

  void _exportStudents() {
    final csv = StringBuffer();
    csv.writeln('ID,Email,Name,Status,Subscription,Credits,Level,Lessons,Hours');
    for (final student in _filteredStudents) {
      csv.writeln(
        '${student['id'] ?? ''},'
        '${student['email'] ?? ''},'
        '${student['full_name'] ?? ''},'
        '${(student['is_active'] ?? true) ? 'Active' : 'Suspended'},'
        '${student['subscription_status'] ?? 'none'},'
        '${student['credits'] ?? 0},'
        '${student['current_level'] ?? ''},'
        '${student['lessons_completed'] ?? 0},'
        '${student['learning_hours'] ?? 0}',
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${_filteredStudents.length} students'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
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

  BadgeType _getSubscriptionBadge(String status) {
    switch (status) {
      case 'active':
        return BadgeType.success;
      case 'trial':
        return BadgeType.info;
      case 'expired':
        return BadgeType.warning;
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
                onPressed: _loadStudents,
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
                  title: 'Student Management',
                  subtitle: 'Manage student accounts and learning progress',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: _exportStudents,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Export'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateOrEditStudentDialog(),
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('Add Student'),
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
              title: 'Total Students',
              value: _totalStudents.toString(),
              subtitle: 'All registered',
              icon: Icons.school_rounded,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'Active Students',
              value: _activeStudents.toString(),
              subtitle: 'Active accounts',
              icon: Icons.check_circle_rounded,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Subscribers',
              value: _subscribedStudents.toString(),
              subtitle: 'Paid plans',
              icon: Icons.card_membership_rounded,
              color: AdminTheme.secondary,
            ),
            StatCard(
              title: 'Trial Users',
              value: _trialStudents.toString(),
              subtitle: 'On free trial',
              icon: Icons.hourglass_bottom_rounded,
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
                hintText: 'Search students by name or email...',
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
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _subscriptionFilter,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'all', child: Text('All Subscriptions')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'trial', child: Text('Trial')),
                  DropdownMenuItem(value: 'expired', child: Text('Expired')),
                  DropdownMenuItem(value: 'none', child: Text('None')),
                ],
                onChanged: (value) {
                  _subscriptionFilter = value ?? 'all';
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
      'Student',
      'Level',
      'Subscription',
      'Credits',
      'Lessons',
      'Status',
      'Actions',
    ];

    final rows = _paginatedStudents.map((student) {
      final isActive = student['is_active'] ?? true;
      final subStatus = student['subscription_status'] ?? 'none';
      final wallet = student['wallet'];
      final credits = wallet != null ? (wallet['balance'] ?? 0) : 0;
      final lessons = student['lessons_completed'] ?? 0;
      final level = student['current_level'] ?? '';

      return [
        _buildStudentCell(context, student),
        StatusBadge(label: level, type: BadgeType.info),
        StatusBadge(
          label: subStatus.toString().toUpperCase(),
          type: _getSubscriptionBadge(subStatus),
        ),
        Text(
          credits.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Text(
          lessons.toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        StatusBadge(
          label: isActive ? 'Active' : 'Suspended',
          type: isActive ? BadgeType.success : BadgeType.error,
        ),
        _buildActionsCell(context, student),
      ];
    }).toList();

    return Card(
      child: _filteredStudents.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_outlined,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text('No students found',
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
                  final student = _paginatedStudents[i];
                  return DataRow(
                    cells: rows[i].map((w) => DataCell(w)).toList(),
                    onSelectChanged: (_) => _showStudentDetail(student),
                  );
                }),
              ),
            ),
    );
  }

  Widget _buildStudentCell(BuildContext context, Map<String, dynamic> student) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AdminTheme.success.withOpacity(0.1),
          child: Text(
            ((student['full_name'] ?? student['email'] ?? '?')[0] as String)
                .toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AdminTheme.success,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              student['full_name'] ?? 'Unknown',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              student['email'] ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsCell(BuildContext context, Map<String, dynamic> student) {
    final isActive = student['is_active'] ?? true;
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
              Text('Edit Student'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'credits',
          child: Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, size: 16),
              SizedBox(width: 8),
              Text('Adjust Credits'),
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
          _showStudentDetail(student);
        } else if (value == 'edit') {
          _showCreateOrEditStudentDialog(student: student);
        } else if (value == 'toggle') {
          _toggleStudentStatus(student);
        } else if (value == 'credits') {
          _showAdjustCreditsDialog(student);
        }
      },
    );
  }

  void _showAdjustCreditsDialog(Map<String, dynamic> student) {
    final wallet = student['wallet'];
    final initialCredits = wallet != null ? (wallet['balance'] ?? 0) : 0;
    final controller = TextEditingController(
      text: initialCredits.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Credits'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student: ${student['full_name'] ?? student['email']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Credits',
                hintText: 'Enter new credit amount',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCredits = int.tryParse(controller.text) ?? 0;
              try {
                final supabase = SupabaseService.instance.client;
                await supabase.from('wallet').upsert({
                  'user_id': student['auth_user_id'],
                  'balance': newCredits,
                }, onConflict: 'user_id');

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Credits updated successfully'),
                      backgroundColor: AdminTheme.success,
                    ),
                  );
                  _loadStudents();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update credits'),
                      backgroundColor: AdminTheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Showing ${_currentPage * _pageSize + 1}-${((_currentPage + 1) * _pageSize).clamp(0, _filteredStudents.length)} of ${_filteredStudents.length}',
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
                  color: isSelected ? AdminTheme.primary : Colors.transparent,
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
