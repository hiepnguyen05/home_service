import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class BookingTimeSlot extends StatelessWidget {
  final String title;
  final List<String> timeSlots;
  final String? selectedTime;
  final Function(String) onTimeSelected;
  final List<String>? enabledSlots;

  const BookingTimeSlot(
      {super.key,
      required this.title,
      required this.timeSlots,
      required this.selectedTime,
      required this.onTimeSelected,
      this.enabledSlots});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: timeSlots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final time = timeSlots[index];
            final isSelected = selectedTime == time;

            // Kiểm tra xem giờ có được phép chọn không
            final isEnabled =
                enabledSlots == null || enabledSlots!.contains(time);

            return InkWell(
              onTap: isEnabled
                  ? () => onTimeSelected(time)
                  : null, // Disable nếu không được phép
              borderRadius: BorderRadius.circular(12),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isEnabled ? Colors.white : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isEnabled
                            ? Colors.grey.shade300
                            : Colors.transparent),
                  ),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isEnabled ? AppColors.textPrimary : Colors.grey),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
