import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class ExtraCostInstructions extends StatelessWidget {
  const ExtraCostInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Hướng dẫn dành cho thợ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem("Nhập chính xác số tiền phát sinh thực tế."),
          _buildInstructionItem("Mô tả chi tiết lý do phát sinh (ví dụ: mua thêm vật tư, thay đổi yêu cầu)."),
          _buildInstructionItem("Khách hàng sẽ nhận được thông báo và cần đồng ý để cập nhật hóa đơn."),
          _buildInstructionItem("Chỉ thực hiện phần việc phát sinh sau khi khách hàng đã xác nhận."),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
