import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/storage/local_storage.dart';

/// Premium splash screen with animated logo, loading indicator, and initialization.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _loadingFade;
  String _statusText = 'Initializing...';

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)),
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)),
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeIn),
    );

    // Set premium status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _loadingController.forward();
    });

    // Initialize and navigate
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _statusText = 'Loading preferences...');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _statusText = 'Setting up experience...');
      await Future.delayed(const Duration(milliseconds: 400));

      setState(() => _statusText = 'Almost ready...');
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Check auth state
      final authState = ref.read(authStateProvider);
      final onboardingDone = LocalStorage.isOnboardingComplete();

      if (!authState.isAuthenticated) {
        context.go(RouteNames.login);
      } else if (!onboardingDone) {
        context.go(RouteNames.onboarding);
      } else {
        // Route based on role
        final role = authState.role;
        switch (role) {
          case UserRole.tutor:
            context.go(RouteNames.tutorDashboard);
          case UserRole.superAdmin:
          case UserRole.admin:
          case UserRole.financeManager:
          case UserRole.tutorManager:
          case UserRole.supportManager:
          case UserRole.contentManager:
          case UserRole.marketingManager:
            context.go(RouteNames.adminFinance);
          case UserRole.student:
            context.go(RouteNames.home);
        }
      }
    } catch (e) {
      if (mounted) {
        context.go(RouteNames.login);
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0B1220),
                    const Color(0xFF131B2E),
                    const Color(0xFF1E293B),
                  ]
                : [
                    const Color(0xFF2563EB),
                    const Color(0xFF7C3AED),
                    const Color(0xFFEC4899),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Logo with glow effect
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withAlpha(30),
                          Colors.white.withAlpha(10),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withAlpha(40),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // App Name
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textFade,
                  child: Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textFade,
                  child: Text(
                    'Speak with confidence',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withAlpha(200),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Loading section
              FadeTransition(
                opacity: _loadingFade,
                child: Column(
                  children: [
                    // Loading indicator
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Status text
                    Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(150),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Version
                    Text(
                      'v${AppConstants.appVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
