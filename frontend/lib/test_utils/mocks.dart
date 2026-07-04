import 'package:mocktail/mocktail.dart';
import '../core/errors/failure.dart';
import '../core/errors/result.dart';

/// Extension to create Result mocks.
extension ResultMockExtensions on Mock {
  /// Create a success result for testing.
  static Result<T> successResult<T>(T value) => Result.success(value);

  /// Create an error result for testing.
  static Result<T> errorResult<T>(Failure failure) => Result.error(failure);
}

/// Test doubles for common types.
class TestConstants {
  TestConstants._();

  static const String testEmail = 'test@example.com';
  static const String testPassword = 'TestPassword123';
  static const String testUserId = 'test-user-id-123';
  static const String testToken = 'test-access-token-abc123';
  static const String testRefreshToken = 'test-refresh-token-xyz789';
  static const String testLessonId = 'lesson-123';
  static const String testVocabularyId = 'vocab-456';
}

/// Common test failures for unit tests.
class TestFailures {
  TestFailures._();

  static const networkFailure = NetworkFailure('Test network error');
  static const authFailure = AuthFailure('Test auth error');
  static const databaseFailure = DatabaseFailure('Test database error');
  static const serverFailure = ServerFailure('Test server error');
  static const unknownFailure = UnknownFailure('Test unknown error');
}

/// Helper for creating test data.
class TestData {
  TestData._();

  static Map<String, dynamic> testUserProfile() => {
    'id': TestConstants.testUserId,
    'email': TestConstants.testEmail,
    'full_name': 'Test User',
    'native_language': 'ml',
    'target_language': 'en',
    'proficiency_level': 'B1',
    'created_at': DateTime.now().toIso8601String(),
  };

  static Map<String, dynamic> testChatMessage() => {
    'id': 'msg-123',
    'content': 'Hello, how are you?',
    'role': 'user',
    'created_at': DateTime.now().toIso8601String(),
  };

  static Map<String, dynamic> testVocabularyWord() => {
    'id': TestConstants.testVocabularyId,
    'word': 'Hello',
    'translation': 'നമസ്കാരം',
    'language': 'en',
    'examples': ['Hello, how are you?'],
    'next_review_at': DateTime.now().toIso8601String(),
    'review_count': 0,
  };
}
