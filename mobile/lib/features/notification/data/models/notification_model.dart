import 'package:cloud_firestore/cloud_firestore.dart';

/// Các loại thông báo trong hệ thống
class NotificationType {
  static const String cancelRequest = 'cancel_request';   // Thợ yêu cầu hủy đơn
  static const String cancelApproved = 'cancel_approved';  // Khách đồng ý hủy
  static const String cancelRejected = 'cancel_rejected';  // Khách từ chối hủy
  static const String extraCostRequest = 'extra_cost_request'; // Thợ yêu cầu chi phí phát sinh
  static const String extraCostApproved = 'extra_cost_approved'; // Khách đồng ý chi phí
  static const String extraCostRejected = 'extra_cost_rejected'; // Khách từ chối chi phí
  static const String bookingAccepted = 'booking_accepted'; // Thợ chấp nhận đơn
  static const String bookingCompleted = 'booking_completed'; // Đơn hoàn thành
  static const String chat = 'chat';                       // Tin nhắn mới
  static const String system = 'system';                   // Thông báo hệ thống
}

class NotificationModel {
  final String id;
  final String receiverId;    // UID người nhận
  final String senderId;      // UID người gửi
  final String title;
  final String body;
  final String type;          // Một trong các NotificationType
  final Map<String, dynamic> data;  // Dữ liệu bổ sung (bookingId, v.v.)
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.receiverId,
    required this.senderId,
    required this.title,
    required this.body,
    required this.type,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: doc.id,
      receiverId: raw['receiverId'] as String? ?? '',
      senderId: raw['senderId'] as String? ?? '',
      title: raw['title'] as String? ?? '',
      body: raw['body'] as String? ?? '',
      type: raw['type'] as String? ?? NotificationType.system,
      data: (raw['data'] as Map<String, dynamic>?) ?? {},
      isRead: raw['isRead'] as bool? ?? false,
      createdAt: (raw['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'receiverId': receiverId,
      'senderId': senderId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      receiverId: receiverId,
      senderId: senderId,
      title: title,
      body: body,
      type: type,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
