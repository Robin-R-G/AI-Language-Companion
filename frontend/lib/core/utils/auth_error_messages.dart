import 'package:ai_language_coach/core/services/logger_service.dart';

/// Maps a raw authentication/network exception to a user-friendly message.
///
/// Technical details (URIs, stack traces, raw exception text) are never
/// returned to the caller — they are logged internally via [Logger] instead.
String friendlyAuthMessage(Object error, [StackTrace? stackTrace]) {
  // Log the real technical details internally for diagnostics.
  Logger.error('Auth error', error, stackTrace);

  final msg = error.toString().toLowerCase();

  if (msg.contains('invalid login credentials')) {
    return 'Invalid email or password. Please try again.';
  }
  if (msg.contains('email not confirmed') || msg.contains('not confirmed')) {
    return 'Please verify your email before logging in.';
  }
  if (msg.contains('user already registered') ||
      msg.contains('already exists')) {
    return 'An account with this email already exists.';
  }
  // Connection / configuration failures (e.g. bad URI, no host, timeouts).
  if (msg.contains('uri') ||
      msg.contains('host') ||
      msg.contains('invalid argument') ||
      msg.contains('network') ||
      msg.contains('socket') ||
      msg.contains('timeout') ||
      msg.contains('connection')) {
    return 'Unable to connect. Please check your internet connection or try '
        'again later.';
  }
  if (msg.contains('too many requests')) {
    return 'Too many attempts. Please try again later.';
  }
  if (msg.contains('password')) {
    return 'Password does not meet requirements.';
  }
  return 'Something went wrong. Please try again.';
}
