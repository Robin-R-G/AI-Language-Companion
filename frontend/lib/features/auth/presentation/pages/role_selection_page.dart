import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;
import '../../../../app/router.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/storage/local_storage.dart';

/// First-launch role selection screen.
/// Shown only once after splash, before auth.
class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  UserRole? _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectRole(UserRole role) async {
    setState(() {
      _selectedRole = role;
      _isLoading = true;
    });

    try {
      // Save selected role locally
      await LocalStorage.setData('selected_role', role.dbValue);

      // If user is authenticated, update their profile role in Supabase
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          await Supabase.instance.client
              .from('user_profiles')
              .upsert({
                'auth_user_id': user.id,
                'role': role.dbValue,
              }, onConflict: 'auth_user_id');
        } catch (_) {
          // Profile may not exist yet; continue
        }
      }

      if (!mounted) return;

      // Navigate based on role
      switch (role) {
        case UserRole.student:
          context.go(RouteNames.onboarding);
          break;
        case UserRole.tutor:
          context.go(RouteNames.tutorRegister);
          break;
        case UserRole.admin:
          context.go(RouteNames.login);
          break;
        default:
          context.go(RouteNames.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF131B2E), const Color(0xFF0B1220)]
                : [const Color(0xFFF0F4FF), const Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Header
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'How will you use\nAI Language Coach?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Choose your role to get started.\nYou can change this later.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Role Cards
                  Expanded(
                    child: Column(
                      children: [
                        _RoleCard(
                          icon: Icons.school_rounded,
                          title: 'Student',
                          subtitle: 'Learn languages with AI coaching, lessons, and practice',
                          color: const Color(0xFF22C55E),
                          isSelected: _selectedRole == UserRole.student,
                          isLoading: _isLoading && _selectedRole == UserRole.student,
                          onTap: () => _selectRole(UserRole.student),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        _RoleCard(
                          icon: Icons.record_voice_over_rounded,
                          title: 'Tutor',
                          subtitle: 'Teach students, manage bookings, and earn income',
                          color: const Color(0xFF3B82F6),
                          isSelected: _selectedRole == UserRole.tutor,
                          isLoading: _isLoading && _selectedRole == UserRole.tutor,
                          onTap: () => _selectRole(UserRole.tutor),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        _RoleCard(
                          icon: Icons.admin_panel_settings_rounded,
                          title: 'Administrator',
                          subtitle: 'Manage platform, users, and operations',
                          color: const Color(0xFF7C3AED),
                          isSelected: _selectedRole == UserRole.admin,
                          isLoading: _isLoading && _selectedRole == UserRole.admin,
                          onTap: () => _selectRole(UserRole.admin),
                        ),
                      ],
                    ),
                  ),

                  // Skip for now
                  TextButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: Text(
                      'I already have an account',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: widget.isSelected ? 4 : 0,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onTap,
          onHighlightChanged: (v) => setState(() => _isPressed = v),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: widget.isSelected
                    ? widget.color
                    : isDark
                        ? AppColors.darkBorder
                        : AppColors.border,
                width: widget.isSelected ? 2 : 1,
              ),
              color: widget.isSelected
                  ? widget.color.withAlpha(15)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: widget.isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.color,
                          ),
                        )
                      : Icon(widget.icon, color: widget.color, size: 28),
                ),
                const SizedBox(width: AppSpacing.base),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isSelected)
                  Icon(
                    Icons.check_circle,
                    color: widget.color,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
