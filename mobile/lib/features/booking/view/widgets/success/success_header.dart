import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/utils/booking_utils.dart';
import 'package:mobile/features/payment/data/models/payment_method.dart';

class SuccessHeader extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final DateTime bookingTime;
  final int? travelTimeMinutes;

  const SuccessHeader({
    super.key,
    required this.paymentMethod,
    required this.bookingTime,
    this.travelTimeMinutes,
  });

  @override
  Widget build(BuildContext context) {
    String arrivalTime;

    // Nếu có thời gian di chuyển (từ màn hình xác nhận) và là đơn booking ngay (trong 1h tới)
    final now = DateTime.now();
    final difference = bookingTime.difference(now);
    final isImmediate = difference.inMinutes < 60;

    if (travelTimeMinutes != null && isImmediate) {
      arrivalTime = "$travelTimeMinutes - ${travelTimeMinutes! + 10} phút";
    } else {
      arrivalTime = BookingUtils.calculateArrivalTime(bookingTime);
    }

    // Determine title based on payment method (if needed, otherwise generic)
    final String title = "Đặt lịch thành công!";

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: "Thợ sẽ đến trong khoảng "),
              TextSpan(
                text: "$arrivalTime.",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
