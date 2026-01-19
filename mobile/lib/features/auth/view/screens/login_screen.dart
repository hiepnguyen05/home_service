import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/utils/validators.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
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
        backgroundColor: AppColors.white,
        elevation: 0,
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
                  // Auth Header
                  const AuthHeader(title: AppTexts.loginTitle),

                  const SizedBox(height: AppSizes.spacingXLarge),

                  // Email Field
                  AppTextField(
                    label: 'Email',
                    hint: 'Nhập email của bạn',
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),

                  // Error message for identifier
                  if (authViewModel.errorMessage != null &&
                      authViewModel.errorMessage!.contains('không hợp lệ'))
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSizes.spacingSmall,
                      ),
                      child: Text(
                        AppTexts.phoneInvalidMessage,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSizes.spacingLarge),

                  // Password Field
                  AppTextField(
                    label: AppTexts.passwordLabel,
                    hint: AppTexts.passwordHint,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  // Error message for password
                  if (authViewModel.errorMessage != null &&
                      authViewModel.errorMessage!.contains('8 ký tự'))
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSizes.spacingSmall,
                      ),
                      child: Text(
                        AppTexts.passwordMinLengthMessage,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSizes.spacingMedium),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.forgotPassword);
                      },
                      child: const Text(
                        AppTexts.forgotPasswordButton,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spacingXLarge),

                  // Login Button
                  AppButton(
                    text: AppTexts.loginButton,
                    onPressed: () => _handleLogin(authViewModel),
                    isLoading: authViewModel.isLoading,
                  ),

                  const SizedBox(height: AppSizes.spacingMedium),

                  // Login with OTP Button
                  AppButton(
                    text: AppTexts.loginWithOtpButton,
                    type: AppButtonType.outline,
                    onPressed: () {
                      // TODO: Implement OTP login
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tính năng đăng nhập OTP sẽ được phát triển',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSizes.spacingXLarge),

                  // Register Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppTexts.dontHaveAccount,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text(
                            AppTexts.registerText,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  void _handleLogin(AuthViewModel authViewModel) async {
    if (_formKey.currentState!.validate()) {
      final success = await authViewModel.login(
        _identifierController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Hiển thị dialog thành công
        DialogUtils.showSuccess(
          context,
          title: 'Đăng nhập thành công!',
          message:
              'Chào mừng bạn quay trở lại ${authViewModel.currentUser?.fullName ?? ''}',
          buttonText: 'Tiếp tục',
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          },
        );
      } else if (mounted && authViewModel.errorMessage != null) {
        // Hiển thị dialog lỗi
        DialogUtils.showError(
          context,
          title: 'Đăng nhập thất bại',
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
