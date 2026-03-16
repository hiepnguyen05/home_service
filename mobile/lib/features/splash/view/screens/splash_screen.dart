import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/location_service.dart';
import 'package:app_links/app_links.dart';
import '../../../../features/payment/data/services/payment_api_service.dart';
import '../../../auth/viewmodel/auth_viewmodel.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../../../provider/data/repositories/provider_repository.dart';
import '../../../booking/view/screens/booking_success_screen.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../../features/payment/data/models/payment_method.dart'; // NEW import for Enum

import 'package:shared_preferences/shared_preferences.dart'; // NEW

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    print('🚀 [Splash] Bắt đầu kiểm tra trạng thái app...');

    // ---------------------------------------------------------
    // 1. KIỂM TRA DEEP LINK (Xử lý khi App restart từ MoMo)
    // ---------------------------------------------------------
    try {
      final appLinks = AppLinks(); // Instantiate AppLinks
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        print("🔗 [Splash] Found Deep Link: $initialUri");
        if (initialUri.scheme == 'homeservice' &&
            initialUri.host == 'payment-callback') {
          print("💳 [Splash] Detected Payment Callback! Handling...");
          await _handlePaymentCallback(initialUri);
          return; // DỪNG flow bình thường nếu đã handle deep link
        }
      }
    } catch (e) {
      print("❌ [Splash] Deep Link Error: $e");
    }

    // ---------------------------------------------------------
    // 2. Flow bình thường (như cũ)
    // ---------------------------------------------------------

    // Ở đây ta cứ init Auth trước.
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    print('🔐 [Splash] Đang khởi tạo AuthViewModel...');
    await authViewModel.initialize();
    print('🔐 [Splash] AuthViewModel đã khởi tạo xong');

    // Đợi một chút để hiển thị splash
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    print('📍 [Splash] Đang kiểm tra quyền location...');
    final hasLocationPermission =
        await LocationService.checkAndRequestPermission();

    if (!hasLocationPermission) {
      print('⚠️ [Splash] Chưa có quyền location -> PermissionScreen');
      Navigator.of(context).pushReplacementNamed(AppRoutes.permission);
      return;
    }

    print('✅ [Splash] Đã có quyền location');

    if (authViewModel.isLoggedIn) {
      final user = authViewModel.currentUser;
      if (user != null && user.isProvider) {
        print('👉 [Splash] Provider -> Home');
        Navigator.of(context).pushReplacementNamed(AppRoutes.providerHome);
      } else {
        print('👉 [Splash] Customer -> Home');
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } else {
      print('👉 [Splash] Login');
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  /// Xử lý Deep Link Payment
  Future<void> _handlePaymentCallback(Uri uri) async {
    final resultCode = uri.queryParameters['resultCode'];
    final orderId = uri.queryParameters['orderId'];

    // Nếu thất bại/huỷ
    if (resultCode != '0' || orderId == null) {
      print("⚠️ [Splash] Payment Failed/Cancelled (ResultCode: $resultCode)");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thanh toán không thành công")),
        );
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      return;
    }

    try {
      // 1. Verify Payment with Backend
      final paymentService = PaymentApiService();
      final statusData = await paymentService.checkPaymentStatus(orderId);
      final status = statusData['data']?['status'];

      if (status == 'success') {
        print("✅ [Splash] Payment Verified! Fetching Booking Info...");

        final bookingRepo = BookingRepository();

        // 2. Try to get saved bookingId from SharedPreferences FIRST
        String? targetBookingId = orderId;
        try {
          final prefs = await SharedPreferences.getInstance();
          final savedBookingId = prefs.getString('pending_payment_booking_id');
          final savedOrderId = prefs.getString('pending_payment_order_id');

          if (savedBookingId != null && savedOrderId == orderId) {
            print(
                "💾 [Splash] Found saved bookingId in Prefs: $savedBookingId");
            targetBookingId = savedBookingId;
            // Clear prefs? Maybe keep until success screen loads?
            // await prefs.remove('pending_payment_booking_id');
          }
        } catch (e) {
          print("⚠️ [Splash] Error reading prefs: $e");
        }

        // 3. Fetch Booking Data
        BookingModel? booking =
            await bookingRepo.getBookingById(targetBookingId ?? orderId);

        // Fallback: If not found, try orderId as bookingId (if different)
        if (booking == null && targetBookingId != orderId) {
          print("⚠️ [Splash] Not found with saved ID, trying orderId...");
          booking = await bookingRepo.getBookingById(orderId);
        }

        if (booking != null) {
          // Capture for closure usage
          final validBooking = booking;
          print("📦 [Splash] Found Booking: ${validBooking.id}");

          // 4. Update status confirmed
          await bookingRepo.updateBookingStatus(
              validBooking.id, BookingStatus.confirmed);

          // 5. Fetch Provider
          final providerRepo = ProviderRepository();
          final provider =
              await providerRepo.getProviderById(validBooking.providerId);

          if (provider != null) {
            print("👨‍🔧 [Splash] Found Provider: ${provider.name}");

            // 6. Navigate to Success Screen
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => BookingSuccessScreen(
                    bookingId: validBooking.id,
                    provider: provider,
                    serviceName:
                        "Dịch vụ", // Fallback or fetch service name if needed
                    bookingTime: validBooking.scheduleAt,
                    paymentMethod: PaymentMethod.momo, // FIXED: Enum
                    travelTimeMinutes: 15, // Estimate or calc
                  ),
                ),
              );
              return;
            }
          }
        } else {
          print(
              "❌ [Splash] Booking not found for ID: $targetBookingId or $orderId");
        }
      }
    } catch (e) {
      print("❌ [Splash] Error recovery: $e");
    }

    // Default fallback
    if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.home_repair_service,
                size: 60,
                color: AppColors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Tên ứng dụng
            const Text(
              'Home Service',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Dịch vụ tại nhà tiện lợi',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

            const SizedBox(height: 16),

            const Text(
              'Đang khởi tạo...',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
