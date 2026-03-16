import 'package:flutter/material.dart';
import 'dart:async'; // NEW
import 'package:app_links/app_links.dart';
import '../../features/payment/data/services/payment_api_service.dart';
import '../../features/booking/data/repositories/booking_repository.dart';
import '../../features/provider/data/repositories/provider_repository.dart';
import '../../features/booking/view/screens/booking_success_screen.dart';
import '../../features/booking/data/models/booking_model.dart';
import '../../features/payment/data/models/payment_method.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'routes/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() {
    _appLinks = AppLinks();
    // Listern for background/foreground deep links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print("🔔 [App] Received Deep Link Stream: $uri");
      if (uri.scheme == 'homeservice' && uri.host == 'payment-callback') {
        _handlePaymentCallback(uri);
      }
    }, onError: (err) {
      print("❌ [App] Deep Link Stream Error: $err");
    });
  }

  Future<void> _handlePaymentCallback(Uri uri) async {
    final resultCode = uri.queryParameters['resultCode'];
    final orderId = uri.queryParameters['orderId'];

    if (resultCode != '0' || orderId == null) {
      print("⚠️ [App] Payment Failed so we ignore or show snackbar");
      return;
    }

    try {
      final paymentService = PaymentApiService();
      final statusData = await paymentService.checkPaymentStatus(orderId);
      final status = statusData['data']?['status'];

      if (status == 'success') {
        print("✅ [App] Payment Verified! Recovering Booking...");

        final bookingRepo = BookingRepository();
        String? targetBookingId = orderId;

        // Try Prefs
        try {
          final prefs = await SharedPreferences.getInstance();
          final savedBookingId = prefs.getString('pending_payment_booking_id');
          final savedOrderId = prefs.getString('pending_payment_order_id');
          if (savedBookingId != null && savedOrderId == orderId) {
            targetBookingId = savedBookingId;
          }
        } catch (e) {
          print(e);
        }

        BookingModel? booking =
            await bookingRepo.getBookingById(targetBookingId ?? orderId);
        if (booking == null && targetBookingId != orderId) {
          booking = await bookingRepo.getBookingById(orderId);
        }

        if (booking != null) {
          final validBooking = booking;
          await bookingRepo.updateBookingStatus(
              validBooking.id, BookingStatus.confirmed);
          final provider = await ProviderRepository()
              .getProviderById(validBooking.providerId);

          if (provider != null) {
            print("🚀 [App] Navigating to Success Screen via Global Key");
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(
                builder: (_) => BookingSuccessScreen(
                  bookingId: validBooking.id,
                  provider: provider,
                  serviceName: "Dịch vụ",
                  bookingTime: validBooking.scheduleAt,
                  paymentMethod: PaymentMethod.momo,
                  travelTimeMinutes: 15,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      print("❌ [App] Deep Link Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
      ],
      locale: const Locale('vi', 'VN'),
      title: 'Home Service App',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
