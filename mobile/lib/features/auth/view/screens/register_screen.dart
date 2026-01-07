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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
        title: const Text(
          AppTexts.registerTitle,
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
                  
                  // Title
                  const Text(
                    AppTexts.registerTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  
                  // Subtitle
                  const Text(
                    AppTexts.registerSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXLarge),
                  
                  // Full Name Field
                  AppTextField(
                    label: AppTexts.fullNameLabel,
                    hint: AppTexts.fullNameHint,
                    controller: _fullNameController,
                    keyboardType: TextInputType.name,
                    validator: Validators.validateFullName,
                  ),
                  const SizedBox(height: AppSizes.spacingLarge),
                  
                  // Phone Field
                  AppTextField(
                    label: AppTexts.phoneLabel,
                    hint: AppTexts.phoneHint,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: AppSizes.spacingLarge),
                  
                  // Email Field
                  AppTextField(
                    label: AppTexts.emailLabel,
                    hint: AppTexts.emailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
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
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.spacingSmall),
                  
                  // Password requirement
                  const Text(
                    AppTexts.passwordMinLengthMessage,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.spacingXLarge * 2),
                  
                  // Register Button
                  AppButton(
                    text: AppTexts.registerButton,
                    onPressed: () => _handleRegister(authViewModel),
                    isLoading: authViewModel.isLoading,
                  ),
                  
                  const SizedBox(height: AppSizes.spacingXLarge),
                  
                  // Login Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppTexts.alreadyHaveAccount,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          },
                          child: const Text(
                            AppTexts.loginText,
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
                  
                  // Error Message
                  if (authViewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.spacingMedium),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.redLight,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
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

  void _handleRegister(AuthViewModel authViewModel) async {
    if (_formKey.currentState!.validate()) {
      final success = await authViewModel.register(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (success && mounted) {
        // Hiển thị dialog thành công
        DialogUtils.showSuccess(
          context,
          title: 'Đăng ký thành công!',
          message: 'Chào mừng ${authViewModel.currentUser?.fullName ?? ''} đến với ứng dụng!',
          buttonText: 'Bắt đầu',
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          },
        );
      } else if (mounted && authViewModel.errorMessage != null) {
        // Hiển thị dialog lỗi
        DialogUtils.showError(
          context,
          title: 'Đăng ký thất bại',
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