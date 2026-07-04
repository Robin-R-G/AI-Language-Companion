/// Test constants used across the test suite.
class TestConstants {
  TestConstants._();

  // ─── User Data ──────────────────────────────────────────────────────────────

  static const String testUserId = 'test_user_001';
  static const String testUserEmail = 'test@example.com';
  static const String testUserPassword = 'TestPass123';
  static const String testUserDisplayName = 'Test User';
  static const String testUserNativeLanguage = 'Malayalam';
  static const String testUserTargetLanguage = 'English';
  static const String testUserProficiencyLevel = 'B1';
  static const String testUserTargetExam = 'ielts';
  static const int testUserXp = 1200;
  static const int testUserStreak = 5;
  static const int testUserLevel = 8;

  // ─── Auth Tokens ────────────────────────────────────────────────────────────

  static const String testAccessToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test';
  static const String testRefreshToken = 'refresh_token_test_value';

  // ─── Feature Identifiers ────────────────────────────────────────────────────

  static const String testLessonId = 'lesson_001';
  static const String testVocabWordId = 'vw_001';
  static const String testChatMessageId = 'msg_001';
  static const String testConversationId = 'conv_001';
  static const String testVoiceSessionId = 'vs_001';
  static const String testMockExamId = 'exam_001';

  // ─── Feature Flags ──────────────────────────────────────────────────────────

  static const Map<String, bool> defaultFeatureFlags = {
    'voice_chat': true,
    'mock_exams': true,
    'vocabulary': true,
    'grammar': true,
    'writing': true,
    'listening': true,
    'reading': true,
    'advanced_analytics': false,
    'offline_mode': false,
    'ai_tutor': false,
    'live_classes': false,
    'new_onboarding': true,
    'dark_mode': true,
    'animations': true,
    'beta_features': false,
    'ab_testing': false,
  };

  // ─── Timeouts ───────────────────────────────────────────────────────────────

  static const Duration shortTimeout = Duration(seconds: 2);
  static const Duration mediumTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(seconds: 10);

  // ─── Strings ────────────────────────────────────────────────────────────────

  static const String testEmptyString = '';
  static const String testLongString =
      'This is a very long string that exceeds the typical maximum length for display fields and should be truncated appropriately.';
  static const String testHtmlString = '<script>alert("xss")</script>';
  static const String testSqlString = "'; DROP TABLE users; --";
}
