import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import '../../test_utils/fake_services.dart';

void main() {
  late FakeSubscriptionRepository fakeSubscriptionRepository;

  setUp(() {
    fakeSubscriptionRepository = FakeSubscriptionRepository();
  });

  group('Subscription Flow', () {
    test('should get current subscription (free tier)', () async {
      final result = await fakeSubscriptionRepository.getCurrentSubscription();

      expect(result.isSuccess, isTrue);
      expect(result.value.planId, 'free');
      expect(result.value.status, 'active');
    });

    test('should get available plans', () async {
      final result = await fakeSubscriptionRepository.getPlans();

      expect(result.isSuccess, isTrue);
      expect(result.value.length, 2);
      expect(result.value.first.name, 'Free');
      expect(result.value.last.name, 'Premium');
    });

    test('should purchase premium plan', () async {
      final result = await fakeSubscriptionRepository.purchase(
        'premium',
        'com.ailanguagecoach.premium.monthly',
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.planId, 'premium');
    });

    test('should restore purchases', () async {
      final result = await fakeSubscriptionRepository.restorePurchases();

      expect(result.isSuccess, isTrue);
    });

    test('should cancel subscription', () async {
      await fakeSubscriptionRepository.purchase('premium', 'store_id');

      final result = await fakeSubscriptionRepository.cancelSubscription();

      expect(result.isSuccess, isTrue);
    });

    test('should check feature access (free tier)', () async {
      final result = await fakeSubscriptionRepository.checkFeatureAccess(
        'advanced_analytics',
      );

      expect(result.isSuccess, isTrue);
      expect(result.value, isFalse);
    });

    test('should check feature access (premium tier)', () async {
      fakeSubscriptionRepository.setCurrentPlan('premium');

      final result = await fakeSubscriptionRepository.checkFeatureAccess(
        'advanced_analytics',
      );

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });

    test('should handle purchase failure', () async {
      fakeSubscriptionRepository.setShouldFail(true);

      final result = await fakeSubscriptionRepository.purchase(
        'premium',
        'store_id',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<PaymentFailure>());
    });

    test('should handle restore failure', () async {
      fakeSubscriptionRepository.setShouldFail(true);

      final result = await fakeSubscriptionRepository.restorePurchases();

      expect(result.isFailure, isTrue);
    });

    test('should update plan after purchase', () async {
      await fakeSubscriptionRepository.purchase('premium', 'store_id');

      final sub = await fakeSubscriptionRepository.getCurrentSubscription();
      expect(sub.value.planId, 'premium');
    });
  });

  group('Subscription State Transitions', () {
    test('free -> premium -> free transition', () async {
      expect(
        (await fakeSubscriptionRepository.getCurrentSubscription()).value.planId,
        'free',
      );

      await fakeSubscriptionRepository.purchase('premium', 'store_id');
      expect(
        (await fakeSubscriptionRepository.getCurrentSubscription()).value.planId,
        'premium',
      );

      await fakeSubscriptionRepository.cancelSubscription();
      expect(
        (await fakeSubscriptionRepository.getCurrentSubscription()).value.planId,
        'free',
      );
    });

    test('premium user has access to premium features', () async {
      fakeSubscriptionRepository.setCurrentPlan('premium');

      final voiceAccess =
          await fakeSubscriptionRepository.checkFeatureAccess('voice_chat');
      final analyticsAccess =
          await fakeSubscriptionRepository.checkFeatureAccess('advanced_analytics');

      expect(voiceAccess.value, isTrue);
      expect(analyticsAccess.value, isTrue);
    });

    test('free user lacks premium features', () async {
      final voiceAccess =
          await fakeSubscriptionRepository.checkFeatureAccess('voice_chat');
      final analyticsAccess =
          await fakeSubscriptionRepository.checkFeatureAccess('advanced_analytics');

      expect(voiceAccess.value, isFalse);
      expect(analyticsAccess.value, isFalse);
    });
  });
}
