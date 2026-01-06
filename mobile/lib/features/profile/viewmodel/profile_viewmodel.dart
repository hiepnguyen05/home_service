import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../auth/data/models/user_model.dart';
import '../data/models/address_model.dart';
import '../data/repositories/profile_repository.dart';

/// ViewModel quản lý trạng thái profile
class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();
  
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;
  List<AddressModel> _addresses = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  List<AddressModel> get addresses => _addresses;
  
  /// Lấy địa chỉ mặc định
  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return null;
    }
  }

  /// Cập nhật trạng thái loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Cập nhật thông báo lỗi
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Tải thông tin profile từ API
  Future<bool> loadProfile(String token) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.getProfile(token);
      
      if (response.success && response.data != null) {
        _currentUser = response.data!.user;
        _addresses = response.data!.addresses;
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Đã xảy ra lỗi khi tải thông tin: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Cập nhật thông tin cá nhân
  Future<bool> updateProfile({
    required String token,
    String? fullName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.updateProfile(
        token: token,
        fullName: fullName,
      );
      
      if (response.success && response.data != null) {
        _currentUser = response.data!;
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Đã xảy ra lỗi khi cập nhật thông tin: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Upload ảnh đại diện
  Future<bool> uploadAvatar(String token, File imageFile) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.uploadAvatar(
        token: token,
        imageFile: imageFile,
      );
      
      if (response.success && response.data != null) {
        _currentUser = response.data!;
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Đã xảy ra lỗi khi upload ảnh: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Cập nhật địa chỉ
  Future<bool> updateAddress({
    required String token,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.updateAddress(
        token: token,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );
      
      if (response.success && response.data != null) {
        // Cập nhật danh sách địa chỉ
        final updatedAddress = response.data!;
        final index = _addresses.indexWhere((addr) => addr.id == updatedAddress.id);
        
        if (index != -1) {
          _addresses[index] = updatedAddress;
        } else {
          _addresses.add(updatedAddress);
        }
        
        // Nếu đây là địa chỉ mặc định, cập nhật các địa chỉ khác
        if (updatedAddress.isDefault) {
          for (int i = 0; i < _addresses.length; i++) {
            if (_addresses[i].id != updatedAddress.id) {
              _addresses[i] = AddressModel(
                id: _addresses[i].id,
                name: _addresses[i].name,
                address: _addresses[i].address,
                latitude: _addresses[i].latitude,
                longitude: _addresses[i].longitude,
                isDefault: false,
                createdAt: _addresses[i].createdAt,
                updatedAt: _addresses[i].updatedAt,
              );
            }
          }
        }
        
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Đã xảy ra lỗi khi cập nhật địa chỉ: $e');
      _setLoading(false);
      return false;
    }
  }
}