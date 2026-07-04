import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// Local storage utility using Hive for cached data and
/// FlutterSecureStorage (Keychain/Keystore) for sensitive tokens.
class LocalStorage {
  static late Box<dynamic> _box;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Initialize Hive.
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('ai_language_coach');
  }

  // Token Management (stored in platform secure storage)
  static Future<String?> getUserToken() async {
    return await _secureStorage.read(key: AppConstants.userTokenKey);
  }

  static Future<void> setUserToken(String token) async {
    await _secureStorage.write(key: AppConstants.userTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  static Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.userTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  // User Profile
  static Map<String, dynamic>? getUserProfile() {
    final data = _box.get(AppConstants.userProfileKey);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static Future<void> setUserProfile(Map<String, dynamic> profile) async {
    await _box.put(AppConstants.userProfileKey, profile);
  }

  static Future<void> clearUserProfile() async {
    await _box.delete(AppConstants.userProfileKey);
  }

  // Onboarding
  static bool isOnboardingComplete() {
    final value = _box.get(AppConstants.onboardingCompleteKey);
    return value as bool? ?? false;
  }

  static Future<void> setOnboardingComplete(bool value) async {
    await _box.put(AppConstants.onboardingCompleteKey, value);
  }

  // Theme Mode
  static ThemeMode getThemeMode() {
    final value = _box.get(AppConstants.themeModeKey);
    final mode = value as String? ?? 'system';
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _box.put(AppConstants.themeModeKey, value);
  }

  // Generic Storage
  static dynamic getData(String key) {
    return _box.get(key);
  }

  static Future<void> setData(String key, dynamic value) async {
    await _box.put(key, value);
  }

  static Future<void> removeData(String key) async {
    await _box.delete(key);
  }

  // Clear All Data
  static Future<void> clearAll() async {
    await _box.clear();
    await _secureStorage.deleteAll();
  }
}
