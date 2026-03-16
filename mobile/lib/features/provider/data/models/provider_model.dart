import '../../../partner/data/models/partner_request_model.dart';

class ProviderModel {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  final double price; // Giá cơ bản
  final double latitude;
  final double longitude;
  final bool isOnline;
  final String phoneNumber; // NEW
  final String address; // NEW
  final List<String> serviceIds; // Danh sách ID dịch vụ mà thợ cung cấp
  final List<PartnerServiceRequest>? services; // NEW: Chi tiết dịch vụ kèm giá
  final String? bio; // NEW: Thông tin giới thiệu
  final List<String>? gallery; // NEW: Thư viện ảnh thực tế
  final int? experienceYears; // NEW: Số năm kinh nghiệm

  const ProviderModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.latitude,
    required this.longitude,
    this.isOnline = true,
    required this.serviceIds,
    this.services,
    this.phoneNumber = "0987654321", // Default for now
    this.address = "Hà Nội", // Default
    this.bio,
    this.gallery,
    this.experienceYears,
  });

  // Factory để tạo từ Firestore Document
  factory ProviderModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProviderModel(
      id: docId,
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      isOnline: map['isOnline'] ?? false,
      serviceIds: List<String>.from(map['serviceIds'] ?? []),
      services: map['services'] != null
          ? (map['services'] as List)
              .map((s) =>
                  PartnerServiceRequest.fromMap(s as Map<String, dynamic>))
              .toList()
          : null,
      phoneNumber: map['phoneNumber'] ?? "0987654321",
      address: map['address'] ?? "Hà Nội",
      bio: map['bio'],
      gallery:
          map['gallery'] != null ? List<String>.from(map['gallery']) : null,
      experienceYears: map['experienceYears'] != null
          ? (map['experienceYears'] as num).toInt()
          : null,
    );
  }

  // Chuyển sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'price': price,
      'latitude': latitude,
      'longitude': longitude,
      'isOnline': isOnline,
      'serviceIds': serviceIds,
      'services': services?.map((s) => s.toMap()).toList(),
      'phoneNumber': phoneNumber,
      'address': address,
      'bio': bio,
      'gallery': gallery,
      'experienceYears': experienceYears,
    };
  }
}
