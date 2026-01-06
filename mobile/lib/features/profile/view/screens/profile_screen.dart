import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/services/location_service.dart';
import '../../../auth/viewmodel/auth_viewmodel.dart';
import '../../viewmodel/profile_viewmodel.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    
    if (authViewModel.token != null) {
      profileViewModel.loadProfile(authViewModel.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Bỏ nút back vì nằm trong bottom nav
      ),
      body: Consumer2<AuthViewModel, ProfileViewModel>(
        builder: (context, authViewModel, profileViewModel, child) {
          if (profileViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          final user = profileViewModel.currentUser ?? authViewModel.currentUser;
          
          if (user == null) {
            return const Center(
              child: Text('Không thể tải thông tin người dùng'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header với avatar và thông tin cơ bản
                ProfileHeader(
                  user: user,
                  onEditPressed: () => _showEditProfileDialog(context),
                  onAvatarPressed: () => _showAvatarOptions(context),
                ),
                
                const SizedBox(height: AppSizes.spacingLarge),
                
                // Menu items
                Container(
                  color: AppColors.white,
                  child: Column(
                    children: [
                      ProfileMenuItem(
                        icon: Icons.location_on,
                        iconColor: AppColors.primary,
                        title: 'Quản lý địa chỉ',
                        subtitle: _getAddressSubtitle(profileViewModel),
                        onTap: () => _showAddressDialog(context),
                      ),
                      const Divider(height: 1, color: AppColors.borderLight),
                      
                      ProfileMenuItem(
                        icon: Icons.payment,
                        iconColor: AppColors.green,
                        title: 'Phương thức thanh toán',
                        onTap: () => _showComingSoon(context, 'Phương thức thanh toán'),
                      ),
                      const Divider(height: 1, color: AppColors.borderLight),
                      
                      ProfileMenuItem(
                        icon: Icons.notifications,
                        iconColor: AppColors.orange,
                        title: 'Cài đặt thông báo',
                        onTap: () => _showComingSoon(context, 'Cài đặt thông báo'),
                      ),
                      const Divider(height: 1, color: AppColors.borderLight),
                      
                      ProfileMenuItem(
                        icon: Icons.help_center,
                        iconColor: Colors.purple,
                        title: 'Trung tâm hỗ trợ',
                        onTap: () => _showComingSoon(context, 'Trung tâm hỗ trợ'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.spacingLarge),
                
                // Nút đăng xuất
                Container(
                  color: AppColors.white,
                  child: ProfileMenuItem(
                    icon: Icons.logout,
                    iconColor: AppColors.red,
                    title: 'Đăng xuất',
                    titleColor: AppColors.red,
                    onTap: () => _showLogoutConfirmation(context),
                  ),
                ),
                
                const SizedBox(height: AppSizes.spacingXLarge),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getAddressSubtitle(ProfileViewModel profileViewModel) {
    final defaultAddress = profileViewModel.defaultAddress;
    if (defaultAddress != null) {
      return defaultAddress.address;
    }
    return 'Chưa có địa chỉ mặc định';
  }

  void _showEditProfileDialog(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final user = profileViewModel.currentUser ?? authViewModel.currentUser;
    
    if (user == null) return;

    final TextEditingController nameController = TextEditingController(text: user.fullName);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Chỉnh sửa thông tin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Consumer<ProfileViewModel>(
              builder: (context, profileVM, child) {
                return TextButton(
                  onPressed: profileVM.isLoading ? null : () async {
                    final newName = nameController.text.trim();
                    if (newName.isEmpty) {
                      _showMessage('Vui lòng nhập họ và tên', isError: true);
                      return;
                    }

                    final token = authViewModel.token;
                    if (token == null) {
                      _showMessage('Phiên đăng nhập đã hết hạn', isError: true);
                      return;
                    }

                    final success = await profileVM.updateProfile(
                      token: token,
                      fullName: newName,
                    );

                    if (!mounted) return;

                    if (success) {
                      Navigator.of(context).pop();
                      _showMessage('Cập nhật thông tin thành công');
                      // Cập nhật thông tin trong AuthViewModel
                      authViewModel.updateUserInfo(profileVM.currentUser!);
                    } else {
                      _showMessage(profileVM.errorMessage ?? 'Cập nhật thất bại', isError: true);
                    }
                  },
                  child: profileVM.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        )
                      : const Text(
                          'Lưu',
                          style: TextStyle(color: AppColors.primary),
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showAvatarOptions(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Thay đổi ảnh đại diện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.spacingLarge),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(context, authViewModel, profileViewModel, true);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingSmall),
                        const Text(
                          'Camera',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Gallery
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(context, authViewModel, profileViewModel, false);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            size: 30,
                            color: AppColors.green,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingSmall),
                        const Text(
                          'Thư viện',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.spacingLarge),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    AuthViewModel authViewModel,
    ProfileViewModel profileViewModel,
    bool fromCamera,
  ) async {
    try {
      // Import image_picker dynamically to avoid compile errors if not installed
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        final token = authViewModel.token;
        if (token == null) {
          _showMessage('Phiên đăng nhập đã hết hạn', isError: true);
          return;
        }

        // Show loading message
        _showMessage('Đang upload ảnh...', isLoading: true);

        final success = await profileViewModel.uploadAvatar(token, File(image.path));

        if (success) {
          _showMessage('Cập nhật ảnh đại diện thành công');
          // Cập nhật thông tin trong AuthViewModel
          authViewModel.updateUserInfo(profileViewModel.currentUser!);
        } else {
          _showMessage(profileViewModel.errorMessage ?? 'Upload ảnh thất bại', isError: true);
        }
      }
    } catch (e) {
      print('Lỗi khi chọn/upload ảnh: $e');
      _showMessage('Không thể chọn ảnh. Vui lòng thử lại.', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false, bool isLoading = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    
    if (isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(message),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 30), // Long duration for loading
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAddressDialog(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    
    double? currentLatitude;
    double? currentLongitude;
    bool isLoadingLocation = false;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Thêm địa chỉ mới',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Form fields
                    const Text(
                      'Tên địa chỉ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'VD: Nhà riêng, Công ty, Trường học...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Location button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isLoadingLocation ? null : () async {
                            setState(() {
                              isLoadingLocation = true;
                            });
                            
                            final position = await LocationService.getCurrentPosition();
                            
                            if (position != null) {
                              currentLatitude = position.latitude;
                              currentLongitude = position.longitude;
                              
                              setState(() {
                                isLoadingLocation = false;
                              });
                              
                              final address = await LocationService.getAddressFromCoordinates(
                                position.latitude,
                                position.longitude,
                              );
                              
                              addressController.text = address;
                              
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.location_on, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text('Đã lấy địa chỉ hiện tại thành công'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              setState(() {
                                isLoadingLocation = false;
                              });
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Không thể lấy vị trí. Vui lòng kiểm tra quyền truy cập.'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isLoadingLocation)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.my_location,
                                    size: 20,
                                    color: AppColors.white,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  isLoadingLocation ? 'Đang lấy vị trí...' : 'Lấy vị trí hiện tại',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Địa chỉ chi tiết',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: addressController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Nhập địa chỉ chi tiết hoặc sử dụng nút lấy vị trí ở trên',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    // Location info
                    if (currentLatitude != null && currentLongitude != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.05),
                              AppColors.primary.withOpacity(0.02),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vị trí đã được xác định',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tọa độ: ${currentLatitude!.toStringAsFixed(6)}, ${currentLongitude!.toStringAsFixed(6)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                borderRadius: BorderRadius.circular(12),
                                child: const Center(
                                  child: Text(
                                    'Hủy',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Consumer<ProfileViewModel>(
                            builder: (context, profileVM, child) {
                              return Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: profileVM.isLoading ? null : () async {
                                      final name = nameController.text.trim();
                                      final address = addressController.text.trim();
                                      
                                      if (name.isEmpty || address.isEmpty) {
                                        _showMessage('Vui lòng nhập đầy đủ thông tin', isError: true);
                                        return;
                                      }

                                      final token = authViewModel.token;
                                      if (token == null) {
                                        _showMessage('Phiên đăng nhập đã hết hạn', isError: true);
                                        return;
                                      }

                                      final success = await profileVM.updateAddress(
                                        token: token,
                                        name: name,
                                        address: address,
                                        latitude: currentLatitude,
                                        longitude: currentLongitude,
                                        isDefault: profileVM.addresses.isEmpty,
                                      );

                                      if (!mounted) return;

                                      if (success) {
                                        Navigator.of(context).pop();
                                        _showMessage('✅ Thêm địa chỉ thành công');
                                        // Reload profile để cập nhật danh sách địa chỉ
                                        _loadProfile();
                                      } else {
                                        _showMessage(profileVM.errorMessage ?? 'Thêm địa chỉ thất bại', isError: true);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Center(
                                        child: profileVM.isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                                ),
                                              )
                                            : const Text(
                                                'Lưu địa chỉ',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    DialogUtils.showInfo(
      context,
      title: 'Sắp ra mắt',
      message: 'Tính năng $feature sẽ được phát triển trong phiên bản tiếp theo.',
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    DialogUtils.showConfirmation(
      context,
      title: 'Xác nhận đăng xuất',
      message: 'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
      onConfirm: () async {
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        await authViewModel.logout();
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      },
    );
  }


}