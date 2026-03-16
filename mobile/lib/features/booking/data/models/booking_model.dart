import 'package:cloud_firestore/cloud_firestore.dart';

class BookingStatus {
  static const String pending = 'pending';
  static const String waitingPayment =
      'waiting_payment'; // Provider accepted, waiting for payment (Online)
  static const String accepted = 'accepted'; // Deprecated in Logic B
  static const String confirmed = 'confirmed'; // Paid/Finalized (COD or Online)
  static const String incoming = 'incoming'; // Provider is coming
  static const String arrived = 'arrived'; // Provider arrived at location
  static const String processing = 'processing'; // Job in progress
  static const String paused = 'paused'; // Job paused
  static const String completed = 'completed'; // Job finished
  static const String cancelled = 'cancelled';
  static const String cancelPending = 'cancel_pending'; // Cancellation requested, waiting for other party
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

  final String? note;

  final int quantity; // NEW
  final String priceUnit; // NEW
  final String? cancelRequestedBy; // User ID who requested cancellation
  final String? cancelNote; // Reason for cancellation request

  final String? extraCostDescription; 
  final double? extraCostAmount;
  final String? extraCostStatus; // 'pending', 'approved', 'rejected'

  final String? checkInImage; // NEW: Proof of arrival
  final double? latitude; // NEW: Real map data
  final double? longitude; // NEW: Real map data

  // Workflow tracking fields
  final DateTime? startedAt; // First job start
  final DateTime? lastStartedAt; // Last time job was started/resumed
  final DateTime? pausedAt; // Last pause time
  final DateTime? completedAt; // Job completed
  final String? completionImage; // NEW: Proof of completion
  final int totalWorkingSeconds; // Total seconds spent working (excluding pauses)

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.providerId,
    required this.scheduleAt,
    required this.address,
    required this.status,
    this.totalPrice = 0.0,
    required this.paymentMethod,
    required this.createdAt,
    this.note,
    this.quantity = 1,
    this.priceUnit = 'lần',
    this.latitude,
    this.longitude,
    this.checkInImage,
    this.startedAt,
    this.lastStartedAt,
    this.pausedAt,
    this.completedAt,
    this.completionImage,
    this.totalWorkingSeconds = 0,
    this.cancelRequestedBy,
    this.cancelNote,
    this.extraCostDescription,
    this.extraCostAmount,
    this.extraCostStatus,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};

      DateTime parseDateTime(dynamic value) {
        if (value is Timestamp) return value.toDate();
        if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
        return DateTime.now();
      }

      DateTime? parseOptionalDateTime(dynamic value) {
        if (value is Timestamp) return value.toDate();
        if (value is String) return DateTime.tryParse(value);
        return null;
      }

      double parseDouble(dynamic value) {
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }

      int parseInt(dynamic value) {
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      return BookingModel(
        id: doc.id,
        customerId: data['customerId']?.toString() ?? '',
        serviceId: data['serviceId']?.toString() ?? '',
        providerId: data['providerId']?.toString() ?? '',
        scheduleAt: parseDateTime(data['scheduleAt']),
        address: data['address']?.toString() ?? '',
        status: data['status']?.toString() ?? 'pending',
        totalPrice: parseDouble(data['totalPrice']),
        paymentMethod: data['paymentMethod']?.toString() ?? 'COD',
        createdAt: parseDateTime(data['createdAt']),
        note: data['note']?.toString(),
        quantity: parseInt(data['quantity'] ?? 1),
        priceUnit: data['priceUnit']?.toString() ?? 'lần',
        latitude: data['latitude'] != null ? parseDouble(data['latitude']) : null,
        longitude: data['longitude'] != null ? parseDouble(data['longitude']) : null,
        checkInImage: data['checkInImage']?.toString(),
        startedAt: parseOptionalDateTime(data['startedAt']),
        lastStartedAt: parseOptionalDateTime(data['lastStartedAt']),
        pausedAt: parseOptionalDateTime(data['pausedAt']),
        completedAt: parseOptionalDateTime(data['completedAt']),
        completionImage: data['completionImage']?.toString(),
        totalWorkingSeconds: parseInt(data['totalWorkingSeconds'] ?? 0),
        cancelRequestedBy: data['cancelRequestedBy']?.toString(),
        cancelNote: data['cancelNote']?.toString(),
        extraCostDescription: data['extraCostDescription']?.toString(),
        extraCostAmount: data['extraCostAmount'] != null ? parseDouble(data['extraCostAmount']) : null,
        extraCostStatus: data['extraCostStatus']?.toString(),
      );
    } catch (e, stack) {
      print("💥 [Model] Lỗi nghiêm trọng khi parse đơn hàng ${doc.id}: $e");
      print(stack.toString());
      return BookingModel(
        id: doc.id,
        customerId: '',
        serviceId: '',
        providerId: '',
        scheduleAt: DateTime.now(),
        address: '',
        status: 'error',
        paymentMethod: 'COD',
        createdAt: DateTime.now(),
      );
    }
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
      'note': note,
      'quantity': quantity,
      'priceUnit': priceUnit,
      'latitude': latitude,
      'longitude': longitude,
      'checkInImage': checkInImage,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'lastStartedAt':
          lastStartedAt != null ? Timestamp.fromDate(lastStartedAt!) : null,
      'pausedAt': pausedAt != null ? Timestamp.fromDate(pausedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'completionImage': completionImage,
      'totalWorkingSeconds': totalWorkingSeconds,
      'cancelRequestedBy': cancelRequestedBy,
      'cancelNote': cancelNote,
      'extraCostDescription': extraCostDescription,
      'extraCostAmount': extraCostAmount,
      'extraCostStatus': extraCostStatus,
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
    String? note,
    int? quantity,
    String? priceUnit,
    double? latitude,
    double? longitude,
    String? checkInImage,
    DateTime? startedAt,
    DateTime? lastStartedAt,
    DateTime? pausedAt,
    DateTime? completedAt,
    String? completionImage,
    int? totalWorkingSeconds,
    String? cancelRequestedBy,
    String? cancelNote,
    String? extraCostDescription,
    double? extraCostAmount,
    String? extraCostStatus,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      scheduleAt: scheduleAt ?? this.scheduleAt,
      address: address ?? this.address,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      quantity: quantity ?? this.quantity,
      priceUnit: priceUnit ?? this.priceUnit,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      checkInImage: checkInImage ?? this.checkInImage,
      startedAt: startedAt ?? this.startedAt,
      lastStartedAt: lastStartedAt ?? this.lastStartedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      completedAt: completedAt ?? this.completedAt,
      completionImage: completionImage ?? this.completionImage,
      totalWorkingSeconds: totalWorkingSeconds ?? this.totalWorkingSeconds,
      cancelRequestedBy: cancelRequestedBy ?? this.cancelRequestedBy,
      cancelNote: cancelNote ?? this.cancelNote,
      extraCostDescription: extraCostDescription ?? this.extraCostDescription,
      extraCostAmount: extraCostAmount ?? this.extraCostAmount,
      extraCostStatus: extraCostStatus ?? this.extraCostStatus,
    );
  }
}
