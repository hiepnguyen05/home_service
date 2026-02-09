import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/address_model.dart';
import '../models/profile_update_request.dart';
import '../models/address_update_request.dart';

/// Service xử lý API profile
class ProfileApiService {
  static const String _profileEndpoint = '/api/profile';

  /// Lấy thông tin profile và địa chỉ
  static Future<ApiResponse<ProfileResponse>> getProfile(String token) async {
    try {
      print('Đang lấy thông tin profile...');
      
      final response = await ApiClient.get(
        '$_profileEndpoint/me',
        token: token,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Lấy profile thành công');
        
        // Backend trả về trực tiếp user và addresses trong response root
        if (jsonData != null && jsonData['user'] != null && jsonData['addresses'] != null) {
          final profileResponse = ProfileResponse(
            user: UserModel.fromJson(jsonData['user']),
            addresses: (jsonData['addresses'] as List)
                .map((addr) => AddressModel.fromJson(addr))
                .toList(),
          );
          
          return ApiResponse<ProfileResponse>(
            success: jsonData['success'] ?? true,
            message: jsonData['message'] ?? 'Lấy thông tin thành công',
            data: profileResponse,
          );
        } else {
          print('Response structure không đúng: $jsonData');
          return ApiResponse<ProfileResponse>(
            success: false,
            message: 'Lấy thông tin thành công nhưng format không đúng',
          );
        }
      } else {
        print('Lấy profile thất bại: ${response.statusCode}');
        return ApiResponse<ProfileResponse>(
          success: false,
          message: jsonData['message'] ?? 'Lấy thông tin thất bại',
        );
      }
    } catch (e) {
      print('Lỗi trong ProfileApiService.getProfile: $e');
      return ApiResponse<ProfileResponse>(
        success: false,
        message: 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.',
      );
    }
  }

  /// Cập nhật thông tin profile
  static Future<ApiResponse<UserModel>> updateProfile(
    ProfileUpdateRequest request,
    String token,
  ) async {
    try {
      print('Đang cập nhật profile...');
      print('Request data: ${request.toJson()}');
      
      final response = await ApiClient.put(
        '$_profileEndpoint/update',
        body: request.toJson(),
        token: token,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Cập nhật profile thành công');
        
        // Backend trả về trực tiếp user trong response root
        if (jsonData != null && jsonData['user'] != null) {
          return ApiResponse<UserModel>(
            success: jsonData['success'] ?? true,
            message: jsonData['message'] ?? 'Cập nhật thành công',
            data: UserModel.fromJson(jsonData['user']),
          );
        } else {
          print('Response structure không đúng: $jsonData');
          return ApiResponse<UserModel>(
            success: false,
            message: 'Cập nhật thành công nhưng không nhận được thông tin user',
          );
        }
      } else {
        print('Cập nhật profile thất bại: ${response.statusCode}');
        return ApiResponse<UserModel>(
          success: false,
          message: jsonData['message'] ?? 'Cập nhật thất bại',
        );
      }
    } catch (e) {
      print('Lỗi trong ProfileApiService.updateProfile: $e');
      return ApiResponse<UserModel>(
        success: false,
        message: 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.',
      );
    }
  }

