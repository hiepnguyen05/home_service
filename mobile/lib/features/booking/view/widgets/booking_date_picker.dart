import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart' show AppColors;

class BookingDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  const BookingDatePicker(
      {super.key, required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: CalendarDatePicker2(
        config: CalendarDatePicker2Config(
            firstDate: DateTime.now(),
            calendarType: CalendarDatePicker2Type.single,
            selectedDayHighlightColor: AppColors.primary,
            weekdayLabels: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'],
            weekdayLabelTextStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            dayTextStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            todayTextStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            controlsHeight: 50,
            controlsTextStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
        value: [selectedDate],
        onValueChanged: (dates) {
          if (dates.isNotEmpty && dates[0] != null) {
            onDateSelected(dates[0]!);
          }
        },
      ),
    );
  }
}
