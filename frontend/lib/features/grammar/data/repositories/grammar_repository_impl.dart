import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/grammar_correction.dart';
import '../../domain/repositories/grammar_repository.dart';

class GrammarRepositoryImpl implements GrammarRepository {
  final Dio _dio;

  GrammarRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<GrammarCorrection>> checkGrammar(
    String text, {
    String? language,
  }) async {
    try {
      final response = await _dio.post(
        '/grammar-check',
        data: {'text': text, if (language != null) 'language': language},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(GrammarCorrection.fromJson(data));
      }
      return const Result.error(AIServiceFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        AIServiceFailure(
          e.message ?? 'Failed to check grammar',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<List<GrammarCorrection>>> getHistory({int limit = 50}) async {
    try {
      final response = await _dio.get(
        '/grammar-check/history',
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      if (data is List) {
        return Result.success(
          data
              .map((e) => GrammarCorrection.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to fetch grammar history',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }
}
