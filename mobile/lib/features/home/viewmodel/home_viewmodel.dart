import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/distance_service.dart';
import '../../provider/data/models/provider_model.dart';
import '../../provider/data/repositories/provider_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ProviderRepository _providerRepository;

  List<ProviderModel> _nearbyProviders = [];
  Map<String, double> _providerDistances = {}; // Cache distance km
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentPosition;

  HomeViewModel({required ProviderRepository providerRepository})
      : _providerRepository = providerRepository {
    _init();
  }

  List<ProviderModel> get nearbyProviders => _nearbyProviders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String getDistanceString(String providerId) {
    if (_providerDistances.containsKey(providerId)) {
      return '${_providerDistances[providerId]!.toStringAsFixed(1)}km';
    }
    return 'Unknown';
  }

  Future<void> _init() async {
    _setLoading(true);
    try {
      // 1. Get current location
      // Note: In real app, we should check permission using PermissionViewModel
      // Here we assume permission is granted or handle error nicely
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      } catch (e) {
        print("Error getting location: $e");
        // Fallback location (Hanoi center)
        _currentPosition = Position(
            longitude: 105.854444,
            latitude: 21.028511,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0);
      }

      // 2. Fetch all providers
      final allProviders = await _providerRepository.getProviders();

      // 3. Filter and Sort by Distance using DistanceService
      if (_currentPosition != null) {
        final results = DistanceService.findNearestItemsWithDistance(
          originLat: _currentPosition!.latitude,
          originLng: _currentPosition!.longitude,
          items: allProviders,
          getLat: (p) => p.latitude,
          getLng: (p) => p.longitude,
          radiusKm: 20.0, // 20km radius
        );

        _nearbyProviders =
            results.map((e) => e['data'] as ProviderModel).toList();

        // Cache distances
        for (var item in results) {
          final p = item['data'] as ProviderModel;
          _providerDistances[p.id] = item['distance'] as double;
        }
      } else {
        _nearbyProviders = allProviders;
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("HomeViewModel Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
