// lib/features/lessons/domain/repositories/lessons_repository.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/lesson.dart';

abstract class LessonsRepository {
  Future<Result<List<Lesson>>> getLessons({String? difficulty, String? category});
  Future<Result<Lesson>> getLesson(String lessonId);
  Future<Result<LessonProgress>> completeLesson({
    required String userId,
    required String lessonId,
    required int score,
  });
  Future<Result<List<Lesson>>> getRecommended(String userId);
}
