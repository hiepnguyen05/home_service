import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/utils/formatters.dart';
import 'package:mobile/features/partner/data/models/partner_request_model.dart';
import 'package:mobile/features/provider/view/widgets/details/skill_chip.dart';

class ProviderSkillsSection extends StatelessWidget {
  final List<PartnerServiceRequest> services;
  final bool isEditing;
  final bool isUpdatePending;
  final VoidCallback onAddService;
  final Function(int) onDeleteService;
  final Function(int) onEditService;
  final Function(int) onToggleService;
  final IconData Function(String?, String) getSkillIcon;

  const ProviderSkillsSection({
    super.key,
    required this.services,
    required this.isEditing,
    required this.isUpdatePending,
    required this.onAddService,
    required this.onDeleteService,
    required this.onEditService,
    required this.onToggleService,
    required this.getSkillIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kỹ năng chuyên môn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (isEditing)
              InkWell(
                onTap: onAddService,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Thêm kỹ năng',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (isUpdatePending)
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Yêu cầu thay đổi giá hoặc thêm dịch vụ đang chờ duyệt. Việc tạm ngưng/xóa có hiệu lực ngay.',
                    style: TextStyle(color: Colors.orange[800], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (services.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: services.asMap().entries.map((entry) {
              final index = entry.key;
              final s = entry.value;
              final priceStr = s.price.isNotEmpty
                  ? AppFormatters.formatCurrency(double.tryParse(s.price) ?? 0)
                  : null;
              
              return SkillChip(
                label: s.serviceName,
                price: priceStr,
                icon: getSkillIcon(s.iconName, s.serviceName),
                isEditing: isEditing,
                isActive: s.isActive,
                onDelete: () => onDeleteService(index),
                onEdit: () => onEditService(index),
                onToggleStatus: () => onToggleService(index),
              );
            }).toList(),
          )
        else
          Text(
            'Chưa cập nhật kỹ năng',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
      ],
    );
  }
}


