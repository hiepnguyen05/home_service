import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import '../jobs/job_item_card.dart';
import '../../screens/provider_check_in_screen.dart';
import '../../screens/provider_work_screen.dart';

class UpcomingJobsList extends StatelessWidget {
  final List<BookingModel> jobs;
  final Function(BookingModel)? onCompleteJob; // NEW

  const UpcomingJobsList({
    super.key,
    required this.jobs,
    this.onCompleteJob, // NEW
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Công việc sắp tới",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (jobs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Chưa có công việc nào sắp tới",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...jobs.map((job) => JobItemCard(
                  booking: job,
                  onTap: () {
                    if (job.status == BookingStatus.confirmed) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProviderCheckInScreen(booking: job),
                        ),
                      );
                    } else if (job.status == BookingStatus.arrived ||
                        job.status == BookingStatus.processing ||
                        job.status == BookingStatus.paused) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProviderWorkScreen(booking: job),
                        ),
                      );
                    }
                  },
                  onComplete:
                      onCompleteJob != null ? () => onCompleteJob!(job) : null,
                )),
        ],
      ),
    );
  }
}
