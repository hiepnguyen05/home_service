import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/distance_service.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../provider/data/models/provider_model.dart';
import '../../../payment/payment.dart';
import '../../viewmodel/booking_viewmodel.dart';
import '../widgets/confirmation/booking_summary_card.dart';
import '../widgets/confirmation/price_details_section.dart';
import '../widgets/confirmation/extra_cost_warning.dart';
import 'booking_success_screen.dart';
import '../widgets/common/booking_stepper.dart';

import '../../../../features/payment/viewmodel/payment_viewmodel.dart';
import '../../../../features/payment/view/screens/momo_payment_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final ProviderModel provider;
  final String serviceName;
  final String serviceId;
  final DateTime bookingTime;
  final double userLat;
  final double userLng;
  final String address;

  const BookingConfirmationScreen({
    super.key,
    required this.provider,
    required this.serviceName,
    required this.serviceId,
    required this.bookingTime,
    required this.userLat,
    required this.userLng,
    required this.address,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  late BookingViewModel _bookingViewModel;
  late PaymentViewModel _paymentViewModel;

  @override
  void initState() {
    super.initState();
    _bookingViewModel = BookingViewModel();
    _paymentViewModel = PaymentViewModel();
  }

  @override
  void dispose() {
    _bookingViewModel.dispose();
    _paymentViewModel.dispose();
    super.dispose();
  }

  void _navigateToSuccess(BuildContext context, dynamic booking) {
    // Tính thời gian di chuyển
    final distance = DistanceService.calculateDistance(widget.userLat,
        widget.userLng, widget.provider.latitude, widget.provider.longitude);
    final travelTimeMinutes = DistanceService.calculateTravelTime(distance);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(
          bookingId: booking.id,
          provider: widget.provider,
          serviceName: widget.serviceName,
          bookingTime: booking.scheduleAt,
          paymentMethod: _bookingViewModel.paymentMethod,
          travelTimeMinutes: travelTimeMinutes,
        ),
      ),
    );
  }

  /// Xử lý quy trình đặt lịch và thanh toán
  Future<void> _handleBookingProcess() async {
    // Hiển thị loading
    DialogUtils.showLoading(context, message: "Đang xử lý...");

    // 1. Tạo đơn đặt lịch trước (luôn cần thiết)
    final totalPrice =
        _bookingViewModel.calculateTotalPrice(widget.provider.price);
    final booking = await _bookingViewModel.createBooking(
      provider: widget.provider,
      serviceId: widget.serviceId,
      scheduledAt: widget.bookingTime,
      address: widget.address,
      totalPrice: totalPrice,
    );

    // Kiểm tra tạo đơn thành công
    if (booking == null) {
      if (mounted) {
        DialogUtils.hideLoading(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(_bookingViewModel.error ?? "Có lỗi xảy ra khi đặt lịch"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 2. Xử lý thanh toán
    if (_bookingViewModel.paymentMethod == PaymentMethod.momo) {
      // Đóng loading ban đầu
      if (mounted) {
        DialogUtils.hideLoading(context);
      }

      // Bắt đầu quy trình MoMo
      if (mounted) {
        final paymentResult = await _paymentViewModel.processMoMoPayment(
          bookingId: booking.id,
          amount: totalPrice,
          orderInfo: "Thanh toan dich vu ${widget.serviceName}",
        );

        if (paymentResult != null && mounted) {
          // Chuyển sang màn hình thanh toán MoMo
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => MoMoPaymentScreen(
                paymentResult: paymentResult,
                serviceName: widget.serviceName,
                amount: totalPrice,
                onPaymentComplete: (success) {
                  if (success) {
                    _navigateToSuccess(context, booking);
                  } else {
                    // Thanh toán bị hủy hoặc thất bại
                    // Ở lại màn hình xác nhận để người dùng thử lại
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Đã hủy thanh toán. Bạn có thể chọn phương thức khác."),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_paymentViewModel.errorMessage ??
                  "Lỗi khởi tạo thanh toán MoMo"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Thanh toán tiền mặt - Thành công ngay lập tức
      if (mounted) {
        DialogUtils.hideLoading(context);
        _navigateToSuccess(context, booking);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _bookingViewModel),
        ChangeNotifierProvider.value(value: _paymentViewModel),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text("Xác nhận đặt lịch"),
          centerTitle: true,
          backgroundColor: const Color(0xFFF8FAFC).withOpacity(0.8),
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          titleTextStyle: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. Thanh tiến trình
              const Center(child: BookingStepper(currentStep: 3)),
              const SizedBox(height: 24),

              // 1. Tóm tắt đơn hàng
              const Text(
                "Tóm tắt đơn hàng",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              BookingSummaryCard(
                serviceName: widget.serviceName,
                providerName: widget.provider.name,
                bookingTime: widget.bookingTime,
                address: widget.address,
              ),

              const SizedBox(height: 24),

              // 2. Phương thức thanh toán
              const Text(
                "Phương thức thanh toán",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<BookingViewModel>(
                builder: (context, vm, child) {
                  return PaymentMethodSelector(
                    selectedMethod: vm.paymentMethod,
                    onChanged: vm.setPaymentMethod,
                  );
                },
              ),

              const SizedBox(height: 24),

              // 3. Chi tiết thanh toán
              const Text(
                "Chi tiết thanh toán",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<BookingViewModel>(
                builder: (context, vm, child) {
                  return PriceDetailsSection(
                    servicePrice: widget.provider.price,
                    platformFee: 0,
                  );
                },
              ),

              const SizedBox(height: 24),

              // 4. Lưu ý về chi phí phát sinh
              const ExtraCostWarning(),

              // Khoảng cách dưới cùng
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: Consumer2<BookingViewModel, PaymentViewModel>(
          builder: (context, bookingVM, paymentVM, child) {
            final totalPrice =
                bookingVM.calculateTotalPrice(widget.provider.price);
            final currencyFormatter =
                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng cộng",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(totalPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          bookingVM.isCreatingBooking || paymentVM.isProcessing
                              ? null
                              : _handleBookingProcess,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child:
                          bookingVM.isCreatingBooking || paymentVM.isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Xác nhận đặt lịch",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
