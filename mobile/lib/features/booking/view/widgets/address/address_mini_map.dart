import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddressMiniMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const AddressMiniMap({
    super.key,
    this.latitude = 21.0285, // Mặc định: Hà Nội
    this.longitude = 105.8542,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(latitude, longitude), // Tâm bản đồ
              initialZoom: 15.0, // Độ zoom vừa phải nhìn thấy đường phố
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag
                    .none, // Tắt kéo thả (để map đứng yên làm cảnh)
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.home_service.app',
              ),
              MarkerLayer(markers: [
                Marker(
                    point: LatLng(latitude, longitude),
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 40))
              ])
            ],
          ),
        ));
  }
}
