import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/chat/data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final String? otherUserAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    this.otherUserAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: otherUserAvatar != null
                  ? CachedNetworkImageProvider(otherUserAvatar!)
                  : null,
              child: otherUserAvatar == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 8),
          ] else if (!isMe) ...[
            const SizedBox(
                width:
                    40), // Khoảng trống nếu avatar bị ẩn cho các tin nhắn liên tiếp
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Tin nhắn văn bản
                if (message.text.isNotEmpty &&
                    message.type != MessageType.image)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft:
                            isMe ? const Radius.circular(12) : Radius.zero,
                        bottomRight:
                            isMe ? Radius.zero : const Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe ? Colors.white : const Color(0xFF1F2937),
                        height: 1.4,
                      ),
                    ),
                  ),

                // Tin nhắn hình ảnh
                if (message.imageUrl != null) ...[
                  if (message.text.isNotEmpty &&
                      message.type == MessageType.image &&
                      isMe)
                    // Nếu là ảnh có kèm văn bản, hiển thị văn bản phía trên ảnh như mẫu thiết kế
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        message.text,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: message.imageUrl!,
                        width: MediaQuery.of(context).size.width * 0.6,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
