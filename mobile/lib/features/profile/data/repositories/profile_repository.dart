import 'dart:io';
import '../../../../core/network/api_response.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/address_model.dart';
import '../models/profile_update_request.dart';
import '../models/address_update_request.dart';
import '../services/profile_api_service.dart';

/// Repository xử lý dữ liệu profile
class ProfileRepository {
  /// Lấy thông tin profile và địa chỉ
  Future<ApiResponse<ProfileResponse>> getProfile(String token) async {
    return await ProfileApiService.getProfile(token);
  }

  /// Cập nhật thông tin cá nhân
  Future<ApiResponse<UserModel>> updateProfile({
    required String token,
    String? fullName,
    String? avatarUrl,
  }) async {
    final request = ProfileUpdateRequest(
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
    return await ProfileApiService.updateProfile(request, token);
  }

  /// Upload ảnh đại diện
  Future<ApiResponse<UserModel>> uploadAvatar({
    required String token,
    required File imageFile,
  }) async {
    return await ProfileApiService.uploadAvatar(imageFile, token);
  }

  /// Cập nhật địa chỉ
  Future<ApiResponse<AddressModel>> updateAddress({
    required String token,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) async {
    final request = AddressUpdateRequest(
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
    return await ProfileApiService.updateAddress(request, token);
  }
}