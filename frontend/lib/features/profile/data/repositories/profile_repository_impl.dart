import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final Dio _dio;

  ProfileRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<void>> updateProfile(Map<String, dynamic> updates) async {
    try {
      await _dio.put('/profile', data: updates);
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to update profile',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<String>> uploadAvatar(String filePath) async {
    try {
      final response = await _dio.post(
        '/profile/avatar',
        data: {'file_path': filePath},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['url'] is String) {
        return Result.success(data['url'] as String);
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to upload avatar',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _dio.delete('/profile');
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to delete account',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }
}
