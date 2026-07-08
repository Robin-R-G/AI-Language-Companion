import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supported application environments/flavors.
enum AppEnvironment { dev, staging, production }

/// Environment-based configuration for the application.
///
/// Reads environment variables from .env file loaded at runtime.
class Environment {
  const Environment._();

  /// Current build environment.
  static AppEnvironment get current => _fromEnvironment();

  /// Supabase project URL.
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous/public key.
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// RevenueCat API key for in-app purchases.
  static String get revenueCatApiKey => dotenv.env['REVENUECAT_API_KEY'] ?? '';

  /// Firebase project ID.
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  /// LiveKit server URL for voice features.
  static String get liveKitUrl => dotenv.env['LIVEKIT_URL'] ?? '';

  /// LiveKit API key.
  static String get liveKitApiKey => dotenv.env['LIVEKIT_API_KEY'] ?? '';

  /// Whether analytics and crash reporting should be enabled.
  static bool get enableAnalytics =>
      current == AppEnvironment.staging || current == AppEnvironment.production;

  /// Whether debug logging should be enabled.
  static bool get enableDebugLogging => current == AppEnvironment.dev;

  /// Whether to use mock services (for testing/development).
  static bool get useMockServices => current == AppEnvironment.dev;

  /// Base URL for API requests.
  static String get apiBaseUrl {
    switch (current) {
      case AppEnvironment.dev:
        return 'http://localhost:54321/functions/v1';
      case AppEnvironment.staging:
        return 'https://staging-api.ailanguagecoach.com/functions/v1';
      case AppEnvironment.production:
        return 'https://api.ailanguagecoach.com/functions/v1';
    }
  }

  /// Parse environment from compile-time constant.
  static AppEnvironment _fromEnvironment() {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
    switch (env.toLowerCase()) {
      case 'staging':
        return AppEnvironment.staging;
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      default:
        return AppEnvironment.dev;
    }
  }

  /// Print current environment configuration (debug only).
  static void printConfig() {
    if (!kDebugMode) return;
    debugPrint('=== Environment Configuration ===');
    debugPrint('Environment: ${current.name}');
    debugPrint('Supabase URL: $supabaseUrl');
    debugPrint('API Base URL: $apiBaseUrl');
    debugPrint('Analytics Enabled: $enableAnalytics');
    debugPrint('Debug Logging: $enableDebugLogging');
    debugPrint('Mock Services: $useMockServices');
    debugPrint('=================================');
  }
}
