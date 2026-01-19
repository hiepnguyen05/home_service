import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/utils/validators.dart';
import '../../viewmodel/auth_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quên mật khẩu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.spacingMedium),

                  // Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 40,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingLarge),

                  // Title
                  const Center(
                    child: Text(
                      'Đặt lại mật khẩu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),

                  // Subtitle
                  const Center(
                    child: Text(
                      'Nhập email của bạn để nhận liên kết đặt lại mật khẩu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXLarge),

                  // Email Field
                  AppTextField(
                    label: 'Email',
                    hint: 'Nhập email của bạn',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),

                  const SizedBox(height: AppSizes.spacingXLarge),

                  // Send Reset Email Button
                  AppButton(
                    text: 'Gửi email đặt lại',
                    onPressed: () => _handleSendResetEmail(authViewModel),
                    isLoading: authViewModel.isLoading,
                  ),

                  const SizedBox(height: AppSizes.spacingLarge),

                  // Back to Login Link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Quay lại đăng nhập',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Error Message
                  if (authViewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSizes.spacingMedium,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.redLight,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSmall,
                          ),
                        ),
                        child: Text(
                          authViewModel.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSendResetEmail(AuthViewModel authViewModel) async {
    if (_formKey.currentState!.validate()) {
      final success = await authViewModel.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (success && mounted) {
        // Hiển thị dialog thành công
        DialogUtils.showSuccess(
          context,
          title: 'Email đã được gửi!',
          message:
              'Vui lòng kiểm tra email của bạn và làm theo hướng dẫn để đặt lại mật khẩu.',
          buttonText: 'Đã hiểu',
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
            Navigator.of(context).pop(); // Quay lại login screen
          },
        );
      } else if (mounted && authViewModel.errorMessage != null) {
        // Hiển thị dialog lỗi
        DialogUtils.showError(
          context,
          title: 'Gửi email thất bại',
          message: authViewModel.errorMessage!,
          buttonText: 'Thử lại',
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
            authViewModel.clearError(); // Xóa lỗi
          },
        );
      }
    }
  }
}
