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

  // Getters (Bộ truy cập)
  List<CategoryModel> get categories => _categories;
  List<ServiceModel> get allServices => _allServices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Khởi tạo các listeners
  void _init() {
    _setLoading(true);

    _categoriesSubscription = _repository.getCategories().listen(
      (data) {
        _categories = data;
        _errorMessage = null;
        _setLoading(false); // Chỉ tắt loading khi có dữ liệu thành công
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = "Lỗi khi tải danh mục: $e";
        _setLoading(false);
        print("Lỗi danh mục: $e");
      },
    );

    // Lấy tất cả dịch vụ đang hoạt động ban đầu (ví dụ: cho danh sách Phổ biến hoặc caching)
    _servicesSubscription = _repository.getServices().listen((data) {
      _allServices = data;
      notifyListeners();
    }, onError: (e) {
      print("Lỗi dịch vụ: $e");
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Phương thức hỗ trợ lấy dịch vụ theo danh mục từ danh sách cục bộ
  // tránh gọi DB mới trừ khi cần thiết
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
