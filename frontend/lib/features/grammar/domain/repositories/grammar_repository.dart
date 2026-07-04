import '../../../../core/errors/result.dart';
import '../entities/grammar_correction.dart';

abstract class GrammarRepository {
  Future<Result<GrammarCorrection>> checkGrammar(
    String text, {
    String? language,
  });
  Future<Result<List<GrammarCorrection>>> getHistory({int limit = 50});
}
