import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../features/splash/view/screens/splash_screen.dart';
import '../features/permission/view/screens/permission_screen.dart';
import '../features/auth/view/screens/login_screen.dart';
import '../features/auth/view/screens/register_screen.dart';
import '../features/auth/view/screens/forgot_password_screen.dart';
import '../features/main/view/screens/main_screen.dart';
import '../features/profile/view/screens/profile_screen.dart';
import '../features/address/view/screens/address_list_screen.dart';
import '../features/address/view/screens/add_edit_address_screen.dart';
import '../features/address/data/models/address_model.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.permission:
        return MaterialPageRoute(builder: (_) => const PermissionScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainScreen());
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
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(), // Default to splash screen
        );
    }
  }
}
