import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// Local storage utility using Hive for caching data.
class LocalStorage {
  static late Box<dynamic> _box;
  static late Box<dynamic> _secureBox;

  /// Initialize Hive and open required boxes.
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('ai_language_coach');
    _secureBox = await Hive.openBox('secure_storage');
  }

  // Token Management
  static String? getUserToken() {
    final value = _secureBox.get(AppConstants.userTokenKey);
    return value as String?;
  }

  static Future<void> setUserToken(String token) async {
    await _secureBox.put(AppConstants.userTokenKey, token);
  }

  static String? getRefreshToken() {
    final value = _secureBox.get(AppConstants.refreshTokenKey);
    return value as String?;
  }

  static Future<void> setRefreshToken(String token) async {
    await _secureBox.put(AppConstants.refreshTokenKey, token);
  }

  static Future<void> clearTokens() async {
    await _secureBox.delete(AppConstants.userTokenKey);
    await _secureBox.delete(AppConstants.refreshTokenKey);
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
    await _secureBox.clear();
  }
}
