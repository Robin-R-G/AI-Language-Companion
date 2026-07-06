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
      estimatedBand: (json['estimated_band'] as String?) ?? 'N/A',
      grammarScore: (json['grammar_score'] as num?)?.toInt() ?? 0,
      vocabularyScore: (json['vocabulary_score'] as num?)?.toInt() ?? 0,
      organizationScore: (json['organization_score'] as num?)?.toInt() ?? 0,
      clarityScore: (json['clarity_score'] as num?)?.toInt() ?? 0,
      strengths: (json['strengths'] as List<dynamic>?)?.cast<String>() ?? [],
      mistakes: (json['mistakes'] as List<dynamic>?)?.cast<String>() ?? [],
      improvedVersion: (json['improved_version'] as String?) ?? '',
      recommendations: (json['recommendations'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

abstract class WritingRemoteDataSource {
  Future<Result<WritingEvaluation>> evaluateEssay(String essayText);
}

class WritingRemoteDataSourceImpl implements WritingRemoteDataSource {
  final SupabaseClient _client;

  WritingRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Result<WritingEvaluation>> evaluateEssay(String essayText) async {
    try {
      final response = await _client.functions.invoke(
        'writing-evaluate',
        body: {
          'essay_text': essayText,
        },
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return Result.success(
            WritingEvaluation.fromJson(data['data'] as Map<String, dynamic>),
          );
        }
        return Result.error(
          ServerFailure(data['message'] as String? ?? 'Evaluation failed'),
        );
      }

      return Result.error(
        ServerFailure('Evaluation failed with status ${response.status}'),
      );
    } catch (e) {
      return Result.error(NetworkFailure('Evaluation failed: $e'));
    }
  }
}
