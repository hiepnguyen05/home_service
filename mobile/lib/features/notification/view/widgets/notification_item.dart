import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/notification/data/models/notification_model.dart';
import 'notification_actions.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final Function(NotificationModel, bool) onHandleCancel;
  final Function(NotificationModel, bool) onHandleExtraCost;
  final Function(NotificationModel) onGoHome;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onHandleCancel,
    required this.onHandleExtraCost,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;
    final IconData icon;
    final Color color;

    switch (notification.type) {
      case NotificationType.cancelRequest:
        icon = Icons.warning_rounded;
        color = Colors.orange;
        break;
      case NotificationType.cancelApproved:
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case NotificationType.cancelRejected:
        icon = Icons.cancel_rounded;
        color = Colors.red;
        break;
      case NotificationType.extraCostRequest:
        icon = Icons.add_circle_rounded;
        color = Colors.blue;
        break;
      case NotificationType.extraCostApproved:
        icon = Icons.beenhere_rounded;
        color = Colors.green;
        break;
      case NotificationType.extraCostRejected:
        icon = Icons.block_rounded;
        color = Colors.red;
        break;
      case NotificationType.bookingAccepted:
        icon = Icons.handshake_rounded;
        color = AppColors.primary;
        break;
      case NotificationType.bookingCompleted:
        icon = Icons.stars_rounded;
        color = Colors.purple;
        break;
      case NotificationType.chat:
        icon = Icons.chat_rounded;
        color = Colors.blue;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: AppColors.primary, blurRadius: 4),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatTimeAgo(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (notification.type == NotificationType.cancelRequest)
                      CancelRequestActions(
                        notification: notification,
                        onHandle: onHandleCancel,
                      ),
                    if (notification.type == NotificationType.cancelApproved)
                      CancelApprovedActions(
                        notification: notification,
                        onGoHome: onGoHome,
                      ),
                    if (notification.type == NotificationType.cancelRejected)
                      CancelRejectedActions(
                        notification: notification,
                        onMarkRead: onTap,
                      ),
                    if (notification.type == NotificationType.extraCostRequest)
                      ExtraCostRequestActions(
                        notification: notification,
                        onHandle: onHandleExtraCost,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return DateFormat('dd/MM, HH:mm').format(dateTime);
  }
}
