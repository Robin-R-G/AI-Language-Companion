// lib/features/reading/data/datasources/reading_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
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
      passage: (json['passage'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      wordCount: (json['word_count'] as num?)?.toInt() ?? 0,
      cefrLevel: (json['cefr_level'] as String?) ?? 'A1',
      vocabulary: (json['vocabulary'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      comprehensionQuestions: (json['comprehension_questions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      culturalNotes: (json['cultural_notes'] as String?) ?? '',
    );
  }
}

abstract class ReadingRemoteDataSource {
  Future<Result<ReadingLesson>> generateLesson(String topic);
}

class ReadingRemoteDataSourceImpl implements ReadingRemoteDataSource {
  final SupabaseClient _client;

  ReadingRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Result<ReadingLesson>> generateLesson(String topic) async {
    try {
      final response = await _client.functions.invoke(
        'agent-orchestrate',
        body: {
          'action': 'route',
          'capability': 'reading',
          'input': topic,
        },
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final output = data['data']['output'] as Map<String, dynamic>;
          return Result.success(ReadingLesson.fromJson(output));
        }
        return Result.error(
          ServerFailure(data['message'] as String? ?? 'Lesson generation failed'),
        );
      }

      return Result.error(
        ServerFailure('Lesson generation failed with status ${response.status}'),
      );
    } catch (e) {
      return Result.error(NetworkFailure('Lesson generation failed: $e'));
    }
  }
}
