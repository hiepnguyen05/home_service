import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

enum ProviderFilter {
  nearest, // Gần nhất
  topRated, // Đánh giá cao
  lowPrice, // Giá thấp
}

class ProviderFilterBar extends StatelessWidget {
  final ProviderFilter selectedFilter;
  final Function(ProviderFilter) onFilterChanged;

  const ProviderFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            label: "Gần nhất",
            isActive: selectedFilter == ProviderFilter.nearest,
            icon: Icons.near_me,
            onTap: () => onFilterChanged(ProviderFilter.nearest),
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            label: "Đánh giá cao",
            isActive: selectedFilter == ProviderFilter.topRated,
            icon: Icons.star,
            onTap: () => onFilterChanged(ProviderFilter.topRated),
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            label: "Giá thấp",
            isActive: selectedFilter == ProviderFilter.lowPrice,
            icon: Icons.attach_money,
            onTap: () => onFilterChanged(ProviderFilter.lowPrice),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.primary.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border:
              isActive ? Border.all(color: AppColors.primary, width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
