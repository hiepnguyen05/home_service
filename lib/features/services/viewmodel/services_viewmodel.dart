import 'dart:async';
import 'package:flutter/material.dart';
import '../data/repositories/service_repository.dart';
import '../data/models/category_model.dart';
import '../data/models/service_model.dart';

class ServicesViewModel extends ChangeNotifier {
  final ServiceRepository _repository;

  List<CategoryModel> _categories = [];
  List<ServiceModel> _allServices = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription? _categoriesSubscription;
  StreamSubscription? _servicesSubscription;

  ServicesViewModel({required ServiceRepository repository})
      : _repository = repository {
    _init();
  }

  // Getters
  List<CategoryModel> get categories => _categories;
  List<ServiceModel> get allServices => _allServices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Init listeners
  void _init() {
    _setLoading(true);

    _categoriesSubscription = _repository.getCategories().listen(
      (data) {
        _categories = data;
        _errorMessage = null;
        _setLoading(false); // Only set not loading after at least one success?
        // Or wait for both? Let's just notify.
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = "Failed to load categories: $e";
        _setLoading(false);
        print("Category Error: $e");
      },
    );

    // Fetch all active services initially (e.g. for Popular list or just caching)
    _servicesSubscription = _repository.getServices().listen((data) {
      _allServices = data;
      notifyListeners();
    }, onError: (e) {
      print("Services Error: $e");
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Helper method to get services by category from the local list
  // avoiding new DB calls unless necessary
  List<ServiceModel> getServicesByCategory(String categoryId) {
    return _allServices.where((s) => s.categoryId == categoryId).toList();
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _servicesSubscription?.cancel();
    super.dispose();
  }
}
