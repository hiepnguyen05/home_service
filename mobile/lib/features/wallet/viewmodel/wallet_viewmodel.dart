import 'package:flutter/material.dart';
import '../data/models/wallet_model.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/wallet_repository.dart';
import '../../booking/data/models/booking_model.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletRepository _repository = WalletRepository();

  WalletModel? _wallet;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  WalletModel? get wallet => _wallet;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Lấy thông tin ví và lịch sử ban đầu
  Future<void> initWallet(String providerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wallet = await _repository.getWallet(providerId);
      _transactions = await _repository.getTransactionHistory(providerId);
    } catch (e) {
      _error = "Lỗi khi tải thông tin ví: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lắng nghe thay đổi ví thời gian thực
  void listenToWallet(String providerId) {
    _repository.walletStream(providerId).listen((updatedWallet) {
      _wallet = updatedWallet;
      notifyListeners();
    });
  }

  // Xử lý hoàn thành đơn hàng từ phía Booking
  Future<void> handleJobCompletion(BookingModel booking) async {
    try {
      await _repository.processBookingPayment(booking);
      // Refresh transactions after completion
      _transactions = await _repository.getTransactionHistory(booking.providerId);
      notifyListeners();
    } catch (e) {
      print("❌ [WalletViewModel] Lỗi xử lý hoàn thành: $e");
    }
  }

  // Xử lý nạp tiền
  Future<void> topUpWallet(String providerId, double amount) async {
    try {
      await _repository.topUpWallet(providerId, amount);
      // Không cần fetch lại vì có walletStream lắng nghe realtime
      // Nhưng transactions thì cần fetch lại
      _transactions = await _repository.getTransactionHistory(providerId);
      notifyListeners();
    } catch (e) {
      print("❌ [WalletViewModel] Lỗi nạp tiền: $e");
    }
  }

  // Xử lý rút tiền
  Future<void> withdrawMoney(String providerId, double amount, String bankInfo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.withdrawMoney(providerId, amount, bankInfo);
      // Cập nhật lại danh sách giao dịch sau khi rút tiền thành công
      _transactions = await _repository.getTransactionHistory(providerId);
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tính toán dữ liệu biểu đồ cho tuần hiện tại
  List<double> getWeeklyChartData() {
    if (_transactions.isEmpty) return List.filled(7, 0.0);

    // Lấy ngày đầu tuần (T2)
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonday = DateTime(monday.year, monday.month, monday.day);

    List<double> dailyTotals = List.filled(7, 0.0);

    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        final txDate = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
        final difference = txDate.difference(startOfMonday).inDays;
        if (difference >= 0 && difference < 7) {
          dailyTotals[difference] += tx.amount;
        }
      }
    }

    // Chuẩn hóa dữ liệu (0.0 - 1.0) cho biểu đồ
    double maxVal = 0.0;
    for (var val in dailyTotals) {
      if (val > maxVal) maxVal = val;
    }

    if (maxVal == 0) return dailyTotals;
    return dailyTotals.map((e) => e / maxVal).toList();
  }

  double getWeeklyTotal() {
    if (_transactions.isEmpty) return 0.0;

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonday = DateTime(monday.year, monday.month, monday.day);

    double total = 0.0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        final txDate = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
        if (txDate.isAtSameMomentAs(startOfMonday) || txDate.isAfter(startOfMonday)) {
          total += tx.amount;
        }
      }
    }
    return total;
  }

  // Thu nhập tháng hiện tại
  double getMonthlyTotal() {
    if (_transactions.isEmpty) return 0.0;

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    double total = 0.0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        final txDate = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
        if (txDate.isAtSameMomentAs(firstDayOfMonth) || txDate.isAfter(firstDayOfMonth)) {
          total += tx.amount;
        }
      }
    }
    return total;
  }

  // Xử lý hôm nay
  double getTodayTotal() {
    if (_transactions.isEmpty) return 0.0;

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    double total = 0.0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        final txDate = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
        if (txDate.isAtSameMomentAs(startOfToday)) {
          total += tx.amount;
        }
      }
    }
    return total;
  }
}
