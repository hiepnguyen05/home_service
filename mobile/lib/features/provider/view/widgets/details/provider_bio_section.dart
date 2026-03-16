import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class ProviderBioSection extends StatelessWidget {
  final String bio;
  final bool isEditing;
  final TextEditingController? controller;

  const ProviderBioSection({
    super.key,
    required this.bio,
    this.isEditing = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới thiệu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (isEditing)
          TextField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Nhập thông tin giới thiệu về bản thân...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
            style: const TextStyle(fontSize: 15, height: 1.5),
          )
        else
          Text(
            bio.isNotEmpty
                ? bio
                : 'Chưa có thông tin giới thiệu. Hãy cập nhật hồ sơ để khách hàng hiểu rõ hơn về bạn.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
      ],
    );
  }
}
