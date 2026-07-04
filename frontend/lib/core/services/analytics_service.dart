import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics service wrapper for Firebase Analytics and PostHog.
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log a custom event.
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters?.map(
          (key, value) => MapEntry(key, value as Object),
        ),
      );
    } catch (e) {
      // Silently fail - analytics should never crash the app
    }
  }

  /// Log user login.
  Future<void> logLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      // Silently fail
    }
  }

  /// Log user signup.
  Future<void> logSignUp(String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      // Silently fail
    }
  }

  /// Log lesson completion.
  Future<void> logLessonCompleted(String lessonId, String lessonTitle) async {
    try {
      await logEvent(
        AnalyticsEvents.lessonCompleted,
        parameters: {'lesson_id': lessonId, 'lesson_title': lessonTitle},
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log voice session start.
  Future<void> logVoiceSessionStarted(String sessionId) async {
    try {
      await logEvent(
        AnalyticsEvents.voiceSessionStarted,
        parameters: {'session_id': sessionId},
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log mock exam completed.
  Future<void> logMockExamCompleted(
    String examType,
    String section,
    double score,
  ) async {
    try {
      await logEvent(
        AnalyticsEvents.mockExamCompleted,
        parameters: {'exam_type': examType, 'section': section, 'score': score},
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log subscription purchase.
  Future<void> logSubscriptionCreated(String plan, String price) async {
    try {
      await logEvent(
        AnalyticsEvents.subscriptionCreated,
        parameters: {'plan': plan, 'price': price},
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Set user properties.
  Future<void> setUserProperties({
    String? nativeLanguage,
    String? targetLanguage,
    String? proficiencyLevel,
    String? targetExam,
    String? subscriptionPlan,
  }) async {
    try {
      if (nativeLanguage != null) {
        await _analytics.setUserProperty(
          name: 'native_language',
          value: nativeLanguage,
        );
      }
      if (targetLanguage != null) {
        await _analytics.setUserProperty(
          name: 'target_language',
          value: targetLanguage,
        );
      }
      if (proficiencyLevel != null) {
        await _analytics.setUserProperty(
          name: 'proficiency_level',
          value: proficiencyLevel,
        );
      }
      if (targetExam != null) {
        await _analytics.setUserProperty(
          name: 'target_exam',
          value: targetExam,
        );
      }
      if (subscriptionPlan != null) {
        await _analytics.setUserProperty(
          name: 'subscription_plan',
          value: subscriptionPlan,
        );
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Set the current screen.
  Future<void> setCurrentScreen(String screenName) async {
    try {
      await _analytics.setCurrentScreen(screenName: screenName);
    } catch (e) {
      // Silently fail
    }
  }
}

/// Analytics event names following the [category]_[action]_[object] convention.
class AnalyticsEvents {
  AnalyticsEvents._();

  // Auth events
  static const String signupCompleted = 'auth_signup_completed';
  static const String loginCompleted = 'auth_login_completed';
  static const String logoutCompleted = 'auth_logout_completed';

  // Onboarding events
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingStepCompleted = 'onboarding_step_completed';

  // Lesson events
  static const String lessonStarted = 'lesson_started';
  static const String lessonCompleted = 'lesson_completed';
  static const String lessonAbandoned = 'lesson_abandoned';

  // Vocabulary events
  static const String vocabularyReviewStarted = 'vocabulary_review_started';
  static const String vocabularyReviewCompleted = 'vocabulary_review_completed';
  static const String vocabularyWordAdded = 'vocabulary_word_added';

  // Chat events
  static const String chatSessionStarted = 'chat_session_started';
  static const String chatMessageSent = 'chat_message_sent';
  static const String chatSessionEnded = 'chat_session_ended';

  // Voice events
  static const String voiceSessionStarted = 'voice_session_started';
  static const String voiceSessionEnded = 'voice_session_ended';
  static const String voiceCallConnected = 'voice_call_connected';

  // Grammar events
  static const String grammarCorrectionViewed = 'grammar_correction_viewed';

  // Mock exam events
  static const String mockExamStarted = 'mock_exam_started';
  static const String mockExamCompleted = 'mock_exam_completed';
  static const String mockExamAbandoned = 'mock_exam_abandoned';

  // Gamification events
  static const String xpAwarded = 'xp_awarded';
  static const String levelUp = 'level_up';
  static const String streakMaintained = 'streak_maintained';
  static const String streakBroken = 'streak_broken';
  static const String achievementUnlocked = 'achievement_unlocked';

  // Subscription events
  static const String subscriptionCreated = 'subscription_created';
  static const String subscriptionRenewed = 'subscription_renewed';
  static const String subscriptionCancelled = 'subscription_cancelled';
  static const String paywallViewed = 'paywall_viewed';

  // Error events
  static const String apiError = 'error_api';
  static const String voiceConnectionFailed = 'error_voice_connection';
  static const String aiResponseFailed = 'error_ai_response';
}
