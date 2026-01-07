<<<<<<< HEAD
import '../../features/auth/data/models/user_model.dart';

=======
>>>>>>> origin/feature/account-management
/// Cấu trúc phản hồi chung từ API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  /// Tạo ApiResponse từ JSON
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
<<<<<<< HEAD
}

/// Phản hồi từ API xác thực (đăng nhập/đăng ký)
class AuthResponse {
  final UserModel user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  /// Tạo AuthResponse từ JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'],
    );
  }
=======
>>>>>>> origin/feature/account-management
}