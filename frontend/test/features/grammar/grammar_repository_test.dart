import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_language_coach/features/grammar/data/repositories/grammar_repository_impl.dart';
import 'package:ai_language_coach/features/grammar/data/datasources/grammar_remote_datasource.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import '../../mocks/mocks.dart';

class MockGrammarRemoteDataSource extends Mock implements GrammarRemoteDataSource {}

void main() {
  late MockGrammarRemoteDataSource mockDataSource;
  late GrammarRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockGrammarRemoteDataSource();
    repository = GrammarRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('GrammarRepositoryImpl', () {
    test('checkGrammar returns correction on success', () async {
      when(() => mockDataSource.checkGrammar(any())).thenAnswer((_) async => Result.success(
        const GrammarResult(
          isCorrect: false,
          original: 'He go to school',
          corrected: 'He goes to school',
          explanation: 'Subject-verb agreement',
          explanationMalayalam: '',
          category: 'grammar',
          examples: [],
        ),
      ));

      final result = await repository.checkGrammar('He go to school');
      expect(result.isSuccess, true);
      expect(result.value.corrected, 'He goes to school');
    });

    test('checkGrammar with language', () async {
      when(() => mockDataSource.checkGrammar(any(), language: any(named: 'language'))).thenAnswer((_) async => Result.success(
        const GrammarResult(
          isCorrect: false,
          original: 'text',
          corrected: 'fixed',
          explanation: 'rule',
          explanationMalayalam: '',
          category: 'General',
          examples: [],
        ),
      ));

      await repository.checkGrammar('text', language: 'ml');
      verify(
        () => mockDataSource.checkGrammar('text', language: 'ml'),
      ).called(1);
    });

    test('checkGrammar handles error', () async {
      when(() => mockDataSource.checkGrammar(any())).thenAnswer((_) async =>
        Result.error(NetworkFailure('Grammar check failed')),
      );

      final result = await repository.checkGrammar('text');
      expect(result.isFailure, true);
    });
  });
}
