import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../booking/data/models/booking_model.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';

class WalletRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy thông tin ví của thợ
  Future<WalletModel?> getWallet(String providerId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(providerId).get();
      if (doc.exists) {
        return WalletModel.fromFirestore(doc);
      } else {
        // Nếu chưa có ví, tạo mới ví 0 đồng
        final newWallet = WalletModel(
          id: providerId,
          balance: 0.0,
          updatedAt: DateTime.now(),
        );
        await _firestore.collection('wallets').doc(providerId).set(newWallet.toMap());
        return newWallet;
      }
    } catch (e) {
      print("❌ [WalletRepo] Lỗi khi lấy ví: $e");
      return null;
    }
  }

  // Lấy lịch sử giao dịch
  Future<List<TransactionModel>> getTransactionHistory(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('walletId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("❌ [WalletRepo] Lỗi khi lấy lịch sử giao dịch: $e");
      return [];
    }
  }

  // Xử lý thanh toán và hoa hồng khi hoàn thành đơn hàng
  Future<void> processBookingPayment(BookingModel booking) async {
    final providerId = booking.providerId;
    final walletRef = _firestore.collection('wallets').doc(providerId);
    final platformFeePercent = 0.25; // 25% platform fee

    try {
      await _firestore.runTransaction((transaction) async {
        final walletDoc = await transaction.get(walletRef);
        
        double currentBalance = 0.0;
        double currentTotalIncome = 0.0;
        
        if (walletDoc.exists) {
          final data = walletDoc.data()!;
          currentBalance = (data['balance'] ?? 0.0).toDouble();
          currentTotalIncome = (data['totalIncome'] ?? 0.0).toDouble();
        }

        final totalPrice = booking.totalPrice;
        final commission = totalPrice * platformFeePercent;
        
        if (booking.paymentMethod == BookingPaymentMethod.eWallet) {
          // Thanh toán online: Thợ nhận 75% vào ví
          final providerEarning = totalPrice - commission;
          final newBalance = currentBalance + providerEarning;
          final newTotalIncome = currentTotalIncome + providerEarning;

          transaction.set(walletRef, {
            'balance': newBalance,
            'totalIncome': newTotalIncome,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          // Log transaction: Thu nhập từ đơn hàng (sau khi trừ phí)
          final transRef = _firestore.collection('transactions').doc();
          transaction.set(transRef, {
            'walletId': providerId,
            'bookingId': booking.id,
            'amount': providerEarning,
            'type': TransactionType.income.toString().split('.').last,
            'paymentMethod': 'E-wallet',
            'description': 'Thu nhập từ đơn hàng ${booking.id} (Trừ 25% phí hệ thống)',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Thanh toán tiền mặt (COD): Khách đưa 100% cho thợ, ví thợ bị trừ 25% phí
          final providerEarning = totalPrice - commission;
          final newBalance = currentBalance - commission;
          final newTotalIncome = currentTotalIncome + providerEarning;

          transaction.set(walletRef, {
            'balance': newBalance,
            'totalIncome': newTotalIncome,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          // Log transaction 1: Thu nhập từ đơn hàng (tiền mặt) - để thống kê
          final incomeTransRef = _firestore.collection('transactions').doc();
          transaction.set(incomeTransRef, {
            'walletId': providerId,
            'bookingId': booking.id,
            'amount': providerEarning,
            'type': TransactionType.income.toString().split('.').last,
            'paymentMethod': 'COD',
            'description': 'Thu nhập (tiền mặt) từ đơn hàng ${booking.id}',
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Log transaction 2: Phí hoa hồng hệ thống (trừ vào ví)
          final commTransRef = _firestore.collection('transactions').doc();
          transaction.set(commTransRef, {
            'walletId': providerId,
            'bookingId': booking.id,
            'amount': -commission,
            'type': TransactionType.commission.toString().split('.').last,
            'paymentMethod': 'COD',
            'description': 'Phí hệ thống 25% cho đơn hàng COD ${booking.id}',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print("❌ [WalletRepo] Lỗi khi xử lý thanh toán ví: $e");
      throw Exception("Không thể xử lý giao dịch ví.");
    }
  }

  // Stream ví để cập nhật thời gian thực
  Stream<WalletModel?> walletStream(String providerId) {
    return _firestore
        .collection('wallets')
        .doc(providerId)
        .snapshots()
        .map((doc) => doc.exists ? WalletModel.fromFirestore(doc) : null);
  }

  // Nạp tiền vào ví
  Future<void> topUpWallet(String providerId, double amount) async {
    final walletRef = _firestore.collection('wallets').doc(providerId);

    try {
      await _firestore.runTransaction((transaction) async {
        final walletDoc = await transaction.get(walletRef);

        double currentBalance = 0.0;
        if (walletDoc.exists) {
          currentBalance = (walletDoc.data()?['balance'] ?? 0.0).toDouble();
        }

        final newBalance = currentBalance + amount;

        transaction.set(walletRef, {
          'balance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Log transaction: Nạp tiền
        final transRef = _firestore.collection('transactions').doc();
        transaction.set(transRef, {
          'walletId': providerId,
          'amount': amount,
          'type': TransactionType.topup.toString().split('.').last,
          'paymentMethod': 'MoMo',
          'description': 'Nạp tiền vào ví qua MoMo',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print("❌ [WalletRepo] Lỗi khi nạp tiền: $e");
      throw Exception("Không thể thực hiện nạp tiền.");
    }
  }

  // Rút tiền khỏi ví
  Future<void> withdrawMoney(String providerId, double amount, String bankInfo) async {
    final walletRef = _firestore.collection('wallets').doc(providerId);

    try {
      await _firestore.runTransaction((transaction) async {
        final walletDoc = await transaction.get(walletRef);

        if (!walletDoc.exists) {
          throw Exception("Không tìm thấy ví.");
        }

        double currentBalance = (walletDoc.data()?['balance'] ?? 0.0).toDouble();

        if (currentBalance < amount) {
          throw Exception("Số dư không đủ để thực hiện rút tiền.");
        }

        final newBalance = currentBalance - amount;

        transaction.set(walletRef, {
          'balance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Log transaction: Rút tiền
        final transRef = _firestore.collection('transactions').doc();
        transaction.set(transRef, {
          'walletId': providerId,
          'amount': -amount, // Số tiền âm cho việc rút
          'type': TransactionType.withdrawal.toString().split('.').last,
          'paymentMethod': 'Bank Transfer',
          'description': 'Rút tiền về tài khoản: $bankInfo',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print("❌ [WalletRepo] Lỗi khi rút tiền: $e");
      throw Exception(e.toString());
    }
  }
}
