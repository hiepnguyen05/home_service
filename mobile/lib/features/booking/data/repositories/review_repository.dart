import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitReview(ReviewModel review) async {
    try {
      final batch = _firestore.batch();

      // 1. Add review document
      final reviewRef = _firestore.collection('reviews').doc();
      batch.set(reviewRef, review.toMap());

      // 2. Update Provider's rating and review count
      final providerRef = _firestore.collection('providers').doc(review.providerId);
      
      await _firestore.runTransaction((transaction) async {
        final providerDoc = await transaction.get(providerRef);
        
        if (!providerDoc.exists) {
          throw Exception("Không tìm thấy thông tin thợ để cập nhật đánh giá.");
        }

        final data = providerDoc.data()!;
        final double currentRating = (data['rating'] ?? 5.0).toDouble();
        final int currentCount = data['reviewCount'] ?? 0;

        final int newCount = currentCount + 1;
        final double newRating = ((currentRating * currentCount) + review.rating) / newCount;

        transaction.update(providerRef, {
          'rating': newRating,
          'reviewCount': newCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Also add the review to the reviews collection within the transaction for atomicity
        transaction.set(reviewRef, review.toMap());
      });

    } catch (e) {
      print("❌ [ReviewRepo] Lỗi khi gửi đánh giá: $e");
      throw Exception("Không thể gửi đánh giá. Vui lòng thử lại.");
    }
  }

  Future<List<ReviewModel>> getReviewsByProvider(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("❌ [ReviewRepo] Lỗi khi lấy danh sách đánh giá: $e");
      return [];
    }
  }

  Future<bool> hasReviewed(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
