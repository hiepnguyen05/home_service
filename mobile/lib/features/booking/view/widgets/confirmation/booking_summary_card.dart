import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';

class BookingSummaryCard extends StatelessWidget {
  final String serviceName;
  final String providerName;
  final DateTime bookingTime;
  final String address;

  const BookingSummaryCard({
    super.key,
    required this.serviceName,
    required this.providerName,
    required this.bookingTime,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm, dd/MM/yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRow(Icons.build, "Dịch vụ", serviceName),
          const SizedBox(height: 12),
          _buildRow(Icons.person, "Thợ thực hiện", providerName),
          const SizedBox(height: 12),
          _buildRow(Icons.calendar_today, "Ngày & Giờ",
              dateFormat.format(bookingTime)),
          const SizedBox(height: 12),
          _buildRow(Icons.location_on, "Địa chỉ", address),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
