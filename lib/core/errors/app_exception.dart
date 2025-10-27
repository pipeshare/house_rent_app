// lib/core/errors/exceptions.dart
class AppException implements Exception {
  final String message;
  final String code;

  const AppException(this.message, {this.code = 'UNKNOWN'});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException(String message)
      : super(message, code: 'NETWORK_ERROR');
}

class FirebaseAuthException extends AppException {
  const FirebaseAuthException(String message, String code)
      : super(message, code: code);
}

class StorageException extends AppException {
  const StorageException(String message, String code)
      : super(message, code: code);
}

class ValidationException extends AppException {
  const ValidationException(String message)
      : super(message, code: 'VALIDATION_ERROR');
}

// lib/core/errors/failures.dart
class Failure {
  final String message;
  final String code;

  Failure(this.message, {this.code = 'UNKNOWN'});

  @override
  String toString() => 'Failure: $message (code: $code)';
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message, code: 'NETWORK_ERROR');
}

class AuthFailure extends Failure {
  AuthFailure(String message, String code) : super(message, code: code);
}

class StorageFailure extends Failure {
  StorageFailure(String message, String code) : super(message, code: code);
}
