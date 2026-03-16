import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';
import '../../../../booking/data/models/booking_model.dart';

class WorkflowActions extends StatelessWidget {
  final String status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onComplete;
  final VoidCallback onCancelRequest;
  final VoidCallback? onAddExtraCost;
  final bool isLoading;

  const WorkflowActions({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onComplete,
    required this.onCancelRequest,
    this.onAddExtraCost,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (status == BookingStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Đơn hàng này đã bị hủy",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (status == BookingStatus.cancelPending) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
            ),
            SizedBox(width: 12),
            Text(
              "Đang chờ khách hàng duyệt hủy...",
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (status == BookingStatus.arrived) {
      return Column(
        children: [
          _buildMainButton(
            text: "Bắt đầu công việc",
            onPressed: onStart,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildCancelButton(),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                text: status == BookingStatus.paused ? "Tiếp tục" : "Tạm ngưng",
                onPressed: status == BookingStatus.paused ? onStart : onPause,
                icon: status == BookingStatus.paused ? Icons.play_arrow : Icons.pause,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMainButton(
                text: "Hoàn thành",
                onPressed: onComplete,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        if (status == BookingStatus.paused && onAddExtraCost != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onAddExtraCost,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text(
                "Thêm chi phí phát sinh",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        _buildCancelButton(),
      ],
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onCancelRequest,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Hủy đơn hàng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: color.withOpacity(0.4),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1F2937),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
