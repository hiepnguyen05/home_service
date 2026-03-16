import 'package:flutter/material.dart';
import '../../../../provider/data/models/provider_model.dart';
import '../../../../../core/services/distance_service.dart';
import 'provider_list_item.dart';

class BookingProviderList extends StatefulWidget {
  final List<ProviderModel> providers;
  final String? selectedProviderId;
  final Function(String) onProviderSelected;
  final Function(ProviderModel) onChat;
  final Function(ProviderModel) onViewDetail;
  final double userLat;
  final double userLng;
  final String priceUnit;

  const BookingProviderList({
    super.key,
    required this.providers,
    required this.selectedProviderId,
    required this.onProviderSelected,
    required this.onChat,
    required this.onViewDetail,
    required this.userLat,
    required this.userLng,
    required this.priceUnit,
  });

  @override
  State<BookingProviderList> createState() => _BookingProviderListState();
}

class _BookingProviderListState extends State<BookingProviderList> {
  @override
  Widget build(BuildContext context) {
    if (widget.providers.isEmpty) {
      return const Center(child: Text("Không tìm thấy thợ phù hợp"));
    }
    return ListView.builder(
      itemCount: widget.providers.length + 1, // +1 for footer
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemBuilder: (context, index) {
        if (index == widget.providers.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              "Bạn có thể nhắn tin hỏi thợ trước khi quyết định đặt dịch vụ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        }

        final provider = widget.providers[index];
        // Calculate distance if not already in model (assuming model might not be updated or consistent)
        // Or if the list is sorted by model.distance, we can use that.
        // But screen code was doing calculation.
        final distance = DistanceService.calculateDistance(widget.userLat,
            widget.userLng, provider.latitude, provider.longitude);
        final travelTime = DistanceService.calculateTravelTime(distance);

        return ProviderListItem(
          provider: provider,
          distanceKm: distance,
          travelTimeMinutes: travelTime,
          priceUnit: widget.priceUnit,
          isSelected: widget.selectedProviderId == provider.id,
          onTap: () => widget.onProviderSelected(provider.id),
          onChat: () => widget.onChat(provider),
          onViewDetail: () => widget.onViewDetail(provider),
        );
      },
    );
  }
}
