import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:ai_language_coach/features/voice/data/repositories/voice_repository_impl.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockDio mockDio;
  late VoiceRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = VoiceRepositoryImpl(dio: mockDio);
  });

  group('VoiceRepositoryImpl', () {
    test('startSession returns session on success', () async {
      final response = MockResponse();
      when(
        () => response.data,
      ).thenReturn({'id': 'vs_1', 'user_id': 'u1', 'provider': 'livekit'});
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.startSession(language: 'en');
      expect(result.isSuccess, true);
      expect(result.value.id, 'vs_1');
    });

    test('startSession with persona', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'id': 'vs_1', 'user_id': 'u1'});
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      await repository.startSession(language: 'en', persona: 'teacher');
      verify(
        () => mockDio.post(
          any(),
          data: any(named: 'data', that: containsPair('persona', 'teacher')),
        ),
      ).called(1);
    });

    test('endSession returns session on success', () async {
      final response = MockResponse();
      when(
        () => response.data,
      ).thenReturn({'id': 'vs_1', 'user_id': 'u1', 'duration_seconds': 120});
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.endSession('vs_1');
      expect(result.isSuccess, true);
    });

    test('evaluateSpeaking returns score on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'fluencyScore': 80,
        'grammarScore': 75,
        'overallScore': 78,
      });
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.evaluateSpeaking('Hello world');
      expect(result.isSuccess, true);
    });

    test('getSessions returns list on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([]);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await repository.getSessions();
      expect(result.isSuccess, true);
    });

    test('handles invalid response format', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'unexpected': true});
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.startSession(language: 'en');
      expect(result.isFailure, true);
    });

    test('handles DioException', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Voice service error',
        ),
      );

      final result = await repository.startSession(language: 'en');
      expect(result.isFailure, true);
    });
  });
}
