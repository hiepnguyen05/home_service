class BannerModel {
  final String id;
  final String imageUrl;
  final int order;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.order,
    this.isActive = true,
  });

  factory BannerModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BannerModel(
      id: id,
      imageUrl: data['imageUrl'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'order': order,
      'isActive': isActive,
    };
  }
}
