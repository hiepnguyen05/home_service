import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/stat_card.dart';
import 'package:mobile/core/services/location_service.dart';
import 'package:mobile/core/widgets/app_dialog.dart';
import 'package:mobile/features/provider/data/repositories/provider_repository.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  bool _isOnline = false;
  String? _savedAddress;
  final ProviderRepository _providerRepo = ProviderRepository();

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    // Lấy trạng thái từ Firestore
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final provider = await _providerRepo.getProviderById(userId);
      if (provider != null && mounted) {
        setState(() {
          _isOnline = provider.isOnline;
        });
      }
    }
  }

  // Hàm bật/tắt trạng thái
  Future<void> _toggleOnlineStatus(bool value) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      DialogUtils.showError(context,
          title: "Lỗi", message: "Bạn cần đăng nhập để sử dụng tính năng này.");
      return;
    }

    if (value) {
      // B0: Validate thông tin User trước khi bật
      DialogUtils.showLoading(context, message: "Đang kiểm tra hồ sơ...");

      String? avatar; // Declare outside try block
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (!mounted) return;
        DialogUtils.hideLoading(context); // Ẩn loading kiểm tra

        if (!userDoc.exists) {
          DialogUtils.showError(context,
              title: "Lỗi", message: "Không tìm thấy hồ sơ người dùng.");
          return;
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        avatar = userData['avatar_url']; // Assign here
        final String? phone = userData['phone'];

        List<String> missing = [];
        if (avatar == null || avatar.isEmpty) missing.add("Ảnh đại diện");
        // Kiểm tra Phone: có thể check thêm độ dài nếu muốn
        if (phone == null || phone.isEmpty) missing.add("Số điện thoại");

        if (missing.isNotEmpty) {
          DialogUtils.showError(
            context,
            title: "Cập nhật hồ sơ",
            message:
                "Để nhận việc, bạn cần bổ sung:\n- ${missing.join('\n- ')}\n\nVui lòng vào mục Cá nhân để cập nhật.",
          );
          // Reset switch về off
          setState(() => _isOnline = false);
          return;
        }
      } catch (e) {
        if (mounted) DialogUtils.hideLoading(context);
        print("Lỗi validate user: $e");
        return;
      }

      // BẬT TRẠNG THÁI -> Lấy vị trí
      DialogUtils.showLoading(context, message: "Đang cập nhật vị trí...");

      final position = await LocationService.getCurrentPosition();

      if (!mounted) return;
      DialogUtils.hideLoading(context); // Ẩn loading vị trí

      if (position != null) {
        // Lấy địa chỉ cụ thể để hiển thị cho đẹp
        final locationData = await LocationService.getLocationDetails(
            position.latitude, position.longitude);
        final address = locationData['full_address'] ?? "Vị trí không xác định";

        // Lưu lên Firebase
        final currentUser = FirebaseAuth.instance.currentUser;
        final success = await _providerRepo.updateProviderStatus(
          providerId: userId,
          isOnline: true,
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
          name: currentUser?.displayName,
          avatarUrl: avatar ?? currentUser?.photoURL,
        );

        if (success) {
          setState(() {
            _isOnline = true;
            _savedAddress = address;
          });

          DialogUtils.showSuccess(
            context,
            title: "Đã bật hoạt động",
            message: "Bạn đang online tại:\n$address",
          );
        } else {
          DialogUtils.showError(context,
              title: "Lỗi",
              message: "Không thể cập nhật trạng thái lên server.");
        }
      } else {
        DialogUtils.showError(
          context,
          title: "Lỗi vị trí",
          message:
              "Không thể lấy vị trí hiện tại. Vui lòng kiểm tra quyền GPS.",
        );
      }
    } else {
      // TẮT TRẠNG THÁI
      final success = await _providerRepo.updateProviderStatus(
        providerId: userId,
        isOnline: false,
      );

      if (success) {
        setState(() {
          _isOnline = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn đã tắt trạng thái hoạt động')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xin chào, Thợ!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // NÚT TRẠNG THÁI HOẠT ĐỘNG
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _isOnline
                                    ? Colors.greenAccent
                                    : Colors.white54),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isOnline ? "Online" : "Offline",
                                style: TextStyle(
                                    color: _isOnline
                                        ? Colors.greenAccent
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: _isOnline,
                                  onChanged: _toggleOnlineStatus,
                                  activeColor: Colors.green,
                                  activeTrackColor: Colors.white,
                                  inactiveThumbColor: Colors.grey,
                                  inactiveTrackColor: Colors.white30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Hôm nay',
                            value: '0',
                            subtitle: 'việc',
                            icon: Icons.work,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Thu nhập',
                            value: '0đ',
                            subtitle: 'tháng này',
                            icon: Icons.attach_money,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Đánh giá',
                            value: '5.0',
                            subtitle: 'sao',
                            icon: Icons.star,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thao tác nhanh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Nút này giờ có thể dùng để làm việc khác, hoặc ẩn đi nếu trùng lặp
                        // Tạm thời mình map nó vào hàm toggle luôn để tiện dụng
                        _buildQuickAction(
                          icon: _isOnline ? Icons.toggle_on : Icons.toggle_off,
                          label: _isOnline ? 'Tắt nhận việc' : 'Bật nhận việc',
                          color: _isOnline ? Colors.green : Colors.grey,
                          onTap: () => _toggleOnlineStatus(!_isOnline),
                        ),
                        const SizedBox(width: 16),
                        _buildQuickAction(
                          icon: Icons.history,
                          label: 'Lịch sử',
                          color: Colors.blue,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _buildQuickAction(
                          icon: Icons.wallet,
                          label: 'Ví tiền',
                          color: Colors.orange,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Jobs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Việc gần đây',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text('Xem tất cả',
                                style: TextStyle(color: AppColors.primary)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Empty state logic depending on Online Status
                    if (!_isOnline)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.power_settings_new,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Bạn đang Offline',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Vui lòng bật trạng thái hoạt động để nhận việc mới',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.radar, // Icon radar quét việc
                              size: 64,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Đang tìm việc quanh đây...',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Hệ thống đang quét các đơn hàng phù hợp với vị trí của bạn',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
