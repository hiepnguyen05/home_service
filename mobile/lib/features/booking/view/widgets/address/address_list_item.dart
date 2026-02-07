import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../address/data/models/address_model.dart';

class AddressListItem extends StatelessWidget {
  final AddressModel addressModel;
  final bool isSelected;
  final VoidCallback onTap;

  const AddressListItem(
      {super.key,
      required this.addressModel,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    String titleLower = addressModel.title.toLowerCase();

    if (titleLower.contains("nhà")) {
      iconData = Icons.home;
    } else if (titleLower.contains("văn phòng") ||
        titleLower.contains("công ty")) {
      iconData = Icons.work;
    } else {
      iconData = Icons.location_on;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            )),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(iconData, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addressModel.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  addressModel.fullAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                )
              ],
            )),
            isSelected
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
