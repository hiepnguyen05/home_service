import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../provider/data/models/provider_model.dart';

class ProviderListItem extends StatelessWidget {
  final ProviderModel provider;
  final bool isSelected;
  final double? distanceKm; // Khoảng cách đã tính toán
  final int? travelTimeMinutes; // Thời gian di chuyển ước tính
  final String priceUnit; // Đơn vị giá: giờ, lần, m²...
  final VoidCallback onTap;
  final VoidCallback onChat;

  const ProviderListItem({
    super.key,
    required this.provider,
    required this.isSelected,
    this.distanceKm,
    this.travelTimeMinutes,
    this.priceUnit = 'lần', // Default
    required this.onTap,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    // Format giá tiền: 250000 -> 250k
    String formattedPrice = "${(provider.price / 1000).toStringAsFixed(0)}k";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // AVATAR
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey, // Background color placeholder
              ),
              child: ClipOval(
                child: (provider.avatarUrl.isNotEmpty &&
                        (provider.avatarUrl.startsWith('http') ||
                            provider.avatarUrl.startsWith('file')))
                    ? Image.network(
                        provider.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, color: Colors.white);
                        },
                      )
                    : const Icon(Icons.person, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),

            // INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Row 1: Khoảng cách & Thời gian
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.textSecondary),
                      Text(
                        "${distanceKm?.toStringAsFixed(1) ?? '?'} km",
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      if (travelTimeMinutes != null) ...[
                        const Text(
                          "•",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Text(
                          "~$travelTimeMinutes phút",
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Row 2: Đánh giá & Giá tiền
                  Row(
                    children: [
                      // Rating
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        "${provider.rating}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      // Divider
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 1,
                        height: 12,
                        color: Colors.grey[300],
                      ),

                      // Price
                      Text(
                        formattedPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "/$priceUnit",
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // ACTIONS
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chat Button
                IconButton(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: AppColors.primary,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 8),

                // Select Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check, color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        isSelected ? "Đã chọn" : "Chọn",
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
