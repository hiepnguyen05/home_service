class ProviderServiceModel {
  final String id;
  final String providerId;
  final String serviceId;
  final double providerPrice;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final bool isActive;
  final String? description;

  const ProviderServiceModel({
    required this.id,
    required this.providerId,
    required this.serviceId,
    required this.providerPrice,
    this.status = 'PENDING',
    this.isActive = true,
    this.description,
  });

  factory ProviderServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return ProviderServiceModel(
      id: id,
      providerId: map['providerId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      providerPrice: (map['providerPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'PENDING',
      isActive: map['isActive'] ?? true,
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'serviceId': serviceId,
      'providerPrice': providerPrice,
      'status': status,
      'isActive': isActive,
      'description': description,
    };
  }
}
