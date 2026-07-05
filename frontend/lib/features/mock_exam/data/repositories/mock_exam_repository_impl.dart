import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/mock_exam.dart';
import '../../domain/repositories/mock_exam_repository.dart';

class MockExamRepositoryImpl implements MockExamRepository {
  final Dio _dio;

  MockExamRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<List<MockExam>>> getExams({
    String? examType,
    String? section,
  }) async {
    try {
      final response = await _dio.get(
        '/mock-exam',
        queryParameters: {
          if (examType != null) 'exam_type': examType,
          if (section != null) 'section': section,
        },
      );
      final data = response.data;
      if (data is List) {
        return Result.success(
          data
              .map((e) => MockExam.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to fetch exams',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<MockExam>> getExamById(String id) async {
    try {
      final response = await _dio.get('/mock-exam/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(MockExam.fromJson(data));
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to fetch exam',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<MockExam>> startExam(String examId) async {
    try {
      final response = await _dio.post(
        '/mock-exam/start',
        data: {'exam_id': examId},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(MockExam.fromJson(data));
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to start exam',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<MockExamQuestion>> submitAnswer(
    String examId,
    String questionId,
    String answer,
  ) async {
    try {
      final response = await _dio.post(
        '/mock-exam/answer',
        data: {'exam_id': examId, 'question_id': questionId, 'answer': answer},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(MockExamQuestion.fromJson(data));
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to submit answer',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<MockExam>> completeExam(String examId) async {
    try {
      final response = await _dio.post(
        '/mock-exam/complete',
        data: {'exam_id': examId},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(MockExam.fromJson(data));
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to complete exam',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<List<MockExam>>> getHistory({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/mock-exam/history',
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      if (data is List) {
        return Result.success(
          data
              .map((e) => MockExam.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to fetch exam history',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }
}
