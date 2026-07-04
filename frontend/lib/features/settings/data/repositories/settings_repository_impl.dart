import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final Dio _dio;

  SettingsRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<AppSettings>> getSettings() async {
    try {
      final response = await _dio.get('/settings');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(AppSettings.fromJson(data));
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(DatabaseFailure(e.message ?? 'Failed to fetch settings', code: e.response?.statusCode?.toString()));
    }
  }

  @override
  Future<Result<AppSettings>> updateSettings(AppSettings settings) async {
    try {
      final response = await _dio.put('/settings', data: settings.toJson());
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(AppSettings.fromJson(data));
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(DatabaseFailure(e.message ?? 'Failed to update settings', code: e.response?.statusCode?.toString()));
    }
  }
}
