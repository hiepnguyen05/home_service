import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../auth/viewmodel/auth_viewmodel.dart';
import '../../viewmodel/partner_viewmodel.dart';

class PartnerPendingScreen extends StatefulWidget {
  const PartnerPendingScreen({super.key});

  @override
  State<PartnerPendingScreen> createState() => _PartnerPendingScreenState();
}

class _PartnerPendingScreenState extends State<PartnerPendingScreen> {
  // Listener subscription
  Stream<QuerySnapshot>? _requestStream;

  @override
  void initState() {
    super.initState();
    _setupListener();
  }

  void _setupListener() {
    // Access stream through ViewModel
    _requestStream = Provider.of<PartnerViewModel>(context, listen: false)
        .getApplicationStatusStream() as Stream<QuerySnapshot>?;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _requestStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildScaffold(
            context: context,
            title: 'Hồ sơ đang chờ duyệt',
            icon: Icons.hourglass_top,
            iconColor: Colors.orange,
            message: 'Hồ sơ của bạn đã được gửi thành công.',
          );
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final status = data['status'] as String?;

          if (status == 'approved') {
            // Delay slightly to show success before navigating
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleApproval(context);
            });
            return _buildScaffold(
              context: context,
              title: 'Hồ sơ đã được duyệt!',
              icon: Icons.check_circle,
              iconColor: Colors.green,
              message: 'Chúc mừng! Bạn đã trở thành đối tác chính thức.',
              showSuccessButton: true,
            );
          } else if (status == 'rejected') {
            final reason = data['rejectReason'] ?? 'Thông tin chưa hợp lệ';
            return _buildScaffold(
              context: context,
              title: 'Hồ sơ bị từ chối',
              icon: Icons.cancel,
              iconColor: Colors.red,
              message: 'Lý do: $reason\nVui lòng kiểm tra và đăng ký lại.',
              isRejected: true,
            );
          }
        }

        // Default Pending State
        return _buildScaffold(
          context: context,
          title: 'Hồ sơ đang chờ duyệt',
          icon: Icons.hourglass_top,
          iconColor: Colors.orange,
          message:
              'Hồ sơ của bạn đã được gửi thành công. Chúng tôi sẽ xem xét và phản hồi trong thời gian sớm nhất.',
        );
      },
    );
  }

  Future<void> _handleApproval(BuildContext context) async {
    // Refresh user info to update role
    await Provider.of<AuthViewModel>(context, listen: false).initialize();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Chúc mừng! Bạn đã được duyệt thành công.')),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.providerHome, (route) => false);
    }
  }

  Widget _buildScaffold({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required String message,
    bool isRejected = false,
    bool showSuccessButton = false,
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác thực hồ sơ',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!isRejected && !showSuccessButton)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                                text:
                                    'Thời gian xét duyệt dự kiến trong vòng '),
                            TextSpan(
                              text: '3 ngày',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' làm việc.'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isRejected) {
                        // Reset flow state in ViewModel
                        Provider.of<PartnerViewModel>(context, listen: false)
                            .reset();
                        // Re-apply logic (pop to registration or pricing)
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.partnerRegistration,
                          (route) => false,
                          arguments: {'forceRetry': true},
                        );
                      } else {
                        // Back to Home
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isRejected ? 'Đăng ký lại' : 'Về trang chủ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (!isRejected && !showSuccessButton) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Cần hỗ trợ? Liên hệ chúng tôi',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
