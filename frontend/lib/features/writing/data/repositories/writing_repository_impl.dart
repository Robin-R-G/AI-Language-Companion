import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/writing_prompt.dart';
import '../../domain/repositories/writing_repository.dart';

class WritingRepositoryImpl implements WritingRepository {
  final Dio _dio;

  WritingRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<List<WritingPrompt>>> getPrompts({
    String? difficulty,
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        '/writing',
        queryParameters: {'difficulty': ?difficulty, 'category': ?category},
      );
      final data = response.data;
      if (data is List) {
        return Result.success(
          data
              .map((e) => WritingPrompt.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to fetch prompts',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<WritingSubmission>> submitWriting(
    String promptId,
    String content,
  ) async {
    try {
      final response = await _dio.post(
        '/writing/submit',
        data: {'prompt_id': promptId, 'content': content},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(WritingSubmission.fromJson(data));
      }
      return const Result.error(AIServiceFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        AIServiceFailure(
          e.message ?? 'Failed to submit writing',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }
}
