import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class SkillChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? price;
  final bool isEditing;
  final bool isActive;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;

  const SkillChip({
    super.key,
    required this.label,
    required this.icon,
    this.price,
    this.isEditing = false,
    this.isActive = true,
    this.onDelete,
    this.onEdit,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.grey[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.grey[200]! : Colors.grey[300]!,
          width: isActive ? 1 : 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : Colors.grey[500],
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label + (isActive ? '' : ' (Tạm ngưng)'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.textPrimary : Colors.grey[500],
                    decoration: isActive ? null : TextDecoration.lineThrough,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (price != null && price!.isNotEmpty)
                  Text(
                    price!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.grey[600] : Colors.grey[400],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
          if (isEditing) ...[
            const SizedBox(width: 8),
            const SizedBox(
              height: 20,
              child: VerticalDivider(width: 1, thickness: 1, color: Colors.grey),
            ),
            const SizedBox(width: 4),
            // Nút Tạm ngưng/Bật lại
            IconButton(
              onPressed: onToggleStatus,
              icon: Icon(
                isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                size: 18,
                color: isActive ? Colors.orange : Colors.green,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: isActive ? 'Tạm ngưng' : 'Hoạt động lại',
            ),
            const SizedBox(width: 8),
            // Nút Chỉnh sửa giá
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Sửa giá',
            ),
            const SizedBox(width: 8),
            // Nút Xóa
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Xóa dịch vụ',
            ),
          ],
        ],
      ),
    );
  }
}
