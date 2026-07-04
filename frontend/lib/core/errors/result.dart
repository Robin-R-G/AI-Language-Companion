import 'failure.dart';

/// A Result type that encapsulates either a success value or a Failure.
/// This prevents raw exceptions from leaking into the UI layer.
class Result<T> {
  final T? _value;
  final Failure? _failure;

  const Result.success(T value) : _value = value, _failure = null;
  const Result.error(Failure failure) : _value = null, _failure = failure;

  /// Returns true if this Result contains a success value.
  bool get isSuccess => _failure == null;

  /// Returns true if this Result contains a Failure.
  bool get isFailure => _failure != null;

  /// Returns the success value, or throws if this is an error Result.
  T get value {
    if (isFailure) {
      throw StateError('Cannot get value from an error Result');
    }
    return _value as T;
  }

  /// Returns the Failure, or throws if this is a success Result.
  Failure get failure {
    if (isSuccess) {
      throw StateError('Cannot get failure from a success Result');
    }
    return _failure!;
  }

  /// Folds the Result by calling onError for failure or onSuccess for success.
  R fold<R>(R Function(Failure failure) onError, R Function(T value) onSuccess) {
    if (isFailure) {
      return onError(_failure!);
    }
    return onSuccess(_value as T);
  }

  /// Maps the success value to a new value using the provided function.
  Result<R> map<R>(R Function(T value) transform) {
    if (isFailure) {
      return Result.error(_failure!);
    }
    return Result.success(transform(_value as T));
  }

  /// Returns the value if success, or the defaultValue if error.
  T getOrElse(T Function() defaultValue) {
    if (isSuccess) {
      return _value as T;
    }
    return defaultValue();
  }

  /// Returns the value if success, or null if error.
  T? getOrNull() {
    if (isSuccess) {
      return _value as T;
    }
    return null;
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success($_value)';
    }
    return 'Result.error($_failure)';
  }
}
