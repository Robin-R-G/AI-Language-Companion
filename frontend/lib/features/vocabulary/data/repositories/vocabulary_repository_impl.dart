import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final Dio _dio;

  VocabularyRepositoryImpl({DioClient? dioClient})
      : _dio = dioClient?.client ?? DioClient().client;

  @override
  Future<List<VocabularyWord>> getDailyVocabulary() async {
    try {
      final response = await _dio.get('/vocabulary');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => VocabularyWord.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw DatabaseFailure(
        e.message ?? 'Failed to fetch daily vocabulary',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<void> updateMastery(String wordId, int masteryScore) async {
    try {
      await _dio.post(
        '/vocabulary',
        data: {
          'word_id': wordId,
          'mastery_score': masteryScore,
        },
      );
    } on DioException catch (e) {
      throw DatabaseFailure(
        e.message ?? 'Failed to update mastery',
        code: e.response?.statusCode?.toString(),
      );
    }
  }

  @override
  Future<List<VocabularyWord>> getHistory({int limit = 50}) async {
    try {
      final response = await _dio.get(
        '/vocabulary/history',
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => VocabularyWord.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw DatabaseFailure(
        e.message ?? 'Failed to fetch vocabulary history',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }
}
