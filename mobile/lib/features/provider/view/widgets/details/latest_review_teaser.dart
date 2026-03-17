import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/booking/data/models/review_model.dart';
import 'package:mobile/features/booking/data/repositories/review_repository.dart';
import 'package:mobile/features/booking/view/widgets/rating/review_item_widget.dart';

class LatestReviewTeaser extends StatefulWidget {
  final int reviewCount;
  final String providerId;
  final VoidCallback? onSeeAll;

  const LatestReviewTeaser({
    super.key,
    required this.reviewCount,
    required this.providerId,
    this.onSeeAll,
  });

  @override
  State<LatestReviewTeaser> createState() => _LatestReviewTeaserState();
}

class _LatestReviewTeaserState extends State<LatestReviewTeaser> {
  final ReviewRepository _reviewRepository = ReviewRepository();
  List<ReviewModel>? _latestReviews;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLatestReviews();
  }

  Future<void> _loadLatestReviews() async {
    if (widget.reviewCount == 0 || widget.providerId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final reviews = await _reviewRepository.getReviewsByProvider(widget.providerId);
      if (mounted) {
        setState(() {
          _latestReviews = reviews.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá mới nhất',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (widget.reviewCount > 0 && _latestReviews != null && _latestReviews!.isNotEmpty)
          Column(
            children: [
              ..._latestReviews!.map((review) => ReviewItemWidget(review: review)),
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: widget.onSeeAll,
                  child: const Text(
                    'Xem tất cả đánh giá',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined, color: Colors.grey[300], size: 48),
                const SizedBox(height: 12),
                Text(
                  'Chưa có đánh giá nào',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hãy hoàn thành các công việc đầu tiên để nhận được phản hồi từ khách hàng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
