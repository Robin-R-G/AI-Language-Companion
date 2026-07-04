import 'package:flutter/material.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/info_tile.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Settings screen with app configuration options.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;
  bool _hasError = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_hasError) return ErrorView(onRetry: _loadData);
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.base),
        itemCount: 5,
        itemBuilder: (context, index) => const ShimmerCard(),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        // Language Section
        _SectionTitle(title: 'Language'),
        InfoTile(
          icon: Icons.translate,
          title: 'App Language',
          subtitle: _selectedLanguage,
          onTap: () => _showLanguageDialog(context),
        ),
        InfoTile(
          icon: Icons.record_voice_over,
          title: 'Native Language (L1)',
          subtitle: 'Malayalam',
          onTap: () {},
        ),
        InfoTile(
          icon: Icons.language,
          title: 'Learning Language (L2)',
          subtitle: 'English',
          onTap: () {},
        ),
        const Divider(),

        // Notifications Section
        _SectionTitle(title: 'Notifications'),
        InfoTile(
          icon: Icons.notifications_outlined,
          title: 'Push Notifications',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
        ),
        InfoTile(
          icon: Icons.alarm,
          title: 'Study Reminders',
          subtitle: 'Daily at 7:00 PM',
          onTap: () {},
        ),
        const Divider(),

        // Account Section
        _SectionTitle(title: 'Account'),
        InfoTile(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          onTap: () {},
        ),
        InfoTile(
          icon: Icons.lock_outline,
          title: 'Change Password',
          onTap: () {},
        ),
        InfoTile(
          icon: Icons.language,
          title: 'Subscription',
          subtitle: 'Free Plan',
          onTap: () {},
        ),
        const Divider(),

        // Support Section
        _SectionTitle(title: 'Support'),
        InfoTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {},
        ),
        InfoTile(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          onTap: () {},
        ),
        InfoTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () {},
        ),
        InfoTile(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'Version 1.0.0',
          onTap: () {},
        ),
        const Divider(),

        // Danger Zone
        _SectionTitle(title: 'Danger Zone'),
        InfoTile(
          icon: Icons.delete_forever,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account and data',
          iconColor: AppColors.error,
          onTap: () => _showDeleteDialog(context),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = ['English', 'Malayalam', 'German', 'French'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _selectedLanguage,
              onChanged: (val) {
                setState(() => _selectedLanguage = val!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is permanent and cannot be undone. All your data, progress, and history will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
