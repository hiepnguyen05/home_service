import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../widgets/summary/summary_success_header.dart';
import '../widgets/summary/summary_card.dart';
import '../widgets/summary/summary_detail_row.dart';
import '../widgets/summary/payment_status_badge.dart';
import '../../../wallet/viewmodel/wallet_viewmodel.dart';
import 'package:provider/provider.dart';

class ProviderJobSummaryScreen extends StatefulWidget {
  final BookingModel booking;
  final String serviceName;
  final String customerName;
  final int finalSessionSeconds;
  final String? completionImageUrl;
  final bool isHistoryView;

  const ProviderJobSummaryScreen({
    super.key,
    required this.booking,
    required this.serviceName,
    required this.customerName,
    required this.finalSessionSeconds,
    this.completionImageUrl,
    this.isHistoryView = false,
  });

  @override
  State<ProviderJobSummaryScreen> createState() => _ProviderJobSummaryScreenState();
}

class _ProviderJobSummaryScreenState extends State<ProviderJobSummaryScreen> {
  bool _isLoading = false;

  Future<void> _confirmAndComplete(double finalPrice) async {
    setState(() => _isLoading = true);
    try {
      final repo = BookingRepository();
      await repo.completeJob(
        widget.booking.id,
        widget.finalSessionSeconds,
        completionImageUrl: widget.completionImageUrl,
        finalPrice: finalPrice,
      );
      
      // 2. Cập nhật ví thợ
      if (mounted) {
        final walletVm = Provider.of<WalletViewModel>(context, listen: false);
        // Lấy lại booking đã cập nhật status/price
        final updatedBooking = await repo.getBookingById(widget.booking.id);
        if (updatedBooking != null) {
          await walletVm.handleJobCompletion(updatedBooking);
        }
      }
      
      if (mounted) {
        DialogUtils.showSuccess(
          context,
          title: "Hoàn tất",
          message: "Đơn hàng đã được ghi nhận hoàn thành. Cảm ơn sự nỗ lực của bạn!",
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showError(
          context,
          title: "Lỗi",
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
    
    // 1. Lấy chi phí phát sinh và trạng thái (để biết đã cộng vào totalPrice chưa)
    final double extraCost = widget.booking.extraCostAmount ?? 0.0;
    final bool isExtraCostApproved = widget.booking.extraCostStatus == 'approved';
    
    // 2. Xác định basePrice thực tế (giá trị trước khi cộng extra cost)
    // Firestore lưu totalPrice là giá đã bao gồm extra cost nếu đã approved.
    double actualBasePrice = widget.booking.totalPrice;
    if (isExtraCostApproved) {
      actualBasePrice = widget.booking.totalPrice - extraCost;
    }
    
    // 3. Logic tính toán tiền dựa trên đơn vị tính
    final bool isHourly = widget.booking.priceUnit == 'giờ';
    final int totalSeconds = widget.booking.totalWorkingSeconds + widget.finalSessionSeconds;
    
    double calculatedBasePrice = actualBasePrice;
    double hourlyRate = 0;
    
    if (isHourly) {
       // hourlyRate = giá gốc / số lượng (giờ) gốc khách đặt
       hourlyRate = actualBasePrice / (widget.booking.quantity > 0 ? widget.booking.quantity : 1);
       debugPrint("--- DEBUG: Hourly Calculation ---");
       debugPrint("Hourly Rate: $hourlyRate");
       
       if (totalSeconds > 0) {
         // calculatedBasePrice mới = đơn giá * (tổng giây / 3600)
         calculatedBasePrice = hourlyRate * (totalSeconds / 3600.0);
         debugPrint("New calculated basePrice: $calculatedBasePrice");
       }
    } else {
      // Đối với các đơn vị khác (lần, bộ, m2...), giá là cố định theo đơn hàng gốc
      debugPrint("--- DEBUG: Fixed Price Calculation ---");
      calculatedBasePrice = actualBasePrice;
    }

    // 4. Tổng cộng cuối cùng
    // CHỈ cộng chi phí phát sinh nếu khách hàng ĐÃ ĐỒNG Ý
    final totalIncome = calculatedBasePrice + (isExtraCostApproved ? extraCost : 0.0);

    final isCOD = widget.booking.paymentMethod == BookingPaymentMethod.COD;
    final buttonText = isCOD ? "Xác nhận thu tiền và hoàn thành" : "Xác nhận và Đóng";

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tổng kết đơn hàng",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF3F4F6), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SummarySuccessHeader(),
            const SizedBox(height: 32),
            
            SummaryCard(
              title: "Thông tin dịch vụ",
              children: [
                SummaryDetailRow(label: "Dịch vụ:", value: widget.serviceName),
                SummaryDetailRow(
                  label: "Ngày thực hiện:", 
                  value: dateFormat.format(widget.booking.scheduleAt),
                ),
                SummaryDetailRow(label: "Khách hàng:", value: widget.customerName),
                if (isHourly)
                   SummaryDetailRow(
                     label: "Thời gian làm việc:", 
                     value: totalSeconds >= 3600
                        ? "${(totalSeconds / 3600.0).toStringAsFixed(1)} giờ"
                        : "${(totalSeconds / 60.0).toStringAsFixed(1)} phút",
                     valueColor: AppColors.primary,
                   ),
              ],
            ),
            const SizedBox(height: 24),
            
            SummaryCard(
              title: "Chi tiết thanh toán",
              children: [
                SummaryDetailRow(
                  label: isHourly 
                      ? "Giá (${currencyFormat.format(hourlyRate)} \u00d7 ${(totalSeconds / 3600.0).toStringAsFixed(1)}h):" 
                      : "Giá cơ bản:", 
                  value: currencyFormat.format(calculatedBasePrice),
                  isBoldValue: isHourly,
                ),
                SummaryDetailRow(
                  label: isExtraCostApproved ? "Chi phí phát sinh:" : "Chi phí phát sinh (Chưa duyệt):", 
                  value: currencyFormat.format(extraCost),
                  isBoldValue: extraCost > 0,
                  valueColor: isExtraCostApproved ? null : Colors.orange,
                ),
                if (widget.booking.extraCostDescription != null &&
                    widget.booking.extraCostDescription!.isNotEmpty)
                  SummaryDetailRow(
                    label: "Mô tả chi phí phát sinh:",
                    value: widget.booking.extraCostDescription!,
                  ),
                const Divider(color: Color(0xFFF3F4F6), height: 24),
                SummaryDetailRow(
                  label: "Tổng thu nhập:", 
                  value: currencyFormat.format(totalIncome),
                  valueColor: const Color(0xFF4CAF50),
                  isLarge: true,
                ),
                const SizedBox(height: 16),
                Center(
                  child: PaymentStatusBadge(paymentMethod: widget.booking.paymentMethod),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.isHistoryView 
          ? null 
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _confirmAndComplete(totalIncome),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          buttonText,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                  ),
                ),
              ),
            ),
    );
  }
}
