import '../entities/vocabulary_word.dart';

abstract class VocabularyRepository {
  Future<List<VocabularyWord>> getDailyVocabulary();
  Future<void> updateMastery(String wordId, int masteryScore);
  Future<List<VocabularyWord>> getHistory({int limit = 50});
}
