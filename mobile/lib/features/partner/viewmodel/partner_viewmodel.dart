import 'package:flutter/material.dart';
import '../data/repositories/partner_repository.dart';
import '../../services/data/models/service_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../data/models/partner_request_model.dart';

class PartnerViewModel extends ChangeNotifier {
  final PartnerRepository _repository;

  PartnerViewModel({PartnerRepository? repository})
      : _repository = repository ?? PartnerRepository();

  // State for KYC Step
  File? _frontIdImage;
  File? _backIdImage;

  // State for Portrait & Bio Step
  File? _portraitImage;
  String _bio = '';
  double _experienceYears = 0.0;

  // State for Certificate Step
  final List<File> _certificateImages = [];

  // State for Pricing Step
  List<ServiceModel> _activeServices = [];
  final Set<String> _selectedServiceIds = {};
  final Map<String, String> _servicePrices = {};
  bool _isLoadingServices = false;

  // Submission State
  bool _isSubmitting = false;
  String? _errorMessage;

  // Getters
  File? get frontIdImage => _frontIdImage;
  File? get backIdImage => _backIdImage;
  File? get portraitImage => _portraitImage;
  String get bio => _bio;
  double get experienceYears => _experienceYears;
  List<File> get certificateImages => List.unmodifiable(_certificateImages);
  List<ServiceModel> get activeServices => _activeServices;
  Set<String> get selectedServiceIds => _selectedServiceIds;
  Map<String, String> get servicePrices => _servicePrices;
  bool get isLoadingServices => _isLoadingServices;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // --- KYC Actions ---
  void setFrontIdImage(File image) {
    _frontIdImage = image;
    notifyListeners();
  }

  void setBackIdImage(File image) {
    _backIdImage = image;
    notifyListeners();
  }

  // --- Portrait & Bio Actions ---
  void setPortraitImage(File image) {
    _portraitImage = image;
    notifyListeners();
  }

  void setBio(String bio) {
    _bio = bio;
    notifyListeners();
  }

  void setExperienceYears(double years) {
    _experienceYears = years;
    notifyListeners();
  }

  // --- Certificate Actions ---
  void addCertificate(File image) {
    _certificateImages.add(image);
    notifyListeners();
  }

  void removeCertificate(int index) {
    if (index >= 0 && index < _certificateImages.length) {
      _certificateImages.removeAt(index);
      notifyListeners();
    }
  }

  // --- Pricing Actions ---
  Future<void> fetchActiveServices() async {
    _isLoadingServices = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeServices = await _repository.getActiveServices();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  void toggleServiceSelection(String serviceId, bool isSelected) {
    if (isSelected) {
      _selectedServiceIds.add(serviceId);
      // Initialize price if not already set (e.g. use suggested or empty)
      if (!_servicePrices.containsKey(serviceId)) {
        _servicePrices[serviceId] = '';
      }
    } else {
      _selectedServiceIds.remove(serviceId);
      _servicePrices.remove(serviceId);
    }
    notifyListeners();
  }

  void initializePricing(List<PartnerServiceRequest> services) {
    _selectedServiceIds.clear();
    _servicePrices.clear();
    for (var s in services) {
      _selectedServiceIds.add(s.serviceId);
      _servicePrices[s.serviceId] = s.price;
    }
    notifyListeners();
  }

  void updateServicePrice(String serviceId, String price) {
    _servicePrices[serviceId] = price;
    notifyListeners();
  }

  // --- Submission ---
  Future<bool> submitApplication() async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Người dùng chưa đăng nhập');
      if (_frontIdImage == null || _backIdImage == null)
        throw Exception('Thiếu ảnh CMND/CCCD');
      if (_portraitImage == null) throw Exception('Thiếu ảnh chân dung');
      if (_portraitImage == null) throw Exception('Thiếu ảnh chân dung');
      if (_bio.isEmpty) throw Exception('Vui lòng nhập giới thiệu bản thân');

      // Prepare service data
      final List<Map<String, dynamic>> selectedServicesData =
          _selectedServiceIds.map((id) {
        final service = _activeServices.firstWhere((s) => s.id == id);
        return {
          'serviceId': id,
          'serviceName': service.name,
          'price': _servicePrices[id] ?? '0',
          'iconName': service.iconName,
          'priceUnit': service.priceUnit,
        };
      }).toList();

      if (selectedServicesData.isEmpty)
        throw Exception('Vui lòng chọn ít nhất một dịch vụ');

      await _repository.submitApplication(
        userId: user.uid,
        fullName: user.displayName ??
            'Unknown', // Or fetch from User Profile if needed
        phoneNumber: user.phoneNumber ?? '',
        frontIdImage: _frontIdImage!,
        backIdImage: _backIdImage!,
        portraitImage: _portraitImage!,
        certificateImages: _certificateImages,
        bio: _bio,
        experienceYears: _experienceYears,
        selectedServices: selectedServicesData,
      );

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitUpdate({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required List<PartnerServiceRequest> services,
    String? bio,
    double? experienceYears,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.submitUpdate(
        userId: userId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        services: services,
        bio: bio,
        experienceYears: experienceYears,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reset flow state
  void reset() {
    _frontIdImage = null;
    _backIdImage = null;
    _portraitImage = null;
    _bio = '';
    _experienceYears = 0.0;
    _certificateImages.clear();
    _selectedServiceIds.clear();
    _servicePrices.clear();
    _errorMessage = null;
    _isSubmitting = false;
    notifyListeners();
  }

  Stream getApplicationStatusStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return _repository.getApplicationStatusStream(user.uid);
    }
    return Stream.empty();
  }

  // Check if user already has an application
  Future<String?> checkExistingApplication() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      debugPrint(
          '[PartnerViewModel] Checking application for user: ${user?.uid}');
      if (user != null) {
        final request = await _repository.getLastApplication(user.uid);
        debugPrint(
            '[PartnerViewModel] Found application: ${request != null}, status: ${request?.status}');
        if (request != null) {
          return request.status;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[PartnerViewModel] Error checking existing application: $e');
      return null;
    }
  }
}
