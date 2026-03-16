import 'package:flutter/material.dart';

class SummarySuccessHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SummarySuccessHeader({
    super.key,
    this.title = "Hoàn thành công việc!",
    this.subtitle = "Cảm ơn bạn đã hoàn thành dịch vụ xuất sắc.",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check,
              size: 40,
              color: Color(0xFF4CAF50),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
