import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class IncomeChartSection extends StatefulWidget {
  final List<double> weeklyChartData;
  final double weeklyTotal;
  final double monthlyTotal;

  const IncomeChartSection({
    super.key,
    required this.weeklyChartData,
    required this.weeklyTotal,
    required this.monthlyTotal,
  });

  @override
  State<IncomeChartSection> createState() => _IncomeChartSectionState();
}

class _IncomeChartSectionState extends State<IncomeChartSection> {
  String _timeframe = 'Tuần';

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeframe Selector
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildTimeframeButton('Tuần'),
              _buildTimeframeButton('Tháng'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        Text(
          'Tổng thu nhập $_timeframe',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              currencyFormat.format(_timeframe == 'Tuần' ? widget.weeklyTotal : widget.monthlyTotal),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Custom Bar Chart
        SizedBox(
          height: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.weeklyChartData.length, (index) {
              final isHighlighted = index == 5; // T7 highlight as per design
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 32,
                    height: 140 * widget.weeklyChartData[index],
                    decoration: BoxDecoration(
                      color: isHighlighted ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                      color: isHighlighted ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeButton(String label) {
    final isSelected = _timeframe == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _timeframe = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
