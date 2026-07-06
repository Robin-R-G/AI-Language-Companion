// lib/features/vocabulary/presentation/controllers/vocabulary_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/models/vocabulary_word.dart';

part 'vocabulary_controller.g.dart';

@riverpod
class VocabularyController extends _$VocabularyController {
  @override
  AsyncValue<List<VocabularyHistory>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadDailyVocabulary() async {
    state = const AsyncValue.loading();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.error('Not authenticated', StackTrace.empty);
      return;
    }

    final repository = ref.read(vocabularyRepositoryProvider);
    final result = await repository.getDailyVocabulary(userId);

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (words) => state = AsyncValue.data(words),
    );
  }

  Future<void> saveReview({
    required String wordId,
    required int masteryScore,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repository = ref.read(vocabularyRepositoryProvider);
    await repository.saveReview(
      userId: userId,
      wordId: wordId,
      masteryScore: masteryScore,
    );

    // Reload vocabulary after review
    await loadDailyVocabulary();
  }
}
