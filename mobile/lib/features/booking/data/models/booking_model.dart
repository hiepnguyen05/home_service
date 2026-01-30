import 'package:cloud_firestore/cloud_firestore.dart';

class BookingStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String completed = 'complted';
  static const String cancelled = 'cancelled';
}

class BookingPaymentMethod {
  static const String COD = 'COD';
  static const String eWallet = 'E-wallet';
}

class BookingModel {
  final String id;
  final String customerId;
  final String serviceId;
  final String providerId;
  final DateTime scheduleAt;
  final String address;
  final String status;
  final double totalPrice;
  final String paymentMethod;
  final DateTime createdAt;

  const BookingModel(
      {required this.id,
      required this.customerId,
      required this.serviceId,
      required this.providerId,
      required this.scheduleAt,
      required this.address,
      required this.status,
      this.totalPrice = 0.0,
      required this.paymentMethod,
      required this.createdAt});

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      providerId: data['providerId'] ?? '',
      scheduleAt: (data['scheduleAt'] as Timestamp).toDate(),
      address: data['address'] ?? '',
      status: data['status'] ?? 'pending',
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'COD',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'serviceId': serviceId,
      'providerId': providerId,
      'scheduleAt': Timestamp.fromDate(scheduleAt),
      'address': address,
      'status': status,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? serviceId,
    String? providerId,
    DateTime? scheduleAt,
    String? address,
    String? status,
    double? totalPrice,
    String? paymentMethod,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      scheduleAt: scheduleAt ?? this.scheduleAt,
      address: address ?? this.address,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
