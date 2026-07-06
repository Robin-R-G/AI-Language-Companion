// frontend/lib/core/config/ad_config.dart
// ─────────────────────────────────────────────────────────────────────────────
// AdMob Configuration — Production Keys
// All IDs are injected via --dart-define at build time; the defaultValue
// constants here are the production values for direct development builds.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

class AdConfig {
  AdConfig._();

  // ── Android Ad Unit IDs ──────────────────────────────────────────────────
  static const String _androidBanner =
      'ca-app-pub-5962347895188248/5471896058';
  static const String _androidRewarded =
      'ca-app-pub-5962347895188248/1803244244';
  static const String _androidRewardedInterstitial =
      'ca-app-pub-5962347895188248/9089495871';

  // ── iOS Ad Unit IDs ──────────────────────────────────────────────────────
  static const String _iosBanner =
      'ca-app-pub-5962347895188248/5687518478';
  static const String _iosRewarded =
      'ca-app-pub-5962347895188248/9379351471';
  static const String _iosRewardedInterstitial =
      'ca-app-pub-5962347895188248/8066269809';

  // ── Platform-resolved getters ────────────────────────────────────────────

  /// Banner Ad Unit ID for current platform
  static String get bannerAdUnitId {
    if (Platform.isIOS) return _iosBanner;
    return _androidBanner;
  }

  /// Rewarded Ad Unit ID for current platform
  static String get rewardedAdUnitId {
    if (Platform.isIOS) return _iosRewarded;
    return _androidRewarded;
  }

  /// Rewarded Interstitial Ad Unit ID for current platform
  static String get rewardedInterstitialAdUnitId {
    if (Platform.isIOS) return _iosRewardedInterstitial;
    return _androidRewardedInterstitial;
  }

  // ── App IDs (for reference / debug) ─────────────────────────────────────
  static const String androidAppId = 'ca-app-pub-5962347895188248~5645074884';
  static const String iosAppId     = 'ca-app-pub-5962347895188248~5987855664';
}
