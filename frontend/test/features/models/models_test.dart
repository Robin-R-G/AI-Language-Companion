import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/achievements/domain/entities/achievement.dart';
import 'package:ai_language_coach/features/ai_chat/domain/entities/chat_message.dart';
import 'package:ai_language_coach/features/auth/domain/entities/user.dart';
import 'package:ai_language_coach/features/grammar/domain/entities/grammar_correction.dart';
import 'package:ai_language_coach/features/lessons/domain/entities/lesson.dart';
import 'package:ai_language_coach/features/mock_exam/domain/entities/mock_exam.dart';
import 'package:ai_language_coach/features/subscription/domain/entities/subscription.dart';
import 'package:ai_language_coach/features/vocabulary/domain/entities/vocabulary_word.dart';
import 'package:ai_language_coach/features/voice/domain/entities/voice_session.dart';
import 'package:ai_language_coach/features/voice/domain/entities/writing_evaluation.dart';

void main() {
  group('AppUser', () {
    final json = {
      'id': 'user_1',
      'email': 'test@test.com',
      'fullName': 'Test User',
      'avatarUrl': 'https://example.com/avatar.png',
      'nativeLanguage': 'Malayalam',
      'targetLanguage': 'en',
      'proficiencyLevel': 'B1',
      'targetExam': 'ielts',
      'xp': 100,
      'streak': 5,
      'level': 3,
      'longestStreak': 5,
      'onboardingCompleted': true,
      'lastActiveAt': '2026-07-04T10:00:00.000',
      'createdAt': '2026-06-01T00:00:00.000',
      'updatedAt': '2026-06-01T00:00:00.000',
    };

    test('fromJson creates correct instance', () {
      final user = AppUser.fromJson(json);
      expect(user.id, 'user_1');
      expect(user.email, 'test@test.com');
      expect(user.fullName, 'Test User');
      expect(user.nativeLanguage, 'Malayalam');
      expect(user.targetLanguage, 'en');
      expect(user.xp, 100);
      expect(user.streak, 5);
      expect(user.level, 3);
      expect(user.onboardingCompleted, true);
    });

    test('toJson produces correct map', () {
      final user = AppUser.fromJson(json);
      final output = user.toJson();
      expect(output['id'], 'user_1');
      expect(output['email'], 'test@test.com');
    });

    test('uses default values for optional fields', () {
      final now = DateTime.now();
      final user = AppUser(
        id: 'u1',
        email: 'e@e.com',
        nativeLanguage: 'Malayalam',
        targetLanguage: 'en',
        onboardingCompleted: false,
        xp: 0,
        level: 0,
        streak: 0,
        longestStreak: 0,
        lastActiveAt: now,
        createdAt: now,
        updatedAt: now,
      );
      expect(user.fullName, isNull);
      expect(user.proficiencyLevel, isNull);
      expect(user.targetExam, isNull);
    });

    test('equality works correctly', () {
      final now = DateTime.now();
      final a = AppUser(
        id: 'u1',
        email: 'e@e.com',
        nativeLanguage: 'Malayalam',
        targetLanguage: 'en',
        onboardingCompleted: false,
        xp: 0,
        level: 0,
        streak: 0,
        longestStreak: 0,
        lastActiveAt: now,
        createdAt: now,
        updatedAt: now,
      );
      final b = AppUser(
        id: 'u1',
        email: 'e@e.com',
        nativeLanguage: 'Malayalam',
        targetLanguage: 'en',
        onboardingCompleted: false,
        xp: 0,
        level: 0,
        streak: 0,
        longestStreak: 0,
        lastActiveAt: now,
        createdAt: now,
        updatedAt: now,
      );
      final c = AppUser(
        id: 'u2',
        email: 'e@e.com',
        nativeLanguage: 'Malayalam',
        targetLanguage: 'en',
        onboardingCompleted: false,
        xp: 0,
        level: 0,
        streak: 0,
        longestStreak: 0,
        lastActiveAt: now,
        createdAt: now,
        updatedAt: now,
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('Achievement', () {
    final json = {
      'id': 'ach_1',
      'userId': 'user_1',
      'badgeId': 'badge_1',
      'title': 'First Lesson',
      'description': 'Complete your first lesson',
      'iconName': 'school',
      'xpReward': 50,
      'category': 'milestone',
      'tier': 'bronze',
      'unlockedAt': '2026-07-04T10:00:00.000',
      'createdAt': '2026-07-04T10:00:00.000',
    };

    test('fromJson creates correct instance', () {
      final ach = Achievement.fromJson(json);
      expect(ach.id, 'ach_1');
      expect(ach.title, 'First Lesson');
      expect(ach.category, 'milestone');
      expect(ach.xpReward, 50);
    });

    test('toJson round-trip', () {
      final ach = Achievement.fromJson(json);
      expect(ach.toJson()['id'], 'ach_1');
      expect(ach.toJson()['title'], 'First Lesson');
    });
  });

  group('AchievementProgress', () {
    test('fromJson and defaults', () {
      final p = AchievementProgress.fromJson({
        'achievementId': 'ach_1',
        'currentValue': 3,
        'targetValue': 5,
        'percentage': 60.0,
      });
      expect(p.achievementId, 'ach_1');
      expect(p.percentage, 60.0);
    });

    test('uses default percentage', () {
      final p = AchievementProgress(achievementId: 'ach_1', targetValue: 10);
      expect(p.percentage, 0.0);
    });
  });

  group('MockExam', () {
    final json = {
      'id': 'exam_1',
      'userId': 'user_1',
      'examType': 'IELTS',
      'section': 'Reading',
      'durationMinutes': 60,
      'totalQuestions': 40,
      'questionsAnswered': 20,
      'correctAnswers': 15,
      'estimatedScore': 5.5,
      'status': 'in_progress',
      'feedback': {'strength': 'reading'},
      'startedAt': '2026-07-04T10:00:00.000',
      'createdAt': '2026-07-04T10:00:00.000',
      'updatedAt': '2026-07-04T10:00:00.000',
    };

    test('fromJson creates correct instance', () {
      final exam = MockExam.fromJson(json);
      expect(exam.id, 'exam_1');
      expect(exam.examType, 'IELTS');
      expect(exam.estimatedScore, 5.5);
      expect(exam.status, 'in_progress');
    });
  });

  group('MockExamQuestion', () {
    test('fromJson creates correct instance', () {
      final q = MockExamQuestion.fromJson({
        'id': 'q_1',
        'examId': 'exam_1',
        'questionNumber': 1,
        'questionType': 'multiple_choice',
        'prompt': 'What is X?',
        'options': {'A': 'Option A', 'B': 'Option B', 'C': 'Option C', 'D': 'Option D'},
        'correctAnswer': 'A',
        'isCorrect': true,
        'createdAt': '2026-07-04T10:00:00.000',
      });
      expect(q.id, 'q_1');
      expect(q.questionType, 'multiple_choice');
      expect(q.correctAnswer, 'A');
      expect(q.isCorrect, true);
      expect(q.userAnswer, isNull);
    });
  });

  group('Subscription', () {
    final json = {
      'id': 'sub_1',
      'userId': 'user_1',
      'provider': 'stripe',
      'planId': 'premium_monthly',
      'planName': 'Premium Monthly',
      'status': 'active',
      'billingCycle': 'monthly',
      'amount': 9.99,
      'currency': 'USD',
      'currentPeriodStart': '2026-07-01T00:00:00.000',
      'currentPeriodEnd': '2026-08-01T00:00:00.000',
      'createdAt': '2026-07-01T00:00:00.000',
      'updatedAt': '2026-07-01T00:00:00.000',
    };

    test('fromJson creates correct instance', () {
      final sub = Subscription.fromJson(json);
      expect(sub.planId, 'premium_monthly');
      expect(sub.status, 'active');
      expect(sub.amount, 9.99);
    });
  });

  group('SubscriptionPlan', () {
    test('fromJson and defaults', () {
      final plan = SubscriptionPlan.fromJson({
        'id': 'plan_1',
        'name': 'Premium Monthly',
        'description': 'Full access',
        'price': 9.99,
        'currency': 'USD',
        'period': 'monthly',
      });
      expect(plan.isPopular, false);
      expect(plan.features, isEmpty);
    });
  });

  group('GrammarCorrection', () {
    final json = {
      'id': 'gc_1',
      'originalText': 'He go to school',
      'correctedText': 'He goes to school',
      'explanation': 'Subject-verb agreement',
      'category': 'grammar',
      'severity': 'high',
      'suggestions': ['He goes to school', 'He is going to school'],
      'createdAt': '2026-07-04T10:00:00.000',
      'startIndex': 0,
      'endIndex': 14,
    };

    test('fromJson creates correct instance', () {
      final gc = GrammarCorrection.fromJson(json);
      expect(gc.originalText, 'He go to school');
      expect(gc.correctedText, 'He goes to school');
      expect(gc.category, 'grammar');
      expect(gc.suggestions.length, 2);
    });

    test('uses default severity', () {
      final gc = GrammarCorrection(
        id: 'gc_1',
        originalText: 'text',
        correctedText: 'fixed',
        explanation: 'rule',
      );
      expect(gc.severity, 'medium');
    });
  });

  group('ChatMessage', () {
    test('fromJson with nested GrammarFeedback', () {
      final msg = ChatMessage.fromJson({
        'id': 'msg_1',
        'role': 'assistant',
        'content': 'Hello!',
        'timestamp': '2026-07-04T10:00:00.000',
        'grammarFeedback': {
          'isCorrect': false,
          'original': 'He go',
          'corrected': 'He goes',
          'explanation': 'Fix verb',
        },
      });
      expect(msg.role, 'assistant');
      expect(msg.grammarFeedback, isNotNull);
      expect(msg.grammarFeedback!.isCorrect, false);
      expect(msg.grammarFeedback!.corrected, 'He goes');
    });

    test('fromJson with nested TranslationData', () {
      final msg = ChatMessage.fromJson({
        'id': 'msg_2',
        'role': 'user',
        'content': 'Hello',
        'translation': {'translation': 'ഹലോ', 'pronunciation': 'həlō'},
      });
      expect(msg.translation, isNotNull);
      expect(msg.translation!.translation, 'ഹലോ');
    });
  });

  group('Lesson', () {
    final json = {
      'id': 'lesson_1',
      'title': 'Present Perfect',
      'description': 'Learn present perfect tense',
      'language': 'en',
      'level': 'B1',
      'order': 1,
      'xpReward': 50,
      'estimatedMinutes': 15,
      'tags': ['grammar'],
      'isLocked': false,
      'createdAt': '2026-07-04T10:00:00.000',
      'updatedAt': '2026-07-04T10:00:00.000',
    };

    test('fromJson creates correct instance', () {
      final lesson = Lesson.fromJson(json);
      expect(lesson.id, 'lesson_1');
      expect(lesson.level, 'B1');
      expect(lesson.estimatedMinutes, 15);
    });
  });

  group('VocabularyWord', () {
    test('fromJson creates correct instance', () {
      final word = VocabularyWord.fromJson({
        'id': 'vocab_1',
        'word': 'ephemeral',
        'meaning': 'Lasting for a very short time',
        'pronunciation': '/ɪˈfɛm(ə)rəl/',
        'examples': ['The beauty of cherry blossoms is ephemeral.'],
        'cefrLevel': 'C1',
        'partOfSpeech': 'adjective',
        'targetLanguage': 'en',
        'nativeLanguage': 'ml',
        'audioUrl': null,
        'imageUrl': null,
        'createdAt': '2026-07-04T10:00:00.000',
        'updatedAt': '2026-07-04T10:00:00.000',
      });
      expect(word.word, 'ephemeral');
      expect(word.cefrLevel, 'C1');
      expect(word.partOfSpeech, 'adjective');
    });
  });

  group('VoiceSession', () {
    test('fromJson creates correct instance', () {
      final session = VoiceSession.fromJson({
        'id': 'vs_1',
        'userId': 'user_1',
        'sessionType': 'practice',
        'targetLanguage': 'en',
        'topic': 'introductions',
        'durationMinutes': 5,
        'xpEarned': 10,
        'status': 'completed',
        'liveKitRoomName': 'room_abc',
        'startedAt': '2026-07-04T10:00:00.000',
        'createdAt': '2026-07-04T10:00:00.000',
        'updatedAt': '2026-07-04T10:00:00.000',
      });
      expect(session.id, 'vs_1');
      expect(session.durationMinutes, 5);
    });
  });

  group('PronunciationScore', () {
    test('fromJson creates correct instance', () {
      final score = PronunciationScore.fromJson({
        'sessionId': 'session_1',
        'userId': 'user_1',
        'overallScore': 78.0,
        'fluency': 75.0,
        'clarity': 80.0,
        'stress': 70.0,
        'intonation': 85.0,
        'confidence': 72.0,
        'wordScores': [],
        'createdAt': '2026-07-04T10:00:00.000',
      });
      expect(score.overallScore, 78.0);
      expect(score.fluency, 75.0);
      expect(score.clarity, 80.0);
    });
  });

  group('WritingEvaluation', () {
    test('fromJson creates correct instance', () {
      final eval = WritingEvaluation.fromJson({
        'estimatedBand': '6.5',
        'grammarScore': 65,
        'vocabularyScore': 70,
        'organizationScore': 60,
        'clarityScore': 68,
        'strengths': ['Good vocabulary'],
        'mistakes': ['Article usage'],
        'improvedVersion': 'Improved text here',
        'recommendations': ['Practice articles'],
      });
      expect(eval.estimatedBand, '6.5');
      expect(eval.grammarScore, 65);
    });
  });
}
