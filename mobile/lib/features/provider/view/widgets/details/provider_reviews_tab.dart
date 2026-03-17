import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/features/booking/data/models/review_model.dart';
import 'package:mobile/features/booking/data/repositories/review_repository.dart';
import '../../../../booking/view/widgets/rating/review_item_widget.dart';

class ProviderReviewsTab extends StatefulWidget {
  final String providerId;
  const ProviderReviewsTab({super.key, required this.providerId});

  @override
  State<ProviderReviewsTab> createState() => _ProviderReviewsTabState();
}

class _ProviderReviewsTabState extends State<ProviderReviewsTab> {
  final ReviewRepository _reviewRepository = ReviewRepository();
  List<ReviewModel>? _allReviews;
  List<ReviewModel>? _filteredReviews;
  bool _isLoading = true;
  int _selectedFilter = 0; // 0 = All, 1-5 = Stars

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (widget.providerId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    final reviews = await _reviewRepository.getReviewsByProvider(widget.providerId);
    if (mounted) {
      setState(() {
        _allReviews = reviews;
        _applyFilter();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_allReviews == null) return;
    if (_selectedFilter == 0) {
      _filteredReviews = _allReviews;
    } else {
      _filteredReviews = _allReviews!
          .where((r) => r.rating >= _selectedFilter && r.rating < _selectedFilter + 1)
          .toList();
      // Alternatively, if the user means "at least X stars" or "exactly X stars":
      // Based on typical UI patterns, "5 stars" usually means exactly 5 stars.
      _filteredReviews = _allReviews!
          .where((r) => r.rating.floor() == _selectedFilter)
          .toList();
    }
  }

  void _onFilterChanged(int rating) {
    setState(() {
      _selectedFilter = rating;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: _buildReviewList(),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(0, 'Tất cả'),
          _buildFilterChip(5, '5 sao'),
          _buildFilterChip(4, '4 sao'),
          _buildFilterChip(3, '3 sao'),
          _buildFilterChip(2, '2 sao'),
          _buildFilterChip(1, '1 sao'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int rating, String label) {
    final isSelected = _selectedFilter == rating;
    return GestureDetector(
      onTap: () => _onFilterChanged(rating),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (rating > 0) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.star,
                size: 14,
                color: isSelected ? Colors.white : Colors.amber,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    if (_filteredReviews == null || _filteredReviews!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 0 ? 'Chưa có đánh giá nào' : 'Không có đánh giá $_selectedFilter sao',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _filteredReviews!.length,
      itemBuilder: (context, index) {
        return ReviewItemWidget(review: _filteredReviews![index]);
      },
    );
  }
}
