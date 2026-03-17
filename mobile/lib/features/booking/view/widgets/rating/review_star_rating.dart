import 'package:flutter/material.dart';

class ReviewStarRating extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;

  const ReviewStarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1.0;
            final isFilled = starValue <= rating;
            return GestureDetector(
              onTap: () => onRatingChanged(starValue),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  color: isFilled ? Colors.yellow[700] : Colors.grey[300],
                  size: 48,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _getRatingLabel(rating),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 5) return "Rất hài lòng";
    if (rating >= 4) return "Hài lòng";
    if (rating >= 3) return "Bình thường";
    if (rating >= 2) return "Không hài lòng";
    return "Rất tệ";
  }
}
