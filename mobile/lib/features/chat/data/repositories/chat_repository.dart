import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile/core/services/cloudinary_service.dart';
import 'package:mobile/features/chat/data/models/message_model.dart';

class ChatRepository {
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://homeservice-a4290-default-rtdb.asia-southeast1.firebasedatabase.app",
  );

  Stream<List<MessageModel>> getMessages(String bookingId) {
    return _database
        .ref('chats/$bookingId/messages')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final List<MessageModel> messages = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          // RTDB yêu cầu xử lý snapshot khác một chút so với Firestore cho streams
          // Chúng ta tự xây dựng danh sách từ Map nhận được
          final message =
              MessageModel.fromMap(key, value as Map<dynamic, dynamic>);
          messages.add(message);
        });
        // Sắp xếp theo timestamp vì Map không đảm bảo thứ tự chính xác từ truy vấn RTDB trong một số trường hợp
        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      return messages;
    });
  }

  Future<void> sendMessage(String bookingId, MessageModel message) async {
    try {
      await _database
          .ref('chats/$bookingId/messages')
          .push()
          .set(message.toMap());
    } catch (e) {
      throw Exception('Lỗi khi gửi tin nhắn qua Realtime Database: $e');
    }
  }

  /// Cập nhật tóm tắt hội thoại cho cả 2 phía
  /// Ghi riêng từng path để tránh lỗi Permission Denied khi update root
  Future<void> updateChatSummary({
    required String bookingId,
    required String lastMessage,
    required String senderId,
    required String receiverId,
    required String senderName,
    String? senderAvatar,
    required String receiverName,
    String? receiverAvatar,
  }) async {
    final timestamp = ServerValue.timestamp;

    // 1. Cập nhật phía người gửi (unreadCount = 0 vì họ là người gửi)
    await _database.ref('user_chats/$senderId/$bookingId').update({
      'lastMessage': lastMessage,
      'lastTimestamp': timestamp,
      'otherUserId': receiverId,
      'otherUserName': receiverName,
      'otherUserAvatar': receiverAvatar,
      'unreadCount': 0,
    });

    // 2. Cập nhật phía người nhận (tăng unreadCount bằng increment)
    await _database.ref('user_chats/$receiverId/$bookingId').update({
      'lastMessage': lastMessage,
      'lastTimestamp': timestamp,
      'otherUserId': senderId,
      'otherUserName': senderName,
      'otherUserAvatar': senderAvatar,
      'unreadCount': ServerValue.increment(1),
    });
  }

  /// Reset số tin nhắn chưa đọc về 0
  Future<void> resetUnreadCount(String userId, String bookingId) async {
    await _database.ref('user_chats/$userId/$bookingId/unreadCount').set(0);
  }

  /// Lắng nghe danh sách hội thoại của một user
  Stream<Map<String, dynamic>> getChatList(String userId) {
    return _database.ref('user_chats/$userId').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {};
      return Map<String, dynamic>.from(data);
    });
  }

  Future<String?> uploadChatImage(File file, String bookingId) async {
    try {
      return await CloudinaryService.uploadFile(
        file: file,
        folder: 'chats/$bookingId',
      );
    } catch (e) {
      throw Exception('Lỗi khi tải ảnh lên: $e');
    }
  }
}
