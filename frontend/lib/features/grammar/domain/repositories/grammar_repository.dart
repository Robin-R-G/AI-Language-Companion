// lib/features/grammar/domain/repositories/grammar_repository.dart
import '../../../../core/errors/result.dart';
import '../../data/datasources/grammar_remote_datasource.dart';

abstract class GrammarRepository {
  Future<Result<List<GrammarRule>>> fetchGrammarRules({
    String? language,
    String? category,
  });
  Future<Result<GrammarResult>> checkGrammar(String text, {String? language});
  Future<Result<List<GrammarPractice>>> getPracticeHistory(String userId, {int limit = 20});
  Future<Result<GrammarPractice>> trackPractice({
    required String userId,
    required String ruleId,
    required String originalText,
    required String correctedText,
    required bool isCorrect,
  });
}
