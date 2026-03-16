import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile/features/notification/data/models/notification_model.dart';

class CancelRequestActions extends StatelessWidget {
  final NotificationModel notification;
  final Function(NotificationModel, bool) onHandle;

  const CancelRequestActions({
    super.key,
    required this.notification,
    required this.onHandle,
  });

  @override
  Widget build(BuildContext context) {
    final String bookingId = notification.data['bookingId'] ?? '';
    if (bookingId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<BookingModel>(
      stream: BookingRepository().streamBooking(bookingId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.status != BookingStatus.cancelPending) {
          return const SizedBox.shrink();
        }

        final booking = snapshot.data!;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final bool isCustomer = booking.customerId == currentUserId;

        if (!isCustomer) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onHandle(notification, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: Colors.grey.shade200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Từ chối", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onHandle(notification, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Đồng ý hủy", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CancelApprovedActions extends StatelessWidget {
  final NotificationModel notification;
  final Function(NotificationModel) onGoHome;

  const CancelApprovedActions({
    super.key,
    required this.notification,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final String bookingId = notification.data['bookingId'] ?? '';
    if (bookingId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<BookingModel>(
      stream: BookingRepository().streamBooking(bookingId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.status != BookingStatus.cancelled) {
          return const SizedBox.shrink();
        }

        final booking = snapshot.data!;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final bool isProvider = booking.providerId == currentUserId;

        if (!isProvider) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              const Divider(height: 1),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => onGoHome(notification),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Đóng & Về trang chủ", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CancelRejectedActions extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkRead;

  const CancelRejectedActions({
    super.key,
    required this.notification,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final String bookingId = notification.data['bookingId'] ?? '';
    if (bookingId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<BookingModel>(
      stream: BookingRepository().streamBooking(bookingId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final booking = snapshot.data!;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final bool isProvider = booking.providerId == currentUserId;

        if (!isProvider ||
            booking.status == BookingStatus.completed ||
            booking.status == BookingStatus.cancelled) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              const Divider(height: 1),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onMarkRead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Tiếp tục công việc", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExtraCostRequestActions extends StatelessWidget {
  final NotificationModel notification;
  final Function(NotificationModel, bool) onHandle;

  const ExtraCostRequestActions({
    super.key,
    required this.notification,
    required this.onHandle,
  });

  @override
  Widget build(BuildContext context) {
    final String bookingId = notification.data['bookingId'] ?? '';
    if (bookingId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<BookingModel>(
      stream: BookingRepository().streamBooking(bookingId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.extraCostStatus != 'pending') {
          return const SizedBox.shrink();
        }

        final booking = snapshot.data!;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final bool isCustomer = booking.customerId == currentUserId;

        if (!isCustomer) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onHandle(notification, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: Colors.grey.shade200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Từ chối", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onHandle(notification, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Chấp nhận", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
