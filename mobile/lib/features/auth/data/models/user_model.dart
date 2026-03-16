/// Model người dùng
class UserModel {
  final int id;
  final String uid; // Firebase UID dạng chuỗi
  final String? code;
  final String fullName;
  final String phone;
  final String email;
  final String? avatarUrl; // URL ảnh đại diện
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fcmToken; // Token cho thông báo đẩy

  UserModel({
    required this.id,
    required this.uid,
    this.code,
    required this.fullName,
    required this.phone,
    required this.email,
    this.avatarUrl, // Không required
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.fcmToken,
  });

  /// Kiểm tra xem user có phải là thợ không
  bool get isProvider => role == 'provider';

  /// Kiểm tra xem user có phải là khách không
  bool get isCustomer => role == 'customer';

  /// Tạo UserModel từ JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      uid: json['uid'] ?? '',
      code: json['code'], // Có thể null
      fullName: json['full_name'],
      phone: json['phone'],
      email: json['email'],
      avatarUrl: json['avatar_url'], // Có thể null
      role: json['role'],
      status: json['status'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      fcmToken: json['fcm_token'],
    );
  }

  /// Chuyển UserModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'code': code,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'fcm_token': fcmToken,
    };
  }

  /// Tạo bản sao với các trường thay đổi
  UserModel copyWith({
    int? id,
    String? uid,
    String? code,
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    String? role,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      code: code ?? this.code,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
