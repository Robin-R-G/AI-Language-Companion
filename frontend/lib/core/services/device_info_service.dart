import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../constants/app_constants.dart';

/// Device information and platform details for the application.
class DeviceInfo {
  final String deviceId;
  final String deviceModel;
  final String deviceBrand;
  final String osName;
  final String osVersion;
  final String appVersion;
  final String buildNumber;
  final bool isPhysicalDevice;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceModel,
    required this.deviceBrand,
    required this.osName,
    required this.osVersion,
    required this.appVersion,
    required this.buildNumber,
    required this.isPhysicalDevice,
  });

  /// Full OS string (e.g., "iOS 16.0" or "Android 13").
  String get osString => '$osName $osVersion';

  /// Full device string (e.g., "Apple iPhone 14 Pro" or "Samsung Galaxy S23").
  String get deviceString => '$deviceBrand $deviceModel';

  /// Convert to map for analytics or logging.
  Map<String, dynamic> toMap() => {
    'device_id': deviceId,
    'device_model': deviceModel,
    'device_brand': deviceBrand,
    'os_name': osName,
    'os_version': osVersion,
    'app_version': appVersion,
    'build_number': buildNumber,
    'is_physical_device': isPhysicalDevice,
  };
}

/// Service for retrieving device information and platform details.
///
/// Used for analytics, crash reporting, and device-specific behavior.
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin;

  DeviceInfoService({DeviceInfoPlugin? deviceInfoPlugin})
    : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  /// Cached device info to avoid repeated platform calls.
  DeviceInfo? _cachedInfo;

  /// Get device information.
  ///
  /// Results are cached after first call since device info
  /// doesn't change during app lifecycle.
  Future<DeviceInfo> getDeviceInfo() async {
    if (_cachedInfo != null) return _cachedInfo!;

    if (Platform.isAndroid) {
      return _getAndroidInfo();
    } else if (Platform.isIOS) {
      return _getIOSInfo();
    }

    // Fallback for other platforms
    return const DeviceInfo(
      deviceId: 'unknown',
      deviceModel: 'unknown',
      deviceBrand: 'unknown',
      osName: 'unknown',
      osVersion: '',
      appVersion: AppConstants.appVersion,
      buildNumber: '1',
      isPhysicalDevice: true,
    );
  }

  /// Get Android-specific device information.
  Future<DeviceInfo> _getAndroidInfo() async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;
    final info = DeviceInfo(
      deviceId: androidInfo.id,
      deviceModel: androidInfo.model,
      deviceBrand: androidInfo.brand,
      osName: 'Android',
      osVersion: androidInfo.version.release,
      appVersion: AppConstants.appVersion,
      buildNumber: androidInfo.version.sdkInt.toString(),
      isPhysicalDevice: androidInfo.isPhysicalDevice,
    );
    _cachedInfo = info;
    return info;
  }

  /// Get iOS-specific device information.
  Future<DeviceInfo> _getIOSInfo() async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;
    final info = DeviceInfo(
      deviceId: iosInfo.identifierForVendor ?? 'unknown',
      deviceModel: iosInfo.name,
      deviceBrand: 'Apple',
      osName: 'iOS',
      osVersion: iosInfo.systemVersion,
      appVersion: AppConstants.appVersion,
      buildNumber: iosInfo.systemVersion,
      isPhysicalDevice: iosInfo.isPhysicalDevice,
    );
    _cachedInfo = info;
    return info;
  }

  /// Clear cached device info (for testing).
  void clearCache() {
    _cachedInfo = null;
  }
}
