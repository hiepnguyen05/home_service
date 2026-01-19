import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service xử lý vị trí địa lý
class LocationService {
  /// Kiểm tra và yêu cầu quyền truy cập vị trí
  static Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra dịch vụ vị trí có được bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Lấy vị trí hiện tại
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Kiểm tra nếu đang ở vị trí Google (emulator)
      if (_isGoogleLocation(position.latitude, position.longitude)) {
        print('Phát hiện emulator - sử dụng vị trí mặc định Hà Nội');
        // Trả về vị trí mặc định ở Hà Nội
        return Position(
          longitude: 105.8542, // Hà Nội
          latitude: 21.0285,   // Hà Nội
          timestamp: DateTime.now(),
          accuracy: position.accuracy,
          altitude: position.altitude,
          altitudeAccuracy: position.altitudeAccuracy,
          heading: position.heading,
          headingAccuracy: position.headingAccuracy,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
        );
      }

      return position;
    } catch (e) {
      print('Lỗi lấy vị trí: $e');
      return null;
    }
  }

  /// Kiểm tra có phải vị trí Google (emulator) không
  static bool _isGoogleLocation(double latitude, double longitude) {
    // Tọa độ Google: 37.4219983, -122.084
    // Cho phép sai số nhỏ
    const googleLat = 37.4219983;
    const googleLng = -122.084;
    const tolerance = 0.01;
    
    return (latitude - googleLat).abs() < tolerance && 
           (longitude - googleLng).abs() < tolerance;
  }

  /// Chuyển đổi tọa độ thành địa chỉ cụ thể
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      print('Đang chuyển đổi tọa độ thành địa chỉ...');
      print('Lat: $latitude, Lng: $longitude');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Tạo địa chỉ đầy đủ từ các thành phần
        List<String> addressParts = [];
        
        // Số nhà và tên đường
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        
        // Phường/Xã
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        
        // Quận/Huyện
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        
        // Tỉnh/Thành phố
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        
        // Quốc gia
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        
        String fullAddress = addressParts.join(', ');
        
        // Nếu không có địa chỉ cụ thể, tạo từ thông tin có sẵn
        if (fullAddress.isEmpty) {
          fullAddress = 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
        }
        
        print('Địa chỉ: $fullAddress');
        print('Chi tiết placemark:');
        print('   - Street: ${place.street}');
        print('   - SubLocality: ${place.subLocality}');
        print('   - Locality: ${place.locality}');
        print('   - AdministrativeArea: ${place.administrativeArea}');
        print('   - Country: ${place.country}');
        
        return fullAddress;
      } else {
        print('Không tìm thấy placemark');
        return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
      }
    } catch (e) {
      print('Lỗi chuyển đổi địa chỉ: $e');
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Danh sách vị trí mẫu cho Việt Nam
  static List<Map<String, dynamic>> getVietnamLocations() {
    return [
      {
        'name': 'Hà Nội',
        'latitude': 21.0285,
        'longitude': 105.8542,
        'address': 'Hà Nội, Việt Nam'
      },
      {
        'name': 'TP. Hồ Chí Minh',
        'latitude': 10.8231,
        'longitude': 106.6297,
        'address': 'TP. Hồ Chí Minh, Việt Nam'
      },
      {
        'name': 'Đà Nẵng',
        'latitude': 16.0544,
        'longitude': 108.2022,
        'address': 'Đà Nẵng, Việt Nam'
      },
      {
        'name': 'Hải Phòng',
        'latitude': 20.8449,
        'longitude': 106.6881,
        'address': 'Hải Phòng, Việt Nam'
      },
      {
        'name': 'Cần Thơ',
        'latitude': 10.0452,
        'longitude': 105.7469,
        'address': 'Cần Thơ, Việt Nam'
      },
    ];
  }
}