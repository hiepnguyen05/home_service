import 'package:flutter/material.dart';
import '../../../core/network/app_exceptions.dart';
import '../data/models/address_model.dart';
import '../data/repositories/address_repository.dart';

/// ViewModel quản lý state cho Address Management
class AddressViewModel extends ChangeNotifier {
  final AddressRepository _repository = AddressRepository();

  // State
  List<AddressModel> _addresses = [];
  AddressModel? _defaultAddress;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<AddressModel> get addresses => _addresses;
  AddressModel? get defaultAddress => _defaultAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasAddresses => _addresses.isNotEmpty;
  int get addressCount => _addresses.length;

  /// Khởi tạo và load dữ liệu
  Future<void> initialize() async {
    print('[ADDRESS_VM] Khởi tạo AddressViewModel...');
    await loadAddresses();
  }

  /// Load danh sách địa chỉ
  Future<void> loadAddresses() async {
    try {
      _setLoading(true);
      _clearError();
      
      print('[ADDRESS_VM] Đang load danh sách địa chỉ...');
      
      _addresses = await _repository.getAddresses();
      _defaultAddress = _addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => _addresses.isNotEmpty ? _addresses.first : null as AddressModel,
      );
      
      print('[ADDRESS_VM] Load thành công ${_addresses.length} địa chỉ');
      
    } catch (e) {
      print('[ADDRESS_VM] Lỗi load địa chỉ: $e');
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Thêm địa chỉ mới
  Future<bool> addAddress(AddressModel address) async {
    try {
      _setLoading(true);
      _clearError();
      
      print('[ADDRESS_VM] Đang thêm địa chỉ: ${address.title}');
      
      // Validate trước khi thêm
      _repository.validateAddress(address);
      
      final newAddress = await _repository.addAddress(address);
      
      // Cập nhật local state
      _addresses.insert(0, newAddress);
      
      if (newAddress.isDefault) {
        _updateDefaultAddress(newAddress);
      }
      
      print('[ADDRESS_VM] Thêm địa chỉ thành công');
      notifyListeners();
      return true;
      
    } catch (e) {
      print('[ADDRESS_VM] Lỗi thêm địa chỉ: $e');
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cập nhật địa chỉ
  Future<bool> updateAddress(AddressModel address) async {
    try {
      _setLoading(true);
      _clearError();
      
      print('[ADDRESS_VM] Đang cập nhật địa chỉ: ${address.id}');
      
      // Validate trước khi cập nhật
      _repository.validateAddress(address);
      
      final updatedAddress = await _repository.updateAddress(address);
      
      // Cập nhật local state
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        
        if (updatedAddress.isDefault) {
          _updateDefaultAddress(updatedAddress);
        }
      }
      
      print('[ADDRESS_VM] Cập nhật địa chỉ thành công');
      notifyListeners();
      return true;
      
    } catch (e) {
      print('[ADDRESS_VM] Lỗi cập nhật địa chỉ: $e');
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Xóa địa chỉ
  Future<bool> deleteAddress(String addressId) async {
    try {
      _setLoading(true);
      _clearError();
      
      print('[ADDRESS_VM] Đang xóa địa chỉ: $addressId');
      
      await _repository.deleteAddress(addressId);
      
      // Cập nhật local state
      _addresses.removeWhere((address) => address.id == addressId);
      
      // Nếu xóa địa chỉ mặc định, chọn địa chỉ đầu tiên làm mặc định
      if (_defaultAddress?.id == addressId) {
        _defaultAddress = _addresses.isNotEmpty ? _addresses.first : null;
        if (_defaultAddress != null) {
          await setDefaultAddress(_defaultAddress!.id);
        }
      }
      
      print('[ADDRESS_VM] Xóa địa chỉ thành công');
      notifyListeners();
      return true;
      
    } catch (e) {
      print('[ADDRESS_VM] Lỗi xóa địa chỉ: $e');
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Đặt địa chỉ mặc định
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      _setLoading(true);
      _clearError();
      
      print('[ADDRESS_VM] Đang đặt địa chỉ mặc định: $addressId');
      
      await _repository.setDefaultAddress(addressId);
      
      // Cập nhật local state
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(
          isDefault: _addresses[i].id == addressId,
        );
      }
      
      _defaultAddress = _addresses.firstWhere((a) => a.id == addressId);
      
      print('[ADDRESS_VM] Đặt địa chỉ mặc định thành công');
      notifyListeners();
      return true;
      
    } catch (e) {
      print('[ADDRESS_VM] Lỗi đặt địa chỉ mặc định: $e');
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy địa chỉ theo ID
  AddressModel? getAddressById(String addressId) {
    try {
      return _addresses.firstWhere((address) => address.id == addressId);
    } catch (e) {
      return null;
    }
  }

  /// Refresh danh sách địa chỉ
  Future<void> refresh() async {
    print('[ADDRESS_VM] Refresh danh sách địa chỉ...');
    await loadAddresses();
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Dispose resources
  @override
  void dispose() {
    print('[ADDRESS_VM] Disposing AddressViewModel...');
    super.dispose();
  }

  // Private methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _updateDefaultAddress(AddressModel newDefault) {
    // Bỏ mặc định của địa chỉ cũ
    for (int i = 0; i < _addresses.length; i++) {
      if (_addresses[i].id != newDefault.id && _addresses[i].isDefault) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    
    _defaultAddress = newDefault;
  }

  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Đã xảy ra lỗi không xác định';
  }

  /// Validate form data
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tiêu đề địa chỉ';
    }
    if (value.trim().length < 2) {
      return 'Tiêu đề phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (value.trim().length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    
    final phoneNumber = value.replaceAll(RegExp(r'[^\d]'), '');
    if (phoneNumber.length < 10 || phoneNumber.length > 11) {
      return 'Số điện thoại phải có 10-11 chữ số';
    }
    
    if (!phoneNumber.startsWith('0')) {
      return 'Số điện thoại phải bắt đầu bằng số 0';
    }
    
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ cụ thể';
    }
    if (value.trim().length < 5) {
      return 'Địa chỉ phải có ít nhất 5 ký tự';
    }
    return null;
  }

  String? validateLocation(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng chọn $fieldName';
    }
    return null;
  }
}