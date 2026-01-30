import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/network/app_exceptions.dart';
import '../../../../core/network/firebase_error_handler.dart';
import '../../../../core/network/network_constants.dart';
import '../models/address_model.dart';

/// Repository quản lý địa chỉ người dùng
class AddressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lấy collection addresses của user hiện tại
  CollectionReference get _addressesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw const AuthException('Người dùng chưa đăng nhập');
    }
    return _firestore
        .collection(NetworkConstants.usersCollection)
        .doc(userId)
        .collection(NetworkConstants.addressesCollection);
  }

  /// Lấy danh sách địa chỉ của user
  Future<List<AddressModel>> getAddresses() async {
    try {
      print('[ADDRESS_REPO] Đang lấy danh sách địa chỉ...');

      final querySnapshot = await _addressesCollection
          .orderBy('isDefault', descending: true)
          .orderBy('updatedAt', descending: true)
          .get();

      final addresses = querySnapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc))
          .toList();

      print('[ADDRESS_REPO] Lấy được ${addresses.length} địa chỉ');
      return addresses;
    } on FirebaseException catch (e) {
      print('[ADDRESS_REPO] Firebase error: ${e.code} - ${e.message}');
      throw FirebaseErrorHandler.handleFirestoreError(e);
    } catch (e) {
      print('[ADDRESS_REPO] Error getting addresses: $e');
      throw UnknownException('Lỗi lấy danh sách địa chỉ: $e');
    }
  }

  /// Thêm địa chỉ mới
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      print('[ADDRESS_REPO] Đang thêm địa chỉ mới: ${address.title}');

      // Nếu đây là địa chỉ mặc định, bỏ mặc định của các địa chỉ khác
      if (address.isDefault) {
        await _clearDefaultAddresses();
      }

      final docRef = await _addressesCollection.add(address.toMap());

      final newAddress = address.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('[ADDRESS_REPO] Thêm địa chỉ thành công: ${newAddress.id}');
      return newAddress;
    } on FirebaseException catch (e) {
      print('[ADDRESS_REPO] Firebase error: ${e.code} - ${e.message}');
      throw FirebaseErrorHandler.handleFirestoreError(e);
    } catch (e) {
      print('[ADDRESS_REPO] Error adding address: $e');
      if (e is AppException) rethrow;
      throw UnknownException('Lỗi thêm địa chỉ: $e');
    }
  }

  /// Cập nhật địa chỉ
  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      print('[ADDRESS_REPO] Đang cập nhật địa chỉ: ${address.id}');

      // Nếu đây là địa chỉ mặc định, bỏ mặc định của các địa chỉ khác
      if (address.isDefault) {
        await _clearDefaultAddresses();
      }

      final updatedAddress = address.copyWith(updatedAt: DateTime.now());

      await _addressesCollection.doc(address.id).update(updatedAddress.toMap());

      print('[ADDRESS_REPO] Cập nhật địa chỉ thành công');
      return updatedAddress;
    } on FirebaseException catch (e) {
      print('[ADDRESS_REPO] Firebase error: ${e.code} - ${e.message}');
      throw FirebaseErrorHandler.handleFirestoreError(e);
    } catch (e) {
      print('[ADDRESS_REPO] Error updating address: $e');
      if (e is AppException) rethrow;
      throw UnknownException('Lỗi cập nhật địa chỉ: $e');
    }
  }

  /// Xóa địa chỉ
  Future<void> deleteAddress(String addressId) async {
    try {
      print('[ADDRESS_REPO] Đang xóa địa chỉ: $addressId');

      await _addressesCollection.doc(addressId).delete();

      print('[ADDRESS_REPO] Xóa địa chỉ thành công');
    } on FirebaseException catch (e) {
      print('[ADDRESS_REPO] Firebase error: ${e.code} - ${e.message}');
      throw FirebaseErrorHandler.handleFirestoreError(e);
    } catch (e) {
      print('[ADDRESS_REPO] Error deleting address: $e');
      throw UnknownException('Lỗi xóa địa chỉ: $e');
    }
  }

  /// Đặt địa chỉ mặc định
  Future<void> setDefaultAddress(String addressId) async {
    try {
      print('[ADDRESS_REPO] Đang đặt địa chỉ mặc định: $addressId');

      // Bỏ mặc định của tất cả địa chỉ
      await _clearDefaultAddresses();

      // Đặt địa chỉ này làm mặc định
      await _addressesCollection.doc(addressId).update({
        'isDefault': true,
        'updatedAt': Timestamp.now(),
      });

      print('[ADDRESS_REPO] Đặt địa chỉ mặc định thành công');
    } on FirebaseException catch (e) {
      print('[ADDRESS_REPO] Firebase error: ${e.code} - ${e.message}');
      throw FirebaseErrorHandler.handleFirestoreError(e);
    } catch (e) {
      print('[ADDRESS_REPO] Error setting default address: $e');
      throw UnknownException('Lỗi đặt địa chỉ mặc định: $e');
    }
  }

  /// Lấy địa chỉ mặc định
  Future<AddressModel?> getDefaultAddress() async {
    try {
      print('[ADDRESS_REPO] Đang lấy địa chỉ mặc định...');

      final querySnapshot = await _addressesCollection
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('[ADDRESS_REPO] Không có địa chỉ mặc định');
        return null;
      }

      final address = AddressModel.fromFirestore(querySnapshot.docs.first);
      print('[ADDRESS_REPO] Lấy địa chỉ mặc định thành công: ${address.title}');
      return address;
    } on FirebaseException catch (e) {
      print('[ADDRESS_REPO] Firebase error: ${e.code} - ${e.message}');
      throw FirebaseErrorHandler.handleFirestoreError(e);
    } catch (e) {
      print('[ADDRESS_REPO] Error getting default address: $e');
      throw UnknownException('Lỗi lấy địa chỉ mặc định: $e');
    }
  }

  /// Lấy địa chỉ theo ID
  Future<AddressModel?> getAddressById(String addressId) async {
    try {
      print('[ADDRESS_REPO] Đang lấy địa chỉ: $addressId');

      final doc = await _addressesCollection.doc(addressId).get();

      if (!doc.exists) {
        print('[ADDRESS_REPO] Không tìm thấy địa chỉ');
        return null;
      }

      final address = AddressModel.fromFirestore(doc);
      print('[ADDRESS_REPO] Lấy địa chỉ thành công: ${address.title}');
      return address;
    } on FirebaseException catch (e) {
      print('[ADDRESS_REPO] Firebase error: ${e.code} - ${e.message}');
      throw FirebaseErrorHandler.handleFirestoreError(e);
    } catch (e) {
      print('[ADDRESS_REPO] Error getting address: $e');
      throw UnknownException('Lỗi lấy địa chỉ: $e');
    }
  }

  /// Stream danh sách địa chỉ (real-time)
  Stream<List<AddressModel>> watchAddresses() {
    try {
      print('[ADDRESS_REPO] Bắt đầu theo dõi danh sách địa chỉ...');

      return _addressesCollection
          .orderBy('isDefault', descending: true)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final addresses = snapshot.docs
            .map((doc) => AddressModel.fromFirestore(doc))
            .toList();

        print('[ADDRESS_REPO] Cập nhật danh sách: ${addresses.length} địa chỉ');
        return addresses;
      });
    } catch (e) {
      print('[ADDRESS_REPO] Error watching addresses: $e');
      throw UnknownException('Lỗi theo dõi danh sách địa chỉ: $e');
    }
  }

  /// Bỏ mặc định của tất cả địa chỉ
  Future<void> _clearDefaultAddresses() async {
    try {
      final querySnapshot =
          await _addressesCollection.where('isDefault', isEqualTo: true).get();

      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isDefault': false,
          'updatedAt': Timestamp.now(),
        });
      }

      await batch.commit();
      print(
          '[ADDRESS_REPO] Đã bỏ mặc định ${querySnapshot.docs.length} địa chỉ');
    } catch (e) {
      print('[ADDRESS_REPO] Error clearing default addresses: $e');
      // Không throw error vì đây là helper method
    }
  }

  /// Kiểm tra số lượng địa chỉ
  Future<int> getAddressCount() async {
    try {
      final querySnapshot = await _addressesCollection.get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('[ADDRESS_REPO] Error getting address count: $e');
      return 0;
    }
  }

  /// Validate địa chỉ trước khi lưu
  void validateAddress(AddressModel address) {
    if (address.title.trim().isEmpty) {
      throw const ValidationException('Vui lòng nhập tiêu đề địa chỉ');
    }

    if (address.fullName.trim().isEmpty) {
      throw const ValidationException('Vui lòng nhập họ tên');
    }

    if (address.phoneNumber.trim().isEmpty) {
      throw const ValidationException('Vui lòng nhập số điện thoại');
    }

    if (address.address.trim().isEmpty) {
      throw const ValidationException('Vui lòng nhập địa chỉ cụ thể');
    }

    /*
    if (address.ward.trim().isEmpty) {
      throw const ValidationException('Vui lòng chọn phường/xã');
    }
    
    if (address.district.trim().isEmpty) {
      throw const ValidationException('Vui lòng chọn quận/huyện');
    }
    
    if (address.city.trim().isEmpty) {
      throw const ValidationException('Vui lòng chọn tỉnh/thành phố');
    }
    */

    // Validate phone number format
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    if (!phoneRegex
        .hasMatch(address.phoneNumber.replaceAll(RegExp(r'[^\d]'), ''))) {
      throw const ValidationException('Số điện thoại không hợp lệ');
    }
  }
}
