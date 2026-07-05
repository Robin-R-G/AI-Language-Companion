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
      script: json['script'] ?? '',
      title: json['title'] ?? '',
      cefrLevel: json['cefr_level'] ?? 'A1',
      gapFill: List<Map<String, dynamic>>.from(json['gap_fill'] ?? []),
      comprehensionQuestions: List<Map<String, dynamic>>.from(json['comprehension_questions'] ?? []),
      speedNotes: json['speed_notes'] ?? 'normal',
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
        final output = response.data['data']['output'];
        return Result.success(ListeningExercise.fromJson(output));
      }

      return Result.error(NetworkFailure(response.data['message'] ?? 'Exercise generation failed'));
    } on DioException catch (e) {
      return Result.error(NetworkFailure('Exercise generation failed: ${e.message}'));
    } catch (e) {
      return Result.error(NetworkFailure('Exercise generation failed: $e'));
    }
  }
}
