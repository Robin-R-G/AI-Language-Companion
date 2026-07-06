import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';

class LessonRepositoryImpl implements LessonRepository {
  final SupabaseClient _client;

  LessonRepositoryImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Result<List<Lesson>>> getLessons({
    String? category,
    String? difficulty,
  }) async {
    try {
      var query = _client.from('lessons').select();

      if (category != null) {
        query = query.eq('category', category);
      }
      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }

      final response = await query.order('title');

      final lessons = (response as List)
          .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(lessons);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load lessons: $e'));
    }
  }

  @override
  Future<Result<Lesson>> getLessonById(String id) async {
    try {
      final response = await _client
          .from('lessons')
          .select()
          .eq('id', id)
          .single();

      return Result.success(Lesson.fromJson(response));
    } catch (e) {
      return Result.error(DatabaseFailure('Lesson not found: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> completeLesson(
    String lessonId,
    int score,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Result.error(AuthFailure('User not authenticated'));
      }

      final response = await _client
          .from('lesson_progress')
          .upsert({
            'user_id': userId,
            'lesson_id': lessonId,
            'completed': true,
            'score': score,
            'time_spent_seconds': 0,
          })
          .select()
          .single();

      return Result.success(response);
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to complete lesson: $e'));
    }
  }
}
