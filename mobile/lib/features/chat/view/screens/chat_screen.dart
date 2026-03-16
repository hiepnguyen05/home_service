import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:mobile/core/constants/app_colors.dart'; // Không sử dụng
import 'package:mobile/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:mobile/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:mobile/features/chat/data/models/message_model.dart';
import 'package:mobile/features/chat/view/widgets/chat_app_bar.dart';
import 'package:mobile/features/chat/view/widgets/message_bubble.dart';
import 'package:mobile/features/chat/view/widgets/quick_actions_bar.dart';
import 'package:mobile/features/chat/view/widgets/chat_input_bar.dart';

class ChatScreen extends StatelessWidget {
  final String bookingId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? targetUserId; // Thêm biến này

  const ChatScreen({
    super.key,
    required this.bookingId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.targetUserId, // Thêm vào constructor
  });

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final currentUser = authViewModel.currentUser;
    final currentUserId = currentUser?.uid ?? '';

    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(
        bookingId: bookingId,
        currentUserId: currentUserId,
        currentUserName: currentUser?.fullName,
        currentUserAvatar: currentUser?.avatarUrl,
        targetUserId: targetUserId,
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9), // Màu nền xám xanh nhạt, hiện đại hơn
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 10),
          child: ChatAppBar(
            userName: otherUserName,
            avatarUrl: otherUserAvatar,
            onBack: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Lịch sử trò chuyện
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading && viewModel.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.messages.isEmpty) {
                    return Center(
                      child: Text(
                        "Hãy bắt đầu cuộc trò chuyện",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true, // Hiển thị tin nhắn mới nhất ở dưới
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = viewModel.messages[index];
                      final isMe = message.senderId == currentUserId;

                      // Kiểm tra xem nên hiển thị tin nhắn hệ thống hay bong bóng tin nhắn
                      if (message.type == MessageType.system) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              message.text,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }

                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                        showAvatar: !isMe,
                        otherUserAvatar: otherUserAvatar,
                      );
                    },
                  );
                },
              ),
            ),

            // Phần chân trang
            const QuickActionsBar(),
            const ChatInputBar(),
          ],
        ),
      ),
    );
  }
}
