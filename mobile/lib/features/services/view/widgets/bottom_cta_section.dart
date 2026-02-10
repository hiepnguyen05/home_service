import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class BottomCTASection extends StatelessWidget {
  final VoidCallback onBookingPressed;

  const BottomCTASection({
    super.key,
    required this.onBookingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: AppButton(
        text: 'Đặt ngay',
        onPressed: onBookingPressed,
        type: AppButtonType.primary,
        height: 54, // Chiều cao lớn hơn một chút để nổi bật
      ),
    );
  }
}
