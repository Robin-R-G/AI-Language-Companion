import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';

class LessonRepositoryImpl implements LessonRepository {
  final Dio _dio;

  LessonRepositoryImpl({DioClient? dioClient})
      : _dio = dioClient?.client ?? DioClient().client;

  @override
  Future<List<Lesson>> getLessons({String? category, String? difficulty}) async {
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
        return data
            .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw ServerFailure(
        e.message ?? 'Failed to fetch lessons',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<Lesson> getLessonById(String id) async {
    try {
      final response = await _dio.get('/lesson-engine/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Lesson.fromJson(data);
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw ServerFailure(
        e.message ?? 'Failed to fetch lesson',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> completeLesson(String lessonId, int score) async {
    try {
      final response = await _dio.post(
        '/lesson-engine/complete',
        data: {
          'lesson_id': lessonId,
          'score': score,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw ServerFailure(
        e.message ?? 'Failed to complete lesson',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
