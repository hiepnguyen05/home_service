import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../features/splash/view/screens/splash_screen.dart';
import '../features/permission/view/screens/permission_screen.dart';
import '../features/auth/view/screens/login_screen.dart';
import '../features/auth/view/screens/register_screen.dart';
import '../features/main/view/screens/main_screen.dart';
import '../features/profile/view/screens/profile_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case AppRoutes.permission:
        return MaterialPageRoute(
          builder: (_) => const PermissionScreen(),
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(), // Default to splash screen
        );
    }
  }
}