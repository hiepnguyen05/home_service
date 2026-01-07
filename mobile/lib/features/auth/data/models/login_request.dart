/// Model yêu cầu đăng nhập
class LoginRequest {
  final String identifier; // email hoặc số điện thoại
  final String password;

  LoginRequest({
    required this.identifier,
    required this.password,
  });

  /// Chuyển thành JSON để gửi API
  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'password': password,
    };
  }
}