import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_categories.dart';
import '../widgets/promotion_banner.dart';
import '../widgets/worker_card.dart';

import 'package:provider/provider.dart';
import '../../../services/viewmodel/services_viewmodel.dart';
import '../../../services/view/screens/services_list_screen.dart';

// ... (imports)

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access ViewModel
    final servicesViewModel = context.watch<ServicesViewModel>();
    final categories = servicesViewModel.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeAppBar(
                userName: 'An',
                // avatarUrl will use placeholder if null
                onNotificationTap: () {
                  // TODO: Handle notification tap
                },
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
              const PromotionBanner(),
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
                child: Column(
                  children: [
                    WorkerCard(
                      name: 'Lê Văn Mạnh',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAtnXswSw0blA-dQLG2GXyoGfg6cKyGPS-EsPECwLSGzXB4TTR1bgZrhtlG7STS3RI8V0cj2ylO1WwHjkp5uuRxVgQzUFyqcfW5etnMYIxoDYA6H_cgMD8iZnFmVw-SlQzAFRp6dVCT1dhnFftrAkTnZbhQQIwQcLJ-oFt97SVKWR7MV5Hh1lfEutgCboUkHJWfXsFi_FXvj3oA561ta43KkFdIsov0CFy_Y31AR8BMBBew_yWT1FcqTBwtJsR6KVWbo-J_zWNY-Rs',
                      rating: 4.9,
                      reviews: 128,
                      distance: '2.1km',
                      price: '250k/h',
                      onBook: () {
                        // TODO: Handle booking
                      },
                    ),
                    const SizedBox(height: 16),
                    WorkerCard(
                      name: 'Trần Thị Bích',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDU6k__qFnv2mUqd7m5nQ2ZE-K_oBIMQkjGQq_z6p3NrxHqCJqbsMy6gGoHqoM4ecvmmpyC3I9X0RcVB7kp4xLFqR6OVsc2ppz4qaKaZ1XoW6stOVIVArtwA0iA4OlBLLcPfESiieXkPdqmfXf1Qvenbpul4dcYDn7IzGZUWh0mT8Tz5uRXac2pZ-Jik8jZaZPYyzgN_DaV7TaJ-RaPfdZM7zl0Prf2MBSoIoX_pEQ1zlW8LhBSEwAsbVoLW-LpRpep_jzohQYlL_U',
                      rating: 4.8,
                      reviews: 96,
                      distance: '3.5km',
                      price: '220k/h',
                      onBook: () {
                        // TODO: Handle booking
                      },
                    ),
                    const SizedBox(height: 24), // Bottom padding
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
