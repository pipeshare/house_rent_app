// lib/core/errors/exceptions.dart
class AppException implements Exception {
  final String message;
  final String code;

  const AppException(this.message, {this.code = 'UNKNOWN'});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException(super.message) : super(code: 'NETWORK_ERROR');
}

class FirebaseAuthException extends AppException {
  const FirebaseAuthException(super.message, String code) : super(code: code);
}

class StorageException extends AppException {
  const StorageException(super.message, String code) : super(code: code);
}

class ValidationException extends AppException {
  const ValidationException(super.message) : super(code: 'VALIDATION_ERROR');
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
  NetworkFailure(super.message) : super(code: 'NETWORK_ERROR');
}

class AuthFailure extends Failure {
  AuthFailure(super.message, String code) : super(code: code);
}

class StorageFailure extends Failure {
  StorageFailure(super.message, String code) : super(code: code);
}
