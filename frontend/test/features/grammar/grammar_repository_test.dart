import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:ai_language_coach/features/grammar/data/repositories/grammar_repository_impl.dart';
import '..\..\mocks/mocks.dart';

void main() {
  late MockDio mockDio;
  late GrammarRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = GrammarRepositoryImpl(dio: mockDio);
  });

  group('GrammarRepositoryImpl', () {
    test('checkGrammar returns correction on success', () async {
      final response = MockResponse<Map<String, dynamic>>();
      when(() => response.data).thenReturn({
        'id': 'gc_1',
        'original_text': 'He go to school',
        'corrected_text': 'He goes to school',
        'explanation': 'Subject-verb agreement',
      });
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.checkGrammar('He go to school');
      expect(result.isSuccess, true);
      expect(result.value.correctedText, 'He goes to school');
    });

    test('checkGrammar with language', () async {
      final response = MockResponse<Map<String, dynamic>>();
      when(() => response.data).thenReturn({
        'id': 'gc_1',
        'original_text': 'text',
        'corrected_text': 'fixed',
        'explanation': 'rule',
      });
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      await repository.checkGrammar('text', language: 'ml');
      verify(
        () => mockDio.post(
          any(),
          data: any(named: 'data', that: containsPair('language', 'ml')),
        ),
      ).called(1);
    });

    test('checkGrammar handles invalid format', () async {
      final response = MockResponse<Map<String, dynamic>>();
      when(() => response.data).thenReturn('not a map');
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.checkGrammar('text');
      expect(result.isFailure, true);
    });

    test('getHistory returns list on success', () async {
      final response = MockResponse<List<dynamic>>();
      when(() => response.data).thenReturn([]);
      when(
        () => mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await repository.getHistory();
      expect(result.isSuccess, true);
    });

    test('handles DioException', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'AI service error',
      ));

      final result = await repository.checkGrammar('text');
      expect(result.isFailure, true);
    });
  });
}
