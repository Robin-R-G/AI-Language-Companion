import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/audit_service.dart';
import '../../../../core/widgets/confirm_dialog.dart';

class StudentDetailDialog extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentDetailDialog({super.key, required this.student});

  @override
  State<StudentDetailDialog> createState() => _StudentDetailDialogState();
}

class _StudentDetailDialogState extends State<StudentDetailDialog> {
  bool _isUpdating = false;

  Map<String, dynamic> get student => widget.student;

  @override
  Widget build(BuildContext context) {
    final isActive = student['is_active'] ?? true;
    final createdAt = DateTime.tryParse(student['created_at'] ?? '');
    final lastLogin = DateTime.tryParse(student['last_login_at'] ?? '');
    final credits = student['credits'] ?? 0;
    final lessons = student['lessons_completed'] ?? 0;
    final hours = student['learning_hours'] ?? '0';
    final level = student['current_level'] ?? 'N/A';
    final subStatus = student['subscription_status'] ?? 'none';
    final targetLanguage = student['target_language'] ?? 'N/A';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
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
                    _buildInfoRow(context, 'Student ID', student['id'] ?? ''),
                    _buildInfoRow(context, 'Email', student['email'] ?? ''),
                    _buildInfoRow(
                        context, 'Full Name', student['full_name'] ?? ''),
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
                        context, 'Phone', student['phone'] ?? 'Not provided'),
                    _buildInfoRow(
                        context, 'Country', student['country'] ?? 'Unknown'),
                    const SizedBox(height: 20),
                    _buildSectionTitle(context, 'Subscription'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      'Plan Status',
                      subStatus.toString().toUpperCase(),
                      badge: StatusBadge(
                        label: subStatus.toString().toUpperCase(),
                        type: _getSubscriptionBadgeType(subStatus),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(context, 'Learning Progress'),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, 'Current Level', level),
                    _buildInfoRow(context, 'Target Language', targetLanguage),
                    _buildInfoRow(
                      context,
                      'Credits',
                      credits.toString(),
                      badge: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminTheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$credits credits',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AdminTheme.secondary,
                          ),
                        ),
                      ),
                    ),
                    _buildInfoRow(
                        context, 'Lessons Completed', lessons.toString()),
                    _buildInfoRow(context, 'Learning Hours', '${hours}h'),
                    const SizedBox(height: 16),
                    _buildProgressSection(context),
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
        color: AdminTheme.success.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AdminTheme.success.withOpacity(0.1),
            child: Text(
              ((student['full_name'] ?? student['email'] ?? '?')[0] as String)
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AdminTheme.success,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['full_name'] ?? 'Unknown Student',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  student['email'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StatusBadge(
                      label: student['current_level'] ?? 'N/A',
                      type: BadgeType.info,
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label:
                          (student['subscription_status'] ?? 'none')
                              .toString()
                              .toUpperCase(),
                      type: _getSubscriptionBadgeType(
                          student['subscription_status'] ?? 'none'),
                    ),
                  ],
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
            color: AdminTheme.success,
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
            width: 140,
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

  BadgeType _getSubscriptionBadgeType(String status) {
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

  Widget _buildProgressSection(BuildContext context) {
    final credits = (student['credits'] ?? 0) as int;
    final maxCredits = 1500;
    final creditProgress = (credits / maxCredits).clamp(0.0, 1.0);

    final lessons = (student['lessons_completed'] ?? 0) as int;
    final maxLessons = 200;
    final lessonProgress = (lessons / maxLessons).clamp(0.0, 1.0);

    return Card(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Credits',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '$credits / $maxCredits',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: creditProgress,
                backgroundColor:
                    AdminTheme.secondary.withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AdminTheme.secondary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lessons Completed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '$lessons / $maxLessons',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: lessonProgress,
                backgroundColor:
                    AdminTheme.primary.withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AdminTheme.primary),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
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
            onPressed:
                _isUpdating ? null : () => _toggleStatus(context, isActive),
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
                      ? 'Suspend Student'
                      : 'Activate Student',
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
      title: '${isActive ? 'Suspend' : 'Activate'} Student',
      content:
          'Are you sure you want to ${isActive ? 'suspend' : 'activate'} ${student['full_name'] ?? student['email']}?',
      confirmLabel: isActive ? 'Suspend' : 'Activate',
      confirmColor: isActive ? AdminTheme.error : AdminTheme.success,
    );

    if (!confirmed) return;

    setState(() => _isUpdating = true);

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
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Student ${isActive ? 'suspended' : 'activated'} successfully',
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
            content: Text('Failed to update student status'),
            backgroundColor: AdminTheme.error,
          ),
        );
      }
    }
  }
}
