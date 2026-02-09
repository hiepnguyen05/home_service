import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/partner_viewmodel.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class PartnerRegistrationScreen extends StatefulWidget {
  const PartnerRegistrationScreen({super.key});

  @override
  State<PartnerRegistrationScreen> createState() =>
      _PartnerRegistrationScreenState();
}

class _PartnerRegistrationScreenState extends State<PartnerRegistrationScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    // Check for forceRetry argument from PartnerPendingScreen
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final forceRetry = args?['forceRetry'] ?? false;

    if (forceRetry) {
      debugPrint(
          '[PartnerRegistrationScreen] Force retry detected, skipping status check');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    debugPrint('[PartnerRegistrationScreen] _checkStatus called');
    final viewModel = Provider.of<PartnerViewModel>(context, listen: false);
    final status = await viewModel.checkExistingApplication();

    debugPrint('[PartnerRegistrationScreen] status result: $status');

    if (!mounted) return;

    if (status != null) {
      // If any application exists (pending, approved, OR rejected),
      // we navigate to PartnerPendingScreen which handles all these states.
      debugPrint(
          '[PartnerRegistrationScreen] Navigating to PartnerPendingScreen');
      Navigator.pushReplacementNamed(context, AppRoutes.partnerPending);
    } else {
      debugPrint(
          '[PartnerRegistrationScreen] No existing application, showing registration form');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký đối tác',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.handshake_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Trở thành đối tác của HomeService',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tham gia mạng lưới đối tác chuyên nghiệp, tăng thu nhập và mở rộng khách hàng của bạn.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildBenefitItem(
              icon: Icons.monetization_on,
              title: 'Thu nhập hấp dẫn',
              description: 'Nhận 85% giá trị đơn hàng, thanh toán minh bạch.',
            ),
            _buildBenefitItem(
              icon: Icons.schedule,
              title: 'Thời gian linh hoạt',
              description: 'Chủ động nhận việc theo thời gian rảnh của bạn.',
            ),
            _buildBenefitItem(
              icon: Icons.people,
              title: 'Khách hàng ổn định',
              description: 'Tiếp cận hàng ngàn khách hàng có nhu cầu mỗi ngày.',
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.kycUpload);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Đăng ký ngay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
