/// Model yêu cầu cập nhật profile
class ProfileUpdateRequest {
  final String? fullName;
  final String? avatarUrl;

  ProfileUpdateRequest({
    this.fullName,
    this.avatarUrl,
  });

  /// Chuyển thành JSON để gửi API
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['fullName'] = fullName;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    return data;
  }
}