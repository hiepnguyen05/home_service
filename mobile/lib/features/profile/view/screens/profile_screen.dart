import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../auth/viewmodel/auth_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  final bool isProviderMode;

  const ProfileScreen({super.key, this.isProviderMode = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final user = authViewModel.currentUser;

          if (user == null) {
            return const Center(
              child: Text(
                'Không có thông tin người dùng',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header với avatar và thông tin cơ bản
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFE8B4A0),
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (user.avatarUrl != null
                                    ? NetworkImage(user.avatarUrl!)
                                    : null) as ImageProvider?,
                            child:
                                _selectedImage == null && user.avatarUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      )
                                    : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Tên và số điện thoại
                      if (_isEditing) ...[
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              AppTextField(
                                controller: _fullNameController,
                                hint: 'Họ và tên',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập họ và tên';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: _phoneController,
                                hint: 'Số điện thoại',
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập số điện thoại';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.phone,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Nút chỉnh sửa/lưu
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton.icon(
                          onPressed: _isEditing ? _saveProfile : _toggleEdit,
                          icon: Icon(
                            _isEditing ? Icons.save : Icons.edit,
                            color: Colors.black,
                            size: 20,
                          ),
                          label: Text(
                            _isEditing ? 'Lưu thay đổi' : 'Chỉnh sửa',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Menu items
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.location_on,
                        iconColor: Colors.blue,
                        title: 'Quản lý địa chỉ',
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.addressList);
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: user.isProvider
                            ? Icons.visibility_outlined
                            : Icons.credit_card,
                        iconColor: Colors.green,
                        title: user.isProvider
                            ? 'Xem trước hồ sơ'
                            : 'Phương thức thanh toán',
                        onTap: () {
                          if (user.isProvider) {
                            Navigator.pushNamed(
                                context, AppRoutes.providerDetail);
                          } else {
                            // TODO: Navigate to payment methods
                          }
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.notifications,
                        iconColor: Colors.orange,
                        title: 'Cài đặt thông báo',
                        onTap: () {
                          // TODO: Navigate to notification settings
                        },
                      ),
                      _buildDivider(),
                      // Conditional: Show role switch for providers, partner registration for customers
                      if (user.isProvider)
                        _buildMenuItem(
                          icon: Icons.swap_horiz,
                          iconColor: AppColors.primary,
                          title: widget.isProviderMode
                              ? 'Chuyển sang chế độ khách'
                              : 'Chuyển sang chế độ thợ',
                          onTap: () {
                            if (widget.isProviderMode) {
                              // Currently in provider mode, switch to customer
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.home,
                                (route) => false,
                              );
                            } else {
                              // Currently in customer mode, switch to provider
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.providerHome,
                                (route) => false,
                              );
                            }
                          },
                        )
                      else
                        _buildMenuItem(
                          icon: Icons.handshake,
                          iconColor: AppColors.primary,
                          title: 'Đăng ký trở thành đối tác',
                          onTap: () {
                            Navigator.pushNamed(
                                context, AppRoutes.partnerRegistration);
                          },
                        ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.help_center,
                        iconColor: Colors.purple,
                        title: 'Trung tâm hỗ trợ',
                        onTap: () {
                          // TODO: Navigate to help center
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Nút đăng xuất
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextButton.icon(
                    onPressed: () => _handleLogout(context, authViewModel),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 60,
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers if canceling edit
        _initializeControllers();
        _selectedImage = null;
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      // Hiển thị dialog chọn nguồn ảnh
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Chọn ảnh đại diện'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Chụp ảnh'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String? avatarUrl;

      // Upload ảnh nếu có chọn ảnh mới
      if (_selectedImage != null) {
        print('[PROFILE] Đang upload ảnh avatar...');

        // Debug Cloudinary configuration
        await CloudinaryService.debugCloudinaryConfiguration();

        // Kiểm tra kết nối Cloudinary trước
        final isConnected = await CloudinaryService.checkCloudinaryConnection();
        print('[PROFILE] Cloudinary connection status: $isConnected');

        if (!isConnected) {
          throw Exception(
              'Cloudinary chưa được cấu hình. Vui lòng:\n1. Đăng ký tài khoản Cloudinary miễn phí\n2. Cập nhật cloud name và upload preset\n3. Kiểm tra kết nối internet');
        }

        avatarUrl = await CloudinaryService.uploadAvatar(_selectedImage!);
        print('[PROFILE] Upload ảnh thành công: $avatarUrl');
      }

      final success = await authViewModel.updateUserInfo(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: avatarUrl,
      );

      // Đóng loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        setState(() {
          _isEditing = false;
          _selectedImage = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authViewModel.errorMessage ?? 'Lỗi cập nhật thông tin',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Đóng loading dialog
      if (mounted) Navigator.of(context).pop();

      print('Error saving profile: $e');

      if (mounted) {
        // Hiển thị lỗi chi tiết hơn
        String errorMessage = 'Lỗi không xác định';

        if (e.toString().contains('cloudinary') ||
            e.toString().contains('Cloudinary')) {
          errorMessage =
              'Lỗi upload ảnh: ${e.toString().replaceAll('Exception: ', '')}';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Upload quá lâu. Vui lòng thử lại với ảnh nhỏ hơn.';
        } else {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () {
                // Thử lại chỉ cập nhật thông tin mà không upload ảnh
                _saveProfileWithoutImage();
              },
            ),
          ),
        );
      }
    }
  }

  /// Lưu thông tin mà không upload ảnh (fallback)
  Future<void> _saveProfileWithoutImage() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    try {
      final success = await authViewModel.updateUserInfo(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        // Không upload ảnh mới
      );

      if (success) {
        setState(() {
          _isEditing = false;
          _selectedImage = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Cập nhật thông tin thành công (không bao gồm ảnh)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLogout(BuildContext context, AuthViewModel authViewModel) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await authViewModel.logout();

      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    }
  }
}
