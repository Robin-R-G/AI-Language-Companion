import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// A wrapper around [FlutterSecureStorage] for secure credential management.
///
/// This service uses platform-native secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences / Keystore
///
/// Use this for storing sensitive data like auth tokens, passwords,
/// and API keys. For non-sensitive data, use [LocalStorage] with Hive.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Read a value from secure storage.
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  /// Write a value to secure storage.
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // Silently fail - secure storage should never crash the app
    }
  }

  /// Delete a value from secure storage.
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // Silently fail
    }
  }

  /// Delete all values from secure storage.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {
      // Silently fail
    }
  }

  /// Check if a key exists in secure storage.
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (_) {
      return false;
    }
  }

  /// Read all key-value pairs from secure storage.
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (_) {
      return {};
    }
  }

  // Token management methods

  /// Get the user's access token.
  Future<String?> getUserToken() async {
    return read(AppConstants.userTokenKey);
  }

  /// Set the user's access token.
  Future<void> setUserToken(String token) async {
    await write(AppConstants.userTokenKey, token);
  }

  /// Get the user's refresh token.
  Future<String?> getRefreshToken() async {
    return read(AppConstants.refreshTokenKey);
  }

  /// Set the user's refresh token.
  Future<void> setRefreshToken(String token) async {
    await write(AppConstants.refreshTokenKey, token);
  }

  /// Clear all authentication tokens.
  Future<void> clearTokens() async {
    await delete(AppConstants.userTokenKey);
    await delete(AppConstants.refreshTokenKey);
  }

  /// Check if user has a stored token.
  Future<bool> hasToken() async {
    final token = await getUserToken();
    return token != null && token.isNotEmpty;
  }
}
