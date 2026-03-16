import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class ProviderIncomeScreen extends StatelessWidget {
  const ProviderIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thu nhập'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Màn hình chi tiết thu nhập\n(Đang phát triển)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
