// lib/features/grammar/data/repositories/grammar_repository_impl.dart
import '../../../../core/errors/result.dart';
import '../../data/datasources/grammar_remote_datasource.dart';
import '../../domain/repositories/grammar_repository.dart';

class GrammarRepositoryImpl implements GrammarRepository {
  final GrammarRemoteDataSource _remoteDataSource;

  GrammarRepositoryImpl({GrammarRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? GrammarRemoteDataSourceImpl();

  @override
  Future<Result<GrammarResult>> checkGrammar(
    String text, {
    String? languageLevel,
    String? nativeLanguage,
  }) {
    return _remoteDataSource.checkGrammar(
      text,
      languageLevel: languageLevel,
      nativeLanguage: nativeLanguage,
    );
  }
}
