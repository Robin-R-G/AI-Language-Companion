import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/audit_service.dart';
import '../../../../core/widgets/confirm_dialog.dart';

class UserDetailDialog extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserDetailDialog({super.key, required this.user});

  @override
  State<UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends State<UserDetailDialog> {
  bool _isUpdating = false;

  Map<String, dynamic> get user => widget.user;

  @override
  Widget build(BuildContext context) {
    final isActive = user['is_active'] ?? true;
    final createdAt = DateTime.tryParse(user['created_at'] ?? '');
    final lastLogin = DateTime.tryParse(user['last_login_at'] ?? '');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isActive),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Account Information'),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, 'User ID', user['id'] ?? ''),
                    _buildInfoRow(context, 'Email', user['email'] ?? ''),
                    _buildInfoRow(
                        context, 'Full Name', user['full_name'] ?? ''),
                    _buildInfoRow(
                      context,
                      'Role',
                      (user['role'] ?? 'unknown').toString().toUpperCase(),
                      badge: _buildRoleBadge(user['role'] ?? ''),
                    ),
                    _buildInfoRow(
                      context,
                      'Status',
                      isActive ? 'Active' : 'Suspended',
                      badge: StatusBadge(
                        label: isActive ? 'Active' : 'Suspended',
                        type:
                            isActive ? BadgeType.success : BadgeType.error,
                      ),
                    ),
                    _buildInfoRow(
                        context, 'Phone', user['phone'] ?? 'Not provided'),
                    _buildInfoRow(
                        context, 'Country', user['country'] ?? 'Unknown'),
                    const SizedBox(height: 20),
                    _buildSectionTitle(context, 'Activity'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      'Joined',
                      createdAt != null
                          ? DateFormat('MMMM d, yyyy').format(createdAt)
                          : 'Unknown',
                    ),
                    _buildInfoRow(
                      context,
                      'Last Login',
                      lastLogin != null
                          ? DateFormat('MMMM d, yyyy h:mm a').format(lastLogin)
                          : 'Never logged in',
                    ),
                    if (user['metadata'] != null &&
                        user['metadata'] is Map) ...[
                      const SizedBox(height: 20),
                      _buildSectionTitle(context, 'Metadata'),
                      const SizedBox(height: 12),
                      ..._buildMetadataRows(context),
                    ],
                    const SizedBox(height: 24),
                    _buildActionButtons(context, isActive),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AdminTheme.primary.withOpacity(0.1),
            child: Text(
              ((user['full_name'] ?? user['email'] ?? '?')[0] as String)
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AdminTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['full_name'] ?? 'Unknown User',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  user['email'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AdminTheme.primary,
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {Widget? badge}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: badge ??
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    BadgeType type;
    switch (role) {
      case 'admin':
        type = BadgeType.error;
        break;
      case 'tutor':
        type = BadgeType.info;
        break;
      case 'student':
        type = BadgeType.success;
        break;
      default:
        type = BadgeType.neutral;
    }
    return StatusBadge(
      label: role.toUpperCase(),
      type: type,
    );
  }

  List<Widget> _buildMetadataRows(BuildContext context) {
    final metadata = user['metadata'] as Map<String, dynamic>;
    return metadata.entries.map((entry) {
      return _buildInfoRow(
        context,
        entry.key.replaceAll('_', ' ').toUpperCase(),
        entry.value?.toString() ?? 'null',
      );
    }).toList();
  }

  Widget _buildActionButtons(BuildContext context, bool isActive) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isUpdating ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Close'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isUpdating ? null : () => _toggleStatus(context, isActive),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isActive ? AdminTheme.error : AdminTheme.success,
            ),
            icon: _isUpdating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
            label: Text(
              _isUpdating
                  ? 'Updating...'
                  : isActive
                      ? 'Suspend User'
                      : 'Activate User',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleStatus(BuildContext context, bool isActive) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: '${isActive ? 'Suspend' : 'Activate'} User',
      content:
          'Are you sure you want to ${isActive ? 'suspend' : 'activate'} ${user['full_name'] ?? user['email']}?',
      confirmLabel: isActive ? 'Suspend' : 'Activate',
      confirmColor: isActive ? AdminTheme.error : AdminTheme.success,
    );

    if (!confirmed) return;

    setState(() => _isUpdating = true);

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
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${isActive ? 'suspended' : 'activated'} successfully',
            ),
            backgroundColor: isActive ? AdminTheme.error : AdminTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update user status'),
            backgroundColor: AdminTheme.error,
          ),
        );
      }
    }
  }
}
