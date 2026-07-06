import 'package:supabase_flutter/supabase_flutter.dart';
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
  final SupabaseClient _client;

  ListeningRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Result<ListeningExercise>> generateExercise(String topic) async {
    try {
      final response = await _client.functions.invoke(
        'agent-orchestrate',
        body: {
          'action': 'route',
          'capability': 'listening',
          'input': topic,
        },
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final output = data['data']['output'] as Map<String, dynamic>;
          return Result.success(ListeningExercise.fromJson(output));
        }
        return Result.error(
          ServerFailure(data['message'] as String? ?? 'Exercise generation failed'),
        );
      }

      return Result.error(
        ServerFailure('Exercise generation failed with status ${response.status}'),
      );
    } catch (e) {
      return Result.error(NetworkFailure('Exercise generation failed: $e'));
    }
  }
}
