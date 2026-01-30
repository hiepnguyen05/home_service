import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../services/data/models/service_model.dart';
import '../models/partner_request_model.dart';
import 'dart:io';

class PartnerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch active services for pricing setup
  Future<List<ServiceModel>> getActiveServices() async {
    try {
      final snapshot = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách dịch vụ: $e');
    }
  }

  // Upload images and submit partner application
  Future<void> submitApplication({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required File frontIdImage,
    required File backIdImage,
    required List<File> certificateImages,
    required List<Map<String, dynamic>> selectedServices,
  }) async {
    try {
      // 1. Upload Images
      final frontUrl = await CloudinaryService.uploadFile(
          file: frontIdImage, folder: 'kyc/front');
      final backUrl = await CloudinaryService.uploadFile(
          file: backIdImage, folder: 'kyc/back');

      List<String> certUrls = [];
      for (var certFile in certificateImages) {
        final url = await CloudinaryService.uploadFile(
            file: certFile, folder: 'certificates');
        if (url != null) certUrls.add(url);
      }

      // 2. Prepare Data
      final requestModel = PartnerRequestModel(
        userId: userId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        idFrontUrl: frontUrl!,
        idBackUrl: backUrl!,
        certificates: certUrls,
        services: selectedServices
            .map((s) => PartnerServiceRequest.fromMap(s))
            .toList(),
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // 3. Save to Firestore
      var data = requestModel.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('partner_requests').add(data);
    } catch (e) {
      throw Exception('Lỗi khi gửi hồ sơ: $e');
    }
  }

  // Stream to listen for application status
  Stream<QuerySnapshot> getApplicationStatusStream(String userId) {
    return _firestore
        .collection('partner_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots();
  }

  // Get latest application (One-time fetch)
  Future<PartnerRequestModel?> getLastApplication(String userId) async {
    try {
      debugPrint(
          '[PartnerRepository] Fetching application for userId: $userId');
      final snapshot = await _firestore
          .collection('partner_requests')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      debugPrint('[PartnerRepository] Found ${snapshot.docs.length} documents');
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        debugPrint('[PartnerRepository] Document status: ${data['status']}');
        return PartnerRequestModel.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('[PartnerRepository] getLastApplication error: $e');
      return null;
    }
  }
}
