import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import 'package:mobile/features/provider/data/models/provider_model.dart';
import 'package:mobile/features/chat/view/screens/chat_screen.dart';
import 'package:mobile/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';

class SuccessActionButtons extends StatefulWidget {
  final ProviderModel provider;
  final String bookingId;

  const SuccessActionButtons({
    super.key,
    required this.provider,
    required this.bookingId,
  });

  @override
  State<SuccessActionButtons> createState() => _SuccessActionButtonsState();
}

class _SuccessActionButtonsState extends State<SuccessActionButtons> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BookingModel>(
      stream: BookingRepository().streamBooking(widget.bookingId),
      builder: (context, snapshot) {
        final booking = snapshot.data;
        final bool canCancel = booking == null ||
            (booking.status != BookingStatus.arrived &&
             booking.status != BookingStatus.processing &&
             booking.status != BookingStatus.paused &&
             booking.status != BookingStatus.completed &&
             booking.status != BookingStatus.cancelPending);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActionButton(
                context,
                icon: Icons.chat_bubble_outline,
                label: "Chat",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        bookingId: widget.bookingId,
                        targetUserId: widget.provider.id,
                        otherUserName: widget.provider.name,
                        otherUserAvatar: widget.provider.avatarUrl,
                      ),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.phone_outlined,
                label: "Gọi",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gọi ${widget.provider.name}...")),
                  );
                },
              ),
              if (canCancel)
                _buildActionButton(
                  context,
                  icon: Icons.cancel_outlined,
                  label: "Hủy",
                  onTap: () {
                    _showCancelDialog(context);
                  },
                ),
              _buildActionButton(
                context,
                icon: Icons.ios_share,
                label: "Chia sẻ",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Chia sẻ...")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min, // CRITICAL: prevent infinite height
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    bool isCancelling = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text("Hủy đơn hàng"),
          content: const Text(
            "Bạn có chắc chắn muốn hủy đơn hàng này không?",
          ),
          actions: [
            TextButton(
              onPressed: isCancelling ? null : () => Navigator.pop(dialogCtx),
              child: const Text("Không"),
            ),
            TextButton(
              onPressed: isCancelling ? null : () async {
                setDialogState(() => isCancelling = true);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await BookingRepository().updateBookingStatus(widget.bookingId, BookingStatus.cancelled);
                  if (dialogCtx.mounted) {
                    Navigator.pop(dialogCtx);
                  }
                  messenger.showSnackBar(
                    const SnackBar(content: Text("Hủy đơn hàng thành công")),
                  );
                  if (mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                } catch (e) {
                  setDialogState(() => isCancelling = false);
                  messenger.showSnackBar(
                    SnackBar(content: Text("Lỗi: $e")),
                  );
                }
              },
              child: isCancelling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Hủy đơn",
                      style: TextStyle(color: Colors.red),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
