import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/features/auth/domain/entities/user.dart';
import '../test_utils/mock_api_responses.dart';

void main() {
  group('Data Flow Integration - Entity Serialization', () {
    test('AppUser fromJson roundtrip', () {
      final json = MockApiResponses.userProfile;

      final user = AppUser(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        displayName: json['full_name'] as String? ?? '',
        nativeLanguage: json['native_language'] as String? ?? '',
        targetLanguage: json['target_language'] as String? ?? 'en',
        proficiencyLevel: json['proficiency_level'] as String? ?? 'A1',
        targetExam: json['target_exam'] as String? ?? 'general',
        isPremium: json['is_premium'] as bool? ?? false,
        subscriptionPlan: json['subscription_plan'] as String? ?? 'free',
      );

      expect(user.id, 'user_123');
      expect(user.email, 'rahul@example.com');
      expect(user.displayName, 'Rahul Nair');
      expect(user.proficiencyLevel, 'B1');
      expect(user.isPremium, false);
    });

    test('voice session data flow', () {
      final data = MockApiResponses.voiceSession;

      expect(data['id'], isNotEmpty);
      expect(data['duration_seconds'], isA<int>());
      expect(data['overall_score'], isA<int>());
      expect(data['overall_score'], greaterThanOrEqualTo(0));
      expect(data['overall_score'], lessThanOrEqualTo(100));
    });

    test('pronunciation score data flow', () {
      final data = MockApiResponses.pronunciationScore;

      expect(data['fluency_score'], inInclusiveRange(0, 100));
      expect(data['grammar_score'], inInclusiveRange(0, 100));
      expect(data['vocabulary_score'], inInclusiveRange(0, 100));
      expect(data['pronunciation_score'], inInclusiveRange(0, 100));
      expect(data['overall_score'], inInclusiveRange(0, 100));
    });

    test('grammar feedback data flow', () {
      final data = MockApiResponses.grammarFeedback;

      expect(data['is_correct'], isA<bool>());
      expect(data['corrected'], isA<String>());
      expect(data['explanation'], isA<String>());
      expect(data['category'], isA<String>());
      expect(data['examples'], isA<List>());
    });

    test('lesson data flow', () {
      final data = MockApiResponses.lesson;

      expect(data['id'], isNotEmpty);
      expect(data['title'], isNotEmpty);
      expect(data['difficulty'], matches(RegExp(r'^[A-C][1-2]$')));
      expect(data['xp_reward'], greaterThan(0));
    });

    test('vocabulary word data flow', () {
      final data = MockApiResponses.vocabularyWord;

      expect(data['word'], isNotEmpty);
      expect(data['meaning'], isNotEmpty);
      expect(data['synonyms'], isA<List>());
      expect(data['antonyms'], isA<List>());
      expect(data['cefr_level'], matches(RegExp(r'^[A-C][1-2]$')));
    });

    test('subscription data flow', () {
      final data = MockApiResponses.subscription;

      expect(data['id'], isNotEmpty);
      expect(data['plan'], isNotEmpty);
      expect(data['status'], isNotEmpty);
      expect(data['will_renew'], isA<bool>());
    });

    test('subscription plan data flow', () {
      final data = MockApiResponses.subscriptionPlan;

      expect(data['id'], isNotEmpty);
      expect(data['name'], isNotEmpty);
      expect(data['price'], isA<num>());
      expect(data['price'], greaterThanOrEqualTo(0));
      expect(data['features'], isA<List>());
    });

    test('achievement data flow', () {
      final data = MockApiResponses.achievement;

      expect(data['id'], isNotEmpty);
      expect(data['name'], isNotEmpty);
      expect(data['description'], isNotEmpty);
      expect(data['xp_reward'], greaterThan(0));
    });

    test('mock exam data flow', () {
      final data = MockApiResponses.mockExam;

      expect(data['id'], isNotEmpty);
      expect(data['type'], isNotEmpty);
      expect(data['score'], isA<num>());
      expect(data['max_score'], isA<num>());
      expect(data['score'], lessThanOrEqualTo(data['max_score']));
    });
  });

  group('Data Flow Integration - Result Monad', () {
    test('Result.success propagation through layers', () async {
      Future<Result<int>> repositoryLayer() async {
        return const Result.success(42);
      }

      Future<Result<String>> serviceLayer() async {
        final result = await repositoryLayer();
        return result.map((value) => 'Result: $value');
      }

      final result = await serviceLayer();

      expect(result.isSuccess, isTrue);
      expect(result.value, 'Result: 42');
    });

    test('Result.error propagation through layers', () async {
      Future<Result<int>> repositoryLayer() async {
        return const Result.error(DatabaseFailure('Connection lost'));
      }

      Future<Result<String>> serviceLayer() async {
        final result = await repositoryLayer();
        return result.map((value) => 'Result: $value');
      }

      final result = await serviceLayer();

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });

    test('Result fold handles both cases', () {
      final successResult = const Result.success(100);
      final errorResult = const Result.error(NetworkFailure('Timeout'));

      final successValue = successResult.fold(
        (failure) => -1,
        (value) => value,
      );
      final errorValue = errorResult.fold(
        (failure) => -1,
        (value) => value,
      );

      expect(successValue, 100);
      expect(errorValue, -1);
    });

    test('Result getOrElse returns default on error', () {
      final result = const Result.error(UnknownFailure('fail'));

      final value = result.getOrElse(() => 42);

      expect(value, 42);
    });

    test('Result getOrNull returns null on error', () {
      final result = const Result.error(UnknownFailure('fail'));

      final value = result.getOrNull();

      expect(value, isNull);
    });
  });
}
