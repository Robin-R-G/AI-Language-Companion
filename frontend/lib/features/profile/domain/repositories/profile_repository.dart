// lib/features/profile/domain/repositories/profile_repository.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/user_profile.dart';

abstract class ProfileRepository {
  Future<Result<UserProfile>> getProfile(String userId);
  Future<Result<UserProfile>> updateProfile(String userId, Map<String, dynamic> updates);
  Future<Result<UserProgress>> getProgress(String userId);
  Future<Result<UserStreak>> getStreak(String userId);
  Future<Result<void>> deleteAccount(String userId);
}
