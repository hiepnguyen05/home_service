import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import 'package:mobile/features/provider/data/models/provider_model.dart';

class SuccessActionButtons extends StatelessWidget {
  final ProviderModel provider;

  const SuccessActionButtons({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          icon: Icons.chat_bubble_outline,
          label: "Chat",
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Mở chat...")),
            );
          },
        ),
        _buildActionButton(
          context,
          icon: Icons.phone_outlined,
          label: "Gọi",
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gọi ${provider.name}...")),
            );
          },
        ),
        _buildActionButton(
          context,
          icon: Icons.cancel_outlined,
          label: "Hủy",
          onTap: () {
            _showCancelDialog(context);
          },
        ),
        _buildActionButton(
          context,
          icon: Icons.ios_share,
          label: "Chia sẻ",
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Chia sẻ...")),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hủy đơn hàng"),
        content: const Text(
          "Bạn có chắc chắn muốn hủy đơn hàng này không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Không"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã gửi yêu cầu hủy đơn")),
              );
            },
            child: const Text(
              "Hủy đơn",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
