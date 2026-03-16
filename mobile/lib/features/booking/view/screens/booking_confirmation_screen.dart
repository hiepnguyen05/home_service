import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NEW
import 'dart:async';
import '../../../../core/services/distance_service.dart';
import '../../../provider/data/models/provider_model.dart';
import '../../../payment/payment.dart';
import '../../data/models/booking_model.dart';
import '../../viewmodel/booking_viewmodel.dart';
import '../widgets/confirmation/booking_summary_card.dart';
import '../widgets/confirmation/price_details_section.dart';
import '../widgets/confirmation/extra_cost_warning.dart';
import '../widgets/confirmation/confirmation_bottom_bar.dart';
import '../widgets/confirmation/section_title.dart';
import 'booking_success_screen.dart';
import '../widgets/common/booking_stepper.dart';
import '../widgets/common/waiting_for_provider_dialog.dart'; // Import common dialog
import '../../../../core/constants/app_colors.dart'; // Added AppColors

import '../../../../features/payment/viewmodel/payment_viewmodel.dart';
import '../../../../features/payment/view/screens/momo_payment_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  // final String bookingId; // Removed
  final ProviderModel provider;
  final String serviceName;
  final String serviceId;
  final DateTime bookingTime;
  final double userLat;
  final double userLng;
  final String address;
  final String? note;
  final String priceUnit; // NEW

  const BookingConfirmationScreen({
    super.key,
    // required this.bookingId, // Removed
    required this.provider,
    required this.serviceName,
    required this.serviceId,
    required this.bookingTime,
    required this.userLat,
    required this.userLng,
    required this.address,
    required this.priceUnit, // NEW
    this.note,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  late BookingViewModel _bookingViewModel;
  late PaymentViewModel _paymentViewModel;

  // Removed redundant AppLinks logic
  // MoMoPaymentScreen handles the deep link and callback

  @override
  void initState() {
    super.initState();
    _bookingViewModel = BookingViewModel();
    // Set price unit from widget
    _bookingViewModel.setPriceUnit(widget.priceUnit);

    _paymentViewModel = PaymentViewModel();
  }

  /// Xử lý quy trình ĐẶT & GỬI YÊU CẦU
  Future<void> _handleBookingProcess() async {
    // 1. Validate info if needed

    // 2. Tạo Booking Request (Booking created with Pending status)
    final totalPrice =
        _bookingViewModel.calculateTotalPrice(widget.provider.price);

    final booking = await _bookingViewModel.createBookingRequest(
      provider: widget.provider,
      serviceId: widget.serviceId,
      scheduledAt: widget.bookingTime,
      address: widget.address,
      totalPrice: totalPrice,
      paymentMethod: _bookingViewModel.paymentMethod,
      note: widget.note,
      userLat: widget.userLat, // Pass lat
      userLng: widget.userLng, // Pass lng
    );

    if (booking == null) {
      _showErrorSnackBar(_bookingViewModel.error ?? "Lỗi tạo đơn hàng");
      return;
    }

    // 3. Logic B + Pay Later: Always wait for provider first
    // Note: Payment is triggered inside _showWaitingDialog when status becomes 'waiting_payment'
    _showWaitingDialog(booking.id);
  }

  /// Hiển thị dialog chờ thợ
  void _showWaitingDialog(String bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return WaitingForProviderDialog(
          bookingId: bookingId,
          bookingViewModel: _bookingViewModel,
          onSuccess: () {
            // Trường hợp 1: COD -> Provider Accept -> Confirmed -> Success
            // Dialog is already popped inside (WaitingForProviderDialog)
            _navigateToSuccess(context, bookingId);
          },
          onWaitingPayment: () {
            // Trường hợp 2: Online -> Provider Accept -> WaitingPayment -> Pay
            // Dialog is already popped inside (WaitingForProviderDialog)

            print(
                "🚀 [BookingScreen] onWaitingPayment TRIGGERED. Starting payment flow...");
            // Trigger payment flow
            if (_bookingViewModel.currentBooking != null) {
              _processPayment(_bookingViewModel.currentBooking!);
            } else {
              print("❌ [BookingScreen] Current booking is NULL!");
              _showErrorSnackBar("Lỗi: Không tìm thấy thông tin đơn hàng");
            }
          },
          onFailure: (reason) {
            // Dialog popped inside
            if (!mounted) return;
            // Show FAILURE DIALOG
            _showFailureDialog(reason);
          },
        );
      },
    );
  }

  void _showFailureDialog(String reason) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text("Đặt lịch thất bại"),
          ],
        ),
        content: Text(
          reason,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text("Đóng", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  /// Xử lý chuyển hướng sang cổng thanh toán
  Future<void> _processPayment(BookingModel booking) async {
    print(
        "🚀 [BookingScreen] _processPayment START for booking: ${booking.id}");
    print("💰 [BookingScreen] Amount: ${booking.totalPrice}");

    // Gọi ViewModel để lấy thông tin thanh toán MoMo
    final paymentResult = await _paymentViewModel.processMoMoPayment(
      bookingId: booking.id,
      amount: booking.totalPrice,
      orderInfo: "Thanh toan dich vu ${widget.serviceName}",
    );

    print(
        "📡 [BookingScreen] Payment Result: ${paymentResult?.success} | Message: ${paymentResult?.message}");

    if (paymentResult != null && paymentResult.success && mounted) {
      print("👉 [BookingScreen] Navigating to MoMo screen...");
      // Điều hướng sang màn hình thanh toán MoMo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => MoMoPaymentScreen(
            paymentResult: paymentResult,
            serviceName: widget.serviceName,
            amount: booking.totalPrice,
            bookingId: booking.id, // Pass booking ID
            onPaymentComplete: (success) async {
              print(
                  "🔥 [BookingScreen] onPaymentComplete Callback triggered. Success: $success");
              if (success) {
                // Thanh toán xong -> Success
                // Cần update status booking -> confirmed (Backend/App link handle)

                // FORCE UPDATE STATUS client side để chắc chắn (nếu backend lag)
                try {
                  print(
                      "🔄 [BookingScreen] Forcing status update to confirmed...");
                  await FirebaseFirestore.instance
                      .collection('bookings')
                      .doc(booking.id)
                      .update({'status': BookingStatus.confirmed});
                  print("✅ [BookingScreen] Status updated.");
                } catch (e) {
                  print("❌ [BookingScreen] Error updating status forced: $e");
                }

                print("👉 [BookingScreen] Navigating to Success Screen...");
                _navigateToSuccess(context, booking.id);
              } else {
                print(
                    "⚠️ [BookingScreen] Payment reported as failed/cancelled.");

                // NEW: Update status to CANCELLED in Firestore so Provider knows
                try {
                  print("🔄 [BookingScreen] Updating status to CANCELLED...");
                  await FirebaseFirestore.instance
                      .collection('bookings')
                      .doc(booking.id)
                      .update({'status': BookingStatus.cancelled});
                  print("✅ [BookingScreen] Status updated to CANCELLED.");
                } catch (e) {
                  print(
                      "❌ [BookingScreen] Error updating status to cancelled: $e");
                }

                _showErrorSnackBar('Thanh toán bị hủy hoặc thất bại');
              }
            },
          ),
        ),
      );
    } else {
      print("❌ [BookingScreen] Payment failed to init");
      _showErrorSnackBar(
          _paymentViewModel.errorMessage ?? "Lỗi khởi tạo thanh toán");
    }
  }

  void _navigateToSuccess(BuildContext context, String bookingId) {
    if (!mounted) return;

    // Tính toán thời gian di chuyển (Logic hiển thị)
    final distance = DistanceService.calculateDistance(widget.userLat,
        widget.userLng, widget.provider.latitude, widget.provider.longitude);
    final travelTimeMinutes = DistanceService.calculateTravelTime(distance);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(
          bookingId: bookingId,
          provider: widget.provider,
          serviceName: widget.serviceName,
          bookingTime: widget.bookingTime,
          paymentMethod: _bookingViewModel.paymentMethod,
          travelTimeMinutes: travelTimeMinutes,
        ),
      ),
      (route) => route.isFirst, // Về màn hình chính luôn
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _bookingViewModel.dispose();
    _paymentViewModel.dispose();
    super.dispose();
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
              const SectionTitle(title: "Tóm tắt đơn hàng"),
              const SizedBox(height: 12),
              BookingSummaryCard(
                serviceName: widget.serviceName,
                providerName: widget.provider.name,
                bookingTime: widget.bookingTime,
                address: widget.address,
              ),

              const SizedBox(height: 24),

              // --- QUANTITY SELECTOR (NEW) ---
              Consumer<BookingViewModel>(
                builder: (context, vm, child) {
                  if (vm.priceUnit == 'giờ' || vm.priceUnit == 'lần')
                    return const SizedBox.shrink();

                  return Column(
                    children: [
                      const SectionTitle(title: "Số lượng"),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Số lượng (${vm.priceUnit})",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => vm.updateQuantity(-1),
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.grey),
                                ),
                                const SizedBox(width: 8),
                                Text("${vm.quantity}",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => vm.updateQuantity(1),
                                  icon: const Icon(Icons.add_circle,
                                      color: AppColors.primary),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              // 2. Phương thức thanh toán
              const SectionTitle(title: "Phương thức thanh toán"),
              const SizedBox(height: 12),
              Consumer<BookingViewModel>(
                builder: (context, vm, child) {
                  // Nếu là giờ -> Chỉ hiện Tiền mặt
                  final allowedMethods = vm.priceUnit == 'giờ'
                      ? [PaymentMethod.cash]
                      : null; // null = all methods

                  return PaymentMethodSelector(
                    selectedMethod: vm.paymentMethod,
                    onChanged: vm.setPaymentMethod,
                    availableMethods: allowedMethods,
                  );
                },
              ),

              const SizedBox(height: 24),

              // 3. Chi tiết thanh toán
              const SectionTitle(title: "Chi tiết thanh toán"),
              const SizedBox(height: 12),
              Consumer<BookingViewModel>(
                builder: (context, vm, child) {
                  final total = vm.calculateTotalPrice(widget.provider.price);
                  return PriceDetailsSection(
                    servicePrice: total, // Updated to use total
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

            return ConfirmationBottomBar(
              totalPrice: totalPrice,
              isLoading: bookingVM.isCreatingBooking || paymentVM.isProcessing,
              onConfirm: _handleBookingProcess, // Call new logic
            );
          },
        ),
      ),
    );
  }
}
