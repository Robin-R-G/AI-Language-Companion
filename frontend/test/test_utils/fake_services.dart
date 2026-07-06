import 'dart:async';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/features/auth/domain/entities/auth_user.dart';
import 'package:ai_language_coach/features/auth/domain/repositories/auth_repository.dart';
import 'package:ai_language_coach/features/subscription/domain/entities/subscription.dart';
import 'package:ai_language_coach/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:ai_language_coach/core/services/connectivity_service.dart';

// ─── Fake Auth Repository ────────────────

class FakeAuthRepository implements AuthRepository {
  final StreamController<bool> _authController =
      StreamController<bool>.broadcast();
  AuthUser? _user;
  bool _shouldFail = false;

  AuthUser? get currentUser => _user;

  void setAuthenticated(AuthUser user) {
    _user = user;
    _authController.add(true);
  }

  void setUnauthenticated() {
    _user = null;
    _authController.add(false);
  }

  void setShouldFail(bool value) => _shouldFail = value;

  @override
  Future<Result<AuthUser>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (_shouldFail) {
      return const Result.error(AuthFailure('Sign up failed'));
    }
    final user = AuthUser(
      id: 'test_id',
      email: email,
      fullName: name,
      avatarUrl: '',
      isOnboardingCompleted: true,
    );
    _user = user;
    _authController.add(true);
    return Result.success(user);
  }

  @override
  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    if (_shouldFail) {
      return const Result.error(AuthFailure('Sign in failed'));
    }
    final user = AuthUser(
      id: 'test_id',
      email: email,
      fullName: 'Test User',
      avatarUrl: '',
      isOnboardingCompleted: true,
    );
    _user = user;
    _authController.add(true);
    return Result.success(user);
  }

  @override
  Future<Result<void>> signOut() async {
    if (_shouldFail) {
      return const Result.error(AuthFailure('Sign out failed'));
    }
    _user = null;
    _authController.add(false);
    return const Result.success(null);
  }

  @override
  Future<Result<AuthUser?>> getCurrentUser() async {
    if (_shouldFail) {
      return const Result.error(AuthFailure('Get current user failed'));
    }
    return Result.success(_user);
  }

  @override
  Future<Result<bool>> isOnboardingCompleted() async {
    if (_shouldFail) {
      return const Result.error(AuthFailure('Failed to check onboarding'));
    }
    return Result.success(_user?.isOnboardingCompleted ?? false);
  }

  @override
  Future<Result<void>> completeOnboarding() async {
    if (_shouldFail) {
      return const Result.error(AuthFailure('Failed to complete onboarding'));
    }
    if (_user != null) {
      _user = _user!.copyWith(isOnboardingCompleted: true);
    }
    return const Result.success(null);
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    if (_shouldFail) {
      return const Result.error(AuthFailure('Failed to reset password'));
    }
    return const Result.success(null);
  }

  @override
  Stream<bool> get authStateChanges => _authController.stream;

  void dispose() => _authController.close();
}

// ─── Fake Connectivity Service ────────────────────────────────────────────────

class FakeConnectivityService implements ConnectivityService {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _isConnected = true;
  
  @override
  bool get isConnected => _isConnected;

  @override
  Stream<bool> get connectionStream => _controller.stream;

  void setConnected(bool connected) {
    _isConnected = connected;
    _controller.add(connected);
  }

  @override
  void startMonitoring() {}

  @override
  void stopMonitoring() {}

  @override
  Future<bool> checkConnectivity() async => _isConnected;

  @override
  void dispose() => _controller.close();
}

// ─── Fake Subscription Repository ─────────────────────────────────────────────

class FakeSubscriptionRepository implements SubscriptionRepository {
  bool _shouldFail = false;
  String _currentPlan = 'free';

  void setShouldFail(bool value) => _shouldFail = value;
  void setCurrentPlan(String plan) => _currentPlan = plan;

  @override
  Future<Result<Subscription>> getCurrentSubscription() async {
    if (_shouldFail) {
      return const Result.error(PaymentFailure('Failed'));
    }
    return Result.success(
      Subscription(
        id: 'sub_1',
        userId: 'user_1',
        provider: 'stripe',
        planId: _currentPlan,
        planName: _currentPlan == 'premium' ? 'Premium' : 'Free',
        status: 'active',
        billingCycle: 'monthly',
        amount: _currentPlan == 'premium' ? 9.99 : 0.0,
        currency: 'USD',
        currentPeriodStart: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<List<SubscriptionPlan>>> getPlans() async {
    if (_shouldFail) {
      return const Result.error(PaymentFailure('Failed'));
    }
    return Result.success([
      SubscriptionPlan(
        id: 'free',
        name: 'Free',
        description: 'Basic access with limited features',
        monthlyPrice: 0.0,
        annualPrice: 0.0,
        currency: 'USD',
        features: const ['5 voice mins/day'],
        dailyVoiceMinutes: 5,
        dailyLessons: 1,
        monthlyMockExams: 0,
        hasPrioritySupport: false,
        hasAdvancedAnalytics: false,
        hasOfflineMode: false,
        isPopular: false,
        sortOrder: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SubscriptionPlan(
        id: 'premium',
        name: 'Premium',
        description: 'Full access to all features',
        monthlyPrice: 9.99,
        annualPrice: 99.99,
        currency: 'USD',
        features: const ['Unlimited voice'],
        dailyVoiceMinutes: 9999,
        dailyLessons: 9999,
        monthlyMockExams: 99,
        hasPrioritySupport: true,
        hasAdvancedAnalytics: true,
        hasOfflineMode: true,
        isPopular: true,
        sortOrder: 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  @override
  Future<Result<Subscription>> purchase(
    String planId,
    String storeProductId,
  ) async {
    if (_shouldFail) {
      return const Result.error(PaymentFailure('Purchase failed'));
    }
    _currentPlan = planId;
    return Result.success(
      Subscription(
        id: 'sub_2',
        userId: 'user_1',
        provider: 'stripe',
        planId: planId,
        planName: planId == 'premium' ? 'Premium' : 'Free',
        status: 'active',
        billingCycle: 'monthly',
        amount: planId == 'premium' ? 9.99 : 0.0,
        currency: 'USD',
        currentPeriodStart: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<Subscription>> restorePurchases() async {
    if (_shouldFail) {
      return const Result.error(PaymentFailure('Restore failed'));
    }
    return Result.success(
      Subscription(
        id: 'sub_1',
        userId: 'user_1',
        provider: 'stripe',
        planId: _currentPlan,
        planName: _currentPlan == 'premium' ? 'Premium' : 'Free',
        status: 'active',
        billingCycle: 'monthly',
        amount: _currentPlan == 'premium' ? 9.99 : 0.0,
        currency: 'USD',
        currentPeriodStart: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<void>> cancelSubscription() async {
    if (_shouldFail) return const Result.error(PaymentFailure('Cancel failed'));
    _currentPlan = 'free';
    return const Result.success(null);
  }

  @override
  Future<Result<bool>> checkFeatureAccess(String feature) async {
    if (_shouldFail) return const Result.error(PaymentFailure('Check failed'));
    return Result.success(_currentPlan == 'premium');
  }

  void dispose() {}
}
