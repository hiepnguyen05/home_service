import '../../../../core/network/api_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../services/auth_api_service.dart';

/// Repository xử lý dữ liệu xác thực
class AuthRepository {
  /// Đăng nhập với email/số điện thoại và mật khẩu
  Future<ApiResponse<AuthResponse>> login(String identifier, String password) async {
    final request = LoginRequest(identifier: identifier, password: password);
    return await AuthApiService.login(request);
  }

  /// Đăng ký tài khoản mới
  Future<ApiResponse<AuthResponse>> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final request = RegisterRequest(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
    );
    return await AuthApiService.register(request);
  }
}