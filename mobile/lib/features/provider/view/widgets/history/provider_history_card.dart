import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/utils/icon_helper.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';

class ProviderHistoryCard extends StatefulWidget {
  final BookingModel booking;
  final String serviceName;
  final String? serviceIconName;
  final VoidCallback onTap;

  const ProviderHistoryCard({
    super.key,
    required this.booking,
    required this.serviceName,
    this.serviceIconName,
    required this.onTap,
  });

  @override
  State<ProviderHistoryCard> createState() => _ProviderHistoryCardState();
}

class _ProviderHistoryCardState extends State<ProviderHistoryCard> {
  final AuthRepository _authRepository = AuthRepository();
  UserModel? _customer;
  bool _isLoadingCustomer = true;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    if (widget.booking.customerId.isEmpty) {
      setState(() => _isLoadingCustomer = false);
      return;
    }
    try {
      final customer = await _authRepository.getUserById(widget.booking.customerId);
      if (mounted) {
        setState(() {
          _customer = customer;
          _isLoadingCustomer = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCustomer = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String shortId =
        widget.booking.id.length > 8 ? widget.booking.id.substring(0, 8) : widget.booking.id;
    final statusChip = _buildStatusChip(widget.booking.status);
    final timeLabelAndValue = _buildTimeInfo(widget.booking);

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
                  IconHelper.getIcon(widget.serviceIconName ?? 'build'),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.serviceName.isNotEmpty ? widget.serviceName : 'Dịch vụ đã đặt',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isLoadingCustomer 
                        ? 'Đang tải khách hàng...' 
                        : 'Khách hàng: ${_customer?.fullName ?? 'Chưa rõ'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
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
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isOngoing(widget.booking.status)
                    ? AppColors.primary
                    : Colors.transparent,
                foregroundColor: _isOngoing(widget.booking.status)
                    ? Colors.white
                    : AppColors.textPrimary,
                elevation: 0,
                side: BorderSide(
                  color: _isOngoing(widget.booking.status)
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
        label = 'Đang đến';
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        break;
      case BookingStatus.pending:
      case BookingStatus.waitingPayment:
        label = 'Chờ xử lý';
        bg = const Color(0xFFFFEFD5);
        fg = const Color(0xFF92400E);
        break;
      case BookingStatus.processing:
      case BookingStatus.arrived:
      case BookingStatus.paused:
        label = 'Đang làm';
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF047857);
        break;
      case BookingStatus.cancelPending:
        label = 'Chờ hủy';
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFF9A3412);
        break;
      case BookingStatus.completed:
        label = 'Hoàn thành';
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
        'Dự kiến:',
        formatter.format(booking.scheduleAt),
      );
    }

    if (booking.status == BookingStatus.completed &&
        booking.completedAt != null) {
      return (
        'Hoàn thành:',
        formatter.format(booking.completedAt!),
      );
    }

    if (booking.status == BookingStatus.cancelled) {
      return (
        'Đã hủy:',
        formatter.format(booking.createdAt),
      );
    }

    return (
      'Thời gian:',
      formatter.format(booking.scheduleAt),
    );
  }
}
