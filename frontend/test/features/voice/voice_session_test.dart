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

  group('Voice Session Tests', () {
    test('should start a voice session', () async {
      when(() => mockVoiceRepository.startSession(
            language: any(named: 'language'),
            persona: any(named: 'persona'),
          )).thenAnswer(
        (_) async => Result.success(VoiceSession(
          id: 'vs_001',
          userId: 'user_001',
          roomId: 'room_001',
          startedAt: DateTime.now(),
        )),
      );

      final result = await mockVoiceRepository.startSession(
        language: 'English',
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.id, 'vs_001');
    });

    test('should end a voice session', () async {
      when(() => mockVoiceRepository.endSession(any())).thenAnswer(
        (_) async => Result.success(VoiceSession(
          id: 'vs_001',
          userId: 'user_001',
          endedAt: DateTime.now(),
        )),
      );

      final result = await mockVoiceRepository.endSession('vs_001');

      expect(result.isSuccess, isTrue);
    });

    test('should evaluate speaking', () async {
      when(() => mockVoiceRepository.evaluateSpeaking(
            any(),
            targetLanguage: any(named: 'targetLanguage'),
          )).thenAnswer(
        (_) async => Result.success(PronunciationScore(
          fluencyScore: 82,
          grammarScore: 75,
          vocabularyScore: 80,
          pronunciationScore: 70,
          overallScore: 78,
          feedback: 'Good job!',
          strengths: ['Natural rhythm'],
          issues: ['Needs more practice'],
          practiceWords: ['think', 'three'],
          shadowingExercise: 'The weather is nice today.',
          estimatedProficiency: 'B1',
        )),
      );

      final result = await mockVoiceRepository.evaluateSpeaking(
        'Hello, how are you today?',
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.overallScore, 78);
      expect(result.value.fluencyScore, 82);
      expect(result.value.strengths, contains('Natural rhythm'));
    });

    test('should get voice sessions history', () async {
      when(() => mockVoiceRepository.getSessions(limit: any(named: 'limit')))
          .thenAnswer(
        (_) async => Result.success([
          VoiceSession(id: 'vs_001', userId: 'user_001', durationSeconds: 300),
          VoiceSession(id: 'vs_002', userId: 'user_001', durationSeconds: 600),
        ]),
      );

      final result = await mockVoiceRepository.getSessions(limit: 20);

      expect(result.isSuccess, isTrue);
      expect(result.value.length, 2);
    });

    test('should handle start session failure', () async {
      when(() => mockVoiceRepository.startSession(
            language: any(named: 'language'),
            persona: any(named: 'persona'),
          )).thenAnswer(
        (_) async => const Result.error(
          VoiceServiceFailure('Failed to connect'),
        ),
      );

      final result = await mockVoiceRepository.startSession(
        language: 'English',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<VoiceServiceFailure>());
    });

    test('should handle evaluate speaking failure', () async {
      when(() => mockVoiceRepository.evaluateSpeaking(
            any(),
            targetLanguage: any(named: 'targetLanguage'),
          )).thenAnswer(
        (_) async => const Result.error(
          VoiceServiceFailure('AI evaluation failed'),
        ),
      );

      final result = await mockVoiceRepository.evaluateSpeaking(
        'Hello world',
      );

      expect(result.isFailure, isTrue);
    });
  });

  group('Pronunciation Score Validation', () {
    test('scores should be within valid range (0-100)', () {
      final score = PronunciationScore(
        fluencyScore: 85,
        grammarScore: 90,
        vocabularyScore: 75,
        pronunciationScore: 80,
        overallScore: 82,
        feedback: 'Good performance',
        strengths: ['Clear articulation'],
        issues: ['Minor grammar errors'],
        practiceWords: ['example'],
        shadowingExercise: 'Practice sentence',
        estimatedProficiency: 'B2',
      );

      expect(score.fluencyScore, inInclusiveRange(0, 100));
      expect(score.grammarScore, inInclusiveRange(0, 100));
      expect(score.vocabularyScore, inInclusiveRange(0, 100));
      expect(score.pronunciationScore, inInclusiveRange(0, 100));
      expect(score.overallScore, inInclusiveRange(0, 100));
    });

    test('overall score should be average of component scores', () {
      final fluency = 80;
      final grammar = 70;
      final vocabulary = 90;
      final pronunciation = 60;
      final expectedOverall =
          ((fluency + grammar + vocabulary + pronunciation) / 4).round();

      final score = PronunciationScore(
        fluencyScore: fluency,
        grammarScore: grammar,
        vocabularyScore: vocabulary,
        pronunciationScore: pronunciation,
        overallScore: expectedOverall,
        feedback: '',
        strengths: [],
        issues: [],
        practiceWords: [],
        shadowingExercise: '',
        estimatedProficiency: 'B1',
      );

      expect(score.overallScore, expectedOverall);
    });
  });

  group('Voice Session Lifecycle', () {
    test('session should have start and end timestamps', () {
      final startTime = DateTime.now();
      final session = VoiceSession(
        id: 'vs_lifecycle',
        userId: 'user_001',
        startedAt: startTime,
      );

      expect(session.startedAt, isNotNull);
      expect(session.endedAt, isNull);
    });

    test('session duration should be calculable', () {
      final start = DateTime(2026, 7, 1, 10, 0, 0);
      final end = DateTime(2026, 7, 1, 10, 5, 0);
      final duration = end.difference(start);

      expect(duration.inSeconds, 300);
      expect(duration.inMinutes, 5);
    });
  });
}
