// lib/features/vocabulary/data/repositories/vocabulary_repository_impl.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/vocabulary_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../datasources/vocabulary_remote_datasource.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final VocabularyRemoteDataSource _remoteDataSource;

  VocabularyRepositoryImpl({VocabularyRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? VocabularyRemoteDataSourceImpl();

  @override
  Future<Result<List<VocabularyHistory>>> getDailyVocabulary(String userId) {
    return _remoteDataSource.getDailyVocabulary(userId);
  }

  @override
  Future<Result<VocabularyHistory>> saveReview({
    required String userId,
    required String wordId,
    required int masteryScore,
  }) {
    return _remoteDataSource.saveReview(
      userId: userId,
      wordId: wordId,
      masteryScore: masteryScore,
    );
  }

  @override
  Future<Result<List<VocabularyHistory>>> getHistory(String userId) {
    return _remoteDataSource.getHistory(userId);
  }
}
