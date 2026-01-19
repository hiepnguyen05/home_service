/// Định nghĩa các loại exception trong ứng dụng
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => message;
}

/// Lỗi mạng
class NetworkException extends AppException {
  const NetworkException(String message, {String? code}) 
      : super(message, code: code);
}

/// Lỗi xác thực
class AuthException extends AppException {
  const AuthException(String message, {String? code}) 
      : super(message, code: code);
}

/// Lỗi Firebase (đổi tên để tránh xung đột)
class AppFirebaseException extends AppException {
  const AppFirebaseException(String message, {String? code}) 
      : super(message, code: code);
}

/// Lỗi Storage
class StorageException extends AppException {
  const StorageException(String message, {String? code}) 
      : super(message, code: code);
}

/// Lỗi validation
class ValidationException extends AppException {
  const ValidationException(String message, {String? code}) 
      : super(message, code: code);
}

/// Lỗi không tìm thấy
class NotFoundException extends AppException {
  const NotFoundException(String message, {String? code}) 
      : super(message, code: code);
}

/// Lỗi không có quyền
class UnauthorizedException extends AppException {
  const UnauthorizedException(String message, {String? code}) 
      : super(message, code: code);
}

/// Lỗi server
class ServerException extends AppException {
  const ServerException(String message, {String? code}) 
      : super(message, code: code);
}

/// Lỗi timeout (đổi tên để tránh xung đột)
class AppTimeoutException extends AppException {
  const AppTimeoutException(String message, {String? code}) 
      : super(message, code: code);
}

/// Lỗi không xác định
class UnknownException extends AppException {
  const UnknownException(String message, {String? code}) 
      : super(message, code: code);
}