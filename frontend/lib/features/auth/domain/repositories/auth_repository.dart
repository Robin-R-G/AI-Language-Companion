// lib/features/auth/domain/repositories/auth_repository.dart
import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<Result<AuthUser>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<AuthUser?>> getCurrentUser();

  Future<Result<bool>> isOnboardingCompleted();

  Future<Result<void>> completeOnboarding();

  Future<Result<void>> resetPassword(String email);
}
