import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/partner/data/models/partner_request_model.dart';
import '../models/provider_model.dart';

class ProviderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy danh sách tất cả Thợ đang Online từ Firestore
  Future<List<ProviderModel>> getProviders() async {
    try {
      print("🔍 [REPO] Đang query providers từ Firestore (isOnline=true)...");

      // Lấy tất cả providers đang online
      final snapshot = await _firestore
          .collection('providers')
          .where('isOnline', isEqualTo: true)
          .get();

      print("📦 [REPO] Firestore trả về ${snapshot.docs.length} documents");

      if (snapshot.docs.isEmpty) {
        print("⚠️ [REPO] Không có thợ nào online.");
        return [];
      }

      final providers = snapshot.docs.map((doc) {
        final data = doc.data();
        print(
            "   📄 Doc ${doc.id}: name=${data['name']}, isOnline=${data['isOnline']}, serviceIds=${data['serviceIds']}, price=${data['price']}");
        return ProviderModel.fromMap(data, doc.id);
      }).toList();

      print("✅ [REPO] Parse thành công ${providers.length} ProviderModel");
      return providers;
    } catch (e) {
      print('❌ [REPO] Lỗi lấy providers từ Firestore: $e');
      return [];
    }
  }

  /// Lấy danh sách thợ Online và KHÔNG BẬN vào thời gian `bookingTime`
  Future<List<ProviderModel>> getAvailableProviders(
      DateTime bookingTime) async {
    try {
      // 1. Lấy tất cả thợ online
      final allProviders = await getProviders();
      if (allProviders.isEmpty) return [];

      // 2. Xác định khung giờ bận (ví dụ: +/- 1 giờ hoặc 2 giờ tùy logic)
      // Giả sử mỗi job kéo dài ít nhất 2 giờ
      final startTime = bookingTime.subtract(const Duration(hours: 2));
      final endTime = bookingTime.add(const Duration(hours: 2));

      print(
          "🔍 [REPO] Check availability from $startTime to $endTime for ${allProviders.length} providers");

      // 3. Query các booking trùng lịch
      // Status cần check: pending, confirmed, waiting_payment, processing
      // (Bỏ qua: cancelled, completed, failed)
      final busyProviderIds = <String>{};

      // Query booking ranges overlap:
      // A booking (start, end) overlaps with (reqStart, reqEnd) if:
      // start < reqEnd AND end > reqStart
      // Tuy nhiên Firestore query range khó, nên ta query theo status và time gần đúng
      // Cách đơn giản nhất: Query tất cả active bookings của các provider này trong ngày đó, rồi check overlap in-memory

      // Lấy start/end of day
      final startOfDay =
          DateTime(bookingTime.year, bookingTime.month, bookingTime.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final activeStatuses = [
        'pending',
        'confirmed',
        'waiting_payment',
        'processing'
      ];

      // Query bookings in that day
      final bookingSnapshot = await _firestore
          .collection('bookings')
          .where('scheduleAt',
              isGreaterThanOrEqualTo: startOfDay, isLessThan: endOfDay)
          .where('status', whereIn: activeStatuses)
          .get();

      print(
          "📅 [REPO] Found ${bookingSnapshot.docs.length} active bookings today");

      for (var doc in bookingSnapshot.docs) {
        final data = doc.data();
        final pId = data['providerId'] as String;
        final scheduleAt = (data['scheduleAt'] as Timestamp).toDate();
        // Giả sử duration mặc định 2h nếu ko có field duration
        // Nếu có field quantity/unit = giờ thì tính theo đó.
        // Để đơn giản, assume 2 hours busy per slot
        int durationHours = 2;

        final jobStart = scheduleAt;
        final jobEnd = jobStart.add(Duration(hours: durationHours));

        // Check overlap with requested [bookingTime, bookingTime + 2h]
        // Requested Job: A
        // Existing Job: B
        // Overlap if (A.start < B.end) && (B.start < A.end)

        // Requested Duration (assume 2h for now or passed in)
        final reqStart = bookingTime;
        final reqEnd = bookingTime.add(Duration(hours: durationHours));

        if (reqStart.isBefore(jobEnd) && jobStart.isBefore(reqEnd)) {
          print(
              "🚫 [REPO] Provider $pId is BUSY (Job: ${doc.id} | $jobStart - $jobEnd)");
          busyProviderIds.add(pId);
        }
      }

      // 4. Filter
      final availableProviders = allProviders.where((p) {
        if (busyProviderIds.contains(p.id)) return false;
        // Check "isBusy" flag status on provider doc if exists (manual toggle)
        // if (p.isBusy) return false;
        return true;
      }).toList();

      print(
          "✅ [REPO] Filtered: ${allProviders.length} -> ${availableProviders.length} available");
      return availableProviders;
    } catch (e) {
      print('❌ [REPO] Lỗi check availability: $e');
      return []; // Or return allProviders based on risk policy
    }
  }

  /// Lấy thông tin một Provider theo ID
  Future<ProviderModel?> getProviderById(String providerId) async {
    try {
      final doc =
          await _firestore.collection('providers').doc(providerId).get();
      if (doc.exists) {
        return ProviderModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Lỗi lấy provider: $e');
    }
    return null;
  }

  /// Cập nhật trạng thái Online và vị trí của Provider
  Future<bool> updateProviderStatus({
    required String providerId,
    required bool isOnline,
    double? latitude,
    double? longitude,
    String? address,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final docRef = _firestore.collection('providers').doc(providerId);
      final docSnapshot = await docRef.get();

      final Map<String, dynamic> data = {
        'isOnline': isOnline,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (latitude != null && longitude != null) {
        data['latitude'] = latitude;
        data['longitude'] = longitude;
      }
      if (address != null) {
        data['address'] = address;
      }

      // Luôn cập nhật tên/avatar nếu có
      if (name != null) data['name'] = name;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

      // LUÔN ĐỒNG BỘ dữ liệu từ Partner Request (Hồ sơ đã được DUYỆT)
      try {
        print("🔍 Đang tìm partner_request (status=approved) cho providerId: $providerId");
        final requestSnapshot = await _firestore
            .collection('partner_requests')
            .where('userId', isEqualTo: providerId)
            .where('status', isEqualTo: 'approved') // Chỉ lấy bản đã duyệt
            .orderBy('createdAt', descending: true) // Lấy bản mới nhất
            .limit(1)
            .get();

        print("📦 Tìm thấy ${requestSnapshot.docs.length} partner_request đã duyệt");

        if (requestSnapshot.docs.isNotEmpty) {
          final reqData = requestSnapshot.docs.first.data();
          final List<dynamic>? services = reqData['services'];

          if (services != null && services.isNotEmpty) {
            List<String> sIds = [];
            List<Map<String, dynamic>> serviceObjects = [];
            double minPrice = double.infinity;

            for (var s in services) {
              final sMap = s as Map<String, dynamic>;
              
              // Map to PartnerServiceRequest to ensure structure and then toMap
              final serviceReq = PartnerServiceRequest.fromMap(sMap);
              
              sIds.add(serviceReq.serviceId);
              serviceObjects.add(serviceReq.toMap());

              // Parse price for minPrice (for display on home screen)
              String pStr = serviceReq.price
                  .replaceAll('.', '')
                  .replaceAll(',', '')
                  .replaceAll(' ', '');
              double? p = double.tryParse(pStr);
              if (p != null && p > 0 && p < minPrice) minPrice = p;
            }

            print("✅ Final: serviceIds=${sIds.length}, services=${serviceObjects.length}, minPrice=$minPrice");
            if (sIds.isNotEmpty) {
              data['serviceIds'] = sIds;
              data['services'] = serviceObjects; // LƯU CẢ HAI ĐỂ ĐỒNG BỘ
            }
            if (minPrice != double.infinity) data['price'] = minPrice;
          }
        } else {
          print("⚠️ KHÔNG tìm thấy partner_request (approved) cho user này!");
        }
      } catch (e, stackTrace) {
        print("❌ Lỗi sync partner_request: $e");
        print("❌ Stack trace: $stackTrace");
      }

      // Fallback defaults if still missing (Chỉ dùng khi thợ chưa có bất kỳ dịch vụ nào)
      if (!data.containsKey('serviceIds') && !docSnapshot.exists) {
        data['serviceIds'] = []; 
      }

      if (!docSnapshot.exists) {
        if (!data.containsKey('name'))
          data['name'] = name ?? 'Thợ Mới';
        if (!data.containsKey('rating')) data['rating'] = 5.0; // Điểm bắt đầu
        if (!data.containsKey('reviewCount')) data['reviewCount'] = 0;
        // Không set giá mặc định nếu không có dữ liệu thật
      }

      print(
          "💾 Đang lưu provider data: isOnline=${data['isOnline']}, price=${data['price']}, serviceIds=${data['serviceIds']}");
      await docRef.set(data, SetOptions(merge: true));
      print("✅ Đã lưu xong provider document");
      return true;
    } catch (e) {
      print('Lỗi cập nhật trạng thái provider: $e');
      return false;
    }
  }

  /// Tạo hoặc cập nhật thông tin Provider (cho lần đầu đăng ký làm thợ)
  Future<bool> setProviderData(ProviderModel provider) async {
    try {
      await _firestore
          .collection('providers')
          .doc(provider.id)
          .set(provider.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Lỗi lưu provider: $e');
      return false;
    }
  }

  Future<void> updateProviderProfile(String providerId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('providers').doc(providerId).update(data);
    } catch (e) {
      throw Exception("Lỗi khi cập nhật hồ sơ thợ: $e");
    }
  }

  /// Lấy số lượng công việc đã hoàn thành của thợ
  Future<int> getCompletedJobsCount(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'completed')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Lỗi lấy số lượng công việc hoàn thành: $e');
      return 0;
    }
  }
}
