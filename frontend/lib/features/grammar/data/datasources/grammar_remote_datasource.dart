// lib/features/grammar/data/datasources/grammar_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';

class GrammarResult {
  final bool isCorrect;
  final String original;
  final String corrected;
  final String explanation;
  final String explanationMalayalam;
  final String category;
  final List<String> examples;

  const GrammarResult({
    required this.isCorrect,
    required this.original,
    required this.corrected,
    required this.explanation,
    required this.explanationMalayalam,
    required this.category,
    required this.examples,
  });

  factory GrammarResult.fromJson(Map<String, dynamic> json) {
    return GrammarResult(
      isCorrect: (json['is_correct'] as bool?) ?? true,
      original: (json['original'] as String?) ?? '',
      corrected: (json['corrected'] as String?) ?? '',
      explanation: (json['explanation'] as String?) ?? '',
      explanationMalayalam: (json['explanation_malayalam'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'General',
      examples: (json['examples'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

abstract class GrammarRemoteDataSource {
  Future<Result<GrammarResult>> checkGrammar(String text, {
    String? languageLevel,
    String? nativeLanguage,
  });
}

class GrammarRemoteDataSourceImpl implements GrammarRemoteDataSource {
  final Dio _dio;

  GrammarRemoteDataSourceImpl({Dio? dio})
      : _dio = dio ?? Dio();

  @override
  Future<Result<GrammarResult>> checkGrammar(
    String text, {
    String? languageLevel,
    String? nativeLanguage,
  }) async {
    try {
      final response = await _dio.post(
        '/grammar/check',
        data: {
          'text': text,
          if (languageLevel != null) 'language_level': languageLevel,
          if (nativeLanguage != null) 'native_language': nativeLanguage,
        },
      );

      if (response.data['success'] == true) {
        return Result.success(GrammarResult.fromJson(response.data['data'] as Map<String, dynamic>));
      }

      return Result.error(NetworkFailure((response.data['message'] as String?) ?? 'Grammar check failed'));
    } on DioException catch (e) {
      return Result.error(NetworkFailure('Grammar check failed: ${e.message}'));
    } catch (e) {
      return Result.error(NetworkFailure('Grammar check failed: $e'));
    }
  }
}
