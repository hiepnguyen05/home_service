import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/services/cloudinary_service.dart';
import 'package:mobile/core/widgets/app_dialog.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../../../services/data/repositories/service_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../widgets/check_in/check_in_instruction_card.dart';
import '../widgets/workflow/evidence_upload_area.dart';
import 'provider_work_screen.dart';

class ProviderCheckInScreen extends StatefulWidget {
  final BookingModel booking;

  const ProviderCheckInScreen({super.key, required this.booking});

  @override
  State<ProviderCheckInScreen> createState() => _ProviderCheckInScreenState();
}

class _ProviderCheckInScreenState extends State<ProviderCheckInScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _checkInImage;
  bool _isGlobalLoading = false;
  String? _serviceName;
  String? _customerName;

  StreamSubscription? _statusSubscription;
  bool _isCancellationDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _fetchNames();
    _listenToStatusChanges();
  }

  void _listenToStatusChanges() {
    _statusSubscription = BookingRepository().streamBooking(widget.booking.id).listen((booking) {
      if (booking.status == BookingStatus.cancelled && !_isCancellationDialogShowing) {
        _isCancellationDialogShowing = true;
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Thông báo"),
              content: const Text("Khách hàng đã hủy đơn hàng này."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.of(context).popUntil((route) => route.isFirst); // Back to dashboard
                  },
                  child: const Text("Đóng"),
                ),
              ],
            ),
          ).then((_) {
            _isCancellationDialogShowing = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchNames() async {
    try {
      final service = await ServiceRepository().getServiceById(widget.booking.serviceId);
      final user = await AuthRepository().getUserById(widget.booking.customerId);
      if (mounted) {
        setState(() {
          _serviceName = service.name;
          _customerName = user?.fullName;
        });
      }
    } catch (e) {
      print("Error fetching names in CheckIn: $e");
    }
  }

  final List<String> _instructions = [
    "Chụp ảnh toàn cảnh phía trước địa điểm làm việc.",
    "Ảnh cần rõ nét, đủ ánh sáng.",
    "Nên có biển số nhà hoặc đặc điểm nhận diện rõ ràng.",
    "Vui lòng mặc đồng phục khi chụp ảnh (nếu có)."
  ];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _checkInImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chụp ảnh: $e')),
      );
    }
  }

  Future<void> _confirmArrival() async {
    if (_checkInImage == null) return;

    setState(() {
      _isGlobalLoading = true;
    });

    try {
      // 1. Upload image lên Cloudinary
      final imageUrl = await CloudinaryService.uploadFile(
        file: _checkInImage!,
        folder: 'check_ins/${widget.booking.id}',
      );

      if (imageUrl == null) throw Exception("Lỗi tải ảnh lên hệ thống");

      // 2. Cập nhật booking status sang processing (đã đến nơi)
      final repo = BookingRepository();
      await repo.confirmArrival(widget.booking.id, imageUrl);

      if (mounted) {
        DialogUtils.showSuccess(
          context,
          title: "Check-in thành công",
          message: "Đã xác nhận đến nơi. Chúc bạn hoàn thành tốt công việc!",
          onPressed: () {
            // Sau khi check-in xong, chuyển thẳng sang màn hình làm việc
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ProviderWorkScreen(
                  booking: widget.booking.copyWith(status: BookingStatus.arrived),
                  serviceName: _serviceName,
                  customerName: _customerName,
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        // Fix: Replace error dialog with soft check inside because exception is expected if cancelled during processing
        if (e.toString().contains("ủy")) {
           // Do nothing, the stream listener will capture and show dialog
           print("Bỏ qua lỗi vì đơn hàng đã bị hủy: $e");
        } else {
           DialogUtils.showError(context, title: "Lỗi", message: "Không thể xác nhận: ${e.toString()}");
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGlobalLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Xác nhận đến nơi",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.primary.withOpacity(0.2), height: 1),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      EvidenceUploadArea(
                        image: _checkInImage,
                        onPickImage: _pickImage,
                        title: "Chụp ảnh tại địa điểm",
                        description: "Vui lòng chụp ảnh tại địa điểm làm việc để xác nhận đã đến.",
                      ),
                      const SizedBox(height: 24),
                      CheckInInstructionCard(instructions: _instructions),
                    ],
                  ),
                ),
              ),
              // Nút hành động ở phía dưới
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _checkInImage != null && !_isGlobalLoading
                        ? _confirmArrival
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    ),
                    child: _isGlobalLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Xác nhận và Bắt đầu làm",
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
          if (_isGlobalLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}

