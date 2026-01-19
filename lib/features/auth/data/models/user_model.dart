/// Model người dùng
class UserModel {
  final int id;
  final String? code; // Có thể null
  final String fullName;
  final String phone;
  final String email;
  final String? avatarUrl; // URL ảnh đại diện
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.code, // Không required
    required this.fullName,
    required this.phone,
    required this.email,
    this.avatarUrl, // Không required
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tạo UserModel từ JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      code: json['code'], // Có thể null
      fullName: json['full_name'],
      phone: json['phone'],
      email: json['email'],
      avatarUrl: json['avatar_url'], // Có thể null
      role: json['role'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Chuyển UserModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}