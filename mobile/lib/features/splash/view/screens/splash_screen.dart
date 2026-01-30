import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/location_service.dart';
import '../../../auth/viewmodel/auth_viewmodel.dart';

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
    print('Bắt đầu kiểm tra trạng thái app...');

    // Khởi tạo AuthViewModel trước
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    print('Đang khởi tạo AuthViewModel...');
    await authViewModel.initialize();
    print('AuthViewModel đã khởi tạo xong');

    // Đợi một chút để hiển thị splash
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    print('Đang kiểm tra quyền location...');
    // Kiểm tra quyền location
    final hasLocationPermission =
        await LocationService.checkAndRequestPermission();

    if (!hasLocationPermission) {
      print('Chưa có quyền location -> chuyển đến PermissionScreen');
      // Chưa có quyền location -> đi đến màn hình cấp quyền
      Navigator.of(context).pushReplacementNamed(AppRoutes.permission);
      return;
    }

    print('Đã có quyền location');

    // Đã có quyền location -> kiểm tra trạng thái đăng nhập
    print('Kiểm tra trạng thái đăng nhập...');
    print('Current user: ${authViewModel.currentUser?.fullName}');
    print('Is logged in: ${authViewModel.isLoggedIn}');

    if (authViewModel.isLoggedIn) {
      final user = authViewModel.currentUser;
      if (user != null && user.isProvider) {
        print('Đã đăng nhập (Provider) -> chuyển đến ProviderMainScreen');
        Navigator.of(context).pushReplacementNamed(AppRoutes.providerHome);
      } else {
        print('Đã đăng nhập (Customer) -> chuyển đến MainScreen');
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } else {
      print('Chưa đăng nhập -> chuyển đến LoginScreen');
      // Chưa đăng nhập -> đi đến màn hình đăng nhập
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
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
