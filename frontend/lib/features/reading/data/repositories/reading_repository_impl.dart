import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/reading_passage.dart';
import '../../domain/repositories/reading_repository.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  final Dio _dio;

  ReadingRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<List<ReadingPassage>>> getPassages({
    String? difficulty,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/reading',
        queryParameters: {
          'limit': limit,
          if (difficulty != null) 'difficulty': difficulty,
        },
      );
      final data = response.data;
      if (data is List) {
        return Result.success(
          data
              .map((e) => ReadingPassage.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to fetch passages',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<ReadingPassage>> getPassage(String id) async {
    try {
      final response = await _dio.get('/reading/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(ReadingPassage.fromJson(data));
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to fetch passage',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }
}
