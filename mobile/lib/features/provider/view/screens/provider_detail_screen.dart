import 'package:flutter/material.dart';
import 'package:mobile/features/partner/data/models/partner_request_model.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/services/cloudinary_config.dart';
import 'package:mobile/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:mobile/features/partner/data/repositories/partner_repository.dart';
import 'package:mobile/features/provider/data/repositories/provider_repository.dart';
import 'package:mobile/features/provider/data/models/provider_model.dart';
import 'package:mobile/core/utils/icon_helper.dart';
import 'package:mobile/core/widgets/sliver_tab_delegate.dart';
import 'package:mobile/features/provider/view/widgets/details/provider_detail_app_bar.dart';
import 'package:mobile/features/provider/view/widgets/details/provider_info_tab.dart';
import 'package:mobile/features/provider/view/widgets/details/provider_reviews_tab.dart';
import 'package:mobile/features/provider/view/widgets/details/provider_profile_header.dart';
import 'package:mobile/features/provider/view/widgets/details/provider_save_button.dart';

import 'package:mobile/features/chat/view/screens/chat_screen.dart';
import 'package:mobile/features/services/view/screens/services_list_screen.dart';
import 'package:mobile/features/partner/view/screens/service_pricing_screen.dart';

class ProviderDetailScreen extends StatefulWidget {
  final ProviderModel? provider;
  final bool isViewOnly;
  final bool canBookDirect; // NEW

  const ProviderDetailScreen({
    super.key,
    this.provider,
    this.isViewOnly = false,
    this.canBookDirect = false, // NEW
  });

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  PartnerRequestModel? _partnerRequest;
  ProviderModel? _providerModel;

  final TextEditingController _bioController = TextEditingController();
  List<String> _tempGallery = [];
  int _completedJobsCount = 0;
  List<PartnerServiceRequest> _tempServices = [];
  bool _isUpdatePending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;

