import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import '../models/category_model.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore;

  ServiceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Fetch Categories
  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection('categories')
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Fetch Services (optionally filtered by category)
  Stream<List<ServiceModel>> getServices({String? categoryId}) {
    Query query =
        _firestore.collection('services').where('isActive', isEqualTo: true);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    // Note: If you have composite indexes issues, you might need to index (categoryId + active + rating/created)
    // For now, let's keep it simple.
    // query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<ServiceModel> getServiceById(String id) async {
    final doc = await _firestore.collection('services').doc(id).get();
    if (doc.exists) {
      return ServiceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } else {
      throw Exception('Service not found');
    }
  }
}
