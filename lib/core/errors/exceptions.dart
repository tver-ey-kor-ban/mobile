/// Base exception class for API errors
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Exception for 401 Unauthorized errors
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException({required this.message});

  @override
  String toString() => message;
}

/// Exception for 404 Not Found errors
class NotFoundException implements Exception {
  final String message;

  NotFoundException({required this.message});

  @override
  String toString() => message;
}

/// Exception for 422 Validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ValidationException(this.message, {this.errors});

  @override
  String toString() => message;
}
