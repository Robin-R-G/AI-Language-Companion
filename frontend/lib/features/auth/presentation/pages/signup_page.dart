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

/// Signup page for new user registration with role-specific flows.
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptTerms = false;

  String get _selectedRole => LocalStorage.getSelectedRole() ?? 'student';
  bool get _isTutorSignup => _selectedRole == 'tutor';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignup() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();

      final authState = ref.read(authControllerProvider);
      if (mounted) {
        if (authState.hasError) {
          final error = authState.error.toString();
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
          ref.read(authStateProvider.notifier).refreshRole();

          if (_isTutorSignup) {
            context.go(RouteNames.tutorRegister);
          } else {
            context.go(RouteNames.onboarding);
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

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
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
          // Create user profile row with selected role
          try {
            final client = Supabase.instance.client;
            final user = client.auth.currentUser;
            if (user != null) {
              final roleValue = _isTutorSignup ? 'student' : _selectedRole;
              await client.from('user_profiles').upsert({
                'auth_user_id': user.id,
                'full_name': _nameController.text.trim(),
                'email': _emailController.text.trim(),
                'role': roleValue,
                'onboarding_completed': false,
              }, onConflict: 'auth_user_id');
            }
          } catch (profileError) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile setup will complete on next login.'),
                  backgroundColor: AppColors.warning,
                ),
              );
            }
          }

          if (_isTutorSignup) {
            context.go(RouteNames.tutorRegister);
          } else {
            context.go(RouteNames.onboarding);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  _isTutorSignup ? 'Create Tutor Account' : 'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _isTutorSignup
                      ? 'Start your teaching journey today'
                      : 'Start your language learning journey today',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.base),

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
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                      return 'Password must contain an uppercase letter';
                    }
                    if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
                      return 'Password must contain a number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.base),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.base),

                // Terms Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: Theme.of(context).textTheme.bodySmall,
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isTutorSignup ? 'Create Tutor Account' : 'Create Account'),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Social Signup Buttons
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignup,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Continue with Google'),
                ),

                const SizedBox(height: AppSpacing.base),

                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Apple Sign-Up coming soon')),
                    );
                  },
                  icon: const Icon(Icons.apple, size: 24),
                  label: const Text('Continue with Apple'),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Login'),
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
