import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class MoMoInstructionCard extends StatelessWidget {
  const MoMoInstructionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hướng dẫn thanh toán:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStep(Icons.phone_android, '1. Mở ứng dụng MoMo'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStep(Icons.qr_code, '3. Quét mã QR'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStep(Icons.touch_app, '2. Chọn "Quét Mã"'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStep(Icons.check_circle_outline, '4. Xác nhận'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
