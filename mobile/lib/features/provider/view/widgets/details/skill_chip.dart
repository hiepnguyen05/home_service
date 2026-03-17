import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class SkillChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? price;
  final bool isEditing;
  final bool isActive;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const SkillChip({
    super.key,
    required this.label,
    required this.icon,
    this.price,
    this.isEditing = false,
    this.isActive = true,
    this.onDelete,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive 
              ? AppColors.primary.withOpacity(0.2) 
              : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive 
                  ? AppColors.primary.withOpacity(0.1) 
                  : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.grey[500],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label + (isActive ? '' : ' (Tạm ngưng)'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
                      fontSize: 13,
                      color: isActive ? AppColors.textSecondary : Colors.grey[400],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
              ],
            ),
          ),
          if (isEditing) ...[
            const SizedBox(width: 16),
            // Nút Tạm ngưng/Bật lại - Styled as small pill
            InkWell(
              onTap: onToggleStatus,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isActive ? Colors.orange : Colors.green).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 18,
                  color: isActive ? Colors.orange : Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Nút Xóa - Styled as small pill
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
