// lib/features/grammar/data/repositories/grammar_repository_impl.dart
import '../../../../core/errors/result.dart';
import '../../data/datasources/grammar_remote_datasource.dart';
import '../../domain/repositories/grammar_repository.dart';

class GrammarRepositoryImpl implements GrammarRepository {
  final GrammarRemoteDataSource _remoteDataSource;

  GrammarRepositoryImpl({GrammarRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? GrammarRemoteDataSourceImpl();

  @override
  Future<Result<List<GrammarRule>>> fetchGrammarRules({
    String? language,
    String? category,
  }) {
    return _remoteDataSource.fetchGrammarRules(
      language: language,
      category: category,
    );
  }

  @override
  Future<Result<GrammarResult>> checkGrammar(String text, {String? language}) {
    return _remoteDataSource.checkGrammar(text, language: language);
  }

  @override
  Future<Result<List<GrammarPractice>>> getPracticeHistory(
    String userId, {
    int limit = 20,
  }) {
    return _remoteDataSource.getPracticeHistory(userId, limit: limit);
  }

  @override
  Future<Result<GrammarPractice>> trackPractice({
    required String userId,
    required String ruleId,
    required String originalText,
    required String correctedText,
    required bool isCorrect,
  }) {
    return _remoteDataSource.trackPractice(
      userId: userId,
      ruleId: ruleId,
      originalText: originalText,
      correctedText: correctedText,
      isCorrect: isCorrect,
    );
  }
}
