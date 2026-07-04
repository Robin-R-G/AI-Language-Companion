import '../../../../core/errors/result.dart';
import '../entities/lesson.dart';

abstract class LessonRepository {
  Future<Result<List<Lesson>>> getLessons({
    String? category,
    String? difficulty,
  });
  Future<Result<Lesson>> getLessonById(String id);
  Future<Result<Map<String, dynamic>>> completeLesson(
    String lessonId,
    int score,
  );
}
