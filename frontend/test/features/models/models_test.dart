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
      'displayName': 'Test User',
      'avatarUrl': 'https://example.com/avatar.png',
      'nativeLanguage': 'Malayalam',
      'targetLanguage': 'en',
      'proficiencyLevel': 'B1',
      'targetExam': 'ielts',
      'xp': 100,
      'streak': 5,
      'level': 3,
      'lessonsCompleted': 10,
      'voiceSessionsCompleted': 2,
      'mockExamsCompleted': 1,
      'lastActiveAt': '2026-07-04T10:00:00.000',
      'createdAt': '2026-06-01T00:00:00.000',
      'isOnboardingComplete': true,
      'isPremium': false,
      'subscriptionPlan': 'free',
      'preferences': {'theme': 'dark'},
    };

    test('fromJson creates correct instance', () {
      final user = AppUser.fromJson(json);
      expect(user.id, 'user_1');
      expect(user.email, 'test@test.com');
      expect(user.displayName, 'Test User');
      expect(user.nativeLanguage, 'Malayalam');
      expect(user.targetLanguage, 'en');
      expect(user.xp, 100);
      expect(user.streak, 5);
      expect(user.level, 3);
      expect(user.isOnboardingComplete, true);
      expect(user.isPremium, false);
      expect(user.subscriptionPlan, 'free');
      expect(user.preferences, {'theme': 'dark'});
    });

    test('toJson produces correct map', () {
      final user = AppUser.fromJson(json);
      final output = user.toJson();
      expect(output['id'], 'user_1');
      expect(output['email'], 'test@test.com');
    });

    test('uses default values for optional fields', () {
      final user = AppUser(id: 'u1', email: 'e@e.com');
      expect(user.displayName, '');
      expect(user.targetLanguage, 'en');
      expect(user.proficiencyLevel, 'A1');
      expect(user.targetExam, 'general');
      expect(user.xp, 0);
      expect(user.streak, 0);
      expect(user.level, 0);
      expect(user.isOnboardingComplete, false);
      expect(user.isPremium, false);
      expect(user.subscriptionPlan, 'free');
      expect(user.preferences, {});
    });

    test('equality works correctly', () {
      final a = AppUser(id: 'u1', email: 'e@e.com');
      final b = AppUser(id: 'u1', email: 'e@e.com');
      final c = AppUser(id: 'u2', email: 'e@e.com');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('Achievement', () {
    final json = {
      'id': 'ach_1',
      'title': 'First Lesson',
      'description': 'Complete your first lesson',
      'icon': 'school',
      'category': 'milestone',
      'requiredValue': 1,
      'currentProgress': 1,
      'xpReward': 50,
      'isUnlocked': true,
      'unlockedAt': '2026-07-04T10:00:00.000',
      'rarity': 'common',
    };

    test('fromJson creates correct instance', () {
      final ach = Achievement.fromJson(json);
      expect(ach.id, 'ach_1');
      expect(ach.title, 'First Lesson');
      expect(ach.category, 'milestone');
      expect(ach.isUnlocked, true);
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
      'examType': 'IELTS',
      'section': 'Reading',
      'title': 'Reading Test 1',
      'description': 'Academic reading passage',
      'durationMinutes': 60,
      'totalQuestions': 40,
      'answeredQuestions': 20,
      'score': 5.5,
      'status': 'in_progress',
      'startedAt': '2026-07-04T10:00:00.000',
      'questions': [],
      'bandScore': '5.5',
    };

    test('fromJson creates correct instance', () {
      final exam = MockExam.fromJson(json);
      expect(exam.id, 'exam_1');
      expect(exam.examType, 'IELTS');
      expect(exam.score, 5.5);
      expect(exam.status, 'in_progress');
      expect(exam.questions, isEmpty);
    });
  });

  group('ExamQuestion', () {
    test('fromJson and defaults', () {
      final q = ExamQuestion.fromJson({
        'id': 'q_1',
        'question': 'What is X?',
        'type': 'multiple_choice',
        'options': ['A', 'B', 'C', 'D'],
        'correctAnswer': 'A',
      });
      expect(q.isCorrect, false);
      expect(q.userAnswer, '');
      expect(q.timeSpentSeconds, 0);
    });
  });

  group('Subscription', () {
    final json = {
      'id': 'sub_1',
      'userId': 'user_1',
      'plan': 'premium_monthly',
      'status': 'active',
      'store': 'app_store',
      'productId': 'com.coach.premium.monthly',
      'currentPeriodStart': '2026-07-01T00:00:00.000',
      'currentPeriodEnd': '2026-08-01T00:00:00.000',
      'createdAt': '2026-07-01T00:00:00.000',
      'isTrial': false,
      'trialDaysRemaining': 0,
      'willRenew': true,
      'features': {'unlimited_chat': true},
    };

    test('fromJson creates correct instance', () {
      final sub = Subscription.fromJson(json);
      expect(sub.plan, 'premium_monthly');
      expect(sub.status, 'active');
      expect(sub.isTrial, false);
      expect(sub.willRenew, true);
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
      'category': 'grammar',
      'difficulty': 'B1',
      'estimatedMinutes': 15,
      'content': 'Lesson content here',
    };

    test('fromJson creates correct instance', () {
      final lesson = Lesson.fromJson(json);
      expect(lesson.id, 'lesson_1');
      expect(lesson.difficulty, 'B1');
      expect(lesson.completionPercentage, 0.0);
      expect(lesson.quizzes, isEmpty);
    });
  });

  group('LessonQuiz', () {
    test('fromJson with options', () {
      final quiz = LessonQuiz.fromJson({
        'questionId': 'q_1',
        'question': 'Choose the correct form:',
        'options': ['go', 'goes', 'going', 'gone'],
        'correctOptionIndex': 1,
        'explanation': 'He goes is correct',
      });
      expect(quiz.options.length, 4);
      expect(quiz.correctOptionIndex, 1);
    });
  });

  group('VocabularyWord', () {
    test('fromJson creates correct instance', () {
      final word = VocabularyWord.fromJson({
        'id': 'vocab_1',
        'word': 'ephemeral',
        'meaning': 'Lasting for a very short time',
        'meaningMalayalam': 'ക്ഷണികമായ',
        'pronunciation': '/ɪˈfɛm(ə)rəl/',
        'examples': ['The beauty of cherry blossoms is ephemeral.'],
        'cefrLevel': 'C1',
        'masteryLevel': 2,
        'reviewCount': 5,
      });
      expect(word.word, 'ephemeral');
      expect(word.cefrLevel, 'C1');
      expect(word.masteryLevel, 2);
    });
  });

  group('VoiceSession', () {
    test('fromJson creates correct instance', () {
      final session = VoiceSession.fromJson({
        'id': 'vs_1',
        'userId': 'user_1',
        'provider': 'livekit',
        'durationSeconds': 120,
        'roomId': 'room_abc',
      });
      expect(session.id, 'vs_1');
      expect(session.durationSeconds, 120);
    });
  });

  group('PronunciationScore', () {
    test('fromJson creates correct instance', () {
      final score = PronunciationScore.fromJson({
        'fluencyScore': 75,
        'grammarScore': 80,
        'vocabularyScore': 70,
        'pronunciationScore': 85,
        'overallScore': 78,
        'feedback': 'Good fluency',
        'strengths': ['Clear pronunciation'],
        'issues': ['Pace control'],
        'estimatedProficiency': 'B2',
      });
      expect(score.overallScore, 78);
      expect(score.estimatedProficiency, 'B2');
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
