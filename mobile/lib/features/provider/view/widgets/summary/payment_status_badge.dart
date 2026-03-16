import 'package:flutter/material.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';

class PaymentStatusBadge extends StatelessWidget {
  final String paymentMethod;

  const PaymentStatusBadge({
    super.key,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = paymentMethod == BookingPaymentMethod.eWallet;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFFEFF6FF) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.check_circle : Icons.money_outlined,
            size: 16,
            color: isOnline ? const Color(0xFF1D4ED8) : const Color(0xFF92400E),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? "Đã thanh toán qua MoMo" : "Thu tiền mặt (COD)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isOnline ? const Color(0xFF1D4ED8) : const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}
