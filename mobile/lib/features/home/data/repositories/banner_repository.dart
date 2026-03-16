import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';

class BannerRepository {
  final FirebaseFirestore _firestore;

  BannerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<BannerModel>> getActiveBanners() async {
    try {
      // Simplified query to avoid index requirement for now
      final querySnapshot = await _firestore
          .collection('banners')
          .get();

      final allBanners = querySnapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc.data(), doc.id))
          .toList();
          
      // Filter and sort manually in memory
      final activeBanners = allBanners
          .where((b) => b.isActive)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
        
      print('BannerRepository: Found ${activeBanners.length} active banners');
      return activeBanners;
    } catch (e) {
      print('Error fetching banners in BannerRepository: $e');
      return [];
    }
  }
}
