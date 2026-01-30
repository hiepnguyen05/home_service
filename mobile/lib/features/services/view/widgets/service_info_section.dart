import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class ServiceInfoSection extends StatelessWidget {
  final String name;
  final double rating;
  final String reviewConut;
  final String description;

  const ServiceInfoSection(
      {super.key,
      required this.name,
      this.rating = 0,
      required this.reviewConut,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          SizedBox(height: 10),
          _buildRating(),
          SizedBox(height: 10),
          _buildDescription()
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      name,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.2,
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          rating.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($reviewConut lượt đánh giá)',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      description,
      textAlign: TextAlign.justify,
      style:
          TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.6),
    );
  }
}
