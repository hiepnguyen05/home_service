import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../routes/app_router.dart';
import '../../../home/view/screens/home_screen.dart';
import '../../../profile/view/screens/profile_screen.dart';
import '../../../booking/view/screens/booking_history_screen.dart';
import '../../../notification/view/screens/notification_screen.dart';
import '../../../notification/data/repositories/notification_repository.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  // Keys for nested navigators to handle back presses
  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // Check if the current tab is Home and it can pop
        final NavigatorState? currentState = _homeNavigatorKey.currentState;
        if (_currentIndex == 0 &&
            currentState != null &&
            currentState.canPop()) {
          currentState.pop();
          return;
        }

        // If at root of Home or other tabs, allow exiting app (or handle standard back)
        // Here we just close the app if can't pop anymore
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Home with Nested Navigation
            Navigator(
              key: _homeNavigatorKey,
              onGenerateRoute: (settings) {
                if (settings.name == AppRoutes.bookingTime) {
                  return AppRouter.generateRoute(settings);
                }
                return MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                );
              },
            ),
            // Tab 1: History
            const BookingHistoryScreen(),
            // Tab 2: Notifications
            const NotificationScreen(),
            // Tab 3: Profile
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.borderLight,
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == _currentIndex) {
                // If tapping the same tab, pop to root of that tab
                if (index == 0) {
                  _homeNavigatorKey.currentState
                      ?.popUntil((route) => route.isFirst);
                }
              } else {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'Lịch sử',
              ),
              BottomNavigationBarItem(
                icon: StreamBuilder<int>(
                  stream: NotificationRepository().streamUnreadCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      child: const Icon(Icons.notifications_outlined),
                    );
                  },
                ),
                activeIcon: StreamBuilder<int>(
                  stream: NotificationRepository().streamUnreadCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      child: const Icon(Icons.notifications),
                    );
                  },
                ),
                label: 'Thông báo',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Tài khoản',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tính năng sẽ được phát triển',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
