import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/services/data/repositories/service_repository.dart';
import 'package:mobile/features/booking/view/widgets/address/address_mini_map.dart';

class NewJobRequestDialog extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final int timeoutSeconds;

  const NewJobRequestDialog({
    super.key,
    required this.booking,
    required this.onAccept,
    required this.onReject,
    this.timeoutSeconds = 90,
  });

  @override
  State<NewJobRequestDialog> createState() => _NewJobRequestDialogState();
}

class _NewJobRequestDialogState extends State<NewJobRequestDialog> {
  late int _remainingSeconds;
  Timer? _timer;
  String _serviceName = "Đang tải...";

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeoutSeconds;
    _startTimer();
    _fetchServiceName();
  }

  Future<void> _fetchServiceName() async {
    try {
      final serviceRepo = ServiceRepository();
      final service =
          await serviceRepo.getServiceById(widget.booking.serviceId);
      if (mounted) {
        setState(() {
          _serviceName = service.name;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _serviceName = widget.booking.serviceId;
        });
      }
      print("Error fetching service name: $e");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        widget.onReject(); // Auto reject on timeout
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildTimeBox(String value, String label) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('EEEE, d MMMM, HH:mm', 'vi_VN');

    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;

    // Logic hiển thị thời gian
    String timeDisplay = dateFormat.format(widget.booking.scheduleAt);
    final now = DateTime.now();
    final diff = widget.booking.scheduleAt.difference(now).inMinutes;
    // Nếu trong khoảng -10p đến +30p thì coi như "Ngay bây giờ"
    if (diff >= -10 && diff <= 30) {
      timeDisplay = "Ngay bây giờ";
    }

    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header (fixed)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: const Text(
                  "YÊU CẦU DỊCH VỤ MỚI",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTimeBox("00", "Giờ"),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 16),
                            child: Text(":",
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.red.shade600,
                                    fontWeight: FontWeight.bold)),
                          ),
                          _buildTimeBox(
                              minutes.toString().padLeft(2, '0'), "Phút"),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 16),
                            child: Text(":",
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.red.shade600,
                                    fontWeight: FontWeight.bold)),
                          ),
                          _buildTimeBox(
                              seconds.toString().padLeft(2, '0'), "Giây"),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Info List
                      _buildInfoItem(Icons.work, "Dịch vụ", _serviceName,
                          isBold: true), // Service Name

                      _buildInfoItem(
                          Icons.calendar_today, "Thời gian", timeDisplay,
                          isBold: timeDisplay == "Ngay bây giờ",
                          color: timeDisplay == "Ngay bây giờ"
                              ? Colors.red
                              : null),

                      _buildInfoItem(
                          Icons.location_on, "Địa chỉ", widget.booking.address),

                      // Map
                      Container(
                        height: 150,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AddressMiniMap(
                            latitude: widget.booking.latitude ?? 21.0285,
                            longitude: widget.booking.longitude ?? 105.8542,
                          ),
                        ),
                      ),

                      // Note (Ghi chú)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.yellow.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.note,
                                  size: 16, color: Colors.orange.shade800),
                              const SizedBox(width: 8),
                              Text("Ghi chú của khách hàng:",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade900,
                                      fontWeight: FontWeight.bold)),
                            ]),
                            const SizedBox(height: 4),
                            Text(
                              (widget.booking.note != null &&
                                      widget.booking.note!.isNotEmpty)
                                  ? widget.booking.note!
                                  : "Không có ghi chú",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),

                      // Payment Method
                      _buildInfoItem(Icons.payment, "Phương thức thanh toán",
                          widget.booking.paymentMethod),

                      const Divider(),

                      // Price
                      _buildInfoItem(Icons.attach_money, "Thu nhập ước tính",
                          currencyFormat.format(widget.booking.totalPrice),
                          isBold: true, color: Colors.green.shade700),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Buttons (fixed at bottom)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: widget.onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "CHẤP NHẬN NGAY",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: widget.onReject,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "BỎ QUA",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildInfoItem(IconData icon, String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color ?? AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
