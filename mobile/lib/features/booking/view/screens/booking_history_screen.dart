import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile/features/booking/view/widgets/history/booking_history_card.dart';
import 'package:mobile/features/booking/view/widgets/history/booking_history_empty_state.dart';
import 'package:mobile/features/booking/view/widgets/history/history_tab_bar.dart';
import 'package:mobile/features/booking/view/screens/order_tracking_screen.dart';
import 'package:mobile/features/booking/view/screens/booking_detail_screen.dart';
import 'package:mobile/features/provider/data/repositories/provider_repository.dart';
import 'package:mobile/features/services/data/models/service_model.dart';
import 'package:mobile/features/services/data/repositories/service_repository.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final BookingRepository _bookingRepository = BookingRepository();
  final ProviderRepository _providerRepository = ProviderRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();
  int _currentTab = 0;
  bool _isLoading = true;
  String? _error;

  List<BookingModel> _ongoing = [];
  List<BookingModel> _completed = [];
  List<BookingModel> _cancelled = [];
  Map<String, ServiceModel> _serviceMap = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Bạn chưa đăng nhập');
      }

      final allBookings =
          await _bookingRepository.getBookingUserId(user.uid);

      final ongoing = <BookingModel>[];
      final completed = <BookingModel>[];
      final cancelled = <BookingModel>[];

      for (final booking in allBookings) {
        if (_isOngoing(booking.status)) {
          ongoing.add(booking);
        } else if (booking.status == BookingStatus.completed) {
          completed.add(booking);
        } else if (booking.status == BookingStatus.cancelled) {
          cancelled.add(booking);
        }
      }

      // Load thông tin dịch vụ cho các serviceId đang dùng
      final serviceIds = <String>{
        for (final b in allBookings) if (b.serviceId.isNotEmpty) b.serviceId,
      }.toList();

      final Map<String, ServiceModel> serviceMap = {};
      await Future.wait(serviceIds.map((id) async {
        try {
          final service = await _serviceRepository.getServiceById(id);
          serviceMap[id] = service;
        } catch (_) {
          // Bỏ qua nếu service không tồn tại
        }
      }));

      setState(() {
        _ongoing = ongoing;
        _completed = completed;
        _cancelled = cancelled;
        _serviceMap = serviceMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  bool _isOngoing(String status) {
    return status == BookingStatus.pending ||
        status == BookingStatus.waitingPayment ||
        status == BookingStatus.incoming ||
        status == BookingStatus.arrived ||
        status == BookingStatus.processing ||
        status == BookingStatus.paused ||
        status == BookingStatus.cancelPending ||
        status == BookingStatus.confirmed;
  }

  void _onTabChanged(int index) {
    if (_currentTab == index) return;
    setState(() {
      _currentTab = index;
    });
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
  }

  Future<void> _openDetail(BookingModel booking) async {
    try {
      final provider = await _providerRepository.getProviderById(booking.providerId);
      if (!mounted) return;

      if (provider == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy thông tin thợ')),
        );
        return;
      }

      final serviceName = _serviceMap[booking.serviceId]?.name ?? 'Dịch vụ đã đặt';

      if (_isOngoing(booking.status)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => OrderTrackingScreen(
              booking: booking,
              provider: provider,
              serviceName: serviceName,
            ),
          ),
        );
      } else {
        // Completed or Cancelled -> Show Details/Summary
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => BookingDetailScreen(
              booking: booking,
              provider: provider,
              serviceName: serviceName,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi mở chi tiết đơn hàng: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Lịch sử',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          HistoryTabBar(
            currentIndex: _currentTab,
            onTabChanged: _onTabChanged,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadHistory,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.red,
              ),
              const SizedBox(height: 12),
              Text(
                'Có lỗi xảy ra',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<BookingModel> currentList;
    String emptyTitle;
    String emptyDescription;

    switch (_currentTab) {
      case 0:
        currentList = _ongoing;
        emptyTitle = 'Không có đơn hàng nào';
        emptyDescription =
            'Tất cả các dịch vụ bạn đặt đang diễn ra sẽ xuất hiện ở đây.';
        break;
      case 1:
        currentList = _completed;
        emptyTitle = 'Chưa có đơn hoàn thành';
        emptyDescription =
            'Các đơn dịch vụ đã hoàn tất sẽ được hiển thị tại đây.';
        break;
      case 2:
      default:
        currentList = _cancelled;
        emptyTitle = 'Không có đơn đã hủy';
        emptyDescription =
            'Các đơn dịch vụ đã hủy sẽ được hiển thị tại đây.';
        break;
    }

    if (currentList.isEmpty) {
      return BookingHistoryEmptyState(
        title: emptyTitle,
        description: emptyDescription,
        onPrimaryAction: _goHome,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: currentList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = currentList[index];
        return BookingHistoryCard(
          booking: booking,
          serviceName:
              _serviceMap[booking.serviceId]?.name ?? 'Dịch vụ đã đặt',
          serviceIconName: _serviceMap[booking.serviceId]?.iconName,
          onTap: () => _openDetail(booking),
        );
      },
    );
  }
}

