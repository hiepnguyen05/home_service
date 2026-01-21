class ServiceModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String imageUrl;
  final String iconName;
  final double rating;
  final int reviewCount;
  final double minPrice;
  final double maxPrice;
  final double suggestedPrice;
  final String priceUnit;
  final bool isActive;

  const ServiceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    this.imageUrl = '',
    required this.iconName,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.minPrice = 0.0,
    this.maxPrice = 0.0,
    this.suggestedPrice = 0.0,
    this.priceUnit = 'lần',
    this.isActive = true,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceModel(
      id: id,
      categoryId: map['categoryId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      iconName: map['iconName'] ?? 'build',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0).toInt(),
      minPrice: (map['minPrice'] ?? 0.0).toDouble(),
      maxPrice: (map['maxPrice'] ?? 0.0).toDouble(),
      suggestedPrice: (map['suggestedPrice'] ?? 0.0).toDouble(),
      priceUnit: map['priceUnit'] ?? 'lần',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'iconName': iconName,
      'rating': rating,
      'reviewCount': reviewCount,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'suggestedPrice': suggestedPrice,
      'priceUnit': priceUnit,
      'isActive': isActive,
    };
  }
}
