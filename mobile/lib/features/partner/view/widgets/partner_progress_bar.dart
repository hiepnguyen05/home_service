import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PartnerProgressBar extends StatelessWidget {
  final int currentStep; // 1-indexed

  const PartnerProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final step = index + 1;
        final isActive = step <= currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < 3) const SizedBox(width: 8),
            ],
          ),
        );
      }),
    );
  }
}
