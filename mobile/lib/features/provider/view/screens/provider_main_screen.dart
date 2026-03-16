import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../screens/provider_dashboard_screen.dart';
import '../screens/provider_history_screen.dart';
import '../screens/provider_income_screen.dart';
import '../../../profile/view/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/provider_viewmodel.dart';
import '../../../../core/widgets/provider_bottom_nav.dart';

class ProviderMainScreen extends StatefulWidget {
  const ProviderMainScreen({super.key});

  @override
  State<ProviderMainScreen> createState() => _ProviderMainScreenState();
}

class _ProviderMainScreenState extends State<ProviderMainScreen> {
  int _currentIndex = 0;
  late ProviderViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProviderViewModel();
    _viewModel.loadData();
    _viewModel.startListeningToJobRequests();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    const ProviderDashboardScreen(),
    const ProviderHistoryScreen(),
    const ProviderIncomeScreen(),
    const ProfileScreen(isProviderMode: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: ProviderBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
