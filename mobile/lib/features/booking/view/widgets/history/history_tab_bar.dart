import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class HistoryTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const HistoryTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem(
            index: 0,
            label: 'Đang diễn ra',
          ),
          _buildTabItem(
            index: 1,
            label: 'Đã hoàn thành',
          ),
          _buildTabItem(
            index: 2,
            label: 'Đã hủy',
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({required int index, required String label}) {
    final bool isActive = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.only(top: 12, bottom: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

