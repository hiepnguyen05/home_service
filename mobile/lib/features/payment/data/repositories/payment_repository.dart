import '../models/payment_method.dart';

/// Repository xử lý các thao tác liên quan đến thanh toán
class PaymentRepository {
  /// Lấy danh sách phương thức thanh toán khả dụng
  Future<List<PaymentMethod>> getAvailablePaymentMethods() async {
    // TODO: Gọi API lấy danh sách phương thức thanh toán (nếu cần)
    // Hiện tại trả về tất cả các phương thức
    return PaymentMethod.values;
  }

  /// Kiểm tra phương thức thanh toán có khả dụng không
  Future<bool> isPaymentMethodAvailable(PaymentMethod method) async {
    // TODO: Gọi API kiểm tra phương thức thanh toán
    return true;
  }

  /// Lấy phương thức thanh toán mặc định của user
  Future<PaymentMethod> getDefaultPaymentMethod() async {
    // TODO: Lấy từ user preferences hoặc API
    return PaymentMethod.momo;
  }

  /// Lưu phương thức thanh toán mặc định
  Future<void> saveDefaultPaymentMethod(PaymentMethod method) async {
    // TODO: Lưu vào user preferences hoặc API
  }
}
