import '../../../../core/errors/result.dart';

abstract class ProfileRepository {
  Future<Result<void>> updateProfile(Map<String, dynamic> updates);
  Future<Result<String>> uploadAvatar(String filePath);
  Future<Result<void>> deleteAccount();
}
