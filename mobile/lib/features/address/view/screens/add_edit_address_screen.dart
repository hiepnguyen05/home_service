import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/services/location_service.dart';
import '../../../auth/viewmodel/auth_viewmodel.dart';
import '../../../auth/data/services/firebase_auth_service.dart';
import '../../data/models/address_model.dart';
import '../../viewmodel/address_viewmodel.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address; // null = thêm mới, có giá trị = chỉnh sửa

  const AddEditAddressScreen({
    super.key,
    this.address,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late AddressViewModel _addressViewModel;

  // Controllers
  final _titleController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();

  // State
  bool _isDefault = false;
  String _selectedAddressType = AddressType.home;
  double? _latitude;
  double? _longitude;
  bool _usedCurrentLocation =
      false; // Flag để biết người dùng có dùng GPS không

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    _addressViewModel = AddressViewModel();
    _initializeForm();
  }

  void _initializeForm() {
    if (_isEditing) {
      final address = widget.address!;
      _titleController.text = address.title;
      _fullNameController.text = address.fullName;
      _phoneController.text = address.phoneNumber;
      _addressController.text = address.address;
      _wardController.text = address.ward;
      _districtController.text = address.district;
      _cityController.text = address.city;
      _isDefault = address.isDefault;
      _latitude = address.latitude;
      _longitude = address.longitude;

      // Set address type
      if (AddressType.types.contains(address.title)) {
        _selectedAddressType = address.title;
      } else {
        _selectedAddressType = AddressType.other;
      }
    } else {
      // Khởi tạo với thông tin user hiện tại
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final user = authViewModel.currentUser;
      if (user != null) {
        _fullNameController.text = user.fullName;
        _phoneController.text = user.phone;
      }
      // Khởi tạo tiêu đề với loại địa chỉ mặc định
      _titleController.text = _selectedAddressType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _addressViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _addressViewModel,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<AddressViewModel>(
          builder: (context, viewModel, child) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Loại địa chỉ
                          _buildSectionTitle('Loại địa chỉ'),
                          _buildAddressTypeSelector(),

                          const SizedBox(height: 24),

                          // Thông tin người nhận
                          _buildSectionTitle('Thông tin người nhận'),
                          const SizedBox(height: 12),

                          AppTextField(
                            controller: _fullNameController,
                            hint: 'Họ và tên',
                            prefixIcon: const Icon(Icons.person_outline),
                            validator: viewModel.validateFullName,
                          ),

                          const SizedBox(height: 16),

                          AppTextField(
                            controller: _phoneController,
                            hint: 'Số điện thoại',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            keyboardType: TextInputType.phone,
                            validator: viewModel.validatePhoneNumber,
                          ),

                          const SizedBox(height: 24),

                          // Địa chỉ
                          _buildSectionTitle('Địa chỉ'),
                          const SizedBox(height: 12),

                          AppTextField(
                            controller: _addressController,
                            hint: 'Địa chỉ cụ thể (số nhà, tên đường)',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            validator: viewModel.validateAddress,
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _wardController,
                                  hint: 'Phường/Xã',
                                  prefixIcon:
                                      const Icon(Icons.location_city_outlined),
                                  validator: (value) => _usedCurrentLocation
                                      ? null
                                      : viewModel.validateLocationRequired(
                                          value, 'phường/xã'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _districtController,
                                  hint: 'Quận/Huyện',
                                  prefixIcon:
                                      const Icon(Icons.location_city_outlined),
                                  validator: (value) => _usedCurrentLocation
                                      ? null
                                      : viewModel.validateLocationRequired(
                                          value, 'quận/huyện'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          AppTextField(
                            controller: _cityController,
                            hint: 'Tỉnh/Thành phố',
                            prefixIcon:
                                const Icon(Icons.location_city_outlined),
                            validator: (value) => _usedCurrentLocation
                                ? null
                                : viewModel.validateLocationRequired(
                                    value, 'tỉnh/thành phố'),
                          ),

                          const SizedBox(height: 16),

                          // Nút lấy vị trí hiện tại
                          _buildGetLocationButton(),

                          const SizedBox(height: 24),

                          // Đặt làm mặc định
                          _buildDefaultAddressSwitch(),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Nút lưu
                  _buildSaveButton(viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Row(
        children: AddressType.types.map((type) {
          final isSelected = _selectedAddressType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAddressType = type;
                  _titleController.text = type;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGetLocationButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextButton.icon(
        onPressed: _getCurrentLocation,
        icon: const Icon(Icons.my_location, color: AppColors.primary),
        label: const Text(
          'Lấy vị trí hiện tại',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAddressSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star_outline,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đặt làm địa chỉ mặc định',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Địa chỉ này sẽ được sử dụng làm mặc định',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDefault,
            onChanged: (value) {
              setState(() {
                _isDefault = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AddressViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: viewModel.isLoading ? null : _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: viewModel.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _isEditing ? 'Cập nhật địa chỉ' : 'Lưu địa chỉ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  void _getCurrentLocation() async {
    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      final position = await LocationService.getCurrentPosition();

      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;

        // Lấy chi tiết địa chỉ
        final addressDetails = await LocationService.getLocationDetails(
          position.latitude,
          position.longitude,
        );

        // Autofill các trường
        setState(() {
          _usedCurrentLocation = true; // Đánh dấu đã dùng GPS
          _addressController.text = addressDetails['address'] ?? '';
          _wardController.text = addressDetails['ward'] ?? '';
          _districtController.text = addressDetails['district'] ?? '';
          _cityController.text = addressDetails['city'] ?? '';

          // Debug check
          print('Autofilled: ${addressDetails.toString()}');
        });
      }

      // Đóng loading
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lấy vị trí hiện tại'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Đóng loading
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lấy vị trí: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = FirebaseAuthService.getCurrentFirebaseUser()
        ?.uid; // Lấy uid từ Firebase Auth

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập lại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final address = AddressModel(
      id: _isEditing ? widget.address!.id : '',
      userId: userId,
      title: _titleController.text.trim(),
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      ward: _wardController.text.trim(),
      district: _districtController.text.trim(),
      city: _cityController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      isDefault: _isDefault,
      createdAt: _isEditing ? widget.address!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await _addressViewModel.updateAddress(address);
    } else {
      success = await _addressViewModel.addAddress(address);
    }

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Cập nhật địa chỉ thành công'
              : 'Thêm địa chỉ thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_addressViewModel.errorMessage ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
