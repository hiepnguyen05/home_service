import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/payment_method.dart';
import '../data/services/payment_api_service.dart';

/// ViewModel quản lý state cho Payment
class PaymentCallbackResult {
  final bool isSuccess;
  final String? orderId;
  final String message;

  PaymentCallbackResult(this.isSuccess, {this.orderId, this.message = ''});
}

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
    print("🎬 [PaymentVM] Processing MoMo Payment for $bookingId...");

    try {
      // Gọi API tạo payment
      final result = await _apiService.createMoMoPayment(
        bookingId: bookingId,
        amount: amount,
        orderInfo: orderInfo,
      );

      if (result.success && result.orderId != null) {
        _currentOrderId = result.orderId;

        // Save bookingId to SharedPreferences for recovery in splash screen
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('pending_payment_booking_id', bookingId);
          await prefs.setString('pending_payment_order_id', result.orderId!);
          print("💾 [PaymentVM] Saved pending bookingId: $bookingId");
        } catch (e) {
          print("⚠️ [PaymentVM] Failed to save preference: $e");
        }

        return result;
      } else {
        print("❌ [PaymentVM] Error: ${result.message}");
        _setError(result.message ?? 'Không nhận được link thanh toán từ MoMo');
        return null;
      }
    } catch (e) {
      print("❌ [PaymentVM] Exception: $e");
      _setError(e.toString());
      return null;
    } finally {
      _setProcessing(false);
    }
  }

  /// Xác nhận thanh toán với Backend (gọi API confirm)
  Future<bool> confirmPayment(String orderId, String resultCode) async {
    try {
      return await _apiService.confirmPayment(orderId, resultCode);
    } catch (e) {
      print('Confirm payment error: $e');
      return false;
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

  /// Xử lý callback từ Deep Link
  PaymentCallbackResult handlePaymentCallback(Uri uri) {
    final resultCode = uri.queryParameters['resultCode'];
    final orderId = uri.queryParameters['orderId'];

    if (resultCode == '0' && orderId != null) {
      return PaymentCallbackResult(true, orderId: orderId);
    } else {
      return PaymentCallbackResult(false, message: "Mã lỗi: $resultCode");
    }
  }

  /// Hoàn tất thanh toán (Confirm + Check Status)
  Future<bool> finalizePayment(String orderId, String resultCode) async {
    _setProcessing(true);
    try {
      // 1. Confirm với Backend
      final confirmed = await _apiService.confirmPayment(orderId, resultCode);

      // 2. Double check status
      final success = await checkPaymentStatus(orderId);

      return confirmed || success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setProcessing(false);
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
