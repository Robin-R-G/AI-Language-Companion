import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';

class LessonRepositoryImpl implements LessonRepository {
  final Dio _dio;

  LessonRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<List<Lesson>>> getLessons({
    String? category,
    String? difficulty,
  }) async {
    try {
      final response = await _dio.get(
        '/lesson-engine',
        queryParameters: {
          if (category != null) 'category': category,
          if (difficulty != null) 'difficulty': difficulty,
        },
      );
      final data = response.data;
      if (data is List) {
        return Result.success(
          data.map((e) => Lesson.fromJson(e as Map<String, dynamic>)).toList(),
        );
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to fetch lessons',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<Lesson>> getLessonById(String id) async {
    try {
      final response = await _dio.get('/lesson-engine/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(Lesson.fromJson(data));
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to fetch lesson',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> completeLesson(
    String lessonId,
    int score,
  ) async {
    try {
      final response = await _dio.post(
        '/lesson-engine/complete',
        data: {'lesson_id': lessonId, 'score': score},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(data);
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to complete lesson',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }
}
