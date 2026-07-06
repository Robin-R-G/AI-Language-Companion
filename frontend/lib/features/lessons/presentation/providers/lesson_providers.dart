import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/models/lesson.dart';

part 'lesson_providers.g.dart';

@riverpod
class LessonsList extends _$LessonsList {
  @override
  AsyncValue<List<Lesson>> build() => const AsyncValue.loading();

  Future<void> loadLessons({String? category, String? difficulty}) async {
    state = const AsyncValue.loading();
    final repo = ref.read(lessonsRepositoryProvider);
    final result = await repo.getLessons(
      category: category,
      difficulty: difficulty,
    );
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (lessons) => state = AsyncValue.data(lessons),
    );
  }
}

@riverpod
class LessonDetail extends _$LessonDetail {
  @override
  AsyncValue<Lesson?> build() => const AsyncValue.data(null);

  Future<void> loadLesson(String id) async {
    state = const AsyncValue.loading();
    final repo = ref.read(lessonsRepositoryProvider);
    final result = await repo.getLesson(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (lesson) => state = AsyncValue.data(lesson),
    );
  }

  Future<void> completeLesson(String lessonId, int score) async {
    final userId = 'current_user';
    final repo = ref.read(lessonsRepositoryProvider);
    final result = await repo.completeLesson(
      userId: userId,
      lessonId: lessonId,
      score: score,
    );
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => loadLesson(lessonId),
    );
  }
}
