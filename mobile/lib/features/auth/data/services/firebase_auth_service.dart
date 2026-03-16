import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/services/notification_service.dart';

/// Service xử lý Firebase Authentication
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Đăng ký tài khoản mới với email và password
  static Future<UserModel> registerWithEmail({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      print('Đang đăng ký tài khoản Firebase...');

      // Tạo tài khoản Firebase Auth
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Không thể tạo tài khoản');
      }

      // Cập nhật display name
      await firebaseUser.updateDisplayName(fullName);

      // Tạo user document trong Firestore
      var userModel = UserModel(
        id: firebaseUser.uid.hashCode,
        uid: firebaseUser.uid,
        code: null,
        fullName: fullName,
        phone: phone,
        email: email,
        avatarUrl: firebaseUser.photoURL,
        role: 'customer', // Default role
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Lấy FCM Token
      final fcmToken = await NotificationService.getToken();
      userModel = userModel.copyWith(fcmToken: fcmToken);

      // Lưu thông tin user vào Firestore
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'full_name': fullName,
        'phone': phone,
        'email': email,
        'avatar_url': firebaseUser.photoURL,
        'role': 'customer',
        'status': 'active',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'fcm_token': fcmToken,
      });

      print('Đăng ký thành công: ${userModel.fullName}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      // Bắt lỗi Firestore (ví dụ: permission-denied)
      print('Firestore Error: ${e.code} - ${e.message}');
      throw Exception('Lỗi Firestore: [${e.code}] ${e.message}');
    } catch (e) {
      print('General Error: $e');
      throw Exception('Lỗi đăng ký: $e');
    }
  }

  /// Đăng nhập với email và password
  static Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('Đang đăng nhập Firebase...');

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Không thể đăng nhập');
      }

      // Lấy thông tin user từ Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      final userData = userDoc.data()!;
      final userModel = UserModel(
        id: firebaseUser.uid.hashCode,
        uid: firebaseUser.uid,
        code: userData['code'],
        fullName: userData['full_name'] ?? firebaseUser.displayName ?? '',
        phone: userData['phone'] ?? '',
        email: firebaseUser.email ?? '',
        avatarUrl: userData['avatar_url'] ?? firebaseUser.photoURL,
        role: userData['role'] ?? 'customer',
        status: userData['status'] ?? 'active',
        createdAt:
            (userData['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (userData['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      // Cập nhật FCM Token khi đăng nhập
      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null) {
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'fcm_token': fcmToken,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      print('Đăng nhập thành công: ${userModel.fullName}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      print('General Error: $e');
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  /// Đăng xuất
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('Đăng xuất thành công');
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      throw Exception('Lỗi đăng xuất: $e');
    }
  }

  /// Lấy user hiện tại
  static User? getCurrentFirebaseUser() {
    return _auth.currentUser;
  }

  /// Lấy thông tin user hiện tại từ Firestore
  static Future<UserModel?> getCurrentUserModel() async {
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      return UserModel(
        id: firebaseUser.uid.hashCode,
        uid: firebaseUser.uid,
        code: userData['code'],
        fullName: userData['full_name'] ?? firebaseUser.displayName ?? '',
        phone: userData['phone'] ?? '',
        email: firebaseUser.email ?? '',
        avatarUrl: userData['avatar_url'] ?? firebaseUser.photoURL,
        role: userData['role'] ?? 'customer',
        status: userData['status'] ?? 'active',
        createdAt:
            (userData['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (userData['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('Lỗi lấy thông tin user: $e');
      return null;
    }
  }

  /// Gửi email reset password
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Đã gửi email reset password');
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Lỗi gửi email reset password: $e');
    }
  }

  /// Cập nhật thông tin user
  static Future<void> updateUserInfo({
    required String uid,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (fullName != null) {
        updateData['full_name'] = fullName;
        // Cập nhật display name trong Firebase Auth
        await _auth.currentUser?.updateDisplayName(fullName);
      }

      if (phone != null) updateData['phone'] = phone;
      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
        // Cập nhật photo URL trong Firebase Auth
        await _auth.currentUser?.updatePhotoURL(avatarUrl);
      }

      await _firestore.collection('users').doc(uid).update(updateData);
      print('Cập nhật thông tin user thành công');
    } catch (e) {
      print('Lỗi cập nhật thông tin user: $e');
      throw Exception('Lỗi cập nhật thông tin: $e');
    }
  }

  /// Xử lý Firebase Auth exceptions
  static Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('Mật khẩu quá yếu');
      case 'email-already-in-use':
        return Exception('Email đã được sử dụng');
      case 'invalid-email':
        return Exception('Email không hợp lệ');
      case 'user-not-found':
        return Exception('Không tìm thấy tài khoản');
      case 'wrong-password':
        return Exception('Mật khẩu không đúng');
      case 'user-disabled':
        return Exception('Tài khoản đã bị vô hiệu hóa');
      case 'too-many-requests':
        return Exception('Quá nhiều yêu cầu. Vui lòng thử lại sau');
      case 'operation-not-allowed':
        return Exception('Phương thức đăng nhập không được phép');
      case 'invalid-credential':
        return Exception('Thông tin đăng nhập không hợp lệ');
      default:
        return Exception('Lỗi xác thực: ${e.message}');
    }
  }

  /// Lấy document của user bất kỳ
  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(
      String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }
}
