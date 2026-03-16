import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile/features/notification/data/models/notification_model.dart';
import 'package:mobile/features/notification/data/repositories/notification_repository.dart';
import '../widgets/notification_item.dart';
import 'package:mobile/features/payment/viewmodel/payment_viewmodel.dart';
import 'package:mobile/features/payment/view/screens/momo_payment_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationRepository _notificationRepo = NotificationRepository();
  final BookingRepository _bookingRepo = BookingRepository();
  final PaymentViewModel _paymentViewModel = PaymentViewModel();
  bool _isExtraCostDialogShowing = false;
  String? _lastExtraCostNotificationId;

  @override
  void dispose() {
    _paymentViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          "Thông báo",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          StreamBuilder<int>(
            stream: _notificationRepo.streamUnreadCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              if (unreadCount == 0) return const SizedBox.shrink();
              return Center(
                child: TextButton(
                  onPressed: () => _notificationRepo.markAllAsRead(),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Đọc tất cả",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationRepo.streamNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 3));
          }
          final notifications = snapshot.data ?? [];
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _maybeShowExtraCostDialog(notifications);
          });
          if (notifications.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: notifications.length,
            cacheExtent: 1000,
            itemBuilder: (context, index) => NotificationItem(
              notification: notifications[index],
              onTap: () => _onNotificationTap(notifications[index]),
              onHandleCancel: _handleCancelResponse,
              onHandleExtraCost: _handleExtraCostResponse,
              onGoHome: _handleGoHome,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 20),
          const Text(
            "Hộp thư trống",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Bạn chưa có thông báo nào mới",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              "Có lỗi xảy ra",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _maybeShowExtraCostDialog(List<NotificationModel> notifications) {
    if (_isExtraCostDialogShowing) return;

    NotificationModel? target;
    for (final notification in notifications) {
      if ((notification.type == NotificationType.extraCostApproved ||
              notification.type == NotificationType.extraCostRejected) &&
          notification.id != _lastExtraCostNotificationId) {
        target = notification;
        break;
      }
    }

    if (target == null) return;
    _lastExtraCostNotificationId = target.id;
    _isExtraCostDialogShowing = true;

    _notificationRepo.markAsRead(target.id);

    final title = target.type == NotificationType.extraCostApproved
        ? 'Chi phí phát sinh đã được đồng ý'
        : 'Chi phí phát sinh bị từ chối';
    final content = target.body.isNotEmpty
        ? target.body
        : (target.type == NotificationType.extraCostApproved
            ? 'Khách hàng đã chấp nhận phần chi phí phát sinh. Vui lòng kiểm tra tổng chi phí và tiếp tục công việc.'
            : 'Khách hàng từ chối chi phí phát sinh. Hãy trao đổi lại và gửi yêu cầu mới nếu cần.');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    ).then((_) {
      _isExtraCostDialogShowing = false;
    });
  }

  void _onNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) {
      await _notificationRepo.markAsRead(notification.id);
    }
  }

  void _handleGoHome(NotificationModel notification) async {
    await _notificationRepo.markAsRead(notification.id);
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
    }
  }

  void _handleCancelResponse(NotificationModel notification, bool approved) async {
    final bookingId = notification.data['bookingId'] as String?;
    if (bookingId == null || bookingId.isEmpty) return;

    try {
      final booking = await _bookingRepo.getBookingById(bookingId);
      final prevStatus = booking?.startedAt != null ? BookingStatus.processing : BookingStatus.arrived;
      await BookingRepository().handleCancellationResponse(bookingId, approved, prevStatus);
      await _notificationRepo.markAsRead(notification.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approved ? "Đã xác nhận hủy đơn" : "Đã từ chối yêu cầu hủy"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleExtraCostResponse(NotificationModel notification, bool approved) async {
    final bookingId = notification.data['bookingId'] as String?;
    if (bookingId == null || bookingId.isEmpty) return;

    try {
      if (!approved) {
        // Just reject it
        await BookingRepository().handleExtraCostResponse(bookingId, false);
      } else {
        // Fetch booking to check payment method
        final booking = await _bookingRepo.getBookingById(bookingId);
        if (booking == null) throw Exception("Không tìm thấy đơn hàng");

        if (booking.paymentMethod == BookingPaymentMethod.COD) {
          // COD: Just approve
          await BookingRepository().handleExtraCostResponse(bookingId, true);
        } else {
          // Online: Need to pay via MoMo
          final extraAmount = booking.extraCostAmount ?? 0.0;
          if (extraAmount <= 0) throw Exception("Số tiền phát sinh không hợp lệ");

          final paymentResult = await _paymentViewModel.processMoMoPayment(
            bookingId: bookingId,
            amount: extraAmount,
            orderInfo: "Thanh toán chi phí phát sinh đơn hàng #${bookingId.substring(0, 8)}",
          );

          if (paymentResult != null && paymentResult.success && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => MoMoPaymentScreen(
                  paymentResult: paymentResult,
                  serviceName: "Chi phí phát sinh",
                  amount: extraAmount,
                  bookingId: bookingId,
                  onPaymentComplete: (success) async {
                    if (success) {
                      await BookingRepository().handleExtraCostResponse(bookingId, true);
                    }
                  },
                ),
              ),
            );
          } else {
            throw Exception(_paymentViewModel.errorMessage ?? "Lỗi khởi tạo thanh toán MoMo");
          }
        }
      }

      await _notificationRepo.markAsRead(notification.id);
      if (mounted) {
        final snackMessage = approved
            ? "Khách hàng đã đồng ý và thanh toán thành công"
            : "Khách hàng đã từ chối chi phí phát sinh";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackMessage),
            behavior: SnackBarBehavior.floating,
            backgroundColor: approved ? AppColors.primary : AppColors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}









