import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/constants/brand_tokens.dart';

/// Avatar selection page with gallery option, male/female tabs.
class AvatarPickerPage extends StatefulWidget {
  final String? currentAvatarUrl;
  final int? currentAvatarId;
  final String? currentAvatarPath;

  const AvatarPickerPage({
    super.key,
    this.currentAvatarUrl,
    this.currentAvatarId,
    this.currentAvatarPath,
  });

  @override
  State<AvatarPickerPage> createState() => _AvatarPickerPageState();
}

class _AvatarPickerPageState extends State<AvatarPickerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedAvatarId;
  String _selectedGender = 'male';
  String? _galleryImagePath;
  bool _useGalleryImage = false;

  static const int _maleCount = 30;
  static const int _femaleCount = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedAvatarId = widget.currentAvatarId;
    _galleryImagePath = widget.currentAvatarPath;

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          if (_tabController.index == 0) {
            _selectedGender = 'male';
          } else if (_tabController.index == 1) {
            _selectedGender = 'female';
          } else {
            _selectedGender = 'gallery';
          }
          _selectedAvatarId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectAvatar(int id) {
    setState(() {
      _selectedAvatarId = id;
      _useGalleryImage = false;
    });
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _galleryImagePath = pickedFile.path;
        _useGalleryImage = true;
        _selectedAvatarId = null;
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _galleryImagePath = pickedFile.path;
        _useGalleryImage = true;
        _selectedAvatarId = null;
      });
    }
  }

  void _confirmSelection() {
    if (_useGalleryImage && _galleryImagePath != null) {
      Navigator.pop(context, {
        'avatarPath': _galleryImagePath,
        'isLocalFile': true,
        'gender': 'gallery',
      });
    } else if (_selectedAvatarId != null) {
      final avatarPath = _selectedGender == 'male'
          ? BrandTokens.maleAvatarPath(_selectedAvatarId!)
          : BrandTokens.femaleAvatarPath(_selectedAvatarId!);
      Navigator.pop(context, {
        'avatarId': _selectedAvatarId,
        'avatarPath': avatarPath,
        'isLocalFile': false,
        'gender': _selectedGender,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Avatar'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Male'),
            Tab(text: 'Female'),
            Tab(icon: Icon(Icons.photo_library), text: 'Gallery'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvatarGrid('male', _maleCount),
                _buildAvatarGrid('female', _femaleCount),
                _buildGalleryTab(),
              ],
            ),
          ),
          _buildPreviewSection(theme),
          _buildBottomBar(theme),
        ],
      ),
    );
  }

  Widget _buildAvatarGrid(String gender, int count) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          final avatarId = index + 1;
          final isSelected = _selectedAvatarId == avatarId && !_useGalleryImage;
          final avatarPath = gender == 'male'
              ? BrandTokens.maleAvatarPath(avatarId)
              : BrandTokens.femaleAvatarPath(avatarId);

          return _AvatarTile(
            avatarPath: avatarPath,
            avatarId: avatarId,
            isSelected: isSelected,
            onTap: () => _selectAvatar(avatarId),
          );
        },
      ),
    );
  }

  Widget _buildGalleryTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          // Current preview
          if (_galleryImagePath != null && _useGalleryImage)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.file(
                  File(_galleryImagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.person,
                size: 60,
                color: AppColors.primary,
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          // Action buttons
          _GalleryButton(
            icon: Icons.photo_library,
            label: 'Choose from Gallery',
            onTap: _pickFromGallery,
          ),
          const SizedBox(height: AppSpacing.base),
          _GalleryButton(
            icon: Icons.camera_alt,
            label: 'Take a Photo',
            onTap: _takePhoto,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(ThemeData theme) {
    if (_selectedAvatarId == null && !_useGalleryImage) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Preview
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _useGalleryImage && _galleryImagePath != null
                  ? Image.file(
                      File(_galleryImagePath!),
                      fit: BoxFit.cover,
                    )
                  : _selectedAvatarId != null
                      ? Image.asset(
                          _selectedGender == 'male'
                              ? BrandTokens.maleAvatarPath(_selectedAvatarId!)
                              : BrandTokens.femaleAvatarPath(_selectedAvatarId!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : const SizedBox(),
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Text(
              _useGalleryImage ? 'Custom photo selected' : 'Avatar selected',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    final hasSelection = _selectedAvatarId != null || _useGalleryImage;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: hasSelection ? _confirmSelection : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.disabled,
              disabledForegroundColor: AppColors.disabledText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text(
              'Select Avatar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarTile extends StatelessWidget {
  final String avatarPath;
  final int avatarId;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarTile({
    required this.avatarPath,
    required this.avatarId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                avatarPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackAvatar(theme),
              ),
              if (isSelected)
                Container(
                  color: AppColors.primary.withOpacity(0.2),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 32,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

class _GalleryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GalleryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.primary),
        label: Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}
