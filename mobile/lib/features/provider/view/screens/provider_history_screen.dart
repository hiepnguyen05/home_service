import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/booking/view/widgets/history/booking_history_empty_state.dart';
import 'package:mobile/features/booking/view/widgets/history/history_tab_bar.dart';
import 'package:mobile/features/services/data/models/service_model.dart';
import 'package:mobile/features/services/data/repositories/service_repository.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/provider_viewmodel.dart';
import '../widgets/history/provider_history_card.dart';
import '../screens/provider_work_screen.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository.dart';
import '../screens/provider_job_summary_screen.dart';

class ProviderHistoryScreen extends StatefulWidget {
  const ProviderHistoryScreen({super.key});

  @override
  State<ProviderHistoryScreen> createState() => _ProviderHistoryScreenState();
}

class _ProviderHistoryScreenState extends State<ProviderHistoryScreen> {
  final ServiceRepository _serviceRepository = ServiceRepository();
  final AuthRepository _authRepository = AuthRepository();
  int _currentTab = 0;
  Map<String, ServiceModel> _serviceMap = {};
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _loadServiceData();
  }

  Future<void> _loadServiceData() async {
    final vm = context.read<ProviderViewModel>();
    await vm.loadData();
    
    final serviceIds = <String>{
      for (final b in vm.bookings) if (b.serviceId.isNotEmpty) b.serviceId,
    }.toList();

    final Map<String, ServiceModel> serviceMap = {};
    await Future.wait(serviceIds.map((id) async {
      try {
        final service = await _serviceRepository.getServiceById(id);
        serviceMap[id] = service;
      } catch (_) {}
    }));

    if (mounted) {
      setState(() {
        _serviceMap = serviceMap;
        _isLoadingServices = false;
      });
    }
  }

  void _onTabChanged(int index) {
    if (_currentTab == index) return;
    setState(() {
      _currentTab = index;
    });
  }

  bool _isOngoing(String status) {
    return status == BookingStatus.pending ||
        status == BookingStatus.waitingPayment ||
        status == BookingStatus.incoming ||
        status == BookingStatus.arrived ||
        status == BookingStatus.processing ||
        status == BookingStatus.paused ||
        status == BookingStatus.confirmed;
  }

  Future<void> _openDetail(BookingModel booking) async {
    if (_isOngoing(booking.status)) {
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProviderWorkScreen(booking: booking),
        ),
      );
    } else if (booking.status == BookingStatus.completed) {
      try {
        final customer = await _authRepository.getUserById(booking.customerId);
        if (!mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderJobSummaryScreen(
              booking: booking,
              serviceName: _serviceMap[booking.serviceId]?.name ?? 'Dịch vụ',
              customerName: customer?.fullName ?? 'Khách hàng',
              finalSessionSeconds: 0, // In history, everything is already in totalWorkingSeconds
              isHistoryView: true,
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải thông tin chi tiết: $e')),
          );
        }
      }
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
          'Lịch sử công việc',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ProviderViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading || _isLoadingServices) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              HistoryTabBar(
                currentIndex: _currentTab,
                onTabChanged: _onTabChanged,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await vm.refreshData();
                    await _loadServiceData();
                  },
                  child: _buildList(vm.bookings),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<BookingModel> allBookings) {
    final List<BookingModel> filteredList;
    String emptyTitle;
    String emptyDescription;

    switch (_currentTab) {
      case 0:
        filteredList = allBookings.where((b) => _isOngoing(b.status)).toList();
        emptyTitle = 'Không có việc nào';
        emptyDescription = 'Các công việc đang thực hiện sẽ hiện ở đây.';
        break;
      case 1:
        filteredList = allBookings.where((b) => b.status == BookingStatus.completed).toList();
        emptyTitle = 'Chưa hoàn thành việc nào';
        emptyDescription = 'Lịch sử các việc đã hoàn tất sẽ hiển thị tại đây.';
        break;
      case 2:
      default:
        filteredList = allBookings.where((b) => b.status == BookingStatus.cancelled).toList();
        emptyTitle = 'Không có việc bị hủy';
        emptyDescription = 'Các công việc đã hủy sẽ hiển thị tại đây.';
        break;
    }

    if (filteredList.isEmpty) {
      return BookingHistoryEmptyState(
        title: emptyTitle,
        description: emptyDescription,
        primaryLabel: 'Quay lại Dashboard',
        onPrimaryAction: () {
          // This depends on how the parent handles navigation, but usually index 0
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: filteredList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = filteredList[index];
        return ProviderHistoryCard(
          booking: booking,
          serviceName: _serviceMap[booking.serviceId]?.name ?? 'Dịch vụ',
          serviceIconName: _serviceMap[booking.serviceId]?.iconName,
          onTap: () => _openDetail(booking),
        );
      },
    );
  }
}
