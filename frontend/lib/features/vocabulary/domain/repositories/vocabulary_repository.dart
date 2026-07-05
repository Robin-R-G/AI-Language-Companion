// lib/features/vocabulary/domain/repositories/vocabulary_repository.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/vocabulary_word.dart';

abstract class VocabularyRepository {
  Future<Result<List<VocabularyHistory>>> getDailyVocabulary(String userId);
  Future<Result<VocabularyHistory>> saveReview({
    required String userId,
    required String wordId,
    required int masteryScore,
  });
  Future<Result<List<VocabularyHistory>>> getHistory(String userId);
}
