import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_categories.dart';
import '../widgets/promotion_banner.dart';
import '../widgets/worker_card.dart';

import 'package:provider/provider.dart';
import '../../../auth/viewmodel/auth_viewmodel.dart';
import '../../viewmodel/home_viewmodel.dart';
import '../../../services/viewmodel/services_viewmodel.dart';
import '../../../services/view/screens/services_list_screen.dart';
import '../../../../core/utils/formatters.dart';
import 'package:mobile/features/provider/view/screens/provider_detail_screen.dart';

// ... (previous imports)

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access ViewModels
    final servicesViewModel = context.watch<ServicesViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final homeViewModel = context.watch<HomeViewModel>();

    final categories = servicesViewModel.categories;
    final currentUser = authViewModel.currentUser;
    final nearbyProviders = homeViewModel.nearbyProviders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeAppBar(
                userName: currentUser?.fullName ?? 'Khách',
                avatarUrl: currentUser?.avatarUrl,
              ),
              HomeSearchBar(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ServicesListScreen()));
                },
              ),
              HomeCategories(
                categories: categories,
                onCategoryTap: (categoryId) {
                  final category = categories.firstWhere(
                      (c) => c.id == categoryId,
                      orElse: () => categories.first);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServicesListScreen(
                        categoryId: categoryId,
                        categoryName: category.name,
                      ),
                    ),
                  );
                },
              ),
              PromotionBanner(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  'Thợ gần đây',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: homeViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : nearbyProviders.isEmpty
                        ? const Center(
                            child: Text(
                              'Không tìm thấy thợ nào gần đây',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : Column(
                            children: nearbyProviders.map((provider) {
                              // Lấy thông tin Category của dịch vụ đầu tiên
                              String? categoryName;
                              String? categoryIcon;
                              String priceUnit = 'giờ'; // Default

                              if (provider.serviceIds.isNotEmpty) {
                                final firstServiceId =
                                    provider.serviceIds.first;
                                // Find service
                                try {
                                  final service = servicesViewModel.allServices
                                      .firstWhere(
                                          (s) => s.id == firstServiceId);

                                  priceUnit = service.priceUnit;

                                  // Find category
                                  final category = servicesViewModel.categories
                                      .firstWhere(
                                          (c) => c.id == service.categoryId);

                                  categoryName = category.name;
                                  categoryIcon = category.iconName;
                                } catch (_) {
                                  // Ignore not found
                                }
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: WorkerCard(
                                  name: provider.name,
                                  imageUrl: provider.avatarUrl,
                                  rating: provider.rating,
                                  reviews: provider.reviewCount,
                                  distance: homeViewModel
                                      .getDistanceString(provider.id),
                                  price:
                                      '${AppFormatters.formatCompactCurrency(provider.price.toDouble())}/${priceUnit == 'giờ' ? 'h' : priceUnit}',
                                  categoryName: categoryName,
                                  categoryIcon: categoryIcon,
                                  onTapCard: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProviderDetailScreen(
                                          provider: provider,
                                          isViewOnly: true,
                                          canBookDirect: true,
                                        ),
                                      ),
                                    );
                                  },
                                  onBook: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Tính năng đặt lịch trực tiếp với ${provider.name} đang phát triển'),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
              ),
              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
