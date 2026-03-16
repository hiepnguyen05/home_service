import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/notification/data/models/notification_model.dart';
import 'package:mobile/features/notification/data/repositories/notification_repository.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookings';
  //Tạo booking
  Future<void> createBooking(BookingModel booking) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(booking.id)
          .set(booking.toMap());
    } catch (e) {
      throw Exception("Lỗi khi tạo đơn hàng $e");
    }
  }

  // Lấy ra booking của một user
  Future<List<BookingModel>> getBookingUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('customerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception("Lỗi khi lấy ra lịch sử đặt lịch: $e");
    }
  }

  // Lấy ra booking của một provider
  Future<List<BookingModel>> getBookingProviderId(String providerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('providerId', isEqualTo: providerId)
          .orderBy('scheduleAt', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Nếu lỗi index chưa được tạo, thử query không có orderBy
      try {
        final querySnapshot = await _firestore
            .collection(_collection)
            .where('providerId', isEqualTo: providerId)
            .get();
        // Sắp xếp client-side
        final bookings = querySnapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList();
        bookings.sort((a, b) => b.scheduleAt.compareTo(a.scheduleAt));
        return bookings;
      } catch (e2) {
        throw Exception("Lỗi khi lấy danh sách đơn hàng của thợ: $e2");
      }
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      final doc = await _firestore.collection(_collection).doc(bookingId).get();
      if ((doc.data() as Map<String, dynamic>)['status'] == BookingStatus.cancelled) {
        throw Exception("Đơn hàng này đã bị khách hàng hủy.");
      }
      await _firestore
          .collection(_collection)
          .doc(bookingId)
          .update({'status': newStatus});
    } catch (e) {
      throw Exception("Có lỗi khi cập nhật trạng thái $e");
    }
  }

  Future<void> confirmArrival(String bookingId, String checkInImageUrl) async {
    try {
      final doc = await _firestore.collection(_collection).doc(bookingId).get();
      if ((doc.data() as Map<String, dynamic>)['status'] == BookingStatus.cancelled) {
        throw Exception("Đơn hàng này đã bị khách hàng hủy.");
      }
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': BookingStatus.arrived, // Updated: arrived
        'checkInImage': checkInImageUrl,
        'arrivedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Lỗi khi xác nhận đến nơi: $e");
    }
  }

  Future<void> startWorking(String bookingId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(bookingId).get();
      final data = doc.data() as Map<String, dynamic>;
      
      if (data['status'] == BookingStatus.cancelled) {
        throw Exception("Đơn hàng này đã bị khách hàng hủy.");
      }
      
      final Map<String, dynamic> updates = {
        'status': BookingStatus.processing,
        'lastStartedAt': FieldValue.serverTimestamp(),
      };

      // Only set startedAt if it hasn't been set before (first start)
      if (data['startedAt'] == null) {
        updates['startedAt'] = FieldValue.serverTimestamp();
      }
      
      // Clear pausedAt when resuming
      updates['pausedAt'] = null;

      await _firestore.collection(_collection).doc(bookingId).update(updates);
    } catch (e) {
      throw Exception("Lỗi khi bắt đầu công việc: $e");
    }
  }

  Future<void> pauseWorking(String bookingId, int currentSessionSeconds) async {
    try {
      final doc = await _firestore.collection(_collection).doc(bookingId).get();
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] == BookingStatus.cancelled) {
        throw Exception("Đơn hàng này đã bị khách hàng hủy.");
      }
      final int totalSeconds = (data['totalWorkingSeconds'] ?? 0) + currentSessionSeconds;

      await _firestore.collection(_collection).doc(bookingId).update({
        'status': BookingStatus.paused,
        'pausedAt': FieldValue.serverTimestamp(),
        'totalWorkingSeconds': totalSeconds,
      });
    } catch (e) {
      throw Exception("Lỗi khi tạm ngưng công việc: $e");
    }
  }

  Future<void> completeJob(String bookingId, int finalSessionSeconds,
      {String? completionImageUrl, double? finalPrice}) async {
    try {
      final doc = await _firestore.collection(_collection).doc(bookingId).get();
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] == BookingStatus.cancelled) {
        throw Exception("Đơn hàng này đã bị khách hàng hủy.");
      }
      final int totalSeconds = (data['totalWorkingSeconds'] ?? 0) + finalSessionSeconds;

      final Map<String, dynamic> updates = {
        'status': BookingStatus.completed,
        'completedAt': FieldValue.serverTimestamp(),
        'completionImage': completionImageUrl,
        'totalWorkingSeconds': totalSeconds,
      };

      if (finalPrice != null) {
        updates['totalPrice'] = finalPrice;
      }

      await _firestore.collection(_collection).doc(bookingId).update(updates);
    } catch (e) {
      throw Exception("Lỗi khi hoàn thành công việc: $e");
    }
  }

  // Lấy chi tiết một booking
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception("Lỗi lấy thông tin booking: $e");
    }
  }

  // Listen to booking updates
  Stream<BookingModel> streamBooking(String bookingId) {
    return _firestore
        .collection(_collection)
        .doc(bookingId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      } else {
        throw Exception("Không tìm thấy đơn hàng");
      }
    });
  }

  // --- cancellation logic ---
  Future<void> requestCancellation(String bookingId, String requesterId, {String? reason}) async {
    try {
      print("📡 [REPO] Gửi yêu cầu hủy đơn $bookingId bởi $requesterId. Lý do: $reason");

      // 1. Cập nhật trạng thái đơn hàng
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': BookingStatus.cancelPending,
        'cancelRequestedBy': requesterId,
        'cancelNote': reason,
      });
      print("✅ [REPO] Cập nhật cancelPending thành công cho $bookingId");

      // 2. Lấy thông tin đơn hàng để biết customerId
      final bookingDoc = await _firestore.collection(_collection).doc(bookingId).get();
      final bookingData = bookingDoc.data() ?? {};
      final customerId = bookingData['customerId'] as String? ?? '';
      final shortId = bookingId.length >= 8 ? bookingId.substring(0, 8) : bookingId;

      // 3. Tạo thông báo cho khách hàng
      if (customerId.isNotEmpty) {
        await NotificationRepository().createNotification(
          receiverId: customerId,
          senderId: requesterId,
          title: 'Yêu cầu hủy đơn',
          body: 'Thợ yêu cầu hủy đơn hàng #$shortId${reason != null ? ". Lý do: $reason" : ""}',
          type: NotificationType.cancelRequest,
          data: {'bookingId': bookingId},
        );
        print("🔔 [REPO] Đã tạo thông báo hủy cho khách $customerId");
      }
    } catch (e) {
      print("❌ [REPO] Lỗi requestCancellation: $e");
      throw Exception("Lỗi khi gửi yêu cầu hủy: $e");
    }
  }

  Future<void> handleCancellationResponse(String bookingId, bool isApproved, String previousStatus) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (isApproved) {
        await _firestore.collection(_collection).doc(bookingId).update({
          'status': BookingStatus.cancelled,
        });
      } else {
        await _firestore.collection(_collection).doc(bookingId).update({
          'status': previousStatus,
          'cancelRequestedBy': null,
          'cancelNote': null,
        });
      }

      // Lấy thông tin đơn để biết providerId
      final bookingDoc = await _firestore.collection(_collection).doc(bookingId).get();
      final bookingData = bookingDoc.data() ?? {};
      final providerId = bookingData['providerId'] as String? ?? '';
      final shortId = bookingId.length >= 8 ? bookingId.substring(0, 8) : bookingId;

      // Tạo thông báo phản hồi cho thợ
      if (providerId.isNotEmpty && user != null) {
        await NotificationRepository().createNotification(
          receiverId: providerId,
          senderId: user.uid,
          title: isApproved ? 'Yêu cầu hủy được chấp nhận' : 'Yêu cầu hủy bị từ chối',
          body: isApproved
              ? 'Khách hàng đã đồng ý hủy đơn hàng #$shortId.'
              : 'Khách hàng đã từ chối yêu cầu hủy đơn hàng #$shortId. Vui lòng tiếp tục công việc.',
          type: isApproved ? NotificationType.cancelApproved : NotificationType.cancelRejected,
          data: {'bookingId': bookingId},
        );
      }

      // 🔔 TẠO THÔNG BÁO CHO CHÍNH KHÁCH HÀNG (Người ra quyết định)
      if (user != null) {
        await NotificationRepository().createNotification(
          receiverId: user.uid,
          senderId: 'system',
          title: isApproved ? 'Đã xác nhận hủy đơn' : 'Đã từ chối hủy đơn',
          body: isApproved
              ? 'Bạn đã đồng ý hủy đơn hàng #$shortId. Đơn hàng hiện đã đóng.'
              : 'Bạn đã từ chối yêu cầu hủy đơn hàng #$shortId.',
          type: isApproved ? NotificationType.cancelApproved : NotificationType.cancelRejected,
          data: {'bookingId': bookingId},
        );
      }
    } catch (e) {
      throw Exception("Lỗi khi xử lý yêu cầu hủy: $e");
    }
  }

  Stream<List<BookingModel>> streamCustomerCancelRequests() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("🔍 [REPO] streamCustomerCancelRequests: User is null");
      return Stream.value([]);
    }

    print("🔍 [REPO] Đang lắng nghe yêu cầu hủy cho khách UID: ${user.uid}");

    return _firestore
        .collection(_collection)
        .where('customerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      print("🔍 [REPO] Snapshot nhận được ${snapshot.docs.length} docs cho khách ${user.uid}");
      final List<BookingModel> list = [];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final status = data['status'];
          final custId = data['customerId'];
          
          print("📄 [REPO] Kiểm tra Đơn ${doc.id} | Status: $status | CustomerID in Doc: $custId");

          if (status == BookingStatus.cancelPending) {
            final booking = BookingModel.fromFirestore(doc);
            list.add(booking);
          }
        } catch (e) {
          print("⚠️ [REPO] Lỗi khi xử lý doc ${doc.id}: $e");
        }
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print("🔍 [REPO] Cuối cùng trả về ${list.length} yêu cầu hủy cho UI");
      return list;
    });
  }

  Future<void> requestExtraCost(
    String bookingId, 
    String providerId, 
    double amount, 
    String description
  ) async {
    try {
      // 1. Cập nhật booking với thông tin chi phí phát sinh
      await _firestore.collection(_collection).doc(bookingId).update({
        'extraCostAmount': amount,
        'extraCostDescription': description,
        'extraCostStatus': 'pending',
      });

      // 2. Lấy thông tin khách hàng để gửi thông báo
      final bookingDoc = await _firestore.collection(_collection).doc(bookingId).get();
      final customerId = bookingDoc.data()?['customerId'] as String? ?? '';
      final shortId = bookingId.length >= 8 ? bookingId.substring(0, 8) : bookingId;

      if (customerId.isNotEmpty) {
        await NotificationRepository().createNotification(
          receiverId: customerId,
          senderId: providerId,
          title: 'Yêu cầu chi phí phát sinh',
          body: 'Thợ yêu cầu thêm chi phí ${amount.toInt()} VNĐ cho đơn hàng #$shortId. Lý do: $description',
          type: NotificationType.extraCostRequest,
          data: {'bookingId': bookingId},
        );
      }
    } catch (e) {
      throw Exception("Lỗi khi gửi yêu cầu chi phí phát sinh: $e");
    }
  }

  Future<void> handleExtraCostResponse(String bookingId, bool isApproved) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final bookingDoc = await _firestore.collection(_collection).doc(bookingId).get();
      final data = bookingDoc.data() ?? {};
      final providerId = data['providerId'] as String? ?? '';
      final extraAmount = (data['extraCostAmount'] as num?)?.toDouble() ?? 0.0;
      final currentTotalPrice = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
      final shortId = bookingId.length >= 8 ? bookingId.substring(0, 8) : bookingId;

      if (isApproved) {
        await _firestore.collection(_collection).doc(bookingId).update({
          'extraCostStatus': 'approved',
          'totalPrice': currentTotalPrice + extraAmount,
        });
      } else {
        await _firestore.collection(_collection).doc(bookingId).update({
          'extraCostStatus': 'rejected',
        });
      }

      // Notify the provider of the customer's decision
      if (providerId.isNotEmpty) {
        await NotificationRepository().createNotification(
          receiverId: providerId,
          senderId: user.uid,
          title: isApproved ? 'Chi phí phát sinh đã được chấp nhận' : 'Chi phí phát sinh bị từ chối',
          body: isApproved
              ? 'Khách hàng đã đồng ý thêm chi phí ${extraAmount.toInt()} VNĐ cho đơn hàng #$shortId.'
              : 'Khách hàng đã từ chối yêu cầu thêm chi phí cho đơn hàng #$shortId.',
          type: isApproved ? NotificationType.extraCostApproved : NotificationType.extraCostRejected,
          data: {'bookingId': bookingId},
        );
      }
    } catch (e) {
      throw Exception("Lỗi khi xử lý yêu cầu chi phí: $e");
    }
  }
}
