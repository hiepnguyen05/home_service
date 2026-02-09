import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../features/splash/view/screens/splash_screen.dart';
import '../features/permission/view/screens/permission_screen.dart';
import '../features/auth/view/screens/login_screen.dart';
import '../features/services/view/screens/services_list_screen.dart';
import '../features/auth/view/screens/register_screen.dart';
import '../features/auth/view/screens/forgot_password_screen.dart';
import '../features/main/view/screens/main_screen.dart';
import '../features/profile/view/screens/profile_screen.dart';
import '../features/address/view/screens/address_list_screen.dart';
import '../features/address/view/screens/add_edit_address_screen.dart';
import '../features/address/data/models/address_model.dart';
import '../features/partner/view/screens/partner_registration_screen.dart';
import '../features/partner/view/screens/kyc_upload_screen.dart';
import '../features/partner/view/screens/certificate_upload_screen.dart';
import '../features/partner/view/screens/service_pricing_screen.dart';
import '../features/partner/view/screens/partner_pending_screen.dart';
import '../features/provider/view/screens/provider_main_screen.dart';
import '../features/partner/view/screens/bio_experience_screen.dart';
import '../features/booking/view/screens/booking_time_screen.dart';
import '../features/booking/view/screens/booking_address_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.permission:
        return MaterialPageRoute(builder: (_) => const PermissionScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.servicesList:
        return MaterialPageRoute(builder: (_) => const ServicesListScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case AppRoutes.providerHome:
        return MaterialPageRoute(builder: (_) => const ProviderMainScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.addressList:
        return MaterialPageRoute(builder: (_) => const AddressListScreen());
      case AppRoutes.addAddress:
        return MaterialPageRoute(builder: (_) => const AddEditAddressScreen());
      case AppRoutes.editAddress:
        final address = settings.arguments;
        return MaterialPageRoute(
          builder: (_) =>
              AddEditAddressScreen(address: address as AddressModel?),
        );
      case AppRoutes.partnerRegistration:
        return MaterialPageRoute(
            builder: (_) => const PartnerRegistrationScreen(),
            settings: settings);
      case AppRoutes.kycUpload:
        return MaterialPageRoute(builder: (_) => const KYCUploadScreen());
      case AppRoutes.certificateUpload:
        return MaterialPageRoute(
            builder: (_) => const CertificateUploadScreen());
      case AppRoutes.servicePricing:
        return MaterialPageRoute(builder: (_) => const ServicePricingScreen());
      case AppRoutes.bioExperience:
        return MaterialPageRoute(builder: (_) => const BioExperienceScreen());
      case AppRoutes.partnerPending:
        return MaterialPageRoute(builder: (_) => const PartnerPendingScreen());
      case AppRoutes.bookingAddress:
        final serviceId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BookingAddressScreen(
            serviceId: serviceId,
            bookingTime:
                DateTime.now(), // Fallback if navigated via named route
          ),
        );
      case AppRoutes.bookingTime:
        final serviceId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BookingTimeScreen(serviceId: serviceId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(), // Default to splash screen
        );
    }
  }
}
