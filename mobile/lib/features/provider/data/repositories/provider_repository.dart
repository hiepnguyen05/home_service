import 'package:cloud_firestore/cloud_firestore.dart';
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
        print("⚠️ [REPO] Không có thợ nào online, dùng Mock Data");
        // Fallback: dùng Mock Data nếu chưa có data thật
        return mockProviders;
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
      // Fallback về Mock data khi lỗi
      return mockProviders;
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

      // LUÔN ĐỒNG BỘ dữ liệu từ Partner Request (Hồ sơ đăng ký thợ)
      try {
        print("🔍 Đang tìm partner_request cho providerId: $providerId");
        final requestSnapshot = await _firestore
            .collection('partner_requests')
            .where('userId', isEqualTo: providerId)
            .limit(1)
            .get();

        print("📦 Tìm thấy ${requestSnapshot.docs.length} partner_request");

        if (requestSnapshot.docs.isNotEmpty) {
          final reqData = requestSnapshot.docs.first.data();
          print("📄 Request data keys: ${reqData.keys}");
          print("📄 Request status: ${reqData['status']}");

          final List<dynamic>? services = reqData['services'];
          print("🛠️ Services: ${services?.length ?? 0} dịch vụ");

          if (services != null && services.isNotEmpty) {
            List<String> sIds = [];
            double minPrice = double.infinity;

            for (var s in services) {
              final sMap = s as Map<String, dynamic>;
              print(
                  "   - Service: ${sMap['serviceName']}, Price: '${sMap['price']}'");

              if (sMap['serviceId'] != null) sIds.add(sMap['serviceId']);
              if (sMap['price'] != null) {
                String pStr = sMap['price']
                    .toString()
                    .replaceAll('.', '')
                    .replaceAll(',', '')
                    .replaceAll(' ', '');
                double? p = double.tryParse(pStr);
                print("   - Parsed price: '$pStr' -> $p");
                if (p != null && p > 0 && p < minPrice) minPrice = p;
              }
            }

            print("✅ Final: serviceIds=${sIds.length}, minPrice=$minPrice");
            if (sIds.isNotEmpty) data['serviceIds'] = sIds;
            if (minPrice != double.infinity) data['price'] = minPrice;
          }
        } else {
          print("⚠️ KHÔNG tìm thấy partner_request nào cho user này!");
        }
      } catch (e, stackTrace) {
        print("❌ Lỗi sync partner_request: $e");
        print("❌ Stack trace: $stackTrace");
      }

      // Fallback defaults if still missing
      if (!data.containsKey('serviceIds') && !docSnapshot.exists) {
        data['serviceIds'] = [
          'sv_cleaning',
          'sv_ac_repair',
          'sv_paint',
          'sv_laundry'
        ];
      }

      if (!docSnapshot.exists) {
        if (!data.containsKey('name'))
          data['name'] = name ?? 'Thợ Mới (${providerId.substring(0, 4)})';
        if (!data.containsKey('rating')) data['rating'] = 5.0;
        if (!data.containsKey('reviewCount')) data['reviewCount'] = 0;
        if (!data.containsKey('price')) data['price'] = 200000.0;
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
}
