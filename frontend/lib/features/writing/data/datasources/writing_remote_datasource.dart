// lib/features/writing/data/datasources/writing_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';

class WritingEvaluation {
  final String estimatedBand;
  final int grammarScore;
  final int vocabularyScore;
  final int organizationScore;
  final int clarityScore;
  final List<String> strengths;
  final List<String> mistakes;
  final String improvedVersion;
  final List<String> recommendations;

  const WritingEvaluation({
    required this.estimatedBand,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.organizationScore,
    required this.clarityScore,
    required this.strengths,
    required this.mistakes,
    required this.improvedVersion,
    required this.recommendations,
  });

  factory WritingEvaluation.fromJson(Map<String, dynamic> json) {
    return WritingEvaluation(
      estimatedBand: json['estimated_band'] ?? 'N/A',
      grammarScore: json['grammar_score'] ?? 0,
      vocabularyScore: json['vocabulary_score'] ?? 0,
      organizationScore: json['organization_score'] ?? 0,
      clarityScore: json['clarity_score'] ?? 0,
      strengths: List<String>.from(json['strengths'] ?? []),
      mistakes: List<String>.from(json['mistakes'] ?? []),
      improvedVersion: json['improved_version'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

abstract class WritingRemoteDataSource {
  Future<Result<WritingEvaluation>> evaluateEssay(String essayText);
}

class WritingRemoteDataSourceImpl implements WritingRemoteDataSource {
  final Dio _dio;

  WritingRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<Result<WritingEvaluation>> evaluateEssay(String essayText) async {
    try {
      final response = await _dio.post(
        '/writing/evaluate',
        data: {'essay_text': essayText},
      );

      if (response.data['success'] == true) {
        return Result.success(WritingEvaluation.fromJson(response.data['data']));
      }

      return Result.error(NetworkFailure(response.data['message'] ?? 'Evaluation failed'));
    } on DioException catch (e) {
      return Result.error(NetworkFailure('Evaluation failed: ${e.message}'));
    } catch (e) {
      return Result.error(NetworkFailure('Evaluation failed: $e'));
    }
  }
}
