// lib/features/lessons/data/repositories/lessons_repository_impl.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/lesson.dart';
import '../../domain/repositories/lessons_repository.dart';
import '../datasources/lessons_remote_datasource.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  final LessonsRemoteDataSource _remoteDataSource;

  LessonsRepositoryImpl({LessonsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? LessonsRemoteDataSourceImpl();

  @override
  Future<Result<List<Lesson>>> getLessons({String? difficulty, String? category}) {
    return _remoteDataSource.getLessons(difficulty: difficulty, category: category);
  }

  @override
  Future<Result<Lesson>> getLesson(String lessonId) {
    return _remoteDataSource.getLesson(lessonId);
  }

  @override
  Future<Result<LessonProgress>> completeLesson({
    required String userId,
    required String lessonId,
    required int score,
  }) {
    return _remoteDataSource.completeLesson(
      userId: userId,
      lessonId: lessonId,
      score: score,
    );
  }

  @override
  Future<Result<List<Lesson>>> getRecommended(String userId) {
    return _remoteDataSource.getRecommended(userId);
  }
}
