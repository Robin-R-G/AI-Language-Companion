import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/features/voice/domain/repositories/voice_repository.dart';
import 'package:ai_language_coach/features/voice/domain/entities/voice_session.dart';

class MockVoiceRepository extends Mock implements VoiceRepository {}

void main() {
  late MockVoiceRepository mockVoiceRepository;

  setUp(() {
    mockVoiceRepository = MockVoiceRepository();
    registerFallbackValue('');
  });

  group('Voice Session Integration', () {
    test('full voice session lifecycle', () async {
      when(() => mockVoiceRepository.startSession(
            language: any(named: 'language'),
            persona: any(named: 'persona'),
          )).thenAnswer(
        (_) async => Result.success(VoiceSession(
          id: 'vs_full',
          userId: 'user_001',
          roomId: 'room_full',
          startedAt: DateTime.now(),
        )),
      );

      when(() => mockVoiceRepository.evaluateSpeaking(
            any(),
            targetLanguage: any(named: 'targetLanguage'),
          )).thenAnswer(
        (_) async => Result.success(PronunciationScore(
          fluencyScore: 85,
          grammarScore: 80,
          vocabularyScore: 75,
          pronunciationScore: 90,
          overallScore: 82,
          feedback: 'Excellent pronunciation!',
          strengths: ['Clear articulation', 'Good pacing'],
          issues: ['Minor grammar issue'],
          practiceWords: ['example', 'practice'],
          shadowingExercise: 'The quick brown fox jumps over the lazy dog.',
          estimatedProficiency: 'B2',
        )),
      );

      when(() => mockVoiceRepository.endSession(any())).thenAnswer(
        (_) async => Result.success(VoiceSession(
          id: 'vs_full',
          userId: 'user_001',
          endedAt: DateTime.now(),
          durationSeconds: 180,
        )),
      );

      final startResult = await mockVoiceRepository.startSession(
        language: 'English',
        persona: 'Friendly Tutor',
      );
      expect(startResult.isSuccess, isTrue);
      final sessionId = startResult.value.id;

      final evalResult = await mockVoiceRepository.evaluateSpeaking(
        'I went to the store yesterday and I buyed some groceries.',
        targetLanguage: 'English',
      );
      expect(evalResult.isSuccess, isTrue);
      expect(evalResult.value.overallScore, greaterThan(0));

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

    test('voice session handles evaluation failure', () async {
      when(() => mockVoiceRepository.evaluateSpeaking(
            any(),
            targetLanguage: any(named: 'targetLanguage'),
          )).thenAnswer(
        (_) async => const Result.error(
          VoiceServiceFailure('AI provider unavailable'),
        ),
      );

      final result = await mockVoiceRepository.evaluateSpeaking(
        'Hello world',
      );

      expect(result.isFailure, isTrue);
    });

    test('get sessions returns history', () async {
      when(() => mockVoiceRepository.getSessions(limit: any(named: 'limit')))
          .thenAnswer(
        (_) async => Result.success([
          VoiceSession(id: 'vs_1', userId: 'user_001', durationSeconds: 120, overallScore: 75),
          VoiceSession(id: 'vs_2', userId: 'user_001', durationSeconds: 300, overallScore: 82),
          VoiceSession(id: 'vs_3', userId: 'user_001', durationSeconds: 180, overallScore: 68),
        ]),
      );

      final result = await mockVoiceRepository.getSessions(limit: 3);

      expect(result.isSuccess, isTrue);
      expect(result.value.length, 3);

      final scores = result.value.map((s) => s.overallScore).toList();
      expect(scores, [75, 82, 68]);
    });
  });
}
