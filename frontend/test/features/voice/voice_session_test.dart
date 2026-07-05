import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/features/voice/domain/repositories/voice_repository.dart';
import 'package:ai_language_coach/shared/models/exam.dart';
import 'package:ai_language_coach/features/voice/data/datasources/voice_remote_datasource.dart';

class MockVoiceRepository extends Mock implements VoiceRepository {}

void main() {
  late MockVoiceRepository mockVoiceRepository;

  setUp(() {
    mockVoiceRepository = MockVoiceRepository();
    registerFallbackValue('');
  });

  group('Voice Session Tests', () {
    test('should start a voice session', () async {
      when(
        () => mockVoiceRepository.startSession(
          language: any(named: 'language'),
          persona: any(named: 'persona'),
        ),
      ).thenAnswer(
        (_) async => const Result.success(
          VoiceSessionResult(
            sessionId: 'vs_001',
            token: 'token_abc',
            roomId: 'room_001',
            livekitUrl: 'wss://livekit.cloud',
          ),
        ),
      );

      final result = await mockVoiceRepository.startSession(
        language: 'English',
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.sessionId, 'vs_001');
      expect(result.value.token, 'token_abc');
    });

    test('should end a voice session', () async {
      when(() => mockVoiceRepository.endSession(any())).thenAnswer(
        (_) async => Result.success(
          VoiceSession(
            id: 'vs_001',
            userId: 'user_001',
            provider: 'livekit',
            duration: 300,
            roomId: 'room_001',
            startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
            endedAt: DateTime.now(),
          ),
        ),
      );

      final result = await mockVoiceRepository.endSession('vs_001');

      expect(result.isSuccess, isTrue);
      expect(result.value.id, 'vs_001');
      expect(result.value.duration, 300);
    });

    test('should handle start session failure', () async {
      when(
        () => mockVoiceRepository.startSession(
          language: any(named: 'language'),
          persona: any(named: 'persona'),
        ),
      ).thenAnswer(
        (_) async =>
            const Result.error(VoiceServiceFailure('Failed to connect')),
      );

      final result = await mockVoiceRepository.startSession(
        language: 'English',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<VoiceServiceFailure>());
    });

    test('should handle end session failure', () async {
      when(
        () => mockVoiceRepository.endSession(any()),
      ).thenAnswer(
        (_) async =>
            const Result.error(VoiceServiceFailure('Failed to end session')),
      );

      final result = await mockVoiceRepository.endSession('vs_001');

      expect(result.isFailure, isTrue);
    });
  });
}
