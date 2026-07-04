import '../../../../core/errors/result.dart';
import '../entities/vocabulary_word.dart';

abstract class VocabularyRepository {
  Future<Result<List<VocabularyWord>>> getDailyVocabulary();
  Future<Result<void>> updateMastery(String wordId, int masteryScore);
  Future<Result<List<VocabularyWord>>> getHistory({int limit = 50});
}
