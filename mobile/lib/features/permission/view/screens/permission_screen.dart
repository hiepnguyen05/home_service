import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/viewmodel/auth_viewmodel.dart';
import '../widgets/permission_item.dart';
import '../../viewmodel/permission_viewmodel.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          AppTexts.permissionTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Bỏ nút back vì đây là flow bắt buộc
      ),
      body: Consumer<PermissionViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.spacingLarge),
                const Text(
                  AppTexts.permissionSubtitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXLarge),
                const PermissionItem(
                  icon: Icons.location_on,
                  title: AppTexts.locationTitle,
                  description: AppTexts.locationDescription,
                  iconColor: AppColors.green,
                  backgroundColor: AppColors.greenLight,
                ),
                const SizedBox(height: AppSizes.spacingLarge),
                const PermissionItem(
                  icon: Icons.notifications,
                  title: AppTexts.notificationTitle,
                  description: AppTexts.notificationDescription,
                  iconColor: AppColors.green,
                  backgroundColor: AppColors.greenLight,
                ),
                const Spacer(),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => _requestPermissions(context, viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                AppTexts.allowButton,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingMedium),
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: TextButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => _skipPermissions(context, viewModel),
                        child: const Text(
                          AppTexts.laterButton,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingLarge),
              ],
            ),
          );
        },
      ),
    );
  }

  void _requestPermissions(BuildContext context, PermissionViewModel viewModel) async {
    await viewModel.requestAllPermissions();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quyền đã được cấp thành công!'),
          backgroundColor: AppColors.green,
        ),
      );
      
      // Sau khi cấp quyền -> kiểm tra trạng thái đăng nhập
      _navigateAfterPermission(context);
    }
  }

  void _skipPermissions(BuildContext context, PermissionViewModel viewModel) {
    viewModel.skipPermissions();
    // Vẫn điều hướng tiếp theo dù bỏ qua quyền
    _navigateAfterPermission(context);
  }

  void _navigateAfterPermission(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    if (authViewModel.isLoggedIn) {
      // Đã đăng nhập -> vào trang chủ
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      // Chưa đăng nhập -> vào màn hình đăng nhập
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }
}