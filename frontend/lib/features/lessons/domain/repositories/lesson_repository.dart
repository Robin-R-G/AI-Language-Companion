import '../entities/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getLessons({String? category, String? difficulty});
  Future<Lesson> getLessonById(String id);
  Future<Map<String, dynamic>> completeLesson(String lessonId, int score);
}
