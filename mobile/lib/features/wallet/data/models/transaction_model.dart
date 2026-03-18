import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  income,      // Thưởng/Thu nhập từ đơn hàng
  commission,  // Phí chiết khấu hệ thống (thường là âm)
  withdrawal,  // Rút tiền
  topup        // Nạp tiền (nếu có)
}

class TransactionModel {
  final String id;
  final String walletId;
  final String? bookingId;
  final double amount;
  final TransactionType type;
  final String? paymentMethod; // COD, E-wallet
  final String description;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.walletId,
    this.bookingId,
    required this.amount,
    required this.type,
    this.paymentMethod,
    required this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      walletId: data['walletId'] ?? '',
      bookingId: data['bookingId'],
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${data['type']}',
        orElse: () => TransactionType.income,
      ),
      paymentMethod: data['paymentMethod'],
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'walletId': walletId,
      'bookingId': bookingId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
