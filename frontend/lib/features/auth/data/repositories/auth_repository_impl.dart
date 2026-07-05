// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SupabaseClient _client;

  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    SupabaseClient? client,
  })  : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl(),
        _client = client ?? Supabase.instance.client;

  @override
  Future<Result<AuthUser>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final result = await _remoteDataSource.signUp(
      email: email,
      password: password,
      name: name,
    );

    return result.fold(
      (failure) => Result.error(failure),
      (response) {
        final user = response.user;
        if (user == null) {
          return const Result.error(AuthFailure('Sign up failed: no user returned'));
        }
        return Result.success(_mapUser(user));
      },
    );
  }

  @override
  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.signIn(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) => Result.error(failure),
      (response) {
        final user = response.user;
        if (user == null) {
          return const Result.error(AuthFailure('Sign in failed: no user returned'));
        }
        return Result.success(_mapUser(user));
      },
    );
  }

  @override
  Future<Result<void>> signOut() async {
    return _remoteDataSource.signOut();
  }

  @override
  Future<Result<AuthUser?>> getCurrentUser() async {
    final result = await _remoteDataSource.getCurrentUser();
    return result.fold(
      (failure) => Result.error(failure),
      (user) {
        if (user == null) return const Result.success(null);
        return Result.success(_mapUser(user));
      },
    );
  }

  @override
  Future<Result<bool>> isOnboardingCompleted() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return const Result.success(false);

      final response = await _client
          .from('user_profiles')
          .select('onboarding_completed')
          .eq('auth_user_id', user.id)
          .maybeSingle();

      return Result.success(response?['onboarding_completed'] ?? false);
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to check onboarding: $e'));
    }
  }

  @override
  Future<Result<void>> completeOnboarding() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.error(AuthFailure('No authenticated user'));
      }

      await _client.from('user_profiles').update({
        'onboarding_completed': true,
      }).eq('auth_user_id', user.id);

      return const Result.success(null);
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to complete onboarding: $e'));
    }
  }

  AuthUser _mapUser(User user) {
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }
}
