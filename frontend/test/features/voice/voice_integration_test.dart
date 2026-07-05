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

  group('Voice Session Integration', () {
    test('full voice session lifecycle', () async {
      final now = DateTime.now();
      when(() => mockVoiceRepository.startSession(
            language: any(named: 'language'),
            persona: any(named: 'persona'),
          )).thenAnswer(
        (_) async => const Result.success(VoiceSessionResult(
          sessionId: 'vs_full',
          token: 'token_123',
          roomId: 'room_123',
          livekitUrl: 'wss://livekit.cloud',
        )),
      );

      when(() => mockVoiceRepository.endSession(any())).thenAnswer(
        (_) async => Result.success(VoiceSession(
          id: 'vs_full',
          userId: 'user_001',
          provider: 'livekit',
          duration: 3,
          roomId: 'room_123',
          startedAt: now,
          endedAt: now,
        )),
      );

      final startResult = await mockVoiceRepository.startSession(
        language: 'English',
        persona: 'Friendly Tutor',
      );
      expect(startResult.isSuccess, isTrue);
      final sessionId = startResult.value.sessionId;

      final endResult = await mockVoiceRepository.endSession(sessionId);
      expect(endResult.isSuccess, isTrue);
    });

    test('voice session handles connection failure', () async {
      when(() => mockVoiceRepository.startSession(
            language: any(named: 'language'),
            persona: any(named: 'persona'),
          )).thenAnswer(
        (_) async => const Result.error(
          VoiceServiceFailure('Connection timed out'),
        ),
      );

      final result = await mockVoiceRepository.startSession(
        language: 'English',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<VoiceServiceFailure>());
    });
  });
}
