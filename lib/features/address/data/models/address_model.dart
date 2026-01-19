import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho địa chỉ người dùng
class AddressModel {
  final String id;
  final String userId;
  final String title; // Nhà riêng, Văn phòng, etc.
  final String fullName;
  final String phoneNumber;
  final String address;
  final String ward; // Phường/Xã
  final String district; // Quận/Huyện
  final String city; // Tỉnh/Thành phố
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.ward,
    required this.district,
    required this.city,
    this.latitude,
    this.longitude,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tạo AddressModel từ Firestore document
  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AddressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      ward: data['ward'] ?? '',
      district: data['district'] ?? '',
      city: data['city'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Tạo AddressModel từ Map
  factory AddressModel.fromMap(Map<String, dynamic> map, String id) {
    return AddressModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      ward: map['ward'] ?? '',
      district: map['district'] ?? '',
      city: map['city'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      isDefault: map['isDefault'] ?? false,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Chuyển đổi thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'ward': ward,
      'district': district,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Tạo bản sao với các thay đổi
  AddressModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? ward,
    String? district,
    String? city,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Địa chỉ đầy đủ
  String get fullAddress {
    return '$address, $ward, $district, $city';
  }

  /// Địa chỉ ngắn gọn
  String get shortAddress {
    return '$address, $district, $city';
  }

  @override
  String toString() {
    return 'AddressModel(id: $id, title: $title, fullAddress: $fullAddress, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AddressModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.address == address &&
        other.ward == ward &&
        other.district == district &&
        other.city == city &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        fullName.hashCode ^
        phoneNumber.hashCode ^
        address.hashCode ^
        ward.hashCode ^
        district.hashCode ^
        city.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        isDefault.hashCode;
  }
}

/// Các loại địa chỉ thường dùng
class AddressType {
  static const String home = 'Nhà riêng';
  static const String office = 'Văn phòng';
  static const String other = 'Khác';
  
  static const List<String> types = [home, office, other];
}