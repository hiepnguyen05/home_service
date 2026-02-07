import 'package:geolocator/geolocator.dart';

class DistanceService {
  /// Tính khoảng cách giữa 2 tọa độ (theo km)
  static double calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000;
  }

  /// Thuật toán tìm kiếm các item gần nhất trong bán kính cho trước (Generic)
  ///
  /// [originLat], [originLng]: Tọa độ gốc
  /// [items]: Danh sách các item cần lọc (Ví dụ: List<ProviderModel>)
  /// [getLat]: Hàm lấy Latitude từ item
  /// [getLng]: Hàm lấy Longitude từ item
  /// [radiusKm]: Bán kính tìm kiếm (Mặc định 10km)
  ///
  /// Trả về: List các item đã lọc và sắp xếp theo khoảng cách tăng dần
  static List<T> findNearestItems<T>({
    required double originLat,
    required double originLng,
    required List<T> items,
    required double Function(T) getLat,
    required double Function(T) getLng,
    double radiusKm = 10.0,
  }) {
    // 1. Tạo danh sách tạm lưu kèm khoảng cách
    List<Map<String, dynamic>> temp = [];

    for (var item in items) {
      double lat = getLat(item);
      double lng = getLng(item);

      double distance = calculateDistance(originLat, originLng, lat, lng);

      if (distance <= radiusKm) {
        temp.add({
          'item': item,
          'distance': distance,
        });
      }
    }

    // 2. Sắp xếp theo khoảng cách tăng dần
    temp.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    // 3. Trả về danh sách item gốc
    return temp.map((e) => e['item'] as T).toList();
  }

  /// Hàm trả về danh sách kèm khoảng cách (nếu cần hiển thị "Cách 2.5km")
  static List<Map<String, dynamic>> findNearestItemsWithDistance<T>({
    required double originLat,
    required double originLng,
    required List<T> items,
    required double Function(T) getLat,
    required double Function(T) getLng,
    double radiusKm = 10.0,
  }) {
    List<Map<String, dynamic>> results = [];

    for (var item in items) {
      double lat = getLat(item);
      double lng = getLng(item);

      double distance = calculateDistance(originLat, originLng, lat, lng);

      if (distance <= radiusKm) {
        results.add({
          'data': item,
          'distance': distance, // km
        });
      }
    }

    results.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    return results;
  }

  /// Tính thời gian di chuyển ước tính (phút)
  /// Giả sử tốc độ trung bình xe máy trong phố là 30km/h
  static int calculateTravelTime(double distanceKm, {double speedKmH = 30.0}) {
    // Thời gian (giờ) = Quãng đường (km) / Vận tốc (km/h)
    double timeHours = distanceKm / speedKmH;
    // Đổi ra phút
    int timeMinutes = (timeHours * 60).round();
    // Tối thiểu 5 phút
    return timeMinutes < 5 ? 5 : timeMinutes;
  }
}
