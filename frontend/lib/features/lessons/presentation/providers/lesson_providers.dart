import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/repositories/lesson_repository_impl.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';

part 'lesson_providers.g.dart';

@riverpod
LessonRepository lessonRepository(LessonRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LessonRepositoryImpl(dioClient: dioClient);
}

@riverpod
class LessonsList extends _$LessonsList {
  @override
  AsyncValue<List<Lesson>> build() => const AsyncValue.loading();

  Future<void> loadLessons({String? category, String? difficulty}) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(lessonRepositoryProvider);
      final lessons = await repo.getLessons(
        category: category,
        difficulty: difficulty,
      );
      state = AsyncValue.data(lessons);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
class LessonDetail extends _$LessonDetail {
  @override
  AsyncValue<Lesson?> build() => const AsyncValue.data(null);

  Future<void> loadLesson(String id) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(lessonRepositoryProvider);
      final lesson = await repo.getLessonById(id);
      state = AsyncValue.data(lesson);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeLesson(String lessonId, int score) async {
    try {
      final repo = ref.read(lessonRepositoryProvider);
      await repo.completeLesson(lessonId, score);
      // Reload the lesson to reflect completion
      await loadLesson(lessonId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
