import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class InstantBookingOption extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const InstantBookingOption({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: 2.0, color: AppColors.primary)),
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flash_on,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Đặt lịch ngay bây giờ",
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            )),
          ),
          const SizedBox(height: 10),
          Text(
            "Dành cho khách hàng cần dịch vụ ngay lập tức",
            style: TextStyle(color: AppColors.textHint),
          )
        ],
      ),
    );
  }
}
