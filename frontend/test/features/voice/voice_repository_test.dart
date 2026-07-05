import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_language_coach/features/voice/data/repositories/voice_repository_impl.dart';
import 'package:ai_language_coach/features/voice/data/datasources/voice_remote_datasource.dart';
import 'package:ai_language_coach/shared/models/exam.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';

class MockVoiceRemoteDataSource extends Mock implements VoiceRemoteDataSource {}

void main() {
  late MockVoiceRemoteDataSource mockDataSource;
  late VoiceRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockVoiceRemoteDataSource();
    repository = VoiceRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('VoiceRepositoryImpl', () {
    test('startSession returns session result on success', () async {
      const expectedResult = VoiceSessionResult(
        sessionId: 'vs_1',
        token: 'token_123',
        roomId: 'room_1',
        livekitUrl: 'wss://livekit.cloud',
      );

      when(
        () => mockDataSource.startSession(
          language: any(named: 'language'),
          persona: any(named: 'persona'),
        ),
      ).thenAnswer((_) async => const Result.success(expectedResult));

      final result = await repository.startSession(language: 'en');
      expect(result.isSuccess, true);
      expect(result.value.sessionId, 'vs_1');
    });

    test('startSession with persona parameters', () async {
      const expectedResult = VoiceSessionResult(
        sessionId: 'vs_1',
        token: 'token_123',
        roomId: 'room_1',
        livekitUrl: 'wss://livekit.cloud',
      );

      when(
        () => mockDataSource.startSession(
          language: 'en',
          persona: 'teacher',
        ),
      ).thenAnswer((_) async => const Result.success(expectedResult));

      final result = await repository.startSession(language: 'en', persona: 'teacher');
      expect(result.isSuccess, true);
      verify(() => mockDataSource.startSession(language: 'en', persona: 'teacher')).called(1);
    });

    test('endSession returns session details on success', () async {
      final expectedSession = VoiceSession(
        id: 'vs_1',
        userId: 'u1',
        provider: 'livekit',
        duration: 120,
        roomId: 'room_1',
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
      );

      when(
        () => mockDataSource.endSession(any()),
      ).thenAnswer((_) async => Result.success(expectedSession));

      final result = await repository.endSession('vs_1');
      expect(result.isSuccess, true);
      expect(result.value.id, 'vs_1');
    });

    test('handles data source errors', () async {
      when(
        () => mockDataSource.startSession(
          language: any(named: 'language'),
          persona: any(named: 'persona'),
        ),
      ).thenAnswer((_) async => const Result.error(NetworkFailure('Error')));

      final result = await repository.startSession(language: 'en');
      expect(result.isFailure, true);
    });
  });
}
