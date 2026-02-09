import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../viewmodel/partner_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/partner_progress_bar.dart';

class CertificateUploadScreen extends StatefulWidget {
  const CertificateUploadScreen({super.key});

  @override
  State<CertificateUploadScreen> createState() =>
      _CertificateUploadScreenState();
}

class _CertificateUploadScreenState extends State<CertificateUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickCertificate(PartnerViewModel viewModel) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        for (var img in images) {
          viewModel.addCertificate(File(img.path));
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> _pickPortrait(PartnerViewModel viewModel) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        viewModel.setPortraitImage(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking portrait: $e');
    }
  }

  void _removeCertificate(PartnerViewModel viewModel, int index) {
    viewModel.removeCertificate(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // background-light
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
          'Tải lên Hồ sơ',
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
                child: PartnerProgressBar(currentStep: 2),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headline Text
                      const SizedBox(height: 16),
                      const Text(
                        'Ảnh chân dung & Chứng chỉ',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Body Text
                      const Text(
                        'Ảnh chân dung chuyên nghiệp và chứng chỉ sẽ giúp bạn xây dựng uy tín.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Portrait Section
                      const Text(
                        'Ảnh chân dung',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap: () => _pickPortrait(viewModel),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: viewModel.portraitImage != null
                                    ? AppColors.primary
                                    : AppColors.borderLight,
                                width: 2,
                              ),
                              image: viewModel.portraitImage != null
                                  ? DecorationImage(
                                      image:
                                          FileImage(viewModel.portraitImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: viewModel.portraitImage == null
                                ? const Icon(
                                    Icons.person_add_alt_1,
                                    color: AppColors.textSecondary,
                                    size: 40,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      if (viewModel.portraitImage == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Center(
                            child: Text(
                              'Nhấn để tải lên ảnh đại diện',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),

                      // Certificate Section
                      const Text(
                        'Chứng chỉ nghề nghiệp',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Upload Area / Image Grid for Certificates
                      if (viewModel.certificateImages.isEmpty)
                        _buildEmptyCertificateState(viewModel)
                      else
                        _buildCertificateGrid(viewModel),

                      const SizedBox(height: 32),

                      // Checklists
                      _buildChecklistItem('Ảnh chụp rõ nét, không bị mờ'),
                      _buildChecklistItem(
                          'Đảm bảo thấy đủ 4 góc của chứng chỉ'),
                      _buildChecklistItem('Ảnh chân dung cần nhìn rõ mặt'),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50], // background-light
                child: Column(
                  children: [
                    if (viewModel.certificateImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _pickCertificate(viewModel),
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Thêm chứng chỉ'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (viewModel.certificateImages.isNotEmpty &&
                                viewModel.portraitImage != null)
                            ? () {
                                Navigator.pushNamed(
                                    context, AppRoutes.servicePricing);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (viewModel.certificateImages.isNotEmpty &&
                                      viewModel.portraitImage != null)
                                  ? AppColors.primary
                                  : Colors.grey[300],
                          foregroundColor:
                              (viewModel.certificateImages.isNotEmpty &&
                                      viewModel.portraitImage != null)
                                  ? Colors.white
                                  : Colors.grey[500],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Tiếp tục',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCertificateState(PartnerViewModel viewModel) {
    return GestureDetector(
      onTap: () => _pickCertificate(viewModel),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderLight,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.upload_file,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tải lên ảnh chứng chỉ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hỗ trợ JPG, PNG, PDF',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateGrid(PartnerViewModel viewModel) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: viewModel.certificateImages.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                viewModel.certificateImages[index],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeCertificate(viewModel, index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
