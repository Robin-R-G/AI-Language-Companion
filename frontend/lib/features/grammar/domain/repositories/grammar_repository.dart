// lib/features/grammar/domain/repositories/grammar_repository.dart
import '../../../../core/errors/result.dart';
import '../../data/datasources/grammar_remote_datasource.dart';

abstract class GrammarRepository {
  Future<Result<GrammarResult>> checkGrammar(String text, {
    String? languageLevel,
    String? nativeLanguage,
  });
}
