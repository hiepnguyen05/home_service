import 'package:flutter/foundation.dart';
import '../../../core/services/notification_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';

/// ViewModel quản lý trạng thái xác thực với Firebase
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;
  bool _isInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  /// Khởi tạo và kiểm tra trạng thái đăng nhập Firebase
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    print('Bắt đầu khởi tạo AuthViewModel...');

    try {
      // Repository tự handle việc ưu tiên cache hay remote
      final userModel = await _authRepository.getCurrentUser();

      if (userModel != null) {
        _currentUser = userModel;
        print('Đã khôi phục session đăng nhập cho: ${userModel.fullName}');

        // Bắt đầu lắng nghe thông báo cho user này
        NotificationService.observeNotifications(userModel.uid);
      } else {
        print('Không tìm thấy thông tin user hoặc chưa đăng nhập');
      }
    } catch (e) {
      print('Lỗi khởi tạo AuthViewModel: $e');
    } finally {
      _isInitialized = true;
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

  /// Đăng nhập với email và mật khẩu
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      print('Đang đăng nhập với email: $email');
      final userModel = await _authRepository.login(email, password);
      _currentUser = userModel;

      // Bắt đầu lắng nghe thông báo
      NotificationService.observeNotifications(userModel.uid);

      _setLoading(false);
      print('Đăng nhập thành công: ${userModel.fullName}');
      return true;
    } catch (e) {
      print('LOGIN ERROR (AuthViewModel): $e'); // Detailed log
      // Helper to format error message
      String message = e.toString().replaceAll('Exception: ', '');
      if (message.contains('network_error')) {
        message = 'Lỗi kết nối mạng. Vui lòng kiểm tra lại.';
      } else if (message.contains('invalid-credential')) {
        message = 'Email hoặc mật khẩu không chính xác.';
      } else if (message.contains('permission-denied')) {
        message =
            'Lỗi quyền truy cập (Firestore Rules). Hãy cấu hình cho phép read/write trong Firebase Console.';
      }
      _setError(message);
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
      print('Đang đăng ký tài khoản với email: $email');

      final userModel = await _authRepository.register(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
      );

      _currentUser = userModel;

      // Bắt đầu lắng nghe thông báo
      NotificationService.observeNotifications(userModel.uid);

      _setLoading(false);
      print('Đăng ký thành công: ${userModel.fullName}');
      return true;
    } catch (e) {
      print('Lỗi đăng ký: $e');
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      print('Đang đăng xuất...');
      await _authRepository.logout();
      _currentUser = null;
      _errorMessage = null;
      print('Đăng xuất thành công');
      notifyListeners();
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      _setError('Lỗi đăng xuất: $e');
    }
  }

  /// Gửi email reset password
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Cập nhật thông tin người dùng
  Future<bool> updateUserInfo({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      // Giả định uid có thể lấy từ currentUser
      // Tuy nhiên Repository cần uid, mà currentUser.id có thể là uid
      // Nếu UserModel.id map với Firebase UID thì ok.
      // Nếu không thì ViewModel không nên biết UID?
      // Repository nên tự biết current UID nếu nó dùng FirebaseAuth.
      // Nhưng Repository method updateUserInfo yêu cầu UID.
      // Ta tạm lấy từ currentUser.id

      await _authRepository.updateUserInfo(
        // uid: bỏ trống để repo tự lấy current uid từ firebase
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      // Reload lại data mới nhất từ repo
      final updatedUser = await _authRepository.getCurrentUser();
      if (updatedUser != null) {
        _currentUser = updatedUser;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }
}
