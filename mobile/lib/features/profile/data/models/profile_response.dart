import '../../../auth/data/models/user_model.dart';
import 'address_model.dart';

/// Response từ API profile
class ProfileResponse {
  final UserModel user;
  final List<AddressModel> addresses;

  ProfileResponse({
    required this.user,
    required this.addresses,
  });
}