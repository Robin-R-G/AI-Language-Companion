import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/repositories/vocabulary_repository_impl.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';

part 'vocabulary_providers.g.dart';

@riverpod
VocabularyRepository vocabularyRepository(VocabularyRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return VocabularyRepositoryImpl(dioClient: dioClient);
}

@riverpod
class DailyVocabulary extends _$DailyVocabulary {
  @override
  AsyncValue<List<VocabularyWord>> build() => const AsyncValue.data([]);

  Future<void> loadVocabulary() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(vocabularyRepositoryProvider);
      final words = await repo.getDailyVocabulary();
      state = AsyncValue.data(words);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateMastery(String wordId, int masteryScore) async {
    final repo = ref.read(vocabularyRepositoryProvider);
    await repo.updateMastery(wordId, masteryScore);

    final currentWords = state.valueOrNull ?? [];
    state = AsyncValue.data(
      currentWords.map((w) {
        if (w.id == wordId) {
          return w.copyWith(
            masteryLevel: masteryScore,
            reviewCount: w.reviewCount + 1,
            lastReviewed: DateTime.now(),
          );
        }
        return w;
      }).toList(),
    );
  }
}

@riverpod
class VocabularyHistory extends _$VocabularyHistory {
  @override
  AsyncValue<List<VocabularyWord>> build() => const AsyncValue.data([]);

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(vocabularyRepositoryProvider);
      final words = await repo.getHistory();
      state = AsyncValue.data(words);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
