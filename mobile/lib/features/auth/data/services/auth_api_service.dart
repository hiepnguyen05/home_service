import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

/// Service xử lý API xác thực
class AuthApiService {
  static const String _authEndpoint = '/api/auth';

  /// Gọi API đăng nhập
  static Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      print('Đang gọi API đăng nhập...');
      print('Request data: ${request.toJson()}');
      
      final response = await ApiClient.post(
        '$_authEndpoint/login',
        body: request.toJson(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Đăng nhập thành công');
        
        // Backend trả về user và token ở root level, không phải trong data
        final authResponse = AuthResponse(
          user: UserModel.fromJson(jsonData['user']),
          token: jsonData['token'],
        );
        
        return ApiResponse<AuthResponse>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Đăng nhập thành công',
          data: authResponse,
        );
      } else {
        print('Đăng nhập thất bại: ${response.statusCode}');
        return ApiResponse<AuthResponse>(
          success: false,
          message: jsonData['message'] ?? 'Đăng nhập thất bại',
          errors: jsonData['errors'] != null ? List<String>.from(jsonData['errors']) : null,
        );
      }
    } catch (e) {
      print('Lỗi trong AuthApiService.login: $e');
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.',
      );
    }
  }

  /// Gọi API đăng ký
  static Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    try {
      print('Đang gọi API đăng ký...');
      print('Request data: ${request.toJson()}');
      
      final response = await ApiClient.post(
        '$_authEndpoint/register',
        body: request.toJson(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print('Đăng ký thành công');
        
        // Backend trả về user và token ở root level, không phải trong data
        final authResponse = AuthResponse(
          user: UserModel.fromJson(jsonData['user']),
          token: jsonData['token'],
        );
        
        return ApiResponse<AuthResponse>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Đăng ký thành công',
          data: authResponse,
        );
      } else {
        print('Đăng ký thất bại: ${response.statusCode}');
        return ApiResponse<AuthResponse>(
          success: false,
          message: jsonData['message'] ?? 'Đăng ký thất bại',
          errors: jsonData['errors'] != null ? List<String>.from(jsonData['errors']) : null,
        );
      }
    } catch (e) {
      print('Lỗi trong AuthApiService.register: $e');
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.',
      );
    }
  }
}