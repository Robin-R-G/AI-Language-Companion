import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/services/feature_flag_service.dart';

void main() {
  late FeatureFlagService featureFlagService;

  setUp(() {
    featureFlagService = FeatureFlagService();
  });

  group('Feature Flag Service', () {
    test('should initialize with default flags', () {
      expect(featureFlagService.isEnabled(FeatureFlags.voiceChat), isTrue);
      expect(featureFlagService.isEnabled(FeatureFlags.mockExams), isTrue);
      expect(featureFlagService.isEnabled(FeatureFlags.vocabulary), isTrue);
      expect(featureFlagService.isEnabled(FeatureFlags.advancedAnalytics),
          isFalse);
      expect(featureFlagService.isEnabled(FeatureFlags.offlineMode), isFalse);
    });

    test('should set a flag', () {
      featureFlagService.setFlag(FeatureFlags.offlineMode, true);

      expect(featureFlagService.isEnabled(FeatureFlags.offlineMode), isTrue);
    });

    test('should set multiple flags', () {
      featureFlagService.setFlags({
        FeatureFlags.offlineMode: true,
        FeatureFlags.aiTutor: true,
        FeatureFlags.liveClasses: true,
      });

      expect(featureFlagService.isEnabled(FeatureFlags.offlineMode), isTrue);
      expect(featureFlagService.isEnabled(FeatureFlags.aiTutor), isTrue);
      expect(featureFlagService.isEnabled(FeatureFlags.liveClasses), isTrue);
    });

    test('should get all flags', () {
      final flags = featureFlagService.getAllFlags();

      expect(flags, isA<Map<String, bool>>());
      expect(flags.containsKey(FeatureFlags.voiceChat), isTrue);
      expect(flags.containsKey(FeatureFlags.offlineMode), isTrue);
    });

    test('should reset to defaults', () {
      featureFlagService.setFlag(FeatureFlags.offlineMode, true);

      featureFlagService.resetToDefaults();

      expect(featureFlagService.isEnabled(FeatureFlags.offlineMode), isFalse);
    });

    test('should return default value for unknown flag', () {
      expect(featureFlagService.isEnabled('unknown_flag'), isFalse);
      expect(
        featureFlagService.isEnabled('unknown_flag', defaultValue: true),
        isTrue,
      );
    });

    test('should get typed value', () {
      featureFlagService.setFlag(FeatureFlags.voiceChat, true);

      final value = featureFlagService.getValue<bool>(FeatureFlags.voiceChat);
      expect(value, isTrue);
    });

    test('premium features should be gated', () {
      expect(
        featureFlagService.hasPremiumFeature(FeatureFlags.advancedAnalytics),
        isFalse,
      );

      featureFlagService.setFlag(FeatureFlags.advancedAnalytics, true);

      expect(
        featureFlagService.hasPremiumFeature(FeatureFlags.advancedAnalytics),
        isTrue,
      );
    });

    test('non-premium features should always be accessible', () {
      featureFlagService.setFlag(FeatureFlags.voiceChat, false);

      expect(featureFlagService.hasPremiumFeature(FeatureFlags.voiceChat),
          isTrue);
    });
  });
}
