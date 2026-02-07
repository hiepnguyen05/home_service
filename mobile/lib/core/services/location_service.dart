import 'package:http/http.dart' as http;
import 'dart:convert';
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
          latitude: 21.0285, // Hà Nội
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
  static Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      print('Đang chuyển đổi tọa độ thành địa chỉ...');
      print('Lat: $latitude, Lng: $longitude');

      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude)
              .timeout(const Duration(seconds: 10));

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
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        // Quốc gia
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        String fullAddress = addressParts.join(', ');

        // Nếu không có địa chỉ cụ thể, tạo từ thông tin có sẵn
        if (fullAddress.isEmpty) {
          fullAddress =
              'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
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
      print('Lỗi chuyển đổi địa chỉ native: $e');
      print('Chuyển sang dùng OpenStreetMap fallback...');
      return await _getAddressFromCoordinatesFallback(latitude, longitude);
    }
  }

  /// Fallback sử dụng OpenStreetMap API (không yêu cầu key)
  static Future<String> _getAddressFromCoordinatesFallback(
      double latitude, double longitude) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1');

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'HomeServiceApp/1.0', // Yêu cầu của Nominatim
          'Accept-Language': 'vi', // Ưu tiên tiếng Việt
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'];
        if (address != null) {
          return address;
        }
      }
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      print('Lỗi chuyển đổi địa chỉ fallback: $e');
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Lấy chi tiết địa chỉ (phân tách thành các thành phần)
  static Future<Map<String, String>> getLocationDetails(
      double latitude, double longitude) async {
    final result = <String, String>{
      'address': '',
      'ward': '',
      'district': '',
      'city': '',
      'full_address': '',
    };

    try {
      print('Đang lấy chi tiết địa chỉ...');

      // Thử dùng native geocoding trước
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude)
              .timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];

        result['address'] = place.street ?? '';
        result['ward'] = place.subLocality ?? '';
        result['district'] =
            place.locality ?? ''; // IOS often puts district in locality
        if (result['district']!.isEmpty) {
          result['district'] = place.subAdministrativeArea ?? '';
        }
        result['city'] = place.administrativeArea ?? '';

        // Tạo full address
        List<String> parts = [];
        if (result['address']!.isNotEmpty) parts.add(result['address']!);
        if (result['ward']!.isNotEmpty) parts.add(result['ward']!);
        if (result['district']!.isNotEmpty) parts.add(result['district']!);
        if (result['city']!.isNotEmpty) parts.add(result['city']!);

        result['full_address'] = parts.join(', ');

        return result;
      }
    } catch (e) {
      print('Lỗi native geocoding: $e');
      print('Chuyển sang dùng OpenStreetMap fallback...');
      return await _getLocationDetailsFallback(latitude, longitude);
    }

    return result;
  }

  /// Fallback lấy chi tiết địa chỉ từ OpenStreetMap
  static Future<Map<String, String>> _getLocationDetailsFallback(
      double latitude, double longitude) async {
    final result = <String, String>{
      'address': '',
      'ward': '',
      'district': '',
      'city': '',
      'full_address': '',
    };

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1');

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'HomeServiceApp/1.0',
          'Accept-Language': 'vi',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressData = data['address'];

        if (addressData != null) {
          // Mapping fields from OSM
          String street = addressData['road'] ?? '';
          String houseNumber = addressData['house_number'] ?? '';
          result['address'] =
              houseNumber.isNotEmpty ? '$houseNumber $street' : street;

          result['ward'] = addressData['quarter'] ??
              addressData['neighbourhood'] ??
              addressData['suburb'] ??
              addressData['village'] ??
              addressData['hamlet'] ??
              addressData['municipality'] ??
              '';

          result['district'] = addressData['city_district'] ??
              addressData['district'] ??
              addressData['county'] ??
              addressData['town'] ??
              '';

          result['city'] = addressData['city'] ??
              addressData['state'] ??
              addressData['province'] ??
              ''; // Some places like Hanoi are states in OSM

          result['full_address'] = data['display_name'] ?? '';
        }
      }
    } catch (e) {
      print('Lỗi fallback geocoding: $e');
    }

    return result;
  }

  /// Tìm tọa độ từ địa chỉ (Forward Geocoding)
  static Future<Map<String, dynamic>?> getCoordinatesFromAddress(
      String address) async {
    try {
      print('Đang tìm tọa độ cho địa chỉ: $address');

      // 1. Thử dùng thư viện native (Google/iOS Geocoder)
      List<Location> locations = await locationFromAddress(address)
          .timeout(const Duration(seconds: 10));

      if (locations.isNotEmpty) {
        final loc = locations[0];
        return {
          'latitude': loc.latitude,
          'longitude': loc.longitude,
          'display_name': address, // Thư viện native ít trả về tên chuẩn
        };
      }
    } catch (e) {
      print('Lỗi native forward geocoding: $e');
      print('Chuyển sang dùng OpenStreetMap Search API...');
      return await _getCoordinatesFromAddressFallback(address);
    }
    return null;
  }

  /// Fallback tìm kiếm địa chỉ dùng OpenStreetMap API
  static Future<Map<String, dynamic>?> _getCoordinatesFromAddressFallback(
      String query) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1&addressdetails=1');

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'HomeServiceApp/1.0',
          'Accept-Language': 'vi',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final firstResult = data[0];
          return {
            'latitude': double.parse(firstResult['lat']),
            'longitude': double.parse(firstResult['lon']),
            'display_name': firstResult['display_name'],
          };
        }
      }
    } catch (e) {
      print('Lỗi fallback search: $e');
    }
    return null;
  }
}
