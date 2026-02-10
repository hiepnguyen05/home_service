import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback onNotificationTap;

  const HomeAppBar({
    super.key,
    required this.userName,
    this.avatarUrl,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                  avatarUrl ??
                      'https://ui-avatars.com/api/?name=User&background=random',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Greeting
          Expanded(
            child: Text(
              'Xin chào, $userName!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Notification Icon
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(
              Icons.notifications_none,
              size: 28,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
