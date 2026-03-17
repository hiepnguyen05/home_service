import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/service_model.dart';
import '../../../../core/utils/icon_helper.dart';

class ServiceItemWidget extends StatelessWidget {
  final ServiceModel? service;
  final String? title;
  final String? subtitle;
  final String? iconName;
  final VoidCallback onTap;

  const ServiceItemWidget({
    super.key,
    this.service,
    this.title,
    this.subtitle,
    this.iconName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayIcon = iconName ?? service?.iconName ?? 'build';
    final displayTitle = title ?? service?.name ?? '';
    final displaySubtitle = subtitle ?? service?.description ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Biểu tượng
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconHelper.getIcon(displayIcon),
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Nội dung văn bản
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displaySubtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Biểu tượng mũi tên
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