    if (user != null) {
      try {
        if (widget.isViewOnly && widget.provider != null) {
          final providerRepo = ProviderRepository();
          final results = await Future.wait([
            providerRepo.getCompletedJobsCount(widget.provider!.id),
          ]);
          setState(() {
            _providerModel = widget.provider;
            _completedJobsCount = results[0];
            _bioController.text = _providerModel?.bio ?? '';
            _tempGallery = List<String>.from(_providerModel?.gallery ?? []);
            _tempServices = List<PartnerServiceRequest>.from(_providerModel?.services ?? []);
            _isLoading = false;
          });
          return;
        }

        final partnerRepo = PartnerRepository();
        final providerRepo = ProviderRepository();

        final results = await Future.wait([
          partnerRepo.getLastApplication(user.uid),
          providerRepo.getProviderById(user.uid),
          providerRepo.getCompletedJobsCount(user.uid),
        ]);

        final partnerReq = results[0] as PartnerRequestModel?;
        final provModel = results[1] as ProviderModel?;
        final completedCount = results[2] as int;

        setState(() {
          _partnerRequest = partnerReq;
          _providerModel = provModel;
          _completedJobsCount = completedCount;
          _isUpdatePending = _partnerRequest?.status == 'pending' &&
              _partnerRequest?.requestType == 'update';
          _bioController.text =
              _providerModel?.bio ?? _partnerRequest?.bio ?? '';
          _tempGallery = List<String>.from(
              _providerModel?.gallery ?? _partnerRequest?.certificates ?? []);

          List<PartnerServiceRequest> baseServices = _providerModel?.services ?? 
              _partnerRequest?.services ?? 
              [];

          _tempServices = List<PartnerServiceRequest>.from(baseServices);
          _isLoading = false;
        });
      } catch (e) {
        debugPrint('Error loading provider detail: $e');
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() => _isSaving = true);
      try {
        final cloudinary = CloudinaryPublic(
          CloudinaryConfig.cloudName,
          CloudinaryConfig.uploadPreset,
          cache: false,
        );
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedFile.path, folder: 'provider_gallery'),
        );
        setState(() {
          _tempGallery.add(response.secureUrl);
          _isSaving = false;
        });
      } catch (e) {
        debugPrint('Error uploading image: $e');
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi khi tải ảnh lên. Vui lòng thử lại.')),
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final providerRepo = ProviderRepository();

      await providerRepo.updateProviderProfile(user.uid, {
        'bio': _bioController.text.trim(),
        'gallery': _tempGallery,
      });

      await providerRepo.updateProviderProfile(user.uid, {
        'bio': _bioController.text.trim(),
        'gallery': _tempGallery,
      });

      await _loadData();
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                ProviderDetailAppBar(
                  isViewOnly: widget.isViewOnly,
                  isEditing: _isEditing,
                  onEditPressed: () => setState(() => _isEditing = true),
                  onClosePressed: () => setState(() {
                    _isEditing = false;
                    _bioController.text = _providerModel?.bio ?? _partnerRequest?.bio ?? '';
                    _tempGallery = List<String>.from(_providerModel?.gallery ?? _partnerRequest?.certificates ?? []);
                  }),
                  onBackPressed: () => Navigator.pop(context),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: ProviderProfileHeader(
                      avatarUrl: widget.isViewOnly ? _providerModel?.avatarUrl : user?.avatarUrl,
                      fullName: (widget.isViewOnly ? _providerModel?.name : user?.fullName) ?? 'N/A',
                      rating: _providerModel?.rating ?? 5.0,
                      reviewCount: _providerModel?.reviewCount ?? 0,
                      experienceYears: _providerModel?.experienceYears ??
                          _partnerRequest?.experienceYears?.toInt(),
                    ),
                  ),
                ),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverTabDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      tabs: const [Tab(text: 'Thông tin'), Tab(text: 'Đánh giá')],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                ProviderInfoTab(
                  providerModel: _providerModel,
                  partnerRequest: _partnerRequest,
                  completedJobsCount: _completedJobsCount,
                  tempServices: _tempServices,
                  tempGallery: _tempGallery,
                  isEditing: _isEditing,
                  isUpdatePending: _isUpdatePending,
                  bioController: _bioController,
                  onAddService: _showAddServicePicker,
                  onDeleteService: _deleteService,
                  onToggleService: _toggleServiceStatus,
                  getSkillIcon: _getSkillIcon,
                  onPickImage: _pickImage,
                  onRemoveImage: (index) => setState(() => _tempGallery.removeAt(index)),
                  onSeeAllReviews: () => _tabController.animateTo(1),
                ),
                ProviderReviewsTab(providerId: _providerModel?.id ?? widget.provider?.id ?? ''),
              ],
            ),
          ),
          if (_isEditing)
            ProviderSaveButton(
              isSaving: _isSaving,
              onSave: _saveProfile,
            ),
          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
          if (widget.isViewOnly && _providerModel != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: widget.isViewOnly && widget.provider != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (widget.canBookDirect) ...[
                      // Chat Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            final authViewModel = context.read<AuthViewModel>();
                            final currentUserId = authViewModel.currentUser?.uid ?? '';
                            final chatId = "pre_${currentUserId}_${widget.provider!.id}";

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  bookingId: chatId,
                                  targetUserId: widget.provider!.id,
                                  otherUserName: widget.provider!.name,
                                  otherUserAvatar: widget.provider!.avatarUrl,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_outlined, color: Colors.blue),
                          tooltip: 'Chat tư vấn',
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.canBookDirect) {
                            // Go to service
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServicesListScreen(
                                provider: _providerModel!,
                                providerServices: _providerModel!.services,
                              ),
                            ),
                          );
                        } else {
                            Navigator.pop(context, _providerModel!.id);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 4,
                        ),
                        child: Text(
                          widget.canBookDirect ? 'Đặt dịch vụ' : 'Chọn thợ này',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  void _showAddServicePicker() async {
    final newServices = await Navigator.push<List<PartnerServiceRequest>>(
      context,
      MaterialPageRoute(
        builder: (context) => ServicePricingScreen(
          initialServices: _tempServices,
          isUpdateMode: true,
          providerId: _providerModel!.id,
          providerName: _providerModel!.name,
          providerPhone: _providerModel!.phoneNumber,
          onSave: (services) {
            setState(() {
              _tempServices = services;
            });
          },
        ),
      ),
    );
    if (newServices != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Đã cập nhật danh sách dịch vụ. Nhấn "Lưu thay đổi" để gửi duyệt.')),
      );
    }
  }

  Future<void> _deleteService(int index) async {
    final service = _tempServices[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa dịch vụ "${service.serviceName}"? Việc này sẽ có hiệu lực ngay lập tức.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Xóa', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        final newServices = List<PartnerServiceRequest>.from(_tempServices);
        newServices.removeAt(index);
        
        await ProviderRepository().updateProviderProfile(_providerModel!.id, {
          'services': newServices.map((s) => s.toMap()).toList(),
          'serviceIds': newServices.map((s) => s.serviceId).toList(),
        });

        setState(() {
          _tempServices = newServices;
          _isSaving = false;
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa dịch vụ thành công.')));
      } catch (e) {
        setState(() => _isSaving = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
      }
    }
  }

  Future<void> _toggleServiceStatus(int index) async {
    final service = _tempServices[index];
    final bool newStatus = !service.isActive;
    
    setState(() => _isSaving = true);
    try {
      final newServices = List<PartnerServiceRequest>.from(_tempServices);
      newServices[index] = PartnerServiceRequest(
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        price: service.price,
        iconName: service.iconName,
        isActive: newStatus,
        changeType: service.changeType,
        oldPrice: service.oldPrice,
      );

      await ProviderRepository().updateProviderProfile(_providerModel!.id, {
        'services': newServices.map((s) => s.toMap()).toList(),
      });

      setState(() {
        _tempServices = newServices;
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newStatus ? 'Đã kích hoạt lại dịch vụ.' : 'Đã tạm ngưng dịch vụ.'))
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  IconData _getSkillIcon(String? iconName, String serviceName) {
    if (iconName != null && iconName.isNotEmpty) {
      return IconHelper.getIcon(iconName);
    }
    final name = serviceName.toLowerCase();
    if (name.contains('điện')) return Icons.bolt;
    if (name.contains('nước')) return Icons.water_drop;
    if (name.contains('lạnh') || name.contains('điều hòa')) return Icons.hvac;
    if (name.contains('khoan') || name.contains('lắp')) return Icons.construction;
    if (name.contains('vệ sinh') || name.contains('dọn')) return Icons.cleaning_services;
    return Icons.settings;
  }
}
