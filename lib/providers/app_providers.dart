import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/permission/viewmodel/permission_viewmodel.dart';
import '../features/auth/viewmodel/auth_viewmodel.dart';
import '../features/auth/data/repositories/auth_repository.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider(create: (_) => AuthRepository()),

        // ViewModels
        ChangeNotifierProvider(create: (_) => PermissionViewModel()),
        ChangeNotifierProxyProvider<AuthRepository, AuthViewModel>(
          create: (context) => AuthViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
          update: (context, repository, previous) =>
              previous ?? AuthViewModel(authRepository: repository),
        ),
      ],
      child: child,
    );
  }
}
