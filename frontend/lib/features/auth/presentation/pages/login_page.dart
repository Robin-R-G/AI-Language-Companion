import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;
import '../../../../app/router.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/auth_error_messages.dart';
import '../controllers/auth_controller.dart';

/// Login page with role-specific flows and admin security.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _selectedRole => LocalStorage.getSelectedRole() ?? 'student';
  bool get _isAdminLogin => _selectedRole == 'admin';

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();

      final authState = ref.read(authControllerProvider);
      if (mounted) {
        if (authState.hasError) {
          final error = authState.error.toString();
          // Silently handle cancelled sign-in
          if (error.contains('cancelled')) {
            setState(() => _isLoading = false);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(friendlyAuthMessage(authState.error!)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (authState.hasValue && authState.value != null) {
          // Refresh auth state to get role
          ref.read(authStateProvider.notifier).refreshRole();
          final authStateFinal = ref.read(authStateProvider);
          final role = authStateFinal.role;

          if (mounted) {
            final onboardingDone = LocalStorage.isOnboardingComplete();
            if (!onboardingDone) {
              context.go(RouteNames.onboarding);
            } else {
              context.go(_homeForRole(role));
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final message = friendlyAuthMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final authState = ref.read(authControllerProvider);
      if (mounted) {
        if (authState.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(friendlyAuthMessage(authState.error!)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (authState.hasValue && authState.value != null) {
          // Check role-based access for admin login
          if (_isAdminLogin) {
            final client = Supabase.instance.client;
            final user = client.auth.currentUser;
            if (user != null) {
              final response = await client
                  .from('user_profiles')
                  .select('role')
                  .eq('auth_user_id', user.id)
                  .maybeSingle();

              final roleStr = response?['role'] as String?;
              final role = UserRole.fromString(roleStr);

              if (!role.isAdminOrAbove) {
                // Not an admin - sign out and show error
                await client.auth.signOut();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Administrator credentials required.'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  setState(() => _isLoading = false);
                }
                return;
              }
            }
          }

          // Refresh auth state to get role
          ref.read(authStateProvider.notifier).refreshRole();
          final authStateFinal = ref.read(authStateProvider);
          final role = authStateFinal.role;

          if (mounted) {
            final onboardingDone = LocalStorage.isOnboardingComplete();
            if (!onboardingDone) {
              context.go(RouteNames.onboarding);
            } else {
              context.go(_homeForRole(role));
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final message = friendlyAuthMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _homeForRole(UserRole role) {
    switch (role) {
      case UserRole.tutor:
        return RouteNames.tutorDashboard;
      case UserRole.superAdmin:
      case UserRole.admin:
      case UserRole.financeManager:
      case UserRole.tutorManager:
      case UserRole.supportManager:
      case UserRole.contentManager:
      case UserRole.marketingManager:
        return RouteNames.adminFinance;
      case UserRole.student:
        return RouteNames.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.huge),

                // Logo & Title
                Icon(
                  _isAdminLogin ? Icons.admin_panel_settings_rounded : Icons.school_rounded,
                  size: 72,
                  color: _isAdminLogin
                      ? const Color(0xFF7C3AED)
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.base),
                Text(
                  _isAdminLogin ? 'Administrator Login' : 'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _isAdminLogin
                      ? 'Administrator credentials required.'
                      : 'Sign in to continue learning',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
                  textAlign: TextAlign.center,
                ),

                // Role badge
                const SizedBox(height: AppSpacing.base),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: (_isAdminLogin ? const Color(0xFF7C3AED) : Theme.of(context).colorScheme.primary).withAlpha(15),
                      borderRadius: BorderRadius.circular(AppRadius.round),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isAdminLogin ? Icons.shield_rounded : Icons.person_rounded,
                          size: 16,
                          color: _isAdminLogin
                              ? const Color(0xFF7C3AED)
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _isAdminLogin ? 'Admin' : 'Student',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isAdminLogin
                                ? const Color(0xFF7C3AED)
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.base),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.sm),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(RouteNames.forgotPassword),
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: AppSpacing.base),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: _isAdminLogin
                      ? ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                        )
                      : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Login'),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Divider (skip social for admin)
                if (!_isAdminLogin) ...[
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                        ),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Social Login Buttons
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: const Text('Continue with Google'),
                  ),

                  const SizedBox(height: AppSpacing.base),

                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Apple Sign-In coming soon')),
                      );
                    },
                    icon: const Icon(Icons.apple, size: 24),
                    label: const Text('Continue with Apple'),
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                // Sign Up Link (skip for admin)
                if (!_isAdminLogin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.push(RouteNames.signup),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),

                // Change role link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => context.go(RouteNames.roleSelection),
                      child: Text(
                        'Change Role',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
