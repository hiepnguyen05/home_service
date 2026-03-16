import 'package:flutter/material.dart';
import 'package:mobile/features/partner/data/models/partner_request_model.dart';
import 'package:mobile/features/provider/data/models/provider_model.dart';
import 'package:mobile/features/provider/view/widgets/details/provider_stats_grid.dart';
import 'package:mobile/features/provider/view/widgets/details/provider_bio_section.dart';
import 'package:mobile/features/provider/view/widgets/details/provider_skills_section.dart';
import 'package:mobile/features/provider/view/widgets/details/work_gallery_section.dart';
import 'package:mobile/features/provider/view/widgets/details/latest_review_teaser.dart';

class ProviderInfoTab extends StatelessWidget {
  final ProviderModel? providerModel;
  final PartnerRequestModel? partnerRequest;
  final int completedJobsCount;
  final List<PartnerServiceRequest> tempServices;
  final List<String> tempGallery;
  final bool isEditing;
  final bool isUpdatePending;
  final TextEditingController bioController;
  final VoidCallback onAddService;
  final Function(int) onDeleteService;
  final Function(int) onEditService;
  final Function(int) onToggleService;
  final IconData Function(String?, String) getSkillIcon;
  final VoidCallback onPickImage;
  final Function(int) onRemoveImage;

  const ProviderInfoTab({
    super.key,
    this.providerModel,
    this.partnerRequest,
    required this.completedJobsCount,
    required this.tempServices,
    required this.tempGallery,
    required this.isEditing,
    required this.isUpdatePending,
    required this.bioController,
    required this.onAddService,
    required this.onDeleteService,
    required this.onEditService,
    required this.onToggleService,
    required this.getSkillIcon,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          16, 20, 16, 100), // Extra padding for save button
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Grid
          ProviderStatsGrid(workCount: completedJobsCount),
          const SizedBox(height: 24),

          // About
          ProviderBioSection(
            bio: providerModel?.bio ?? partnerRequest?.bio ?? '',
            isEditing: isEditing,
            controller: bioController,
          ),
          const SizedBox(height: 24),

          // Skills
          ProviderSkillsSection(
            services: tempServices,
            isEditing: isEditing,
            isUpdatePending: isUpdatePending,
            onAddService: onAddService,
            onDeleteService: onDeleteService,
            onEditService: onEditService,
            onToggleService: onToggleService,
            getSkillIcon: getSkillIcon,
          ),

          const SizedBox(height: 24),

          // Gallery
          WorkGallerySection(
            images: isEditing
                ? tempGallery
                : (providerModel?.gallery ?? partnerRequest?.certificates),
            isEditable: isEditing,
            onAddImage: onPickImage,
            onRemoveImage: onRemoveImage,
          ),
          const SizedBox(height: 24),

          // Latest Review Teaser
          LatestReviewTeaser(reviewCount: providerModel?.reviewCount ?? 0),
        ],
      ),
    );
  }
}



