import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobile/features/chat/data/repositories/chat_repository.dart';

class ChatListViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final String userId;

  StreamSubscription? _subscription;
  List<ChatSummary> _chats = [];
  bool _isLoading = true;

  List<ChatSummary> get chats => _chats;
  bool get isLoading => _isLoading;

  int get totalUnreadCount {
    return _chats.fold(0, (sum, chat) => sum + chat.unreadCount);
  }

  ChatListViewModel({required this.userId}) {
    _listenToChats();
  }

  void _listenToChats() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.getChatList(userId).listen((data) {
      final List<ChatSummary> chatList = [];

      data.forEach((bookingId, value) {
        if (value is Map) {
          chatList.add(
              ChatSummary.fromMap(bookingId, Map<String, dynamic>.from(value)));
        }
      });

      // Sắp xếp theo timestamp mới nhất lên đầu
      chatList.sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp));

      _chats = chatList;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('❌ [ChatListViewModel] Lỗi stream chat list: $error');
      debugPrint('🔍 [ChatListViewModel] userId đang sử dụng: $userId');
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class ChatSummary {
  final String bookingId;
  final String lastMessage;
  final int lastTimestamp;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final int unreadCount;

  ChatSummary({
    required this.bookingId,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.unreadCount,
  });

  factory ChatSummary.fromMap(String bookingId, Map<String, dynamic> map) {
    return ChatSummary(
      bookingId: bookingId,
      lastMessage: map['lastMessage'] ?? '',
      lastTimestamp: map['lastTimestamp'] ?? 0,
      otherUserId: map['otherUserId'] ?? '',
      otherUserName: map['otherUserName'] ?? 'Người dùng',
      otherUserAvatar: map['otherUserAvatar'],
      unreadCount: map['unreadCount'] ?? 0,
    );
  }
}
