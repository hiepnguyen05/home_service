import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';

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
          .orderBy('createAt', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception("Lỗi khi lấy ra lịch sử đặt lịch: $e");
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(bookingId)
          .update({'status': newStatus});
    } catch (e) {
      throw Exception("Có lỗi khi cập nhật trạng thái $e");
    }
  }
}
