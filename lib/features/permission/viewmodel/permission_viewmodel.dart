import 'package:flutter/foundation.dart';

class PermissionViewModel extends ChangeNotifier {
  bool _isLocationPermissionGranted = false;
  bool _isNotificationPermissionGranted = false;
  bool _isLoading = false;

  bool get isLocationPermissionGranted => _isLocationPermissionGranted;
  bool get isNotificationPermissionGranted => _isNotificationPermissionGranted;
  bool get isLoading => _isLoading;

  Future<void> requestLocationPermission() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual location permission request
      // Using permission_handler package
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      _isLocationPermissionGranted = true;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestNotificationPermission() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual notification permission request
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      _isNotificationPermissionGranted = true;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestAllPermissions() async {
    await requestLocationPermission();
    await requestNotificationPermission();
  }

  void skipPermissions() {
    // Handle skip logic
    debugPrint('User skipped permissions');
  }
}