  /// Upload ảnh đại diện
  static Future<ApiResponse<UserModel>> uploadAvatar(
    File imageFile,
    String token,
  ) async {
    try {
      print('Đang upload ảnh đại diện...');
      print('File path: ${imageFile.path}');
      print('File exists: ${await imageFile.exists()}');
      
      final uri = Uri.parse('${ApiClient.baseUrl}$_profileEndpoint/update');
      final request = http.MultipartRequest('PUT', uri);
      
      // Thêm headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      
      // Đọc file thành bytes để có control tốt hơn
      final fileBytes = await imageFile.readAsBytes();
      print('File size: ${fileBytes.length} bytes');
      
      if (fileBytes.isEmpty) {
        throw Exception('File rỗng hoặc không đọc được');
      }
      
      // Luôn sử dụng JPEG format để đảm bảo tương thích
      const mimeType = 'image/jpeg';
      const filename = 'avatar.jpg';
      
      print('MIME type: $mimeType');
      print('Filename: $filename');
      
      // Thêm file từ bytes với MIME type JPEG
      final multipartFile = http.MultipartFile.fromBytes(
        'avatar', // Tên field phải khớp với backend
        fileBytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);
      
      print('Request headers: ${request.headers}');
      print('Request files: ${request.files.length}');
      if (request.files.isNotEmpty) {
        print('File field name: ${request.files.first.field}');
        print('File content type: ${request.files.first.contentType}');
        print('File filename: ${request.files.first.filename}');
        print('File length: ${request.files.first.length}');
      }

      print('Sending multipart request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          print('Upload ảnh thành công');
          print('JSON data: $jsonData');
          print('JSON data type: ${jsonData.runtimeType}');
          print('Has data key: ${jsonData?.containsKey('data')}');
          if (jsonData != null && jsonData.containsKey('data')) {
            print('Data content: ${jsonData['data']}');
            print('Has user key: ${jsonData['data']?.containsKey('user')}');
          }
          
          // Kiểm tra cấu trúc response - backend trả về trực tiếp user trong response root
          if (jsonData != null && jsonData['user'] != null) {
            return ApiResponse<UserModel>(
              success: jsonData['success'] ?? true,
              message: jsonData['message'] ?? 'Upload ảnh thành công',
              data: UserModel.fromJson(jsonData['user']),
            );
          } else {
            print('Response structure không đúng: $jsonData');
            return ApiResponse<UserModel>(
              success: false,
              message: 'Upload thành công nhưng không nhận được thông tin user',
            );
          }
        } catch (e) {
          print('Lỗi parse JSON: $e');
          return ApiResponse<UserModel>(
            success: false,
            message: 'Upload thành công nhưng lỗi parse response: $e',
          );
        }
      } else {
        // Thử parse JSON response để lấy error message
        try {
          final jsonData = jsonDecode(response.body);
          print('Upload ảnh thất bại: ${response.statusCode}');
          return ApiResponse<UserModel>(
            success: false,
            message: jsonData['message'] ?? 'Upload ảnh thất bại',
          );
        } catch (e) {
          print('Upload ảnh thất bại, không parse được response: ${response.statusCode}');
          return ApiResponse<UserModel>(
            success: false,
            message: 'Upload ảnh thất bại (${response.statusCode})',
          );
        }
      }
    } catch (e) {
      print('Lỗi trong ProfileApiService.uploadAvatar: $e');
      return ApiResponse<UserModel>(
        success: false,
        message: 'Lỗi upload ảnh: $e',
      );
    }
  }

  /// Cập nhật địa chỉ
  static Future<ApiResponse<AddressModel>> updateAddress(
    AddressUpdateRequest request,
    String token,
  ) async {
    try {
      print('Đang cập nhật địa chỉ...');
      print('Request data: ${request.toJson()}');
      
      final response = await ApiClient.put(
        '$_profileEndpoint/address',
        body: request.toJson(),
        token: token,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Cập nhật địa chỉ thành công');
        
        // Backend trả về trực tiếp address trong response root
        if (jsonData != null && jsonData['address'] != null) {
          return ApiResponse<AddressModel>(
            success: jsonData['success'] ?? true,
            message: jsonData['message'] ?? 'Cập nhật địa chỉ thành công',
            data: AddressModel.fromJson(jsonData['address']),
          );
        } else {
          print('Response structure không đúng: $jsonData');
          return ApiResponse<AddressModel>(
            success: false,
            message: 'Cập nhật thành công nhưng không nhận được thông tin địa chỉ',
          );
        }
      } else {
        print('Cập nhật địa chỉ thất bại: ${response.statusCode}');
        return ApiResponse<AddressModel>(
          success: false,
          message: jsonData['message'] ?? 'Cập nhật địa chỉ thất bại',
        );
      }
    } catch (e) {
      print('Lỗi trong ProfileApiService.updateAddress: $e');
      return ApiResponse<AddressModel>(
        success: false,
        message: 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.',
      );
    }
  }
}

/// Response từ API profile
class ProfileResponse {
  final UserModel user;
  final List<AddressModel> addresses;

  ProfileResponse({
    required this.user,
    required this.addresses,
  });
}