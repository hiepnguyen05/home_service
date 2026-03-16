import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:intl/intl.dart';

class TrackingTimeline extends StatelessWidget {
  final BookingModel booking;

  const TrackingTimeline({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // Current status index logic
    int currentStep = 0;
    if (booking.status == BookingStatus.confirmed ||
        booking.status == BookingStatus.waitingPayment) {
      currentStep = 0; // Đã xác nhận
    } else if (booking.status == BookingStatus.incoming ||
        booking.status == BookingStatus.accepted) {
      currentStep = 1; // Đang đến
    } else if (booking.status == BookingStatus.arrived) {
      currentStep = 2; // Đã đến nơi
    } else if (booking.status == BookingStatus.processing ||
        booking.status == BookingStatus.paused) {
      currentStep = 3; // Đang thực hiện
    } else if (booking.status == BookingStatus.completed) {
      currentStep = 4; // Hoàn thành
    } else if (booking.status == BookingStatus.pending) {
      currentStep = -1; // Chưa xác nhận
    }

    // Fix status logic for timeline
    final steps = [
      _TimelineStep(
        title: "Đã xác nhận",
        time: DateFormat('HH:mm, dd/MM').format(booking.createdAt),
        isActive: true, // Always active if we are here (from success screen)
        isCompleted: currentStep > 0,
        isPulse: currentStep == 0,
      ),
      _TimelineStep(
        title: "Đang đến",
        subtitle: "Thợ đang trên đường di chuyển đến địa chỉ của bạn",
        isActive: currentStep >= 1,
        isCompleted: currentStep > 1,
        isPulse: currentStep == 1,
      ),
      _TimelineStep(
        title: "Đã đến nơi",
        subtitle: "Thợ đã có mặt tại địa điểm làm việc",
        isActive: currentStep >= 2,
        isCompleted: currentStep > 2,
        isPulse: currentStep == 2,
      ),
      _TimelineStep(
        title: "Đang thực hiện",
        subtitle: booking.status == BookingStatus.paused 
            ? "Công việc đang tạm dừng" 
            : "Thợ đang tiến hành công việc",
        isActive: currentStep >= 3,
        isCompleted: currentStep > 3,
        isPulse: currentStep == 3,
      ),
      _TimelineStep(
        title: "Hoàn thành",
        isActive: currentStep >= 4,
        isCompleted: currentStep >= 4,
      ),
    ];

    return Stack(
      children: [
        // Line background
        Positioned(
          left: 11,
          top: 8,
          bottom: 24,
          width: 2,
          child: Container(color: Colors.grey.shade200),
        ),
        // Active Line
        Positioned(
          left: 11,
          top: 8,
          // Calculate height based on active steps (approximate)
          height: (currentStep + 1) * 88.0, // Updated height per item
          width: 2,
          child: Container(color: AppColors.primary),
        ),
        Column(
          children: steps.map((step) => _buildTimelineItem(step)).toList(),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(_TimelineStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot
          SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (step.isPulse)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                  ),
                Container(
                  width: step.isActive ? 12 : 12, // Fixed size
                  height: step.isActive ? 12 : 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isActive
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    border: step.isActive
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    boxShadow: step.isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: step.isCompleted
                      ? const Icon(Icons.check, size: 8, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: step.isActive
                        ? (step.isPulse
                            ? AppColors.primary
                            : AppColors.textPrimary)
                        : Colors.grey.shade400,
                    height: 1,
                  ),
                ),
                if (step.subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    step.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: step.isActive
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
                if (step.time != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    step.time!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String title;
  final String? subtitle;
  final String? time;
  final bool isActive;
  final bool isCompleted;
  final bool isPulse;

  _TimelineStep({
    required this.title,
    this.subtitle,
    this.time,
    required this.isActive,
    this.isCompleted = false,
    this.isPulse = false,
  });
}
