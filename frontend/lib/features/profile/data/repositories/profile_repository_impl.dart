// lib/features/profile/data/repositories/profile_repository_impl.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({ProfileRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ProfileRemoteDataSourceImpl();

  @override
  Future<Result<UserProfile>> getProfile(String userId) {
    return _remoteDataSource.getProfile(userId);
  }

  @override
  Future<Result<UserProfile>> updateProfile(String userId, Map<String, dynamic> updates) {
    return _remoteDataSource.updateProfile(userId, updates);
  }

  @override
  Future<Result<UserProgress>> getProgress(String userId) {
    return _remoteDataSource.getProgress(userId);
  }

  @override
  Future<Result<UserStreak>> getStreak(String userId) {
    return _remoteDataSource.getStreak(userId);
  }

  @override
  Future<Result<void>> deleteAccount(String userId) {
    return _remoteDataSource.deleteAccount(userId);
  }
}
