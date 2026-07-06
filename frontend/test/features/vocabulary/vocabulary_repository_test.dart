import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_language_coach/features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import 'package:ai_language_coach/features/vocabulary/data/datasources/vocabulary_remote_datasource.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/shared/models/vocabulary_word.dart';
import '../../mocks/mocks.dart';

class MockVocabularyRemoteDataSource extends Mock implements VocabularyRemoteDataSource {}

void main() {
  late MockVocabularyRemoteDataSource mockDataSource;
  late VocabularyRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockVocabularyRemoteDataSource();
    repository = VocabularyRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('VocabularyRepositoryImpl', () {
    test('getDailyVocabulary returns list on success', () async {
      when(() => mockDataSource.getDailyVocabulary(any()))
          .thenAnswer((_) async => const Result.success([]));

      final result = await repository.getDailyVocabulary('user_1');
      expect(result.isSuccess, true);
      expect(result.value.length, 0);
    });

    test('saveReview calls correct endpoint', () async {
      when(() => mockDataSource.saveReview(
        userId: any(named: 'userId'),
        wordId: any(named: 'wordId'),
        masteryScore: any(named: 'masteryScore'),
      )).thenAnswer((_) async => Result.success(
        const VocabularyHistory(
          id: 'vh_1',
          userId: 'user_1',
          wordId: 'v1',
          masteryLevel: 3,
        ),
      ));

      final result = await repository.saveReview(
        userId: 'user_1',
        wordId: 'v1',
        masteryScore: 3,
      );
      expect(result.isSuccess, true);
    });

    test('getHistory returns list on success', () async {
      when(() => mockDataSource.getHistory(any()))
          .thenAnswer((_) async => const Result.success([]));

      final result = await repository.getHistory('user_1');
      expect(result.isSuccess, true);
    });

    test('handles error', () async {
      when(() => mockDataSource.getDailyVocabulary(any()))
          .thenAnswer((_) async => Result.error(NetworkFailure('Failed to fetch')));

      final result = await repository.getDailyVocabulary('user_1');
      expect(result.isFailure, true);
    });
  });
}
