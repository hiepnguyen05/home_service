import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/constants/app_routes.dart';
import 'package:mobile/core/widgets/app_image.dart';
import 'package:mobile/features/services/data/models/service_model.dart';
import 'package:mobile/features/services/view/widgets/bottom_cta_section.dart';
import 'package:mobile/features/services/view/widgets/faq_section.dart';
import 'package:mobile/features/services/view/widgets/process_steps_section.dart';
import 'package:mobile/features/services/view/widgets/service_info_section.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServiceModel service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white.withOpacity(0.9),
            title: const Text(
              'Chi tiết dịch vụ',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new)),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                AppImage(imageUrl: service.imageUrl),
                ServiceInfoSection(
                    name: service.name,
                    reviewConut: service.reviewCount.toString(),
                    description: service.description),
                ProcessStepsSection(),
                FAQSection()
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomCTASection(onBookingPressed: () {
        Navigator.pushNamed(
          context,
          AppRoutes.bookingTime,
          arguments: service.id,
        );
      }),
    );
  }
}
