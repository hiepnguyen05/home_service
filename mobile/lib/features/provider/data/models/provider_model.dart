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
  final List<String> serviceIds; // Danh sách ID dịch vụ mà thợ cung cấp

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
    };
  }
}

// Mock Data cho demo
final List<ProviderModel> mockProviders = [
  ProviderModel(
    id: '1',
    name: 'Nguyễn Văn A',
    avatarUrl: 'https://i.pravatar.cc/150?u=1',
    rating: 4.8,
    reviewCount: 120,
    price: 250000,
    latitude: 21.028511,
    longitude: 105.854444, // Hà Nội
    serviceIds: ['sv_ac_repair', 'sv_cleaning'],
  ),
  ProviderModel(
    id: '2',
    name: 'Trần Thị B',
    avatarUrl: 'https://i.pravatar.cc/150?u=2',
    rating: 4.9,
    reviewCount: 85,
    price: 280000,
    latitude: 21.030000,
    longitude: 105.850000, // Gần đó
    serviceIds: ['sv_cleaning', 'sv_laundry'],
  ),
  ProviderModel(
    id: '3',
    name: 'Lê Văn C',
    avatarUrl: 'https://i.pravatar.cc/150?u=3',
    rating: 4.7,
    reviewCount: 200,
    price: 260000,
    latitude: 21.040000,
    longitude: 105.860000, // Xa hơn chút
    serviceIds: ['sv_plumbing', 'sv_ac_repair'],
  ),
  ProviderModel(
    id: '4',
    name: 'Phạm Văn D',
    avatarUrl: 'https://i.pravatar.cc/150?u=4',
    rating: 5.0,
    reviewCount: 10,
    price: 300000,
    latitude: 21.010000,
    longitude: 105.840000,
    serviceIds: ['sv_painting', 'sv_cleaning'],
  ),
  ProviderModel(
    id: '5',
    name: 'Hoàng Thị E',
    avatarUrl: 'https://i.pravatar.cc/150?u=5',
    rating: 4.5,
    reviewCount: 40,
    price: 150000,
    latitude: 21.015000,
    longitude: 105.845000,
    serviceIds: ['sv_cleaning'],
  ),
];
