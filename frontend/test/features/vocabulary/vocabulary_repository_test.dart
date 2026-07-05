import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:ai_language_coach/features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockDio mockDio;
  late VocabularyRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = VocabularyRepositoryImpl(dio: mockDio);
  });

  group('VocabularyRepositoryImpl', () {
    test('getDailyVocabulary returns list on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([
        {'id': 'v1', 'word': 'ephemeral', 'meaning': 'Short-lived'},
        {'id': 'v2', 'word': 'eloquent', 'meaning': 'Fluent'},
      ]);
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await repository.getDailyVocabulary();
      expect(result.isSuccess, true);
      expect(result.value.length, 2);
    });

    test('getDailyVocabulary handles invalid format', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'invalid': 'object'});
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await repository.getDailyVocabulary();
      expect(result.isFailure, true);
    });

    test('updateMastery calls correct endpoint', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => MockResponse());

      final result = await repository.updateMastery('v1', 3);
      expect(result.isSuccess, true);
      verify(
        () => mockDio.post(
          any(),
          data: any(named: 'data', that: containsPair('word_id', 'v1')),
        ),
      ).called(1);
    });

    test('getHistory returns list on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([]);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await repository.getHistory();
      expect(result.isSuccess, true);
    });

    test('handles DioException', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Failed to fetch',
        ),
      );

      final result = await repository.getDailyVocabulary();
      expect(result.isFailure, true);
    });
  });
}
