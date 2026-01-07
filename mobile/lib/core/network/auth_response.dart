import '../../features/auth/data/models/user_model.dart';

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
}