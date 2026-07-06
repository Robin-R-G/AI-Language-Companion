// lib/features/listening/data/datasources/listening_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';

class ListeningExercise {
  final String script;
  final String title;
  final String cefrLevel;
  final List<Map<String, dynamic>> gapFill;
  final List<Map<String, dynamic>> comprehensionQuestions;
  final String speedNotes;

  const ListeningExercise({
    required this.script,
    required this.title,
    required this.cefrLevel,
    required this.gapFill,
    required this.comprehensionQuestions,
    required this.speedNotes,
  });

  factory ListeningExercise.fromJson(Map<String, dynamic> json) {
    return ListeningExercise(
      script: (json['script'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      cefrLevel: (json['cefr_level'] as String?) ?? 'A1',
      gapFill: (json['gap_fill'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      comprehensionQuestions: (json['comprehension_questions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      speedNotes: (json['speed_notes'] as String?) ?? 'normal',
    );
  }
}

abstract class ListeningRemoteDataSource {
  Future<Result<ListeningExercise>> generateExercise(String topic);
}

class ListeningRemoteDataSourceImpl implements ListeningRemoteDataSource {
  final Dio _dio;

  ListeningRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<Result<ListeningExercise>> generateExercise(String topic) async {
    try {
      final response = await _dio.post(
        '/agent-orchestrate',
        data: {
          'action': 'route',
          'capability': 'listening',
          'input': topic,
        },
      );

      if (response.data['success'] == true) {
        final output = response.data['data']['output'] as Map<String, dynamic>;
        return Result.success(ListeningExercise.fromJson(output));
      }

      return Result.error(NetworkFailure((response.data['message'] as String?) ?? 'Exercise generation failed'));
    } on DioException catch (e) {
      return Result.error(NetworkFailure('Exercise generation failed: ${e.message}'));
    } catch (e) {
      return Result.error(NetworkFailure('Exercise generation failed: $e'));
    }
  }
}
