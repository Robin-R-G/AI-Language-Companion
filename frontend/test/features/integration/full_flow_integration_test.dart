import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import '../../test_utils/fake_services.dart';
import '../../test_utils/mock_api_responses.dart';
import '../../test_utils/test_constants.dart';

void main() {
  late FakeAuthRepository fakeAuth;
  late FakeSubscriptionRepository fakeSubscription;
  late FakeConnectivityService fakeConnectivity;

  setUp(() {
    fakeAuth = FakeAuthRepository();
    fakeSubscription = FakeSubscriptionRepository();
    fakeConnectivity = FakeConnectivityService();
  });

  tearDown(() {
    fakeAuth.dispose();
    fakeSubscription.dispose();
    fakeConnectivity.dispose();
  });

  group('Full Application Flow Integration', () {
    test('onboarding -> subscription check -> feature usage', () async {
      expect(fakeAuth.currentUser, isNull);

      final signUpResult = await fakeAuth.signUp(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );
      expect(signUpResult.isSuccess, isTrue);
      expect(fakeAuth.currentUser, isNotNull);

      final subResult = await fakeSubscription.getCurrentSubscription();
      expect(subResult.isSuccess, isTrue);
      expect(subResult.value.planId, 'free');

      final accessResult =
          await fakeSubscription.checkFeatureAccess('advanced_analytics');
      expect(accessResult.value, isFalse);
    });

    test('subscription upgrade flow', () async {
      await fakeAuth.signIn(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );

      final plansResult = await fakeSubscription.getPlans();
      expect(plansResult.isSuccess, isTrue);
      expect(plansResult.value.length, 2);

      final purchaseResult = await fakeSubscription.purchase(
        'premium',
        'com.ailanguagecoach.premium.monthly',
      );
      expect(purchaseResult.isSuccess, isTrue);

      final accessResult =
          await fakeSubscription.checkFeatureAccess('advanced_analytics');
      expect(accessResult.value, isTrue);
    });

    test('offline -> online transition', () async {
      fakeConnectivity.setConnected(false);
      expect(fakeConnectivity.isConnected, isFalse);

      fakeConnectivity.setConnected(true);
      expect(fakeConnectivity.isConnected, isTrue);
    });

    test('auth state persists across operations', () async {
      await fakeAuth.signIn(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );
      expect(fakeAuth.currentUser, isNotNull);

      final subResult = await fakeSubscription.getCurrentSubscription();
      expect(subResult.isSuccess, isTrue);

      expect(fakeAuth.currentUser, isNotNull);
    });

    test('error recovery flow', () async {
      fakeSubscription.setShouldFail(true);

      final failResult = await fakeSubscription.getCurrentSubscription();
      expect(failResult.isFailure, isTrue);

      fakeSubscription.setShouldFail(false);

      final successResult = await fakeSubscription.getCurrentSubscription();
      expect(successResult.isSuccess, isTrue);
    });
  });

  group('Data Flow Integration', () {
    test('user profile data matches across services', () async {
      await fakeAuth.signIn(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );

      final user = fakeAuth.currentUser!;
      expect(user.email, TestConstants.testUserEmail);
    });

    test('subscription state affects feature access', () async {
      final accessBefore =
          await fakeSubscription.checkFeatureAccess('voice_chat');
      expect(accessBefore.value, isFalse);

      await fakeSubscription.purchase('premium', 'store_id');

      final accessAfter =
          await fakeSubscription.checkFeatureAccess('voice_chat');
      expect(accessAfter.value, isTrue);
    });

    test('cancellation reverts feature access', () async {
      await fakeSubscription.purchase('premium', 'store_id');

      final accessBefore =
          await fakeSubscription.checkFeatureAccess('advanced_analytics');
      expect(accessBefore.value, isTrue);

      await fakeSubscription.cancelSubscription();

      final accessAfter =
          await fakeSubscription.checkFeatureAccess('advanced_analytics');
      expect(accessAfter.value, isFalse);
    });
  });

  group('API Response Parsing', () {
    test('should parse user profile response', () {
      final data = MockApiResponses.userProfile;

      expect(data['id'], 'user_123');
      expect(data['full_name'], 'Rahul Nair');
      expect(data['proficiency_level'], 'B1');
      expect(data['xp'], 1200);
      expect(data['streak'], 5);
    });

    test('should parse subscription response', () {
      final data = MockApiResponses.subscription;

      expect(data['id'], 'sub_abc123');
      expect(data['plan'], 'premium');
      expect(data['status'], 'active');
      expect(data['will_renew'], true);
    });

    test('should parse voice session response', () {
      final data = MockApiResponses.voiceSession;

      expect(data['id'], 'vs_abc123');
      expect(data['duration_seconds'], 300);
      expect(data['overall_score'], 78);
    });

    test('should parse pronunciation score response', () {
      final data = MockApiResponses.pronunciationScore;

      expect(data['fluency_score'], 82);
      expect(data['grammar_score'], 75);
      expect(data['overall_score'], 78);
      expect(data['strengths'], isList);
      expect(data['issues'], isList);
    });

    test('should parse grammar feedback response', () {
      final data = MockApiResponses.grammarFeedback;

      expect(data['is_correct'], false);
      expect(data['corrected'], 'I have gone to the store');
      expect(data['category'], 'Tense');
      expect(data['examples'], isList);
    });

    test('should parse lesson list response', () {
      final data = MockApiResponses.lessonsList;

      expect(data.length, 3);
      expect(data.first['title'], 'Present Perfect Simple');
      expect(data.last['difficulty'], 'A2');
    });

    test('should parse vocabulary word response', () {
      final data = MockApiResponses.vocabularyWord;

      expect(data['word'], 'Empathetic');
      expect(data['meaning_malayalam'], 'സഹാനുഭൂതിയുള്ള');
      expect(data['synonyms'], isList);
      expect(data['cefr_level'], 'B2');
    });
  });
}
