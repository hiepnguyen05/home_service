import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../booking/viewmodel/booking_viewmodel.dart';
import '../../../../booking/data/models/booking_model.dart';

class WaitingForProviderDialog extends StatefulWidget {
  final String bookingId;
  final BookingViewModel bookingViewModel;
  final VoidCallback onSuccess;
  final VoidCallback? onWaitingPayment; // NEW
  final Function(String) onFailure;

  const WaitingForProviderDialog({
    super.key,
    required this.bookingId,
    required this.bookingViewModel,
    required this.onSuccess,
    this.onWaitingPayment, // NEW
    required this.onFailure,
  });

  @override
  State<WaitingForProviderDialog> createState() =>
      _WaitingForProviderDialogState();
}

class _WaitingForProviderDialogState extends State<WaitingForProviderDialog> {
  int _secondsRemaining = 30;
  Timer? _timer;
  StreamSubscription<BookingModel?>? _statusSubscription;
  bool _hasCompleted = false; // Ngăn gọi callback nhiều lần

  @override
  void initState() {
    super.initState();
    print("⏳ [WaitDialog] initState - bookingId: ${widget.bookingId}");
    _startTimer();
    _listenToStatus();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_hasCompleted) return;
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _handleTimeout();
      }
    });
  }

  void _listenToStatus() {
    print("👀 [WaitDialog] Listening to booking status...");
    _statusSubscription = widget.bookingViewModel
        .streamBooking(widget.bookingId)
        .listen((booking) {
      if (_hasCompleted) return;
      // if (booking == null) return; // Removed redundant check

      print("📡 [WaitDialog] Status update: ${booking.status}");

      if (booking.status == BookingStatus.confirmed) {
        // Case 1: COD - Confirmed directly
        print("✅ [WaitDialog] Provider accepted (COD)!");
        _cleanup();
        _hasCompleted = true;

        // Fix: Close dialog before calling callback
        if (mounted) {
          Navigator.of(context).pop();
        }

        widget.onSuccess();
      } else if (booking.status == BookingStatus.waitingPayment) {
        // Case 2: Online - Waiting Payment -> Auto Navigate to Payment
        print(
            "💳 [WaitDialog] Provider accepted (Online) -> Auto Navigate to Payment");
        _cleanup();
        _hasCompleted = true;

        // IMPORTANT: Close dialog first, then trigger callback to navigate
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (widget.onWaitingPayment != null) {
          widget.onWaitingPayment!();
        } else {
          widget.onSuccess();
        }
      } else if (booking.status == BookingStatus.cancelled) {
        print("❌ [WaitDialog] Booking cancelled by provider");
        _cleanup();
        _hasCompleted = true;
        if (mounted) Navigator.of(context).pop(); // Close dialog
        widget.onFailure("Thợ đã từ chối yêu cầu này. Vui lòng chọn thợ khác.");
      }
    }, onError: (e) {
      print("❌ [WaitDialog] Stream Error: $e");
    });
  }

  void _handleTimeout() {
    if (_hasCompleted) return;
    print("⏰ [WaitDialog] Timeout!");
    _cleanup();
    _hasCompleted = true;
    if (mounted) Navigator.of(context).pop(); // Close dialog

    widget.bookingViewModel.cancelBooking(widget.bookingId,
        reason: "Hết thời gian chờ thợ xác nhận");
    widget
        .onFailure("Thợ không phản hồi. Vui lòng thử lại hoặc chọn thợ khác.");
  }

  void _handleUserCancel() {
    if (_hasCompleted) return;
    print("🚫 [WaitDialog] User cancelled manually");
    _cleanup();
    _hasCompleted = true;
    if (mounted) Navigator.of(context).pop(); // Close dialog

    widget.bookingViewModel
        .cancelBooking(widget.bookingId, reason: "Khách hàng hủy khi đang chờ");
    widget.onFailure("Đã hủy yêu cầu");
  }

  void _cleanup() {
    _timer?.cancel();
    _statusSubscription?.cancel();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            "Đang chờ thợ xác nhận...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Vui lòng đợi trong $_secondsRemaining giây",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _handleUserCancel,
            child: const Text("Hủy", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
