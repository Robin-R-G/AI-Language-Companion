import 'dart:async';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Permission types used by the application.
enum AppPermission { camera, microphone, notifications, location }

/// Manages runtime permission requests for the application.
///
/// Wraps [permission_handler] to provide a clean interface for
/// requesting and checking permissions needed by features.
class PermissionManager {
  /// Check if a specific permission is granted.
  Future<bool> isGranted(AppPermission permission) async {
    final status = await _getPermissionStatus(permission);
    return status.isGranted;
  }

  /// Check if a specific permission is denied.
  Future<bool> isDenied(AppPermission permission) async {
    final status = await _getPermissionStatus(permission);
    return status.isDenied;
  }

  /// Check if a permission is permanently denied.
  Future<bool> isPermanentlyDenied(AppPermission permission) async {
    final status = await _getPermissionStatus(permission);
    return status.isPermanentlyDenied;
  }

  /// Request a specific permission.
  /// Returns true if permission is granted after request.
  Future<bool> request(AppPermission appPermission) async {
    final permission = _getPermissionHandler(appPermission);
    final status = await permission.request();
    return status.isGranted;
  }

  /// Request multiple permissions at once.
  /// Returns a map of permission to grant status.
  Future<Map<AppPermission, bool>> requestMultiple(
    List<AppPermission> permissions,
  ) async {
    final handlerPermissions = permissions.map(_getPermissionHandler).toList();

    final statuses = await handlerPermissions.request();

    final results = <AppPermission, bool>{};
    for (var i = 0; i < permissions.length; i++) {
      results[permissions[i]] =
          statuses[handlerPermissions[i]]?.isGranted ?? false;
    }
    return results;
  }

  /// Open app settings page for the user to manually enable permissions.
  Future<bool> openSettings() async {
    return ph.openAppSettings();
  }

  /// Get permission status for microphone (for voice features).
  Future<bool> requestMicrophonePermission() async {
    return request(AppPermission.microphone);
  }

  /// Get permission status for camera (for QR scanning).
  Future<bool> requestCameraPermission() async {
    return request(AppPermission.camera);
  }

  /// Get permission status for notifications.
  Future<bool> requestNotificationPermission() async {
    return request(AppPermission.notifications);
  }

  /// Check if all required permissions for voice features are granted.
  Future<bool> hasVoicePermissions() async {
    final micGranted = await isGranted(AppPermission.microphone);
    return micGranted;
  }

  /// Get the current status of a permission.
  Future<ph.PermissionStatus> _getPermissionStatus(
    AppPermission permission,
  ) async {
    final perm = _getPermissionHandler(permission);
    return perm.status;
  }

  /// Map [AppPermission] to [permission_handler] Permission.
  ph.Permission _getPermissionHandler(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return ph.Permission.camera;
      case AppPermission.microphone:
        return ph.Permission.microphone;
      case AppPermission.notifications:
        return ph.Permission.notification;
      case AppPermission.location:
        return ph.Permission.location;
    }
  }
}
