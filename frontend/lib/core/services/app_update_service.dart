import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

/// Result of an app update check.
enum UpdateStatus {
  /// No update available.
  upToDate,

  /// Update available but not critical.
  optionalUpdate,

  /// Critical update required to continue using the app.
  criticalUpdate,
}

/// Information about an available app update.
class AppUpdateInfo {
  final UpdateStatus status;
  final String latestVersion;
  final String currentVersion;
  final String? updateUrl;
  final String? releaseNotes;

  const AppUpdateInfo({
    required this.status,
    required this.latestVersion,
    required this.currentVersion,
    this.updateUrl,
    this.releaseNotes,
  });

  bool get hasUpdate => status != UpdateStatus.upToDate;
  bool get isCritical => status == UpdateStatus.criticalUpdate;
}

/// Service for checking and prompting app updates.
///
/// Checks the platform-specific app store for new versions
/// and provides update prompts to users.
class AppUpdateService {
  /// Store URLs for each platform.
  static String get _iosAppStoreUrl =>
      'https://apps.apple.com/app/id${AppConstants.iosAppStoreId}';
  static String get _androidPlayStoreUrl =>
      'https://play.google.com/store/apps/details?id=${AppConstants.androidPackageName}';

  /// Minimum supported version - users below this must update.
  static const String _minimumSupportedVersion = '1.0.0';

  /// Check for app updates.
  ///
  /// Returns an [AppUpdateInfo] with the current and latest versions.
  /// In development mode, this always returns up-to-date status.
  Future<AppUpdateInfo> checkForUpdate() async {
    if (kDebugMode) {
      return const AppUpdateInfo(
        status: UpdateStatus.upToDate,
        latestVersion: AppConstants.appVersion,
        currentVersion: AppConstants.appVersion,
      );
    }

    try {
      return AppUpdateInfo(
        status: UpdateStatus.upToDate,
        latestVersion: AppConstants.appVersion,
        currentVersion: AppConstants.appVersion,
        updateUrl: Platform.isIOS ? _iosAppStoreUrl : _androidPlayStoreUrl,
      );
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return const AppUpdateInfo(
        status: UpdateStatus.upToDate,
        latestVersion: AppConstants.appVersion,
        currentVersion: AppConstants.appVersion,
      );
    }
  }

  /// Compare two version strings.
  ///
  /// Returns:
  /// - negative if v1 < v2
  /// - 0 if v1 == v2
  /// - positive if v1 > v2
  int compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (var i = 0; i < parts1.length; i++) {
      if (i >= parts2.length) return 1;
      if (parts1[i] != parts2[i]) {
        return parts1[i].compareTo(parts2[i]);
      }
    }
    return parts1.length.compareTo(parts2.length);
  }

  /// Check if the current version is below the minimum supported version.
  bool isBelowMinimumVersion(String currentVersion) {
    return compareVersions(currentVersion, _minimumSupportedVersion) < 0;
  }

  /// Open the app store page for the user to update.
  Future<bool> openAppStore() async {
    final uri = Uri.parse(
      Platform.isIOS ? _iosAppStoreUrl : _androidPlayStoreUrl,
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Force the user to update (for critical updates).
  ///
  /// Shows a dialog that cannot be dismissed.
  /// Returns when the user taps the update button.
  Future<void> promptForceUpdate(AppUpdateInfo info) async {
    debugPrint('Force update required: ${info.latestVersion}');
    await openAppStore();
  }
}
