// lib/features/lessons/presentation/controllers/lessons_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/lessons_remote_datasource.dart';
import '../../data/repositories/lessons_repository_impl.dart';
import '../../../../shared/models/lesson.dart';

part 'lessons_controller.g.dart';

@riverpod
LessonsRepository lessonsRepository(LessonsRepositoryRef ref) {
  return LessonsRepositoryImpl();
}

@riverpod
class LessonsController extends _$LessonsController {
  @override
  AsyncValue<List<Lesson>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadLessons({String? difficulty, String? category}) async {
    state = const AsyncValue.loading();
    final repository = ref.read(lessonsRepositoryProvider);
    final result = await repository.getLessons(
      difficulty: difficulty,
      category: category,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (lessons) => state = AsyncValue.data(lessons),
    );
  }

  Future<void> loadRecommended() async {
    state = const AsyncValue.loading();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.error('Not authenticated', StackTrace.empty);
      return;
    }

    final repository = ref.read(lessonsRepositoryProvider);
    final result = await repository.getRecommended(userId);

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (lessons) => state = AsyncValue.data(lessons),
    );
  }

  Future<void> completeLesson({
    required String lessonId,
    required int score,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repository = ref.read(lessonsRepositoryProvider);
    await repository.completeLesson(
      userId: userId,
      lessonId: lessonId,
      score: score,
    );
  }
}
