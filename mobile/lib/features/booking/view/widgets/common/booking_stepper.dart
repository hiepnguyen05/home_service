import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class BookingStepper extends StatelessWidget {
  final int currentStep; // 0..3

  const BookingStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        Color color = index <= currentStep
            ? AppColors.primary
            : AppColors.primary.withOpacity(0.3);

        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
