import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/booking/viewmodel/review_viewmodel.dart';
import 'package:mobile/features/provider/data/models/provider_model.dart';
import 'package:provider/provider.dart';
import '../widgets/rating/review_image_picker.dart';
import '../widgets/rating/review_service_info.dart';
import '../widgets/rating/review_star_rating.dart';

class RatingScreen extends StatefulWidget {
  final BookingModel booking;
  final ProviderModel provider;
  final String serviceName;

  const RatingScreen({
    super.key,
    required this.booking,
    required this.provider,
    required this.serviceName,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit(ReviewViewModel vm, AuthViewModel authVm) async {
    final user = authVm.currentUser;
    if (user == null) return;

    final success = await vm.submitReview(
      bookingId: widget.booking.id,
      providerId: widget.provider.id,
      currentUser: user,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cảm ơn bạn đã đánh giá dịch vụ!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (vm.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final reviewVm = context.watch<ReviewViewModel>();
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Đánh giá & Nhận xét"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ReviewServiceInfo(
              serviceName: widget.serviceName,
              providerName: widget.provider.name,
              date: dateFormat.format(widget.booking.scheduleAt),
              providerAvatar: widget.provider.avatarUrl,
            ),
            const SizedBox(height: 32),
            const Text(
              "Bạn thấy dịch vụ thế nào?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ReviewStarRating(
              rating: reviewVm.rating,
              onRatingChanged: reviewVm.setRating,
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Viết nhận xét của bạn",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  onChanged: reviewVm.setComment,
                  decoration: InputDecoration(
                    hintText: "Chia sẻ cảm nhận của bạn về dịch vụ...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ReviewImagePicker(
              images: reviewVm.images,
              onPickImage: reviewVm.pickImage,
              onRemoveImage: reviewVm.removeImage,
              isLoading: reviewVm.isSubmitting && reviewVm.images.length >= 0, // Simplified loading check
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: reviewVm.isSubmitting ? null : () => _submit(reviewVm, authVm),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: reviewVm.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    "Gửi đánh giá",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
