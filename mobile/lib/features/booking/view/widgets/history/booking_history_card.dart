import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/utils/icon_helper.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';

class BookingHistoryCard extends StatelessWidget {
  final BookingModel booking;
  final String serviceName;
  final String? serviceIconName;
  final VoidCallback onTap;
  final VoidCallback? onRate;
  final bool isReviewed;

  const BookingHistoryCard({
    super.key,
    required this.booking,
    required this.serviceName,
    this.serviceIconName,
    required this.onTap,
    this.onRate,
    this.isReviewed = false,
  });

  @override
  Widget build(BuildContext context) {
    final String shortId =
        booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id;
    final statusChip = _buildStatusChip(booking.status);
    final timeLabelAndValue = _buildTimeInfo(booking);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  IconHelper.getIcon(serviceIconName ?? 'build'),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName.isNotEmpty ? serviceName : 'Dịch vụ đã đặt',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mã đơn: #$shortId',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              statusChip,
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            color: AppColors.borderLight,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeLabelAndValue.$1,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                timeLabelAndValue.$2,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isOngoing(booking.status)
                          ? AppColors.primary
                          : Colors.transparent,
                      foregroundColor: _isOngoing(booking.status)
                          ? Colors.white
                          : AppColors.textPrimary,
                      elevation: 0,
                      side: BorderSide(
                        color: _isOngoing(booking.status)
                            ? AppColors.primary
                            : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (booking.status == BookingStatus.completed) ...[
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: isReviewed ? null : onRate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isReviewed ? Colors.grey : AppColors.primary,
                      side: BorderSide(color: isReviewed ? Colors.grey : AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isReviewed ? 'Đã đánh giá' : 'Đánh giá',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isReviewed ? Colors.grey : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  bool _isOngoing(String status) {
    return status == BookingStatus.pending ||
        status == BookingStatus.waitingPayment ||
        status == BookingStatus.incoming ||
        status == BookingStatus.arrived ||
        status == BookingStatus.processing ||
        status == BookingStatus.paused ||
        status == BookingStatus.cancelPending;
  }

  Widget _buildStatusChip(String status) {
    String label;
    Color bg;
    Color fg;

    switch (status) {
      case BookingStatus.incoming:
        label = 'Thợ đang đến';
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        break;
      case BookingStatus.pending:
      case BookingStatus.waitingPayment:
        label = 'Đang chờ xử lý';
        bg = const Color(0xFFFFEFD5);
        fg = const Color(0xFF92400E);
        break;
      case BookingStatus.processing:
      case BookingStatus.arrived:
      case BookingStatus.paused:
        label = 'Đang diễn ra';
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF047857);
        break;
      case BookingStatus.cancelPending:
        label = 'Chờ xác nhận hủy';
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFF9A3412);
        break;
      case BookingStatus.completed:
        label = 'Đã hoàn thành';
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF047857);
        break;
      case BookingStatus.cancelled:
        label = 'Đã hủy';
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
      default:
        label = 'Không rõ';
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF4B5563);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  (String, String) _buildTimeInfo(BookingModel booking) {
    final formatter = DateFormat('HH:mm dd/MM');

    if (_isOngoing(booking.status)) {
      return (
        'Thời gian đặt dịch vụ:',
        formatter.format(booking.scheduleAt),
      );
    }

    if (booking.status == BookingStatus.completed &&
        booking.completedAt != null) {
      return (
        'Hoàn thành lúc:',
        formatter.format(booking.completedAt!),
      );
    }

    if (booking.status == BookingStatus.cancelled) {
      return (
        'Đã hủy lúc:',
        formatter.format(booking.createdAt),
      );
    }

    return (
      'Thời gian đặt:',
      formatter.format(booking.scheduleAt),
    );
  }
}

