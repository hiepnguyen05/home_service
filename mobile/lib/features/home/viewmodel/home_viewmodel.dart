import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/distance_service.dart';
import '../../provider/data/models/provider_model.dart';
import '../../provider/data/repositories/provider_repository.dart';
import '../data/models/banner_model.dart';
import '../data/repositories/banner_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ProviderRepository _providerRepository;
  final BannerRepository _bannerRepository;

  List<ProviderModel> _nearbyProviders = [];
  List<BannerModel> _banners = [];
  Map<String, double> _providerDistances = {}; // Cache distance km
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentPosition;

  HomeViewModel({
    required ProviderRepository providerRepository,
    required BannerRepository bannerRepository,
  })  : _providerRepository = providerRepository,
        _bannerRepository = bannerRepository {
    _init();
  }

  List<ProviderModel> get nearbyProviders => _nearbyProviders;
  List<BannerModel> get banners => _banners;
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
      // 1. Fetch Banners
      _banners = await _bannerRepository.getActiveBanners();
      notifyListeners(); // Notify UI as soon as banners are ready

      // 2. Get current location
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

      // 3. Fetch all providers
      final allProviders = await _providerRepository.getProviders();

      // 4. Filter and Sort by Distance using DistanceService
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
