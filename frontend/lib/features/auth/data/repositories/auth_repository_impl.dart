import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<Result<AppUser>> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        return const Result.error(AuthFailure('Sign up returned no user'));
      }
      return Result.success(_mapSupabaseUser(response.user!));
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<AppUser>> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        return const Result.error(AuthFailure('Sign in returned no user'));
      }
      return Result.success(_mapSupabaseUser(response.user!));
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }

  @override
  AppUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return _mapSupabaseUser(user);
  }

  @override
  Stream<bool> get authStateChanges => _supabase.auth.onAuthStateChange.map(
    (_) => _supabase.auth.currentUser != null,
  );

  AppUser _mapSupabaseUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String? ?? '',
      avatarUrl: user.userMetadata?['avatar_url'] as String? ?? '',
      nativeLanguage: user.userMetadata?['native_language'] as String? ?? '',
      targetLanguage: user.userMetadata?['target_language'] as String? ?? 'en',
      proficiencyLevel:
          user.userMetadata?['proficiency_level'] as String? ?? 'A1',
      targetExam: user.userMetadata?['target_exam'] as String? ?? 'general',
      isPremium: user.userMetadata?['is_premium'] as bool? ?? false,
      subscriptionPlan:
          user.userMetadata?['subscription_plan'] as String? ?? 'free',
      isOnboardingComplete:
          user.userMetadata?['onboarding_complete'] as bool? ?? false,
      createdAt: user.createdAt is String
          ? DateTime.parse(user.createdAt as String)
          : null,
    );
  }
}
