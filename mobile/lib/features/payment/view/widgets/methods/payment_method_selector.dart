import 'package:flutter/material.dart';
import '../../../data/models/payment_method.dart';
import 'payment_method_option.dart';

/// Widget selector cho phương thức thanh toán
class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final Function(PaymentMethod) onChanged;
  final List<PaymentMethod>? availableMethods;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
    this.availableMethods,
  });

  @override
  Widget build(BuildContext context) {
    final methods = availableMethods ?? PaymentMethod.values;

    return Column(
      children: methods.asMap().entries.map((entry) {
        final index = entry.key;
        final method = entry.value;

        return Column(
          children: [
            PaymentMethodOption(
              method: method,
              isSelected: selectedMethod == method,
              onTap: () => onChanged(method),
            ),
            if (index < methods.length - 1) const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }
}
