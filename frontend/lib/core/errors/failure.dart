/// Base failure class for domain layer error handling.
/// All failures should extend this class to maintain consistency.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Database-related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// AI service-related failures
class AIServiceFailure extends Failure {
  const AIServiceFailure(super.message, {super.code});
}

/// Voice service-related failures
class VoiceServiceFailure extends Failure {
  const VoiceServiceFailure(super.message, {super.code});
}

/// Payment-related failures
class PaymentFailure extends Failure {
  const PaymentFailure(super.message, {super.code});
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
