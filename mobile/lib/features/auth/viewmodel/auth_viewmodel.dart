import 'package:flutter/foundation.dart';
import '../../../core/network/api_response.dart';
import '../../../core/services/storage_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';

/// ViewModel quản lý trạng thái xác thực
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;
  String? _token;
  bool _isInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null && _token != null;
  bool get isInitialized => _isInitialized;

  /// Khởi tạo và load dữ liệu từ storage
  Future<void> initialize() async {
    if (_isInitialized) {
      print('AuthViewModel đã được khởi tạo rồi');
      return;
    }
    
    print('Bắt đầu khởi tạo AuthViewModel...');
    
    try {
      print('Đang đọc dữ liệu từ SharedPreferences...');
      final token = await StorageService.getAuthToken();
      final userInfo = await StorageService.getUserInfo();
      
      print('Token từ storage: ${token != null ? 'có (${token.substring(0, 20)}...)' : 'không có'}');
      print('User info từ storage: ${userInfo != null ? userInfo['full_name'] : 'không có'}');
      
      if (token != null && userInfo != null) {
        _token = token;
        _currentUser = UserModel.fromJson(userInfo);
        print('Đã khôi phục session đăng nhập cho: ${_currentUser!.fullName}');
      } else {
        print('Không có session đăng nhập trong storage');
      }
    } catch (e) {
      print('Lỗi khởi tạo AuthViewModel: $e');
    } finally {
      _isInitialized = true;
      print('AuthViewModel đã khởi tạo xong. IsLoggedIn: $isLoggedIn');
      notifyListeners();
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

  /// Đăng nhập
  Future<bool> login(String identifier, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authRepository.login(identifier, password);
      
      if (response.success && response.data != null) {
        _currentUser = response.data!.user;
        _token = response.data!.token;
        
        // Lưu vào storage
        await StorageService.saveAuthToken(_token!);
        await StorageService.saveUserInfo(_currentUser!.toJson());
        
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Đã xảy ra lỗi: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Đăng ký tài khoản mới
  Future<bool> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authRepository.register(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
      );
      
      if (response.success && response.data != null) {
        _currentUser = response.data!.user;
        _token = response.data!.token;
        
        // Lưu vào storage
        await StorageService.saveAuthToken(_token!);
        await StorageService.saveUserInfo(_currentUser!.toJson());
        
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Đã xảy ra lỗi: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _errorMessage = null;
    
    // Xóa khỏi storage
    await StorageService.clearAuthData();
    
    notifyListeners();
  }

  /// Cập nhật thông tin người dùng
  Future<void> updateUserInfo(UserModel user) async {
    _currentUser = user;
    // Cập nhật storage
    await StorageService.saveUserInfo(user.toJson());
    notifyListeners();
  }
}