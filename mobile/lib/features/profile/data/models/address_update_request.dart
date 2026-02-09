/// Model yêu cầu cập nhật địa chỉ
class AddressUpdateRequest {
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool? isDefault;

  AddressUpdateRequest({
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.isDefault,
  });

  /// Chuyển thành JSON để gửi API
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (address != null) data['address'] = address;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (isDefault != null) data['isDefault'] = isDefault;
    return data;
  }
}