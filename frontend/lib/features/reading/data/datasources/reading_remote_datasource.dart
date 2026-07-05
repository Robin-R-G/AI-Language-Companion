// lib/features/reading/data/datasources/reading_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';

class ReadingLesson {
  final String passage;
  final String title;
  final int wordCount;
  final String cefrLevel;
  final List<Map<String, dynamic>> vocabulary;
  final List<Map<String, dynamic>> comprehensionQuestions;
  final String culturalNotes;

  const ReadingLesson({
    required this.passage,
    required this.title,
    required this.wordCount,
    required this.cefrLevel,
    required this.vocabulary,
    required this.comprehensionQuestions,
    required this.culturalNotes,
  });

  factory ReadingLesson.fromJson(Map<String, dynamic> json) {
    return ReadingLesson(
      passage: json['passage'] ?? '',
      title: json['title'] ?? '',
      wordCount: json['word_count'] ?? 0,
      cefrLevel: json['cefr_level'] ?? 'A1',
      vocabulary: List<Map<String, dynamic>>.from(json['vocabulary'] ?? []),
      comprehensionQuestions: List<Map<String, dynamic>>.from(json['comprehension_questions'] ?? []),
      culturalNotes: json['cultural_notes'] ?? '',
    );
  }
}

abstract class ReadingRemoteDataSource {
  Future<Result<ReadingLesson>> generateLesson(String topic);
}

class ReadingRemoteDataSourceImpl implements ReadingRemoteDataSource {
  final Dio _dio;

  ReadingRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<Result<ReadingLesson>> generateLesson(String topic) async {
    try {
      final response = await _dio.post(
        '/agent-orchestrate',
        data: {
          'action': 'route',
          'capability': 'reading',
          'input': topic,
        },
      );

      if (response.data['success'] == true) {
        final output = response.data['data']['output'];
        return Result.success(ReadingLesson.fromJson(output));
      }

      return Result.error(NetworkFailure(response.data['message'] ?? 'Lesson generation failed'));
    } on DioException catch (e) {
      return Result.error(NetworkFailure('Lesson generation failed: ${e.message}'));
    } catch (e) {
      return Result.error(NetworkFailure('Lesson generation failed: $e'));
    }
  }
}
