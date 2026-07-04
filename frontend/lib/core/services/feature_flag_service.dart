import 'package:flutter/foundation.dart';

/// Predefined feature flag keys for the application.
class FeatureFlags {
  FeatureFlags._();

  // Core features
  static const String voiceChat = 'voice_chat';
  static const String mockExams = 'mock_exams';
  static const String vocabulary = 'vocabulary';
  static const String grammar = 'grammar';
  static const String writing = 'writing';
  static const String listening = 'listening';
  static const String reading = 'reading';

  // Premium features
  static const String advancedAnalytics = 'advanced_analytics';
  static const String offlineMode = 'offline_mode';
  static const String aiTutor = 'ai_tutor';
  static const String liveClasses = 'live_classes';

  // UI features
  static const String newOnboarding = 'new_onboarding';
  static const String darkMode = 'dark_mode';
  static const String animations = 'animations';

  // Experimental features
  static const String betaFeatures = 'beta_features';
  static const String aBTesting = 'ab_testing';
}

/// Service for managing feature flags.
///
/// Feature flags allow controlling feature rollout without app updates.
/// Flags can be configured remotely or locally for development.
class FeatureFlagService {
  final Map<String, bool> _flags = {};
  final Map<String, dynamic> _config = {};

  FeatureFlagService() {
    _initializeDefaults();
  }

  /// Initialize default feature flag values.
  void _initializeDefaults() {
    // Core features - enabled by default
    _flags[FeatureFlags.voiceChat] = true;
    _flags[FeatureFlags.mockExams] = true;
    _flags[FeatureFlags.vocabulary] = true;
    _flags[FeatureFlags.grammar] = true;
    _flags[FeatureFlags.writing] = true;
    _flags[FeatureFlags.listening] = true;
    _flags[FeatureFlags.reading] = true;

    // Premium features
    _flags[FeatureFlags.advancedAnalytics] = false;
    _flags[FeatureFlags.offlineMode] = false;
    _flags[FeatureFlags.aiTutor] = false;
    _flags[FeatureFlags.liveClasses] = false;

    // UI features
    _flags[FeatureFlags.newOnboarding] = true;
    _flags[FeatureFlags.darkMode] = true;
    _flags[FeatureFlags.animations] = true;

    // Experimental features
    _flags[FeatureFlags.betaFeatures] = kDebugMode;
    _flags[FeatureFlags.aBTesting] = kDebugMode;
  }

  /// Check if a feature flag is enabled.
  bool isEnabled(String flag, {bool defaultValue = false}) {
    return _flags[flag] ?? defaultValue;
  }

  /// Get a feature flag value with type casting.
  T? getValue<T>(String flag) {
    final value = _config[flag];
    if (value is T) return value;
    return null;
  }

  /// Set a feature flag value.
  void setFlag(String flag, bool value) {
    _flags[flag] = value;
  }

  /// Set multiple feature flags at once.
  void setFlags(Map<String, bool> flags) {
    _flags.addAll(flags);
  }

  /// Get all current flag values.
  Map<String, bool> getAllFlags() {
    return Map.unmodifiable(_flags);
  }

  /// Update flags from remote configuration.
  ///
  /// In production, this would fetch from a remote config service
  /// (Firebase Remote Config, LaunchDarkly, etc.).
  Future<void> updateFromRemote() async {
    // TODO: Implement remote feature flag fetching
    // Example with Firebase Remote Config:
    // final remoteConfig = FirebaseRemoteConfig.instance;
    // await remoteConfig.fetchAndActivate();
    // _flags[FeatureFlags.voiceChat] = remoteConfig.getBool('voice_chat');
  }

  /// Reset all flags to defaults.
  void resetToDefaults() {
    _flags.clear();
    _config.clear();
    _initializeDefaults();
  }

  /// Check if user has access to a premium feature.
  bool hasPremiumFeature(String feature) {
    if (feature == FeatureFlags.advancedAnalytics ||
        feature == FeatureFlags.offlineMode ||
        feature == FeatureFlags.aiTutor ||
        feature == FeatureFlags.liveClasses) {
      return isEnabled(feature);
    }
    return true;
  }
}
