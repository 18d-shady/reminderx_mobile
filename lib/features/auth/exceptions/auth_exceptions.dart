class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class NetworkException extends AuthException {
  NetworkException() : super('Network connection error. Please check your internet connection.', code: 'NETWORK_ERROR');
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Invalid username or password.', code: 'INVALID_CREDENTIALS');
}

class TokenExpiredException extends AuthException {
  TokenExpiredException() : super('Your session has expired. Please login again.', code: 'TOKEN_EXPIRED');
}

class ServerException extends AuthException {
  ServerException() : super('Server error. Please try again later.', code: 'SERVER_ERROR');
}

class UnknownException extends AuthException {
  UnknownException() : super('An unexpected error occurred. Please try again.', code: 'UNKNOWN_ERROR');
} 