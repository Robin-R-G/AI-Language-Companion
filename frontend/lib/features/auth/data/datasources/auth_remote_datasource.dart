// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';

abstract class AuthRemoteDataSource {
  Future<Result<AuthResponse>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Result<AuthResponse>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<AuthResponse>> refreshSession(String refreshToken);

  Future<Result<User?>> getCurrentUser();

  Future<Result<Session?>> getCurrentSession();

  Future<Result<void>> resetPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Result<AuthResponse>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      return Result.success(response);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Sign up failed: $e'));
    }
  }

  @override
  Future<Result<AuthResponse>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return Result.success(response);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Sign in failed: $e'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Sign out failed: $e'));
    }
  }

  @override
  Future<Result<AuthResponse>> refreshSession(String refreshToken) async {
    try {
      final response = await _client.auth.recoverSession(refreshToken);
      return Result.success(response);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Session refresh failed: $e'));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      return Result.success(user);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to get current user: $e'));
    }
  }

  @override
  Future<Result<Session?>> getCurrentSession() async {
    try {
      final session = _client.auth.currentSession;
      return Result.success(session);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to get session: $e'));
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Password reset failed: $e'));
    }
  }
}
