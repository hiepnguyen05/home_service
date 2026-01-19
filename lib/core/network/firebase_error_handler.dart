import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_exceptions.dart';

/// Xử lý và chuyển đổi lỗi Firebase thành AppException
class FirebaseErrorHandler {
  
  /// Xử lý lỗi Firebase Auth
  static AppException handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return const AuthException('Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.');
      case 'email-already-in-use':
        return const AuthException('Email này đã được sử dụng. Vui lòng sử dụng email khác.');
      case 'invalid-email':
        return const AuthException('Định dạng email không hợp lệ.');
      case 'user-not-found':
        return const AuthException('Không tìm thấy tài khoản với email này.');
      case 'wrong-password':
        return const AuthException('Mật khẩu không đúng.');
      case 'user-disabled':
        return const AuthException('Tài khoản đã bị vô hiệu hóa.');
      case 'too-many-requests':
        return const AuthException('Quá nhiều yêu cầu. Vui lòng thử lại sau.');
      case 'operation-not-allowed':
        return const AuthException('Phương thức đăng nhập không được phép.');
      case 'invalid-credential':
        return const AuthException('Thông tin đăng nhập không hợp lệ.');
      case 'network-request-failed':
        return const NetworkException('Lỗi kết nối mạng. Vui lòng kiểm tra internet.');
      case 'requires-recent-login':
        return const AuthException('Vui lòng đăng nhập lại để thực hiện thao tác này.');
      default:
        return AuthException('Lỗi xác thực: ${e.message ?? 'Không xác định'}', code: e.code);
    }
  }

  /// Xử lý lỗi Firestore
  static AppException handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'cancelled':
        return const AppFirebaseException('Thao tác đã bị hủy.');
      case 'unknown':
        return const AppFirebaseException('Lỗi không xác định.');
      case 'invalid-argument':
        return const AppFirebaseException('Tham số không hợp lệ.');
      case 'deadline-exceeded':
        return const AppTimeoutException('Thao tác quá thời gian chờ.');
      case 'not-found':
        return const NotFoundException('Không tìm thấy dữ liệu.');
      case 'already-exists':
        return const AppFirebaseException('Dữ liệu đã tồn tại.');
      case 'permission-denied':
        return const UnauthorizedException('Không có quyền truy cập.');
      case 'resource-exhausted':
        return const AppFirebaseException('Tài nguyên đã cạn kiệt.');
      case 'failed-precondition':
        return const AppFirebaseException('Điều kiện tiên quyết không được đáp ứng.');
      case 'aborted':
        return const AppFirebaseException('Thao tác đã bị hủy bỏ.');
      case 'out-of-range':
        return const AppFirebaseException('Giá trị ngoài phạm vi.');
      case 'unimplemented':
        return const AppFirebaseException('Tính năng chưa được triển khai.');
      case 'internal':
        return const ServerException('Lỗi server nội bộ.');
      case 'unavailable':
        return const NetworkException('Dịch vụ không khả dụng. Vui lòng thử lại sau.');
      case 'data-loss':
        return const AppFirebaseException('Mất dữ liệu không thể khôi phục.');
      case 'unauthenticated':
        return const AuthException('Chưa xác thực. Vui lòng đăng nhập lại.');
      default:
        return AppFirebaseException('Lỗi Firestore: ${e.message ?? 'Không xác định'}', code: e.code);
    }
  }

  /// Xử lý lỗi chung
  static AppException handleGenericError(dynamic error) {
    if (error is FirebaseAuthException) {
      return handleAuthError(error);
    } else if (error is FirebaseException) {
      return handleFirestoreError(error);
    } else if (error is AppException) {
      return error;
    } else {
      return UnknownException('Lỗi không xác định: ${error.toString()}');
    }
  }
}