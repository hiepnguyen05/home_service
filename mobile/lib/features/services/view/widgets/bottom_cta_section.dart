import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_bottom_bar.dart'; // Import widget mới vừa tạo

class BottomCTASection extends StatelessWidget {
  final VoidCallback onBookingPressed;

  const BottomCTASection({
    super.key,
    required this.onBookingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Quan trọng: Chiếm chiều cao tối thiểu
      children: [
        // 1. PHẦN NÚT ĐẶT NGAY (Nổi lên trên)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            border: const Border(top: BorderSide(color: AppColors.borderLight)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: AppButton(
            text: 'Đặt ngay',
            onPressed: onBookingPressed,
            type: AppButtonType.primary,
            height: 54, // Chiều cao to hơn một chút cho nổi bật
          ),
        ),

        // 2. PHẦN MENU ĐIỀU HƯỚNG (Giả lập để giống Home)
        // Lưu ý: Ở màn hình chi tiết, thường ta không chuyển tab thật
        // mà chỉ hiển thị để user biết mình đang ở tab nào (thường là Home)
        AppBottomBar(
          currentIndex: 0, // Đang ở tab Home
          onTap: (index) {
            // Logic điều hướng nếu cần (thường là pop về MainScreen rồi switch tab)
            // Ví dụ: Navigator.of(context).popUntil(...)
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Lịch sử',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Hộp thư',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        ),
      ],
    );
  }
}

// Test main để xem trước giao diện
