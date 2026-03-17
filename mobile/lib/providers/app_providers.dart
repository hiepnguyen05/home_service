import 'package:flutter/material.dart';
import 'package:mobile/features/address/data/repositories/address_repository.dart';
import 'package:mobile/features/address/viewmodel/address_viewmodel.dart';
import 'package:provider/provider.dart';
import '../features/permission/viewmodel/permission_viewmodel.dart';
import '../features/auth/viewmodel/auth_viewmodel.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/services/data/repositories/service_repository.dart';
import '../features/services/viewmodel/services_viewmodel.dart';
import '../features/partner/data/repositories/partner_repository.dart';
import '../features/partner/viewmodel/partner_viewmodel.dart';
import '../features/provider/data/repositories/provider_repository.dart';
import '../features/booking/data/repositories/booking_repository.dart';
import '../features/booking/viewmodel/booking_viewmodel.dart';
import '../features/home/viewmodel/home_viewmodel.dart';
import '../features/home/data/repositories/banner_repository.dart';
import '../features/chat/viewmodel/chat_list_viewmodel.dart';
import '../features/booking/data/repositories/review_repository.dart';
import '../features/booking/viewmodel/review_viewmodel.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider(create: (_) => AuthRepository()),
        Provider(create: (_) => ServiceRepository()),
        Provider(create: (_) => PartnerRepository()),
        Provider(create: (_) => AddressRepository()),
        Provider(create: (_) => ProviderRepository()),
        Provider(create: (_) => BannerRepository()),
        Provider(create: (_) => ReviewRepository()),
        // ViewModels
        ChangeNotifierProvider(create: (_) => PermissionViewModel()),
        ChangeNotifierProvider(create: (_) => AddressViewModel()),
        ChangeNotifierProxyProvider<AuthRepository, AuthViewModel>(
          create: (context) => AuthViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
          update: (context, repository, previous) =>
              previous ?? AuthViewModel(authRepository: repository),
        ),
        ChangeNotifierProxyProvider<ServiceRepository, ServicesViewModel>(
          create: (context) => ServicesViewModel(
            repository: context.read<ServiceRepository>(),
          ),
          update: (context, repository, previous) =>
              previous ?? ServicesViewModel(repository: repository),
        ),
        ChangeNotifierProxyProvider<PartnerRepository, PartnerViewModel>(
          create: (context) => PartnerViewModel(
            repository: context.read<PartnerRepository>(),
          ),
          update: (context, repository, previous) =>
              previous ?? PartnerViewModel(repository: repository),
        ),
        ChangeNotifierProxyProvider2<ProviderRepository, BannerRepository,
            HomeViewModel>(
          create: (context) => HomeViewModel(
            providerRepository: context.read<ProviderRepository>(),
            bannerRepository: context.read<BannerRepository>(),
          ),
          update: (context, providerRepo, bannerRepo, previous) =>
              previous ??
              HomeViewModel(
                providerRepository: providerRepo,
                bannerRepository: bannerRepo,
              ),
        ),
        // Booking
        Provider(create: (_) => BookingRepository()),
        ChangeNotifierProxyProvider3<ProviderRepository, ServiceRepository,
            BookingRepository, BookingViewModel>(
          create: (context) => BookingViewModel(
            providerRepository: context.read<ProviderRepository>(),
            serviceRepository: context.read<ServiceRepository>(),
            bookingRepository: context.read<BookingRepository>(),
          ),
          update: (context, providerRepo, serviceRepo, bookingRepo, previous) =>
              previous ??
              BookingViewModel(
                providerRepository: providerRepo,
                serviceRepository: serviceRepo,
                bookingRepository: bookingRepo,
              ),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, ChatListViewModel?>(
          create: (context) => null,
          update: (context, auth, previous) {
            final userId = auth.currentUser?.uid;
            if (userId == null) return null;
            if (previous?.userId == userId) return previous;
            return ChatListViewModel(userId: userId);
          },
        ),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
      ],
      child: child,
    );
  }
}
