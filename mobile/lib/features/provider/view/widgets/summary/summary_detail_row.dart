import 'package:flutter/material.dart';

class SummaryDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBoldValue;
  final Color? valueColor;
  final bool isLarge;

  const SummaryDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isBoldValue = true,
    this.valueColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: isLarge ? 16 : 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF1F2937),
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
                fontSize: isLarge ? 20 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
