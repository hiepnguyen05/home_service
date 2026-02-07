import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/payment_method.dart';

/// Widget hiển thị một option phương thức thanh toán
class PaymentMethodOption extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodOption({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _buildRadioIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (method.hasImageIcon) {
      return Image.network(
        method.iconUrl!,
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.error, size: 24),
      );
    } else {
      return Icon(
        method.icon,
        color: AppColors.textSecondary,
        size: 24,
      );
    }
  }

  Widget _buildRadioIndicator() {
    return Icon(
      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      color: isSelected ? AppColors.primary : AppColors.borderColor,
      size: 20,
    );
  }
}
