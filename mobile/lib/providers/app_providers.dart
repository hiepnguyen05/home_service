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
      ],
      child: child,
    );
  }
}
