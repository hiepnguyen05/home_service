import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:mobile/core/constants/app_colors.dart'; // Unused
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository.dart'; // Thêm repo lấy thông tin KH
import 'provider_check_in_screen.dart'; // Added
import 'package:mobile/features/chat/view/screens/chat_screen.dart'; // Added

class ProviderOrderSuccessScreen extends StatefulWidget {
  final BookingModel booking;

  const ProviderOrderSuccessScreen({super.key, required this.booking});

  @override
  State<ProviderOrderSuccessScreen> createState() => _ProviderOrderSuccessScreenState();
}

class _ProviderOrderSuccessScreenState extends State<ProviderOrderSuccessScreen> {
  StreamSubscription? _statusSubscription;
  bool _isCancellationDialogShowing = false;
  bool _isLoadingCustomer = true;

  String _customerName = "Khách hàng";
  String? _customerAvatar;
  String? _customerPhone;

  @override
  void initState() {
    super.initState();
    _listenToStatusChanges();
    _fetchCustomerInfo();
  }

  Future<void> _fetchCustomerInfo() async {
    try {
      final user = await AuthRepository().getUserById(widget.booking.customerId);
      if (mounted) {
        setState(() {
          if (user != null) {
            _customerName = user.fullName.isNotEmpty ? user.fullName : "Khách hàng";
            _customerAvatar = user.avatarUrl;
            _customerPhone = user.phone;
          }
          _isLoadingCustomer = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải thông tin khách hàng: $e");
      if (mounted) {
        setState(() {
          _isLoadingCustomer = false;
        });
      }
    }
  }

  Future<void> _callCustomer() async {
    if (_customerPhone == null || _customerPhone!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chưa có số điện thoại khách hàng")),
        );
      }
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: _customerPhone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Cannot launch';
      }
    } catch (e) {
      debugPrint("Lỗi gọi điện: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể thực hiện cuộc gọi")),
        );
      }
    }
  }

  void _listenToStatusChanges() {
    _statusSubscription = BookingRepository().streamBooking(widget.booking.id).listen((booking) {
      if (booking.status == BookingStatus.cancelled && !_isCancellationDialogShowing) {
        _isCancellationDialogShowing = true;
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Thông báo"),
              content: const Text("Khách hàng đã hủy đơn hàng này."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to dashboard
                  },
                  child: const Text("Đóng"),
                ),
              ],
            ),
          ).then((_) {
            _isCancellationDialogShowing = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _openMap(BuildContext context) async {
    // 1. Thử dùng google.navigation (đặc thù cho Android)
    // q: truy vấn (địa chỉ), mode: d (đi xe), w (đi bộ), v.v.
    String query = Uri.encodeComponent(widget.booking.address);
    final googleNavUrl = Uri.parse("google.navigation:q=$query");
    final googleMapsHttpUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

    bool launched = false;
    try {
      if (await canLaunchUrl(googleNavUrl)) {
        launched = await launchUrl(googleNavUrl);
      }
    } catch (e) {
      debugPrint("Không thể mở google.navigation: $e");
    }

    // 2. Chuyển sang HTTP URL nếu không mở được app
    if (!launched) {
      try {
        if (!await launchUrl(googleMapsHttpUrl,
            mode: LaunchMode.externalApplication)) {
          throw 'Could not launch maps';
        }
      } catch (e) {
        debugPrint("Không thể mở bản đồ http: $e");
      }
    }

    // 3. Chuyển hướng sang màn hình Check-in ngay lập tức
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProviderCheckInScreen(booking: widget.booking),
        ),
      );
    }
  }

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          bookingId: widget.booking.id,
          targetUserId: widget.booking.customerId, // Truyền ID khách để gửi thông báo
          otherUserName: _customerName, // Tên thật từ User repository
          otherUserAvatar: _customerAvatar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày/giờ
    final timeFormat = DateFormat('hh:mm a'); // 09:30 AM
    final dateFormat =
        DateFormat('EEEE, dd MMMM, yyyy', 'vi'); // Hôm nay, 24 Tháng 5, 2024

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // màu nền chính
      body: Column(
        children: [
          // Khoảng trống cho thanh trạng thái
          SizedBox(height: MediaQuery.of(context).padding.top + 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Biểu tượng tích xanh
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7), // xanh lá nhạt
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50), // màu chính
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    "Đặt lịch thành công!",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937), // chữ chính
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    "Yêu cầu dịch vụ đã được xác nhận. Vui lòng chuẩn bị dụng cụ.",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      color: Color(0xFF64748B), // chữ phụ
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Info Card
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 380),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24), // bo góc 24
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Phần thời gian
                        const Text(
                          "THỜI GIAN CÓ MẶT",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B), // chữ phụ
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.schedule,
                                color: Color(0xFF4CAF50), size: 28),
                            const SizedBox(width: 8),
                            Text(
                              timeFormat.format(widget.booking.scheduleAt),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(widget.booking.scheduleAt),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Divider(
                            height: 1,
                            color: Color(0xFFF1F5F9)), // viền xám nhạt
                        const SizedBox(height: 24),

                        // Location Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9), // xám 100
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Địa điểm làm việc",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.booking.address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Buttons
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Column(
                      children: [
                        // Nút bắt đầu di chuyển
                        _buildButton(
                          onPressed: () => _openMap(context),
                          icon: Icons.navigation,
                          label: "Bắt đầu di chuyển",
                          backgroundColor: const Color(0xFF4CAF50),
                          textColor: Colors.white,
                          hasShadow: true,
                        ),
                        const SizedBox(height: 16),

                        // Chờ tải xong thông tin khách hàng mới hiện các nút phụ
                        _isLoadingCustomer
                            ? const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
                              )
                            : Column(
                                children: [
                                  // Nút Gọi khách hàng
                                  _buildButton(
                                    onPressed: () => _callCustomer(),
                                    icon: Icons.phone_in_talk,
                                    label: "Gọi khách hàng",
                                    backgroundColor: Colors.white,
                                    textColor: const Color(0xFF4CAF50),
                                    borderColor: const Color(0xFF4CAF50),
                                  ),
                                  const SizedBox(height: 16),

                                  // Chat Button
                                  _buildButton(
                                    onPressed: () => _openChat(context),
                                    icon: Icons.chat_bubble_outline,
                                    label: "Chat với khách hàng",
                                    backgroundColor: Colors.white,
                                    textColor: const Color(0xFF1F2937),
                                    borderColor: const Color(0xFFE2E8F0),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chỉ báo dưới cùng (để làm đẹp)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: 128,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    bool hasShadow = false,
  }) {
    return Container(
      width: double.infinity,
      height: 64, // chiều cao khoảng py-4 px-6
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16), // bo góc 16
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : null,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3), // bóng xanh lá
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
