import 'package:flutter/foundation.dart';

/// Centralized logging service for the application.
/// In production, this should integrate with Firebase Crashlytics.
class Logger {
  static void debug(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('[WARNING] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[ERROR] $message');
      if (error != null) {
        print('[ERROR] Details: $error');
      }
      if (stackTrace != null) {
        print('[ERROR] Stack trace: $stackTrace');
      }
    }
    // In production, log to Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
  }

  static void logEvent(String name, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      print('[EVENT] $name: $parameters');
    }
    // In production, log to Analytics
    // FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
  }
}
