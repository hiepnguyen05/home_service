import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String id; // Matches providerId
  final double balance;
  final double totalIncome;
  final double totalWithdrawn;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.balance,
    this.totalIncome = 0.0,
    this.totalWithdrawn = 0.0,
    required this.updatedAt,
  });

  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return WalletModel(
      id: doc.id,
      balance: (data['balance'] ?? 0.0).toDouble(),
      totalIncome: (data['totalIncome'] ?? 0.0).toDouble(),
      totalWithdrawn: (data['totalWithdrawn'] ?? 0.0).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'balance': balance,
      'totalIncome': totalIncome,
      'totalWithdrawn': totalWithdrawn,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
