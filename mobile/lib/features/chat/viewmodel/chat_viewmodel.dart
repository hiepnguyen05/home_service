import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobile/features/chat/data/models/message_model.dart';
import 'package:mobile/features/chat/data/repositories/chat_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final String bookingId;
  final String currentUserId;
  final String? currentUserName;
  final String? currentUserAvatar;
  final String? targetUserId;
  final String? otherUserName;
  final String? otherUserAvatar;

  StreamSubscription<List<MessageModel>>? _subscription;
  List<MessageModel> _messages = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatViewModel({
    required this.bookingId,
    required this.currentUserId,
    this.currentUserName,
    this.currentUserAvatar,
    this.targetUserId,
    this.otherUserName,
    this.otherUserAvatar,
  }) {
    _listenToMessages();
    _resetUnread();
  }

  void _resetUnread() {
    _repository.resetUnreadCount(currentUserId, bookingId);
  }

  void _listenToMessages() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.getMessages(bookingId).listen((newMessages) {
      _messages = newMessages;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('❌ [ChatViewModel] Lỗi stream messages: $error');
      debugPrint(
          '🔍 [ChatViewModel] bookingId: $bookingId, currentUserId: $currentUserId');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    final message = MessageModel(
      id: '',
      senderId: currentUserId,
      text: text.trim(),
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    await _repository.sendMessage(bookingId, message);

    // Cập nhật tóm tắt hội thoại (Shopee style)
    _updateSummary(text.trim());

    // Gửi thông báo cho đối phương
    _sendNotification(text.trim());
  }

  Future<void> sendImageMessage(File file) async {
    _isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await _repository.uploadChatImage(file, bookingId);
      if (imageUrl != null) {
        final message = MessageModel(
          id: '',
          senderId: currentUserId,
          text: 'Đã gửi một ảnh',
          imageUrl: imageUrl,
          timestamp: DateTime.now(),
          type: MessageType.image,
        );
        await _repository.sendMessage(bookingId, message);

        // Cập nhật tóm tắt hội thoại
        _updateSummary('Đã gửi một ảnh');

        // Gửi thông báo cho đối phương
        _sendNotification('Đã gửi một ảnh');
      }
    } catch (e) {
      debugPrint('Error sending image: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateSummary(String lastMessage) async {
    final targetId = _determineTargetId();
    if (targetId == null) {
      debugPrint('⚠️ [ChatViewModel] Không tìm thấy targetId để cập nhật summary');
      return;
    }

    try {
      await _repository.updateChatSummary(
        bookingId: bookingId,
        lastMessage: lastMessage,
        senderId: currentUserId,
        receiverId: targetId,
        senderName: currentUserName ?? 'Người dùng',
        senderAvatar: currentUserAvatar,
        receiverName: otherUserName ?? 'Khách',
        receiverAvatar: otherUserAvatar,
      );
      debugPrint('✅ [ChatViewModel] Cập nhật chat summary thành công');
    } catch (e) {
      debugPrint('❌ [ChatViewModel] Lỗi cập nhật summary: $e');
      debugPrint('🔍 senderId=$currentUserId, receiverId=$targetId, bookingId=$bookingId');
    }
  }

  String? _determineTargetId() {
    // 1. Ưu tiên sử dụng targetUserId từ tham số truyền vào
    if (targetUserId != null && targetUserId!.isNotEmpty) {
      return targetUserId;
    }

    // 2. Fallback: Giải mã từ bookingId nếu định dạng pre_{customerId}_{providerId}
    if (bookingId.startsWith('pre_')) {
      final parts = bookingId.split('_');
      if (parts.length >= 3) {
        final customerId = parts[1];
        final providerId = parts[2];

        if (currentUserId == customerId) {
          return providerId;
        } else {
          return customerId;
        }
      }
    }
    return null;
  }

  Future<void> _sendNotification(String messageText) async {
    try {
      final targetId = _determineTargetId();

      if (targetId == null) {
        debugPrint('⚠️ Không tìm thấy target user ID để gửi thông báo');
        return;
      }

      // Ghi thông báo vào RTDB để phía bên kia nhận được (local notification fallback)
      await FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            "https://homeservice-a4290-default-rtdb.asia-southeast1.firebasedatabase.app",
      ).ref('notifications/$targetId').push().set({
        'title': 'Tin nhắn mới',
        'body': messageText,
        'chatId': bookingId,
        'senderId': currentUserId,
        'timestamp': ServerValue.timestamp,
      });

      debugPrint('Đã gửi thông báo RTDB cho user: $targetId');
    } catch (e) {
      debugPrint('Lỗi khi gửi thông báo: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
