// frontend/lib/shared/widgets/ad_banner_widget.dart
// ─────────────────────────────────────────────────────────────────────────────
// AdBannerWidget — reusable banner ad widget
// Shows a real AdMob banner on Android/iOS, renders nothing on web/desktop.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize size;

  const AdBannerWidget({
    super.key,
    this.size = AdSize.banner,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _initAd();
  }

  void _initAd() {
    // Only render on mobile platforms
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;

    _ad = AdService._instance.createBannerAd(
      size: widget.size,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _loaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return const SizedBox.shrink();
    }

    if (!_loaded || _ad == null) {
      return SizedBox(
        height: widget.size.height.toDouble(),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
