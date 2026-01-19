import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../../../../core/services/storage_service.dart';

/// Repository xử lý dữ liệu xác thực với Firebase
class AuthRepository {
  /// Đăng nhập với email và mật khẩu
  Future<UserModel> login(String email, String password) async {
    // 1. Gọi Firebase Service
    final userModel = await FirebaseAuthService.signInWithEmail(
      email: email,
      password: password,
    );

    // 2. Lưu cache local
    await StorageService.saveUserInfo(userModel.toJson());

    // 3. Lưu token (nếu cần thiết, tuỳ chiến lược token)
    final firebaseUser = FirebaseAuthService.getCurrentFirebaseUser();
    if (firebaseUser != null) {
      final token = await firebaseUser.getIdToken();
      if (token != null) {
        await StorageService.saveAuthToken(token);
      }
    }

    return userModel;
  }

  /// Đăng ký tài khoản mới
  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final userModel = await FirebaseAuthService.registerWithEmail(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
    );

    // Lưu cache
    await StorageService.saveUserInfo(userModel.toJson());

    // Lưu token
    final firebaseUser = FirebaseAuthService.getCurrentFirebaseUser();
    if (firebaseUser != null) {
      final token = await firebaseUser.getIdToken();
      if (token != null) {
        await StorageService.saveAuthToken(token);
      }
    }

    return userModel;
  }

  /// Đăng xuất
  Future<void> logout() async {
    await FirebaseAuthService.signOut();
    await StorageService.clearAuthData();
  }

  /// Lấy user hiện tại (ưu tiên cache hoặc lấy mới từ remote)
  Future<UserModel?> getCurrentUser() async {
    // Check firebase user
    final firebaseUser = FirebaseAuthService.getCurrentFirebaseUser();
    if (firebaseUser == null) return null;

    // Lấy từ remote để đảm bảo data mới nhất
    try {
      final userModel = await FirebaseAuthService.getCurrentUserModel();
      if (userModel != null) {
        await StorageService.saveUserInfo(userModel.toJson());
        return userModel;
      }
    } catch (e) {
      // Nếu lỗi mạng, có thể fallback lấy từ cache
      // Nhưng ở đây ta cứ throw hoặc return null tuỳ policy
    }
    return null;
  }

  /// Gửi email reset password
  Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuthService.sendPasswordResetEmail(email);
  }

  /// Cập nhật thông tin user
  Future<void> updateUserInfo({
    String? uid,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    // Nếu không truyền uid, tự lấy uid hiện tại
    String? targetUid = uid;
    if (targetUid == null) {
      final firebaseUser = FirebaseAuthService.getCurrentFirebaseUser();
      if (firebaseUser != null) {
        targetUid = firebaseUser.uid;
      } else {
        throw Exception('Người dùng chưa đăng nhập');
      }
    }

    await FirebaseAuthService.updateUserInfo(
      uid: targetUid,
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
    );

    // Logic cập nhật lại cache user info nên được gọi lại
    // bằng cách gọi lại getCurrentUser hoặc update thủ công nếu có model mới
  }
}
