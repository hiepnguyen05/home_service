import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../viewmodel/partner_viewmodel.dart';
import '../../../../features/auth/viewmodel/auth_viewmodel.dart';
import '../widgets/partner_progress_bar.dart';

class BioExperienceScreen extends StatefulWidget {
  const BioExperienceScreen({super.key});

  @override
  State<BioExperienceScreen> createState() => _BioExperienceScreenState();
}

class _BioExperienceScreenState extends State<BioExperienceScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<PartnerViewModel>(context, listen: false);
    _bioController.text = viewModel.bio;
    if (viewModel.experienceYears > 0) {
      _experienceController.text = viewModel.experienceYears.toString();
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _onContinue(PartnerViewModel viewModel) async {
    if (_bioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập giới thiệu bản thân')),
      );
      return;
    }

    final experience = double.tryParse(_experienceController.text);
    if (experience == null || experience < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Vui lòng nhập số năm kinh nghiệm hợp lệ (ví dụ: 1.5)')),
      );
      return;
    }

    viewModel.setBio(_bioController.text);
    viewModel.setExperienceYears(experience);

    if (!viewModel.isSubmitting) {
      final success = await viewModel.submitApplication();
      if (success && mounted) {
        // Refresh user data (avatar) from Firestore
        await Provider.of<AuthViewModel>(context, listen: false).initialize();
        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.partnerPending);
        }
      } else if (viewModel.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${viewModel.errorMessage}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hoàn thiện hồ sơ',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<PartnerViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Progress Bar
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: PartnerProgressBar(currentStep: 4),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hồ sơ chuyên môn',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cung cấp thêm thông tin để khách hàng tin tưởng và lựa chọn bạn.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Years of Experience
                      const Text(
                        'Số năm kinh nghiệm',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'VD: 5',
                            suffixText: 'năm',
                            prefixIcon: const Icon(Icons.workspace_premium,
                                color: AppColors.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bio
                      const Text(
                        'Giới thiệu bản thân và kinh nghiệm làm việc',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _bioController,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText:
                                'Mô tả các kỹ năng chuyên môn, các dự án tiêu biểu bạn đã thực hiện và lý do khách hàng nên chọn dịch vụ của bạn...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tối thiểu 50 ký tự để hồ sơ nổi bật hơn.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tip box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Một lời giới thiệu chi tiết giúp tăng khả năng nhận việc lên đến 40%.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: viewModel.isSubmitting
                        ? null
                        : () => _onContinue(viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                    ),
                    child: viewModel.isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text(
                            'Đăng ký',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
