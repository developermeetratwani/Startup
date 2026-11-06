sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}
final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}
final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}
final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}
