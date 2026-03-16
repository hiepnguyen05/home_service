import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';

class ProviderWaitingPaymentDialog extends StatefulWidget {
  final String bookingId;
  final VoidCallback onPaymentSuccess; // Khách đã trả tiền
  final Function(String) onPaymentFailed; // Khách hủy hoặc lỗi

  const ProviderWaitingPaymentDialog({
    super.key,
    required this.bookingId,
    required this.onPaymentSuccess,
    required this.onPaymentFailed,
  });

  @override
  State<ProviderWaitingPaymentDialog> createState() =>
      _ProviderWaitingPaymentDialogState();
}

class _ProviderWaitingPaymentDialogState
    extends State<ProviderWaitingPaymentDialog> {
  int _secondsRemaining = 300; // 5 phút chờ thanh toán
  Timer? _timer;
  StreamSubscription<DocumentSnapshot>? _statusSubscription;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _listenToBookingStatus();
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

  void _listenToBookingStatus() {
    _statusSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .listen((snapshot) {
      if (_hasCompleted || !snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final status = data['status'] as String?;

      print("Payment Wait Dialog - Status: $status");

      if (status == BookingStatus.confirmed) {
        // Payment success
        _cleanup();
        _hasCompleted = true;
        widget.onPaymentSuccess();
      } else if (status == BookingStatus.cancelled) {
        // Customer cancelled or failed payment
        _cleanup();
        _hasCompleted = true;
        widget.onPaymentFailed("Khách hàng đã hủy hoặc thanh toán thất bại.");
      }
    });
  }

  void _handleTimeout() {
    if (_hasCompleted) return;
    _cleanup();
    _hasCompleted = true;
    // Auto cancel if timeout
    FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .update({'status': BookingStatus.cancelled});

    widget.onPaymentFailed("Hết thời gian chờ thanh toán.");
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
    // Format mm:ss
    final minutes = (_secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

    return PopScope(
      canPop: false, // Prevent back button
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              "Đang chờ khách thanh toán...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Tự động hủy sau: $minutes:$seconds",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () {
                // Provider manually cancels wait
                // Should ideally confirm "Are you sure?"
                _cleanup();
                _hasCompleted = true;
                // Note: Does provider cancelling here cancel the booking?
                // Yes, probably safer to just close dialog or cancel booking.
                // Let's cancel the booking to release state.
                FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(widget.bookingId)
                    .update({'status': BookingStatus.cancelled});
                widget.onPaymentFailed("Bạn đã hủy chờ thanh toán.");
              },
              child: const Text("Hủy chờ"),
            ),
          ],
        ),
      ),
    );
  }
}
