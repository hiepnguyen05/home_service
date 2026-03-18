import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../screens/provider_dashboard_screen.dart';
import '../screens/provider_history_screen.dart';
import '../../../wallet/view/screens/wallet_screen.dart';
import '../../../profile/view/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/provider_viewmodel.dart';
import '../../../wallet/data/repositories/wallet_repository.dart';
import '../../../../core/widgets/provider_bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../wallet/viewmodel/wallet_viewmodel.dart';

class ProviderMainScreen extends StatefulWidget {
  const ProviderMainScreen({super.key});

  @override
  State<ProviderMainScreen> createState() => _ProviderMainScreenState();
}

class _ProviderMainScreenState extends State<ProviderMainScreen> {
  late ProviderViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProviderViewModel(
      walletRepo: context.read<WalletRepository>(),
    );
    _viewModel.loadData();
    _viewModel.startListeningToJobRequests();

    // Khởi tạo WalletViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final walletVm = context.read<WalletViewModel>();
        walletVm.initWallet(userId);
        walletVm.listenToWallet(userId);
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    const ProviderDashboardScreen(),
    const ProviderHistoryScreen(),
    const WalletScreen(),
    const ProfileScreen(isProviderMode: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ProviderViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            body: IndexedStack(
              index: vm.currentTabIndex,
              children: _screens,
            ),
            bottomNavigationBar: ProviderBottomNav(
              currentIndex: vm.currentTabIndex,
              onTap: (index) {
                vm.setCurrentTabIndex(index);
              },
            ),
          );
        },
      ),
    );
  }
}
