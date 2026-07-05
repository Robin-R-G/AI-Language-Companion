import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/features/voice/domain/repositories/voice_repository.dart';
import 'package:ai_language_coach/features/voice/domain/entities/voice_session.dart';

class MockVoiceRepository extends Mock implements VoiceRepository {}

WordScore _wordScore(String word, double score, String status) {
  return WordScore(word: word, score: score, status: status);
}

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
        (_) async => Result.success(VoiceSession(
          id: 'vs_full',
          userId: 'user_001',
          sessionType: 'conversation',
          targetLanguage: 'en',
          topic: 'general',
          durationMinutes: 0,
          xpEarned: 0,
          status: 'active',
          startedAt: now,
          createdAt: now,
          updatedAt: now,
        )),
      );

      when(() => mockVoiceRepository.evaluateSpeaking(
            any(),
            targetLanguage: any(named: 'targetLanguage'),
          )).thenAnswer(
        (_) async => Result.success(PronunciationScore(
          sessionId: 'vs_full',
          userId: 'user_001',
          overallScore: 82,
          fluency: 85,
          clarity: 80,
          stress: 90,
          intonation: 75,
          confidence: 80,
          wordScores: [
            _wordScore('hello', 90, 'good'),
            _wordScore('world', 85, 'good'),
          ],
          createdAt: now,
        )),
      );

      when(() => mockVoiceRepository.endSession(any())).thenAnswer(
        (_) async => Result.success(VoiceSession(
          id: 'vs_full',
          userId: 'user_001',
          sessionType: 'conversation',
          targetLanguage: 'en',
          topic: 'general',
          durationMinutes: 3,
          xpEarned: 50,
          status: 'completed',
          startedAt: now,
          endedAt: now,
          createdAt: now,
          updatedAt: now,
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
      final now = DateTime.now();
      when(() => mockVoiceRepository.getSessions(limit: any(named: 'limit')))
          .thenAnswer(
        (_) async => Result.success([
          VoiceSession(
            id: 'vs_1',
            userId: 'user_001',
            sessionType: 'conversation',
            targetLanguage: 'en',
            topic: 'greetings',
            durationMinutes: 2,
            xpEarned: 20,
            status: 'completed',
            startedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
          VoiceSession(
            id: 'vs_2',
            userId: 'user_001',
            sessionType: 'practice',
            targetLanguage: 'en',
            topic: 'work',
            durationMinutes: 5,
            xpEarned: 50,
            status: 'completed',
            startedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
          VoiceSession(
            id: 'vs_3',
            userId: 'user_001',
            sessionType: 'exam',
            targetLanguage: 'en',
            topic: 'test_prep',
            durationMinutes: 3,
            xpEarned: 30,
            status: 'completed',
            startedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        ]),
      );

      final result = await mockVoiceRepository.getSessions(limit: 3);

      expect(result.isSuccess, isTrue);
      expect(result.value.length, 3);
    });
  });
}
