import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/notification/data/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'notifications';

  // ─── CREATE ────────────────────────────────────────────────────────

  /// Tạo một thông báo mới trong Firestore.
  /// Trả về ID của document vừa tạo.
  Future<String> createNotification({
    required String receiverId,
    required String senderId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic> data = const {},
  }) async {
    final docRef = await _firestore.collection(_collection).add({
      'receiverId': receiverId,
      'senderId': senderId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('🔔 [NOTI_REPO] Đã tạo thông báo ${docRef.id} cho $receiverId (type: $type)');
    return docRef.id;
  }

  // ─── READ (STREAMS) ───────────────────────────────────────────────

  /// Lắng nghe tất cả thông báo của người dùng hiện tại (realtime).
  /// Sắp xếp mới nhất lên trên.
  Stream<List<NotificationModel>> streamNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('receiverId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = <NotificationModel>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(NotificationModel.fromFirestore(doc));
        } catch (e) {
          print('⚠️ [NOTI_REPO] Bỏ qua notification lỗi ${doc.id}: $e');
        }
      }
      return list;
    });
  }

  /// Lắng nghe số lượng thông báo chưa đọc (để hiện badge).
  Stream<int> streamUnreadCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection(_collection)
        .where('receiverId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ─── UPDATE ───────────────────────────────────────────────────────

  /// Đánh dấu một thông báo là đã đọc.
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection(_collection).doc(notificationId).update({
      'isRead': true,
    });
  }

  /// Đánh dấu tất cả thông báo của người dùng hiện tại là đã đọc.
  Future<void> markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection(_collection)
        .where('receiverId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ─── DELETE ───────────────────────────────────────────────────────

  /// Xóa một thông báo.
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection(_collection).doc(notificationId).delete();
  }
}
