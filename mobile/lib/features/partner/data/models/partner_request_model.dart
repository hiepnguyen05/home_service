class PartnerRequestModel {
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String idFrontUrl;
  final String idBackUrl;
  final List<String> certificates;
  final List<PartnerServiceRequest> services;
  final String status;
  final DateTime? createdAt;
  final String? rejectReason;
  final String? portraitUrl;
  final String? bio;
  final double? experienceYears;
  final String requestType; // 'registration' hoặc 'update'

  PartnerRequestModel({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.idFrontUrl,
    required this.idBackUrl,
    required this.certificates,
    required this.services,
    this.status = 'pending',
    this.createdAt,
    this.rejectReason,
    this.portraitUrl,
    this.bio,
    this.experienceYears,
    this.requestType = 'registration',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'idFrontUrl': idFrontUrl,
      'idBackUrl': idBackUrl,
      'certificates': certificates,
      'services': services.map((x) => x.toMap()).toList(),
      'status': status,
      'createdAt': createdAt,
      'rejectReason': rejectReason,
      'portraitUrl': portraitUrl,
      'bio': bio,
      'experienceYears': experienceYears,
      'requestType': requestType,
    };
  }

  factory PartnerRequestModel.fromMap(Map<String, dynamic> map) {
    return PartnerRequestModel(
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      idFrontUrl: map['idFrontUrl'] ?? '',
      idBackUrl: map['idBackUrl'] ?? '',
      certificates: List<String>.from(map['certificates'] ?? []),
      services: List<PartnerServiceRequest>.from(
          (map['services'] as List? ?? [])
              .map((x) => PartnerServiceRequest.fromMap(x))),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
      rejectReason: map['rejectReason'],
      portraitUrl: map['portraitUrl'],
      bio: map['bio'],
      experienceYears: (map['experienceYears'] as num?)?.toDouble(),
      requestType: map['requestType'] ?? 'registration',
    );
  }
}

class PartnerServiceRequest {
  final String serviceId;
  final String serviceName;
  final String price;
  final String priceUnit; // NEW
  final String? iconName;
  final String? changeType; // 'added', 'updated', 'deleted', null
  final String? oldPrice;
  final bool isActive; // NEW: Trạng thái tạm ngưng/hoạt động

  PartnerServiceRequest({
    required this.serviceId,
    required this.serviceName,
    required this.price,
    this.priceUnit = 'lần', // Default to 'lần'
    this.iconName,
    this.changeType,
    this.oldPrice,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'price': price,
      'priceUnit': priceUnit, // NEW
      'iconName': iconName,
      'changeType': changeType,
      'oldPrice': oldPrice,
      'isActive': isActive,
    };
  }

  factory PartnerServiceRequest.fromMap(Map<String, dynamic> map) {
    return PartnerServiceRequest(
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      price: map['price'] ?? '',
      priceUnit: map['priceUnit'] ?? 'lần', // NEW
      iconName: map['iconName'],
      changeType: map['changeType'],
      oldPrice: map['oldPrice'],
      isActive: map['isActive'] ?? true,
    );
  }
}
