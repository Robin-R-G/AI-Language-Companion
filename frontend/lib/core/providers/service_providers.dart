import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment.dart';
import '../services/analytics_service.dart';
import '../services/app_lifecycle_service.dart';
import '../services/app_update_service.dart';
import '../services/connectivity_service.dart';
import '../services/device_info_service.dart';
import '../services/feature_flag_service.dart';
import '../services/permission_manager.dart';
import '../storage/secure_storage_service.dart';

/// Provider for the current AppEnvironment.
final environmentProvider = Provider<AppEnvironment>((ref) {
  return Environment.current;
});

/// Provider for SecureStorageService.
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Provider for PermissionManager.
final permissionManagerProvider = Provider<PermissionManager>((ref) {
  return PermissionManager();
});

/// Provider for DeviceInfoService.
final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  return DeviceInfoService();
});

/// Provider for AppUpdateService.
final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService();
});

/// Provider for FeatureFlagService.
final featureFlagServiceProvider = Provider<FeatureFlagService>((ref) {
  return FeatureFlagService();
});

/// Provider for AppLifecycleService.
///
/// Note: This is a singleton - use [Provider] not [StateProvider]
/// since the lifecycle service manages its own state internally.
final appLifecycleServiceProvider = Provider<AppLifecycleService>((ref) {
  final service = AppLifecycleService();
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for AnalyticsService.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Provider for ConnectivityService.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.startMonitoring();
  ref.onDispose(service.dispose);
  return service;
});
