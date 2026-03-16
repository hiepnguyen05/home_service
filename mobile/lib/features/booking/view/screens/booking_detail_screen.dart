import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/provider/data/models/provider_model.dart';
import 'package:mobile/features/provider/view/widgets/summary/summary_card.dart';
import 'package:mobile/features/provider/view/widgets/summary/summary_detail_row.dart';
import 'package:mobile/features/provider/view/widgets/summary/summary_success_header.dart';
import 'package:mobile/features/provider/view/widgets/summary/payment_status_badge.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;
  final ProviderModel provider;
  final String serviceName;

  const BookingDetailScreen({
    super.key,
    required this.booking,
    required this.provider,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final double basePrice = booking.totalPrice;
    final double extraCost = booking.extraCostAmount ?? 0.0;
    final double totalPaid = basePrice + extraCost;

    final isHourly = booking.totalWorkingSeconds > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SummarySuccessHeader(),
            const SizedBox(height: 32),

            // Service Info
            SummaryCard(
              title: "Thông tin dịch vụ",
              children: [
                SummaryDetailRow(label: "Dịch vụ:", value: serviceName),
                SummaryDetailRow(label: "Thợ thực hiện:", value: provider.name),
                SummaryDetailRow(
                  label: "Ngày thực hiện:",
                  value: dateFormat.format(booking.scheduleAt),
                ),
                SummaryDetailRow(label: "Địa chỉ:", value: booking.address),
                if (isHourly)
                  SummaryDetailRow(
                    label: "Thời gian làm việc:",
                    value: booking.totalWorkingSeconds >= 3600
                        ? "${(booking.totalWorkingSeconds / 3600.0).toStringAsFixed(1)} giờ"
                        : "${(booking.totalWorkingSeconds / 60.0).toStringAsFixed(1)} phút",
                    valueColor: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Payment Details
            SummaryCard(
              title: "Chi tiết thanh toán",
              children: [
                SummaryDetailRow(
                  label: isHourly ? "Giá dịch vụ (theo giờ):" : "Giá dịch vụ:",
                  value: currencyFormat.format(basePrice),
                ),
                if (extraCost > 0)
                  SummaryDetailRow(
                    label: "Chi phí phát sinh:",
                    value: currencyFormat.format(extraCost),
                    isBoldValue: true,
                  ),
                if (booking.extraCostDescription != null &&
                    booking.extraCostDescription!.isNotEmpty)
                  SummaryDetailRow(
                    label: "Mô tả phát sinh:",
                    value: booking.extraCostDescription!,
                  ),
                const Divider(color: Color(0xFFF3F4F6), height: 24),
                SummaryDetailRow(
                  label: "Tổng cộng đã thanh toán:",
                  value: currencyFormat.format(totalPaid),
                  valueColor: const Color(0xFF4CAF50),
                  isLarge: true,
                ),
                const SizedBox(height: 16),
                Center(
                  child: PaymentStatusBadge(paymentMethod: booking.paymentMethod),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Helpful text
            const Text(
              "Cảm ơn bạn đã sử dụng dịch vụ của HomeService!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
