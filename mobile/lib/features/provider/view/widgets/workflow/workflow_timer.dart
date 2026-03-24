import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class WorkflowTimer extends StatelessWidget {
  final int totalSeconds;

  const WorkflowTimer({super.key, required this.totalSeconds});

  @override
  Widget build(BuildContext context) {
    final int safeTotal = totalSeconds < 0 ? 0 : totalSeconds;
    final int hours = safeTotal ~/ 3600;
    final int minutes = (safeTotal % 3600) ~/ 60;
    final int seconds = safeTotal % 60;

    return Column(
      children: [
        const Text(
          "Thời gian làm việc",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeUnit(_formatNumber(hours), "Giờ"),
            _buildSeparator(),
            _buildTimeUnit(_formatNumber(minutes), "Phút"),
            _buildSeparator(),
            _buildTimeUnit(_formatNumber(seconds), "Giây"),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int number) => number.toString().padLeft(2, '0');

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 24),
      child: Text(
        ":",
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }
}
