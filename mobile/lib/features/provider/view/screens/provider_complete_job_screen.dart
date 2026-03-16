import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../booking/data/models/booking_model.dart';
import '../widgets/workflow/evidence_upload_area.dart';
import 'provider_job_summary_screen.dart';
import '../../../services/data/repositories/service_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class ProviderCompleteJobScreen extends StatefulWidget {
  final BookingModel booking;
  final int finalSessionSeconds;
  final String? serviceName; // Thêm
  final String? customerName; // Thêm

  const ProviderCompleteJobScreen({
    super.key,
    required this.booking,
    required this.finalSessionSeconds,
    this.serviceName,
    this.customerName,
  });

  @override
  State<ProviderCompleteJobScreen> createState() => _ProviderCompleteJobScreenState();
}

class _ProviderCompleteJobScreenState extends State<ProviderCompleteJobScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _evidenceImage;
  bool _isLoading = false;
  String? _serviceName;
  String? _customerName;

  @override
  void initState() {
    super.initState();
    _serviceName = widget.serviceName;
    _customerName = widget.customerName;
    _fetchMissingNames();
  }

  Future<void> _fetchMissingNames() async {
    if (_serviceName == null || _customerName == null) {
      // Logic tương tự ProviderWorkScreen để đảm bảo có tên hiển thị
      if (_serviceName == null) {
        try {
          final s = await ServiceRepository().getServiceById(widget.booking.serviceId);
          _serviceName = s.name;
        } catch (_) {}
      }
      if (_customerName == null) {
        try {
          final u = await AuthRepository().getUserById(widget.booking.customerId);
          _customerName = u?.fullName;
        } catch (_) {}
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _evidenceImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chụp ảnh: $e')),
      );
    }
  }

  Future<void> _uploadAndProceed() async {
    if (_evidenceImage == null) return;

    print("--- DEBUG: Starting Upload and Proceed ---");
    print("Booking ID: ${widget.booking.id}");
    print("Final Session Seconds: ${widget.finalSessionSeconds}");
    print("Total Working Seconds from Booking: ${widget.booking.totalWorkingSeconds}");

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Upload evidence image to Cloudinary
      final imageUrl = await CloudinaryService.uploadFile(
        file: _evidenceImage!,
        folder: 'job_completion_evidence/${widget.booking.id}',
      );

      if (imageUrl == null) throw Exception("Lỗi tải ảnh lên hệ thống");

      // Thay vì gọi repo hoàn thành ngay, chuyển sang màn hình Tổng kết
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderJobSummaryScreen(
              booking: widget.booking,
              serviceName: _serviceName ?? "Dịch vụ",
              customerName: _customerName ?? "Khách hàng",
              finalSessionSeconds: widget.finalSessionSeconds,
              completionImageUrl: imageUrl,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showError(
          context,
          title: "Lỗi",
          message: "Không thể hoàn tất: ${e.toString()}",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Hoàn thành công việc",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 4),
              child: Text(
                "Chụp ảnh bằng chứng",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Text(
                "Vui lòng chụp ảnh kết quả công việc đã hoàn thành để xác nhận với khách hàng.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
            ),
            
            // Upload Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EvidenceUploadArea(
                  image: _evidenceImage,
                  onPickImage: _pickImage,
                  title: "Nhấn để thêm ảnh",
                  description: "Ảnh chụp sẽ được hiển thị ở đây.",
                  buttonText: "Chụp ảnh hoàn thành",
                  isDashed: true,
                ),
              ),
            ),

            // Final Action Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_evidenceImage != null && !_isLoading) ? _uploadAndProceed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Hoàn tất công việc",
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
        ),
      ),
    );
  }
}
