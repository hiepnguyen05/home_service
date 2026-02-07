import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum FailureType {
  bookingFailed,
  paymentCancelled,
  paymentFailed,
  timeout,
}

class BookingFailureScreen extends StatelessWidget {
  final FailureType failureType;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const BookingFailureScreen({
    super.key,
    required this.failureType,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Thông báo"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: BackButton(
          color: AppColors.textPrimary,
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Spacer(),

              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _getIconBgColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(),
                  size: 50,
                  color: _getIconBgColor(),
                ),
              ),

              const SizedBox(height: 24),

              // Tiêu đề
              Text(
                _getTitle(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Phụ đề
              Text(
                _getSubtitle(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const Spacer(),

              // Nút thử lại (nếu có)
              if (onRetry != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Thử lại',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Nút về trang chủ
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Về trang chủ',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (failureType) {
      case FailureType.bookingFailed:
        return Icons.event_busy;
      case FailureType.paymentCancelled:
        return Icons.cancel_outlined;
      case FailureType.paymentFailed:
        return Icons.payment;
      case FailureType.timeout:
        return Icons.timer_off;
    }
  }

  Color _getIconBgColor() {
    switch (failureType) {
      case FailureType.bookingFailed:
        return Colors.red;
      case FailureType.paymentCancelled:
        return Colors.orange;
      case FailureType.paymentFailed:
        return Colors.red;
      case FailureType.timeout:
        return Colors.orange;
    }
  }

  String _getTitle() {
    switch (failureType) {
      case FailureType.bookingFailed:
        return 'Đặt lịch thất bại';
      case FailureType.paymentCancelled:
        return 'Đã hủy thanh toán';
      case FailureType.paymentFailed:
        return 'Thanh toán thất bại';
      case FailureType.timeout:
        return 'Hết thời gian thanh toán';
    }
  }

  String _getSubtitle() {
    switch (failureType) {
      case FailureType.bookingFailed:
        return 'Có lỗi xảy ra khi đặt lịch.\nVui lòng thử lại sau.';
      case FailureType.paymentCancelled:
        return 'Bạn đã hủy giao dịch thanh toán.\nĐơn đặt lịch của bạn chưa được xác nhận.';
      case FailureType.paymentFailed:
        return 'Thanh toán không thành công.\nVui lòng kiểm tra lại thông tin thanh toán.';
      case FailureType.timeout:
        return 'Đã quá thời gian thanh toán.\nVui lòng đặt lịch lại nếu cần.';
    }
  }
}
