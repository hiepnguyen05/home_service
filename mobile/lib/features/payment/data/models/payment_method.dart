import 'package:flutter/material.dart';

/// Phương thức thanh toán
enum PaymentMethod {
  momo,
  cash,
}

/// Extension cung cấp thông tin cho PaymentMethod
extension PaymentMethodExtension on PaymentMethod {
  /// Tên hiển thị
  String get label {
    switch (this) {
      case PaymentMethod.momo:
        return 'Ví MoMo';
      case PaymentMethod.cash:
        return 'Tiền mặt';
    }
  }

  /// Mô tả
  String get description {
    switch (this) {
      case PaymentMethod.momo:
        return 'Thanh toán qua ví điện tử MoMo';
      case PaymentMethod.cash:
        return 'Thanh toán tiền mặt khi hoàn thành';
    }
  }

  /// URL icon (cho MoMo)
  String? get iconUrl {
    switch (this) {
      case PaymentMethod.momo:
        return 'https://avatars.githubusercontent.com/u/36770798?s=280&v=4'; // Logo MoMo reliable URL
      case PaymentMethod.cash:
        return null;
    }
  }

  /// Icon (cho cash)
  IconData? get icon {
    switch (this) {
      case PaymentMethod.momo:
        return null;
      case PaymentMethod.cash:
        return Icons.payments;
    }
  }

  /// Có sử dụng image URL không
  bool get hasImageIcon => iconUrl != null;
}
