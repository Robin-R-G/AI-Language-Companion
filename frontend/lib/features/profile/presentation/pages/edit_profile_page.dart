import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'avatar_picker_page.dart';

/// Edit Profile screen for updating user information.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isLoading = false;
  bool _hasError = false;
  bool _isSaving = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedNativeLanguage = 'Malayalam';
  String _selectedTargetLanguage = 'English';
  String _selectedLevel = 'Intermediate';

  // Avatar state
  int? _selectedAvatarId;
  String? _selectedAvatarPath;
  bool _isLocalFile = false;

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
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Load profile from Supabase
        final profile = await Supabase.instance.client
            .from('user_profiles')
            .select()
            .eq('auth_user_id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            _nameController.text = (profile?['full_name'] as String?) ?? user.email?.split('@').first ?? '';
            _emailController.text = user.email ?? '';
            _selectedNativeLanguage = (profile?['native_language'] as String?) ?? 'Malayalam';
            _selectedTargetLanguage = (profile?['target_language'] as String?) ?? 'English';
            _selectedLevel = (profile?['proficiency_level'] as String?) ?? 'Intermediate';
            _selectedAvatarPath = profile?['avatar_url'] as String?;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('user_profiles').upsert({
          'auth_user_id': user.id,
          'full_name': _nameController.text.trim(),
          'native_language': _selectedNativeLanguage,
          'target_language': _selectedTargetLanguage,
          'proficiency_level': _selectedLevel,
          if (_selectedAvatarPath != null && !_isLocalFile)
            'avatar_url': _selectedAvatarPath,
        }, onConflict: 'auth_user_id');
      }
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _openAvatarPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => AvatarPickerPage(
        currentAvatarId: _selectedAvatarId,
        currentAvatarPath: _isLocalFile ? _selectedAvatarPath : null,
      )),
    );

    if (result != null) {
      setState(() {
        _selectedAvatarId = result['avatarId'] as int?;
        _selectedAvatarPath = result['avatarPath'] as String?;
        _isLocalFile = result['isLocalFile'] as bool? ?? false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        // Avatar
        Center(
          child: Stack(
            children: [
              _buildAvatar(),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _openAvatarPicker,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Change Avatar Button
        Center(
          child: TextButton.icon(
            onPressed: _openAvatarPicker,
            icon: const Icon(Icons.face, size: 18),
            label: const Text('Change Avatar'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Name
        AppTextField(
          controller: _nameController,
          labelText: 'Name',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: AppSpacing.base),

        // Email
        AppTextField(
          controller: _emailController,
          labelText: 'Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          enabled: false,
        ),
        const SizedBox(height: AppSpacing.base),

        // Native Language
        _DropdownField(
          label: 'Native Language (L1)',
          value: _selectedNativeLanguage,
          items: const ['Malayalam', 'Hindi', 'Tamil', 'Telugu', 'Kannada'],
          onChanged: (val) => setState(() => _selectedNativeLanguage = val!),
        ),
        const SizedBox(height: AppSpacing.base),

        // Target Language
        _DropdownField(
          label: 'Target Language (L2)',
          value: _selectedTargetLanguage,
          items: const ['English', 'German', 'French', 'Japanese', 'Korean'],
          onChanged: (val) => setState(() => _selectedTargetLanguage = val!),
        ),
        const SizedBox(height: AppSpacing.base),

        // Proficiency Level
        _DropdownField(
          label: 'Current Level',
          value: _selectedLevel,
          items: const [
            'Beginner',
            'Elementary',
            'Intermediate',
            'Upper Intermediate',
            'Advanced',
          ],
          onChanged: (val) => setState(() => _selectedLevel = val!),
        ),
        const SizedBox(height: AppSpacing.xxl),

        AppButton(
          label: 'Save Changes',
          onPressed: _saveProfile,
          isLoading: _isSaving,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildAvatar() {
    // Local file (from gallery)
    if (_isLocalFile && _selectedAvatarPath != null) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: ClipOval(
          child: Image.file(
            File(_selectedAvatarPath!),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Pre-made avatar asset
    if (_selectedAvatarPath != null && !_isLocalFile) {
      return AppAvatar(
        radius: 50,
        assetPath: _selectedAvatarPath,
      );
    }

    // Default fallback
    return const AppAvatar(radius: 50);
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.language),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
