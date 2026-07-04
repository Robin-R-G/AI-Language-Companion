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
  List<VocabularyWord> build() => [];

  Future<void> loadVocabulary() async {
    final repo = ref.read(vocabularyRepositoryProvider);
    final result = await repo.getDailyVocabulary();
    result.fold((_) {}, (words) => state = words);
  }

  Future<void> updateMastery(String wordId, int masteryScore) async {
    final repo = ref.read(vocabularyRepositoryProvider);
    await repo.updateMastery(wordId, masteryScore);

    state = [
      for (final w in state)
        if (w.id == wordId)
          w.copyWith(
            masteryLevel: masteryScore,
            reviewCount: w.reviewCount + 1,
            lastReviewed: DateTime.now(),
          )
        else
          w,
    ];
  }
}

@riverpod
class VocabularyHistory extends _$VocabularyHistory {
  @override
  List<VocabularyWord> build() => [];

  Future<void> loadHistory() async {
    final repo = ref.read(vocabularyRepositoryProvider);
    final result = await repo.getHistory();
    result.fold((_) {}, (words) => state = words);
  }
}
