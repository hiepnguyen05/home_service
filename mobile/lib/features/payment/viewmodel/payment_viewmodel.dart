import 'package:flutter/material.dart';
import '../data/models/payment_method.dart';
import '../data/services/payment_api_service.dart';

/// ViewModel quản lý state cho Payment
class PaymentViewModel extends ChangeNotifier {
  final PaymentApiService _apiService = PaymentApiService();

  // State
  PaymentMethod _selectedMethod = PaymentMethod.momo;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _currentOrderId;

  // Getters
  PaymentMethod get selectedMethod => _selectedMethod;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get currentOrderId => _currentOrderId;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Chọn phương thức thanh toán
  void selectPaymentMethod(PaymentMethod method) {
    if (_selectedMethod != method) {
      _selectedMethod = method;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Xử lý thanh toán MoMo - trả về MoMoPaymentResult
  Future<MoMoPaymentResult?> processMoMoPayment({
    required String bookingId,
    required double amount,
    required String orderInfo,
  }) async {
    _setProcessing(true);
    _errorMessage = null;

    try {
      // Gọi API tạo payment
      final result = await _apiService.createMoMoPayment(
        bookingId: bookingId,
        amount: amount,
        orderInfo: orderInfo,
      );

      if (result.success && result.orderId != null) {
        _currentOrderId = result.orderId;
        return result;
      } else {
        _setError(result.message ?? 'Không nhận được link thanh toán từ MoMo');
        return null;
      }
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setProcessing(false);
    }
  }

  /// Kiểm tra kết quả sau khi quay lại từ MoMo
  Future<bool> checkPaymentStatus(String orderId) async {
    try {
      final result = await _apiService.checkPaymentStatus(orderId);
      final status = result['data']?['status'];
      return status == 'success';
    } catch (e) {
      print('Check status error: $e');
      return false;
    }
  }

  /// Reset về phương thức mặc định
  void reset() {
    _selectedMethod = PaymentMethod.momo;
    _isProcessing = false;
    _errorMessage = null;
    _currentOrderId = null;
    if (!_isDisposed) notifyListeners();
  }

  /// Clear error
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      if (!_isDisposed) notifyListeners();
    }
  }

  // Private methods
  void _setProcessing(bool processing) {
    if (_isProcessing != processing) {
      _isProcessing = processing;
      if (!_isDisposed) notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    if (!_isDisposed) notifyListeners();
  }
}
