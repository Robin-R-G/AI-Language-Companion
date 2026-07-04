import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final Dio _dio;

  AchievementRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<List<Achievement>>> getAchievements() async {
    try {
      final response = await _dio.get('/achievements');
      final data = response.data;
      if (data is List) {
        return Result.success(
          data
              .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to fetch achievements',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<List<AchievementProgress>>> getProgress() async {
    try {
      final response = await _dio.get('/achievements/progress');
      final data = response.data;
      if (data is List) {
        return Result.success(
          data
              .map(
                (e) => AchievementProgress.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        );
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to fetch achievement progress',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<Achievement>> checkAndAward(String achievementId) async {
    try {
      final response = await _dio.post(
        '/achievements/check',
        data: {'achievement_id': achievementId},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(Achievement.fromJson(data));
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to check achievement',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }
}
