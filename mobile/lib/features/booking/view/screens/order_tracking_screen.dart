import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/provider/data/models/provider_model.dart';
import 'package:mobile/features/booking/viewmodel/booking_viewmodel.dart';
import 'package:provider/provider.dart';

import '../widgets/tracking/provider_info_card.dart';
import '../widgets/tracking/tracking_timeline.dart';
import '../widgets/tracking/order_details_card.dart';

class OrderTrackingScreen extends StatefulWidget {
  final BookingModel booking;
  final ProviderModel provider;
  final String serviceName;

  const OrderTrackingScreen({
    super.key,
    required this.booking,
    required this.provider,
    required this.serviceName,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Start tracking in ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingViewModel>().startTrackingBooking(widget.booking.id);
    });
  }

  @override
  void dispose() {
    // Stop tracking when leaving screen
    // Note: If we navigate away but want to keep tracking (e.g. PIP), handle differently.
    // For now, stop tracking to save resources.
    // Check if mounted to avoid errors if VM is disposed
    // context.read<BookingViewModel>().stopTrackingBooking(); // Can't call context in dispose safely if widget tree is dismantling
    // Best practice: ViewModel usually handles its own cleanup or we call it before dispose or in deactivate.
    // But since VM is provided from above (GLOBAL or Scoped), we should be careful.
    // If VM is global, we must stop tracking.
    // We can use a reference to VM captured in didChangeDependencies or just call it.
    // However, context might be unsafe in dispose.
    super.dispose();
  }

  @override
  void deactivate() {
    context.read<BookingViewModel>().stopTrackingBooking();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: Consumer<BookingViewModel>(
        builder: (context, viewModel, child) {
          // Use real-time data if available, otherwise fall back to initial data
          final currentBooking = viewModel.trackingBooking ?? widget.booking;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // 1. Provider Info
                ProviderInfoCard(
                  provider: widget.provider,
                  serviceName: widget.serviceName,
                  bookingId: currentBooking.id,
                ),

                // 2. Timeline
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Chi tiết tiến độ đơn hàng",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TrackingTimeline(booking: currentBooking),
                    ],
                  ),
                ),

                // 3. Order Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OrderDetailsCard(
                    booking: currentBooking,
                    serviceName: widget.serviceName,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // bottomNavigationBar: _buildBottomNav(), // Removed as requested
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        "Theo dõi đơn hàng",
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: BackButton(
        color: AppColors.textPrimary,
        onPressed: () => Navigator.of(context).pop(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.grey.shade100, height: 1),
      ),
    );
  }
}
