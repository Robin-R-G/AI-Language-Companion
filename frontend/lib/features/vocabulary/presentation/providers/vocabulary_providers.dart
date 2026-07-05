import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/vocabulary_repository_impl.dart';
import '../../domain/entities/vocabulary_word.dart' as domain;
import '../../domain/repositories/vocabulary_repository.dart';

part 'vocabulary_providers.g.dart';

@riverpod
VocabularyRepository vocabularyRepository(VocabularyRepositoryRef ref) {
  return VocabularyRepositoryImpl();
}

@riverpod
class DailyVocabulary extends _$DailyVocabulary {
  @override
  List<domain.VocabularyWord> build() => [];

  Future<void> loadVocabulary() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(vocabularyRepositoryProvider);
    final result = await repo.getDailyVocabulary(userId);
    result.fold(
      (_) {},
      (histories) {
        state = histories
            .where((h) => h.word != null)
            .map((h) => domain.VocabularyWord(
                  id: h.word!.id,
                  word: h.word!.word,
                  meaning: h.word!.meaning,
                  pronunciation: h.word!.pronunciation,
                  examples: h.word!.examples,
                  cefrLevel: h.word!.cefrLevel,
                  partOfSpeech: '',
                  targetLanguage: '',
                  nativeLanguage: '',
                  audioUrl: null,
                  imageUrl: null,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ))
            .toList();
      },
    );
  }

  Future<void> updateMastery(String wordId, int masteryScore) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(vocabularyRepositoryProvider);
    await repo.saveReview(
      userId: userId,
      wordId: wordId,
      masteryScore: masteryScore,
    );

    await loadVocabulary();
  }
}
