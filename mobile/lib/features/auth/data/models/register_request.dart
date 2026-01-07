/// Model yêu cầu đăng ký
class RegisterRequest {
  final String fullName;
  final String phone;
  final String email;
  final String password;

  RegisterRequest({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
  });

  /// Chuyển thành JSON để gửi API
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
    };
  }
}