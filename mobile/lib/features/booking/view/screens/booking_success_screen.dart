import 'package:flutter/material.dart';
import 'package:mobile/features/booking/view/screens/order_tracking_screen.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../provider/data/models/provider_model.dart';
import '../../../payment/data/models/payment_method.dart';
import '../widgets/success/success_header.dart';
import '../widgets/success/order_info_card.dart';
import '../widgets/success/success_action_buttons.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String bookingId;
  final ProviderModel provider;
  final String serviceName;
  final DateTime bookingTime;
  final PaymentMethod paymentMethod;
  final int? travelTimeMinutes;

  const BookingSuccessScreen({
    super.key,
    required this.bookingId,
    required this.provider,
    required this.serviceName,
    required this.bookingTime,
    required this.paymentMethod,
    this.travelTimeMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: BackButton(
          color: AppColors.textPrimary,
          onPressed: () {
            // Quay về trang chủ, xóa luồng đặt lịch
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header (Icon, Tiêu đề, Phụ đề)
            SuccessHeader(
              paymentMethod: paymentMethod,
              bookingTime: bookingTime,
              travelTimeMinutes: travelTimeMinutes,
            ),

            const SizedBox(height: 32),

            // 2. Mã đơn hàng
            OrderInfoCard(bookingId: bookingId),

            const SizedBox(height: 32),

            // 3. Nút hành động
            SuccessActionButtons(
              provider: provider,
              bookingId: bookingId,
            ),

            const SizedBox(height: 32),

            // 4. Nút theo dõi đơn hàng
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingScreen(
                        booking: BookingModel(
                          id: bookingId,
                          customerId: "", // Placeholder or fetch if needed
                          providerId: provider.id,
                          serviceId: "", // Placeholder
                          scheduleAt: bookingTime,
                          address:
                              "", // Placeholder - BookingSuccess doesn't have address
                          status: BookingStatus.confirmed,
                          paymentMethod: paymentMethod == PaymentMethod.cash
                              ? BookingPaymentMethod.COD
                              : BookingPaymentMethod.eWallet,
                          createdAt: DateTime.now(),
                        ),
                        provider: provider,
                        serviceName: serviceName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined, color: Colors.white),
                label: const Text(
                  "Theo dõi đơn đặt lịch",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
