import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../payment/data/services/payment_api_service.dart';
import '../../../payment/view/screens/momo_payment_screen.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/wallet_viewmodel.dart';
import '../../../auth/viewmodel/auth_viewmodel.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  final List<int> _suggestedAmounts = [50000, 100000, 200000, 500000, 1000000];
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleTopUp() async {
    final amountText = _amountController.text.replaceAll('.', '');
    if (amountText.isEmpty) {
      DialogUtils.showError(context, title: 'Thông báo', message: 'Vui lòng nhập số tiền cần nạp');
      return;
    }

    final double amount = double.tryParse(amountText) ?? 0;
    if (amount < 10000) {
      DialogUtils.showError(context, title: 'Thông báo', message: 'Số tiền nạp tối thiểu là 10.000đ');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      final walletVm = Provider.of<WalletViewModel>(context, listen: false);
      final providerId = authVm.currentUser?.uid;

      if (providerId == null) throw Exception("User not logged in");

      final paymentService = PaymentApiService();
      
      // Tạo request thanh toán MoMo
      final result = await paymentService.createMoMoPayment(
        bookingId: "TOPUP_${providerId}_${DateTime.now().millisecondsSinceEpoch}",
        amount: amount,
        orderInfo: "Nạp tiền vào ví HomeService",
      );

      if (result.success && result.payUrl != null && mounted) {
        // Chuyển đến màn hình thanh toán MoMo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MoMoPaymentScreen(
              paymentResult: result,
              serviceName: "Nạp tiền ví thợ",
              amount: amount,
              isTopUp: true,
              onPaymentComplete: (success) async {
                if (success) {
                  // Gọi ViewModel để cập nhật ví sau khi thanh toán thành công
                  await walletVm.topUpWallet(providerId, amount);
                  
                  if (!mounted) return;
                  
                  await DialogUtils.showSuccess(
                    context,
                    title: 'Nạp tiền thành công',
                    message: 'Số tiền ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount)} đã được cộng vào ví của bạn.',
                  );
                  
                  if (mounted) {
                    Navigator.pop(context); // Quay lại màn hình ví
                  }
                } else {
                  if (mounted) {
                    DialogUtils.showError(context, title: 'Lỗi', message: 'Giao dịch nạp tiền thất bại hoặc đã bị hủy.');
                  }
                }
              },
            ),
          ),
        );
      } else {
        if (mounted) {
          DialogUtils.showError(context, title: 'Lỗi', message: result.message ?? 'Không thể khởi tạo thanh toán MoMo');
        }
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showError(context, title: 'Lỗi', message: 'Đã xảy ra lỗi: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nạp tiền vào ví'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập số tiền nạp',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: '₫',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gợi ý số tiền',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _suggestedAmounts.map((amount) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _amountController.text = amount.toString();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(20),
                      color: _amountController.text == amount.toString() 
                        ? AppColors.primary.withOpacity(0.1) 
                        : Colors.transparent,
                    ),
                    child: Text(
                      currencyFormat.format(amount),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleTopUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Tiếp tục',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
