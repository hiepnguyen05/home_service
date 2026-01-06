import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/permission/viewmodel/permission_viewmodel.dart';
import '../features/auth/viewmodel/auth_viewmodel.dart';
import '../features/profile/viewmodel/profile_viewmodel.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PermissionViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: child,
    );
  }
}