import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class ProviderStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ProviderStatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ProviderStatsGrid extends StatelessWidget {
  final int workCount;
  final String satisfactionRate;
  final String responseTime;

  const ProviderStatsGrid({
    super.key,
    required this.workCount,
    this.satisfactionRate = '98%',
    this.responseTime = '30p',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ProviderStatsCard(icon: Icons.engineering, value: '$workCount+', label: 'Công việc'),
          Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
          ProviderStatsCard(icon: Icons.thumb_up, value: satisfactionRate, label: 'Hài lòng'),
          Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
          ProviderStatsCard(icon: Icons.schedule, value: responseTime, label: 'Phản hồi'),
        ],
      ),
    );
  }
}
