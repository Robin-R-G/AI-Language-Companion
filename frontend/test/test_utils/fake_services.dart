import 'dart:async';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/features/auth/domain/entities/user.dart';
import 'package:ai_language_coach/features/auth/domain/repositories/auth_repository.dart';
import 'package:ai_language_coach/features/subscription/domain/entities/subscription.dart';
import 'package:ai_language_coach/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:ai_language_coach/core/services/connectivity_service.dart';

// ─── Fake Auth Repository ─────────────────────────────────────────────────────

class FakeAuthRepository implements AuthRepository {
  final StreamController<bool> _authController =
      StreamController<bool>.broadcast();
  AppUser? _user;
  bool _shouldFail = false;

  void setAuthenticated(AppUser user) {
    _user = user;
    _authController.add(true);
  }

  void setUnauthenticated() {
    _user = null;
    _authController.add(false);
  }

  void setShouldFail(bool value) => _shouldFail = value;

  @override
  Future<Result<AppUser>> signUp(String email, String password) async {
    if (_shouldFail) {
      return const Result.error(AuthFailure('Sign up failed'));
    }
    final user = AppUser(id: 'test_id', email: email, displayName: 'Test User');
    _user = user;
    _authController.add(true);
    return Result.success(user);
  }

  @override
  Future<Result<AppUser>> signIn(String email, String password) async {
    if (_shouldFail) {
      return const Result.error(AuthFailure('Sign in failed'));
    }
    final user = AppUser(id: 'test_id', email: email, displayName: 'Test User');
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
  AppUser? get currentUser => _user;

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
        plan: _currentPlan,
        status: 'active',
      ),
    );
  }

  @override
  Future<Result<List<SubscriptionPlan>>> getPlans() async {
    if (_shouldFail) {
      return const Result.error(PaymentFailure('Failed'));
    }
    return const Result.success([
      SubscriptionPlan(
        id: 'free',
        name: 'Free',
        description: 'Basic access with limited features',
        price: 0,
        currency: 'USD',
        period: 'monthly',
        features: ['5 voice mins/day'],
      ),
      SubscriptionPlan(
        id: 'premium',
        name: 'Premium',
        description: 'Full access to all features',
        price: 9.99,
        currency: 'USD',
        period: 'monthly',
        features: ['Unlimited voice'],
        isPopular: true,
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
        plan: planId,
        status: 'active',
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
        plan: _currentPlan,
        status: 'active',
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
}
