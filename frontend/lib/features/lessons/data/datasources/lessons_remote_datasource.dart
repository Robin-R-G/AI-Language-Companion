// lib/features/lessons/data/datasources/lessons_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../shared/models/lesson.dart';

abstract class LessonsRemoteDataSource {
  Future<Result<List<Lesson>>> getLessons({String? difficulty, String? category});
  Future<Result<Lesson>> getLesson(String lessonId);
  Future<Result<LessonProgress>> completeLesson({
    required String userId,
    required String lessonId,
    required int score,
  });
  Future<Result<List<Lesson>>> getRecommended(String userId);
}

class LessonsRemoteDataSourceImpl implements LessonsRemoteDataSource {
  final SupabaseClient _client;

  LessonsRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Result<List<Lesson>>> getLessons({
    String? difficulty,
    String? category,
  }) async {
    try {
      var query = _client.from('lessons').select().isFilter('deleted_at', null);

      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }
      if (category != null) {
        query = query.eq('category', category);
      }

      final response = await query.order('title');

      final lessons = (response as List)
          .map((json) => Lesson.fromJson(json))
          .toList();

      return Result.success(lessons);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load lessons: $e'));
    }
  }

  @override
  Future<Result<Lesson>> getLesson(String lessonId) async {
    try {
      final response = await _client
          .from('lessons')
          .select()
          .eq('id', lessonId)
          .single();

      return Result.success(Lesson.fromJson(response));
    } catch (e) {
      return Result.error(DatabaseFailure('Lesson not found: $e'));
    }
  }

  @override
  Future<Result<LessonProgress>> completeLesson({
    required String userId,
    required String lessonId,
    required int score,
  }) async {
    try {
      final xp = _calculateXp(score);

      final response = await _client
          .from('lesson_progress')
          .upsert({
            'user_id': userId,
            'lesson_id': lessonId,
            'completed_at': DateTime.now().toIso8601String(),
            'completion_percentage': 100.0,
            'earned_xp': xp,
          })
          .select()
          .single();

      // Update user XP
      await _client.rpc('increment_xp', params: {
        'target_user_id': userId,
        'xp_amount': xp,
      });

      return Result.success(LessonProgress.fromJson(response));
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to complete lesson: $e'));
    }
  }

  @override
  Future<Result<List<Lesson>>> getRecommended(String userId) async {
    try {
      final profile = await _client
          .from('user_profiles')
          .select('proficiency_level')
          .eq('auth_user_id', userId)
          .single();

      final level = profile['proficiency_level'] ?? 'A1';

      final response = await _client
          .from('lessons')
          .select()
          .eq('difficulty', level)
          .isFilter('deleted_at', null)
          .limit(5);

      final lessons = (response as List)
          .map((json) => Lesson.fromJson(json))
          .toList();

      return Result.success(lessons);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load recommendations: $e'));
    }
  }

  int _calculateXp(int score) {
    if (score >= 90) return 50;
    if (score >= 70) return 30;
    if (score >= 50) return 15;
    return 5;
  }
}
