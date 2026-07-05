import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/progress_stats.dart';
import '../../domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final Dio _dio;

  ProgressRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<ProgressStats>> getStats({String? period}) async {
    try {
      final response = await _dio.get(
        '/progress',
        queryParameters: {'period': ?period},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(ProgressStats.fromJson(data));
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to fetch progress',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }
}
