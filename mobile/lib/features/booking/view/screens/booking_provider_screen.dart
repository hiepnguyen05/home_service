import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';

import '../../viewmodel/booking_viewmodel.dart';
import '../widgets/common/booking_stepper.dart';
import '../widgets/provider/provider_filter_bar.dart';
import '../widgets/provider/booking_provider_list.dart';
import 'booking_confirmation_screen.dart';

class BookingProviderScreen extends StatefulWidget {
  final double userLat;
  final double userLng;
  final String? serviceId;
  final DateTime bookingTime; // NEW
  final String address; // NEW

  const BookingProviderScreen({
    super.key,
    required this.userLat,
    required this.userLng,
    this.serviceId,
    required this.bookingTime, // NEW
    required this.address, // NEW
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Chat với ${provider.name}")),
                      );
                    },
                    userLat: widget.userLat,
                    userLng: widget.userLng,
                    priceUnit: viewModel.priceUnit,
                  );
                },
              ),
            ),
          ],
        ),

        // Nút tiếp theo
        bottomNavigationBar:
            _selectedProviderId != null ? _buildBottomBar() : null,
      ),
    );
  }

  Widget _buildBottomBar() {
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
            // Chuyển sang màn hình xác nhận
            final selectedProvider = _viewModel.providers
                .firstWhere((p) => p.id == _selectedProviderId);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingConfirmationScreen(
                  provider: selectedProvider,
                  serviceName: _viewModel.serviceName,
                  serviceId: widget.serviceId ?? '',
                  bookingTime: widget.bookingTime,
                  userLat: widget.userLat,
                  userLng: widget.userLng,
                  address: widget.address,
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
