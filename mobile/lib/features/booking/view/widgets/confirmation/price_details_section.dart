import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';

class PriceDetailsSection extends StatelessWidget {
  final double servicePrice;
  final double platformFee;

  const PriceDetailsSection({
    super.key,
    required this.servicePrice,
    required this.platformFee,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRow("Giá dịch vụ", servicePrice, currencyFormatter),
          // const SizedBox(height: 12),
          // _buildRow("Phí nền tảng", platformFee, currencyFormatter),
          // const Divider(height: 24),
          // _buildRow("Tổng cộng", servicePrice + platformFee, currencyFormatter,
          //     isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double value, NumberFormat formatter,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color:
                isHighlight ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          formatter.format(value),
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
