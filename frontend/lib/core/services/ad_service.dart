// frontend/lib/core/services/ad_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// AdService — Production Google Mobile Ads integration
// Handles: initialization, banner ads, rewarded ads, rewarded interstitial ads
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/ad_config.dart';

// ── Provider ─────────────────────────────────────────────────────────────────
final adServiceProvider = Provider<AdService>((ref) => AdService._instance);

// ── AdLoadState ──────────────────────────────────────────────────────────────
enum AdLoadState { idle, loading, loaded, failed }

// ── AdService ─────────────────────────────────────────────────────────────────
class AdService {
  AdService._();
  static final AdService _instance = AdService._();

  bool _initialized = false;

  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;

  AdLoadState rewardedState = AdLoadState.idle;
  AdLoadState rewardedInterstitialState = AdLoadState.idle;

  // ── Initialization ─────────────────────────────────────────────────────────
  Future<void> initialize() async {
    // Ads only run on Android / iOS — skip on web/desktop
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    if (_initialized) return;

    await MobileAds.instance.initialize();
    _initialized = true;

    // Pre-load both rewarded formats immediately after init
    await Future.wait([
      _loadRewarded(),
      _loadRewardedInterstitial(),
    ]);
  }

  // ── Banner Ad ──────────────────────────────────────────────────────────────
  /// Creates a new [BannerAd]. Caller must call [dispose()] on it.
  BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    BannerAdListener? listener,
  }) {
    return BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: listener ??
          BannerAdListener(
            onAdLoaded: (_) => debugPrint('[AdService] Banner loaded'),
            onAdFailedToLoad: (ad, error) {
              debugPrint('[AdService] Banner failed: $error');
              ad.dispose();
            },
          ),
    );
  }

  // ── Rewarded Ad ────────────────────────────────────────────────────────────
  Future<void> _loadRewarded() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    rewardedState = AdLoadState.loading;

    await RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          rewardedState = AdLoadState.loaded;
          debugPrint('[AdService] Rewarded loaded');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          rewardedState = AdLoadState.failed;
          debugPrint('[AdService] Rewarded failed: $error');
        },
      ),
    );
  }

  /// Shows a rewarded ad. Calls [onRewarded] with the reward amount on success.
  /// Returns false if the ad isn't ready.
  Future<bool> showRewarded({
    required void Function(int credits) onRewarded,
    VoidCallback? onAdClosed,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      // On unsupported platforms, simulate a reward for dev convenience
      onRewarded(10);
      return true;
    }

    if (_rewardedAd == null) {
      await _loadRewarded();
    }

    final ad = _rewardedAd;
    if (ad == null) return false;

    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        rewardedState = AdLoadState.idle;
        onAdClosed?.call();
        // Pre-load next ad
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        rewardedState = AdLoadState.idle;
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await ad.show(
      onUserEarnedReward: (_, reward) {
        // reward.amount is a num, convert to int credits
        onRewarded(reward.amount.toInt());
      },
    );

    return completer.future;
  }

  // ── Rewarded Interstitial Ad ───────────────────────────────────────────────
  Future<void> _loadRewardedInterstitial() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    rewardedInterstitialState = AdLoadState.loading;

    await RewardedInterstitialAd.load(
      adUnitId: AdConfig.rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          rewardedInterstitialState = AdLoadState.loaded;
          debugPrint('[AdService] Rewarded Interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          _rewardedInterstitialAd = null;
          rewardedInterstitialState = AdLoadState.failed;
          debugPrint('[AdService] Rewarded Interstitial failed: $error');
        },
      ),
    );
  }

  /// Shows a rewarded interstitial (unskippable mid-session ad).
  /// Calls [onRewarded] with credits on success.
  Future<bool> showRewardedInterstitial({
    required void Function(int credits) onRewarded,
    VoidCallback? onAdClosed,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      onRewarded(20);
      return true;
    }

    if (_rewardedInterstitialAd == null) {
      await _loadRewardedInterstitial();
    }

    final ad = _rewardedInterstitialAd;
    if (ad == null) return false;

    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        rewardedInterstitialState = AdLoadState.idle;
        onAdClosed?.call();
        _loadRewardedInterstitial();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        rewardedInterstitialState = AdLoadState.idle;
        _loadRewardedInterstitial();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await ad.show(
      onUserEarnedReward: (_, reward) {
        onRewarded(reward.amount.toInt());
      },
    );

    return completer.future;
  }

  // ── Is ready checks ────────────────────────────────────────────────────────
  bool get isRewardedReady =>
      _rewardedAd != null && rewardedState == AdLoadState.loaded;

  bool get isRewardedInterstitialReady =>
      _rewardedInterstitialAd != null &&
      rewardedInterstitialState == AdLoadState.loaded;

  // ── Dispose ────────────────────────────────────────────────────────────────
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    _rewardedAd = null;
    _rewardedInterstitialAd = null;
  }
}
