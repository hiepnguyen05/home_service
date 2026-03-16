import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';

import 'package:mobile/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:mobile/features/chat/view/screens/chat_screen.dart';
import '../../viewmodel/booking_viewmodel.dart';
import '../widgets/common/booking_stepper.dart';
import '../widgets/provider/provider_filter_bar.dart';
import '../widgets/provider/booking_provider_list.dart';
import 'booking_confirmation_screen.dart';
import 'package:mobile/features/provider/view/screens/provider_detail_screen.dart';

class BookingProviderScreen extends StatefulWidget {
  final double userLat;
  final double userLng;
  final String? serviceId;
  final DateTime bookingTime; // NEW
  final String address;
  final String? note; // NEW

  const BookingProviderScreen({
    super.key,
    required this.userLat,
    required this.userLng,
    this.serviceId,
    required this.bookingTime,
    required this.address,
    this.note, // NEW
  });

  @override
  State<BookingProviderScreen> createState() => _BookingProviderScreenState();
}

class _BookingProviderScreenState extends State<BookingProviderScreen> {
  String? _selectedProviderId;
  final BookingViewModel _viewModel = BookingViewModel();

  @override
  void initState() {
    super.initState();
    // Load dữ liệu
    _viewModel.loadProviders(
      userLat: widget.userLat,
      userLng: widget.userLng,
      serviceId: widget.serviceId,
      bookingTime:
          widget.bookingTime, // Pass booking time to filter availability
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text("Chọn thợ"),
          centerTitle: true,
          backgroundColor: const Color(0xFFF8FAFC).withOpacity(0.8),
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          titleTextStyle: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        body: Column(
          children: [
            // Thanh tiến trình
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: BookingStepper(currentStep: 2),
            ),

            // Thanh lọc
            Consumer<BookingViewModel>(
              builder: (context, viewModel, child) {
                return ProviderFilterBar(
                  selectedFilter: viewModel.selectedFilter,
                  onFilterChanged: (filter) {
                    viewModel.changeFilter(
                        filter, widget.userLat, widget.userLng);
                  },
                );
              },
            ),

            // Danh sách thợ
            Expanded(
              child: Consumer<BookingViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.error != null) {
                    return Center(
                      child: Text(
                        "Lỗi: ${viewModel.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (viewModel.providers.isEmpty) {
                    return const Center(
                      child: Text(
                        "Không tìm thấy thợ nào gần bạn",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    );
                  }

                  return BookingProviderList(
                    providers: viewModel.providers,
                    selectedProviderId: _selectedProviderId,
                    onProviderSelected: (id) {
                      setState(() {
                        if (_selectedProviderId == id) {
                          _selectedProviderId = null;
                        } else {
                          _selectedProviderId = id;
                        }
                      });
                    },
                    onChat: (provider) {
                      final authViewModel = context.read<AuthViewModel>();
                      final currentUserId =
                          authViewModel.currentUser?.uid ?? '';

                      // Tạo ID chat tạm thời cho tư vấn trước khi đặt lịch
                      final chatId = "pre_${currentUserId}_${provider.id}";

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            bookingId: chatId,
                            targetUserId: provider.id,
                            otherUserName: provider.name,
                            otherUserAvatar: provider.avatarUrl,
                          ),
                        ),
                      );
                    },
                    userLat: widget.userLat,
                    userLng: widget.userLng,
                    priceUnit: viewModel.priceUnit,
                    onViewDetail: (provider) async {
                      final selectedId = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProviderDetailScreen(
                            provider: provider,
                            isViewOnly: true,
                          ),
                        ),
                      );

                      if (selectedId != null && mounted) {
                        setState(() {
                          _selectedProviderId = selectedId;
                        });
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),

        // Nút tiếp theo
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_selectedProviderId == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            // 1. Lấy thông tin provider đã chọn
            final selectedProvider = _viewModel.providers
                .firstWhere((p) => p.id == _selectedProviderId);

            // 2. Chuyển sang màn hình xác nhận (Booking chưa tạo)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingConfirmationScreen(
                  provider: selectedProvider,
                  serviceName: _viewModel.serviceName,
                  serviceId: widget.serviceId ?? '',
                  bookingTime: widget.bookingTime,
                  address: widget.address,
                  userLat: widget.userLat,
                  userLng: widget.userLng,
                  note: widget.note,
                  priceUnit: _viewModel.priceUnit, // Pass loaded price unit
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            "Tiếp theo",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
