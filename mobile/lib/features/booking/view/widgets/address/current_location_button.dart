import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class CurrentLocationButton extends StatelessWidget {
  final VoidCallback onTap;

  const CurrentLocationButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.my_location, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text(
              "Sử dụng vị trí hiện tại",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
