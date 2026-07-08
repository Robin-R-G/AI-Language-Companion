import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/admin_config.dart';
import '../../../../core/services/audit_service.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/data_table_widget.dart';
import '../widgets/tutor_detail_dialog.dart';

class TutorsPage extends StatefulWidget {
  const TutorsPage({super.key});

  @override
  State<TutorsPage> createState() => _TutorsPageState();
}

class _TutorsPageState extends State<TutorsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'All';
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _allTutors = [];
  List<Map<String, dynamic>> _filteredTutors = [];

  int _totalCount = 0;
  int _verifiedCount = 0;
  int _pendingCount = 0;
  int _suspendedCount = 0;

  final _filters = ['All', 'Pending', 'Verified', 'Suspended'];

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _loadTutors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _supabase
          .from('user_profiles')
          .select('*, tutor_profiles(*)')
          .eq('role', 'tutor')
          .order('created_at', ascending: false);

      final tutors = List<Map<String, dynamic>>.from(response);

      _totalCount = tutors.length;
      _verifiedCount = tutors
          .where((t) => (t['verification_status'] ?? '') == 'verified')
          .length;
      _pendingCount = tutors
          .where((t) => (t['verification_status'] ?? '') == 'pending')
          .length;
      _suspendedCount = tutors
          .where((t) => (t['is_suspended'] == true))
          .length;

      setState(() {
        _allTutors = tutors;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load tutors: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    var results = List<Map<String, dynamic>>.from(_allTutors);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = results.where((t) {
        final name = (t['full_name'] ?? '').toString().toLowerCase();
        final email = (t['email'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q);
      }).toList();
    }

    switch (_activeFilter) {
      case 'Pending':
        results = results
            .where((t) => (t['verification_status'] ?? '') == 'pending')
            .toList();
        break;
      case 'Verified':
        results = results
            .where((t) => (t['verification_status'] ?? '') == 'verified')
            .toList();
        break;
      case 'Suspended':
        results = results.where((t) => t['is_suspended'] == true).toList();
        break;
    }

    setState(() => _filteredTutors = results);
  }

  Future<void> _verifyTutor(Map<String, dynamic> tutor) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Verify Tutor',
      content:
          'Are you sure you want to verify ${tutor['full_name'] ?? 'this tutor'}? They will be able to accept bookings.',
      confirmLabel: 'Verify',
      confirmColor: AdminTheme.success,
    );
    if (!confirmed) return;

    try {
      await _supabase.from('user_profiles').update({
        'verification_status': 'verified',
        'verified_at': DateTime.now().toIso8601String(),
      }).eq('id', tutor['id']);

      await _loadTutors();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tutor verified successfully'),
            backgroundColor: AdminTheme.success,
          ),
        );
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
    }
  }

  Future<void> _suspendTutor(Map<String, dynamic> tutor) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Suspend Tutor',
      content:
          'Are you sure you want to suspend ${tutor['full_name'] ?? 'this tutor'}? They will be unable to accept new bookings.',
      confirmLabel: 'Suspend',
      confirmColor: AdminTheme.error,
    );
    if (!confirmed) return;

    try {
      await _supabase.from('user_profiles').update({
        'is_suspended': true,
        'suspended_at': DateTime.now().toIso8601String(),
      }).eq('id', tutor['id']);

      await _loadTutors();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tutor suspended'),
            backgroundColor: AdminTheme.warning,
          ),
        );
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
    }
  }

  Future<void> _unsuspendTutor(Map<String, dynamic> tutor) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Reactivate Tutor',
      content:
          'Reactivate ${tutor['full_name'] ?? 'this tutor'}? They will be able to accept bookings again.',
      confirmLabel: 'Reactivate',
      confirmColor: AdminTheme.success,
    );
    if (!confirmed) return;

    try {
      await _supabase.from('user_profiles').update({
        'is_suspended': false,
        'suspended_at': null,
      }).eq('id', tutor['id']);

      await _loadTutors();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tutor reactivated'),
            backgroundColor: AdminTheme.success,
          ),
        );
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
    }
  }

  void _showTutorDetail(Map<String, dynamic> tutor) {
    showDialog(
      context: context,
      builder: (_) => TutorDetailDialog(tutor: tutor),
    );
  }

  Future<void> _showCreateOrEditTutorDialog({Map<String, dynamic>? tutor}) async {
    final isEdit = tutor != null;
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController(text: tutor?['email'] ?? '');
    final passwordController = TextEditingController();
    final nameController = TextEditingController(text: tutor?['full_name'] ?? '');
    final phoneController = TextEditingController(text: tutor?['phone'] ?? '');
    final countryController = TextEditingController(text: tutor?['country'] ?? '');
    
    final experienceController = TextEditingController(
      text: tutor?['tutor_profiles'] != null
          ? (tutor?['tutor_profiles']['years_of_experience'] ?? 0).toString()
          : '0',
    );
    final specializationsController = TextEditingController(
      text: tutor?['tutor_profiles'] != null
          ? ((tutor?['tutor_profiles']['specializations'] as List?) ?? []).join(', ')
          : '',
    );
    final statusController = TextEditingController(
      text: tutor?['tutor_profiles'] != null
          ? (tutor?['tutor_profiles']['status'] ?? 'pending')
          : 'pending',
    );

    bool isActive = !(tutor?['is_suspended'] == true);
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEdit ? 'Edit Tutor' : 'Create Tutor'),
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
                        controller: experienceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Years of Experience'),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Must be a number' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: specializationsController,
                        decoration: const InputDecoration(labelText: 'Specializations (comma separated)'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: statusController.text,
                        decoration: const InputDecoration(labelText: 'Verification Status'),
                        items: const [
                          DropdownMenuItem(value: 'draft', child: Text('Draft')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'approved', child: Text('Approved')),
                          DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => statusController.text = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Is Active (Not Suspended)'),
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
                            final supabase = _supabase;
                            final yearsExp = int.parse(experienceController.text);
                            final specs = specializationsController.text
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) => s.isNotEmpty)
                                .toList();
                            
                            if (isEdit) {
                              await supabase.from('user_profiles').update({
                                'full_name': nameController.text,
                                'phone': phoneController.text,
                                'country': countryController.text,
                                'is_suspended': !isActive,
                              }).eq('id', tutor['id']);

                              await supabase.from('tutor_profiles').upsert({
                                'user_id': tutor['auth_user_id'],
                                'years_of_experience': yearsExp,
                                'specializations': specs,
                                'status': statusController.text,
                              }, onConflict: 'user_id');

                              await AuditService.instance.log(
                                action: 'tutor_update',
                                targetType: 'tutor',
                                targetId: tutor['id'],
                                details: {'email': tutor['email']},
                              );
                            } else {
                              final tempClient = SupabaseClient(
                                AdminConfig.supabaseUrl,
                                AdminConfig.supabaseAnonKey,
                              );
                              
                              final authResult = await tempClient.auth.signUp(
                                email: emailController.text.trim(),
                                password: passwordController.text,
                              );
                              
                              if (authResult.user == null) {
                                throw Exception('Auth user creation failed.');
                              }

                              await supabase.from('user_profiles').update({
                                'full_name': nameController.text,
                                'role': 'tutor',
                                'phone': phoneController.text,
                                'country': countryController.text,
                                'is_suspended': !isActive,
                                'email': emailController.text.trim(),
                              }).eq('auth_user_id', authResult.user!.id);

                              await supabase.from('tutor_profiles').upsert({
                                'user_id': authResult.user!.id,
                                'years_of_experience': yearsExp,
                                'specializations': specs,
                                'status': statusController.text,
                              }, onConflict: 'user_id');
                            }
                            
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEdit ? 'Tutor updated successfully' : 'Tutor created successfully'),
                                  backgroundColor: AdminTheme.success,
                                ),
                              );
                              _loadTutors();
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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  BadgeType _statusBadgeType(String? status) {
    return switch (status) {
      'verified' => BadgeType.success,
      'pending' => BadgeType.warning,
      'rejected' => BadgeType.error,
      _ => BadgeType.neutral,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Tutor Management',
          subtitle: 'Manage tutor verification, profiles, and access',
          actions: [
            ElevatedButton.icon(
              onPressed: () => _showCreateOrEditTutorDialog(),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Add Tutor'),
            ),
          ],
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AdminTheme.error),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AdminTheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadTutors,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildFiltersAndSearch(),
          const SizedBox(height: 16),
          _buildTutorsTable(),
        ],
      ],
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
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            StatCard(
              title: 'Total Tutors',
              value: '$_totalCount',
              subtitle: 'Registered on platform',
              icon: Icons.school_rounded,
              color: AdminTheme.primary,
              trend: _totalCount > 0 ? 5.2 : null,
            ),
            StatCard(
              title: 'Verified',
              value: '$_verifiedCount',
              subtitle: 'Active and verified',
              icon: Icons.verified_rounded,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Pending Verification',
              value: '$_pendingCount',
              subtitle: 'Awaiting review',
              icon: Icons.pending_actions_rounded,
              color: AdminTheme.warning,
            ),
            StatCard(
              title: 'Suspended',
              value: '$_suspendedCount',
              subtitle: 'Currently suspended',
              icon: Icons.block_rounded,
              color: AdminTheme.error,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltersAndSearch() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        return isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchField(
                    controller: _searchController,
                    hintText: 'Search tutors by name or email...',
                    onChanged: (value) {
                      _searchQuery = value;
                      _applyFilter();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: SearchField(
                      controller: _searchController,
                      hintText: 'Search tutors by name or email...',
                      onChanged: (value) {
                        _searchQuery = value;
                        _applyFilter();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildFilterChips(),
                ],
              );
      },
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: _filters.map((filter) {
        final isActive = _activeFilter == filter;
        return ChoiceChip(
          label: Text(filter),
          selected: isActive,
          onSelected: (_) {
            setState(() => _activeFilter = filter);
            _applyFilter();
          },
          selectedColor: AdminTheme.primary.withOpacity(0.1),
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive
                ? AdminTheme.primary
                : Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTutorsTable() {
    final columns = [
      'Tutor',
      'Email',
      'Status',
      'Verification',
      'Joined',
      'Actions',
    ];

    final rows = _filteredTutors.map((tutor) {
      final fullName = tutor['full_name'] ?? 'Unknown';
      final email = tutor['email'] ?? 'N/A';
      final isSuspended = tutor['is_suspended'] == true;
      final verificationStatus = tutor['verification_status'] ?? 'pending';
      final createdAt = tutor['created_at'];
      final avatarLetter = fullName.toString().isNotEmpty
          ? fullName.toString()[0].toUpperCase()
          : '?';

      return [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AdminTheme.primary.withOpacity(0.1),
              child: Text(
                avatarLetter,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AdminTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                fullName.toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Text(email.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
        StatusBadge(
          label: isSuspended ? 'Suspended' : 'Active',
          type: isSuspended ? BadgeType.error : BadgeType.success,
        ),
        StatusBadge(
          label: verificationStatus.toString().toUpperCase(),
          type: _statusBadgeType(verificationStatus),
        ),
        Text(_formatDate(createdAt)),
        _buildActionsMenu(tutor),
      ];
    }).toList();

    return AdminDataTable(
      columns: columns,
      rows: rows,
      onRowTap: (index) => _showTutorDetail(_filteredTutors[index]),
    );
  }

  Widget _buildActionsMenu(Map<String, dynamic> tutor) {
    final isSuspended = tutor['is_suspended'] == true;
    final verificationStatus = tutor['verification_status'] ?? 'pending';

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18),
      onSelected: (action) {
        switch (action) {
          case 'view':
            _showTutorDetail(tutor);
            break;
          case 'edit':
            _showCreateOrEditTutorDialog(tutor: tutor);
            break;
          case 'verify':
            _verifyTutor(tutor);
            break;
          case 'suspend':
            _suspendTutor(tutor);
            break;
          case 'unsuspend':
            _unsuspendTutor(tutor);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility_rounded, size: 16),
              SizedBox(width: 8),
              Text('View Profile'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 16),
              SizedBox(width: 8),
              Text('Edit Tutor'),
            ],
          ),
        ),
        if (verificationStatus == 'pending')
          const PopupMenuItem(
            value: 'verify',
            child: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 16, color: AdminTheme.success),
                SizedBox(width: 8),
                Text('Verify Tutor',
                    style: TextStyle(color: AdminTheme.success)),
              ],
            ),
          ),
        if (!isSuspended)
          const PopupMenuItem(
            value: 'suspend',
            child: Row(
              children: [
                Icon(Icons.block_rounded, size: 16, color: AdminTheme.error),
                SizedBox(width: 8),
                Text('Suspend', style: TextStyle(color: AdminTheme.error)),
              ],
            ),
          ),
        if (isSuspended)
          const PopupMenuItem(
            value: 'unsuspend',
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 16, color: AdminTheme.success),
                SizedBox(width: 8),
                Text('Reactivate',
                    style: TextStyle(color: AdminTheme.success)),
              ],
            ),
          ),
      ],
    );
  }
}
