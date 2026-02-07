import 'package:flutter/material.dart';
import 'package:mobile/core/services/distance_service.dart';
import 'package:mobile/features/provider/data/models/provider_model.dart';
import 'package:mobile/features/provider/data/repositories/provider_repository.dart';
import 'package:mobile/features/services/data/repositories/service_repository.dart';
import 'package:mobile/features/payment/data/models/payment_method.dart';
import 'package:mobile/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../view/widgets/provider/provider_filter_bar.dart';

class BookingViewModel extends ChangeNotifier {
  final ProviderRepository _providerRepository;
  final ServiceRepository _serviceRepository;
  final BookingRepository _bookingRepository;

  BookingViewModel({
    ProviderRepository? providerRepository,
    ServiceRepository? serviceRepository,
    BookingRepository? bookingRepository,
  })  : _providerRepository = providerRepository ?? ProviderRepository(),
        _serviceRepository = serviceRepository ?? ServiceRepository(),
        _bookingRepository = bookingRepository ?? BookingRepository();

  // State
  List<ProviderModel> _providers = [];
  bool _isLoading = true;
  bool _isCreatingBooking = false;
  String _priceUnit = 'lần';
  String _serviceName = '';
  ProviderFilter _selectedFilter = ProviderFilter.nearest;
  PaymentMethod _paymentMethod = PaymentMethod.momo;
  String? _error;

  // Getters
  List<ProviderModel> get providers => _providers;
  bool get isLoading => _isLoading;
  bool get isCreatingBooking => _isCreatingBooking;
  String get priceUnit => _priceUnit;
  String get serviceName => _serviceName;
  ProviderFilter get selectedFilter => _selectedFilter;
  PaymentMethod get paymentMethod => _paymentMethod;
  String? get error => _error;

  /// Load providers và service data
  Future<void> loadProviders({
    required double userLat,
    required double userLng,
    String? serviceId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Load service data để lấy priceUnit
      if (serviceId != null) {
        await _loadServiceData(serviceId);
      }

      // 2. Load providers
      List<ProviderModel> allProviders =
          await _providerRepository.getProviders();

      // 3. Lọc theo service ID
      List<ProviderModel> filteredList = allProviders.where((p) {
        return serviceId == null || p.serviceIds.contains(serviceId);
      }).toList();

      // 4. Lọc theo khoảng cách (20km)
      final sortedProviders = DistanceService.findNearestItems<ProviderModel>(
        originLat: userLat,
        originLng: userLng,
        items: filteredList,
        getLat: (p) => p.latitude,
        getLng: (p) => p.longitude,
        radiusKm: 20.0,
      );

      _providers = sortedProviders;

      // 5. Áp dụng filter mặc định
      _sortProviders(userLat, userLng);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load service data để lấy priceUnit
  Future<void> _loadServiceData(String serviceId) async {
    try {
      final service = await _serviceRepository.getServiceById(serviceId);
      _priceUnit = service.priceUnit;
      _serviceName = service.name;
    } catch (e) {
      print("⚠️ [VM] Không lấy được service data: $e");
    }
  }

  /// Tạo đơn đặt lịch mới
  Future<BookingModel?> createBooking({
    required ProviderModel provider,
    required String serviceId,
    required DateTime scheduledAt,
    required String address,
    required double totalPrice,
  }) async {
    _isCreatingBooking = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Vui lòng đăng nhập để đặt lịch");
      }

      // Tạo booking ID
      final bookingId = const Uuid().v4();

      // Chuyển đổi PaymentMethod enum sang string cho Firestore
      final paymentMethodStr = _paymentMethod == PaymentMethod.cash
          ? BookingPaymentMethod.COD
          : BookingPaymentMethod.eWallet;

      final booking = BookingModel(
        id: bookingId,
        customerId: currentUser.uid,
        serviceId: serviceId,
        providerId: provider.id,
        scheduleAt: scheduledAt,
        address: address,
        status: BookingStatus.pending,
        totalPrice: totalPrice,
        paymentMethod: paymentMethodStr,
        createdAt: DateTime.now(),
      );

      await _bookingRepository.createBooking(booking);

      _isCreatingBooking = false;
      notifyListeners();

      return booking;
    } catch (e) {
      _error = e.toString();
      _isCreatingBooking = false;
      notifyListeners();
      return null;
    }
  }

  /// Thay đổi filter và sắp xếp lại
  void changeFilter(ProviderFilter filter, double userLat, double userLng) {
    _selectedFilter = filter;
    _sortProviders(userLat, userLng);
    notifyListeners();
  }

  /// Thay đổi phương thức thanh toán
  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  /// Sắp xếp providers theo filter đã chọn
  void _sortProviders(double userLat, double userLng) {
    if (_providers.isEmpty) return;

    switch (_selectedFilter) {
      case ProviderFilter.nearest:
        // Sắp xếp theo khoảng cách (gần nhất)
        _providers.sort((a, b) {
          final distA = DistanceService.calculateDistance(
              userLat, userLng, a.latitude, a.longitude);
          final distB = DistanceService.calculateDistance(
              userLat, userLng, b.latitude, b.longitude);
          return distA.compareTo(distB);
        });
        break;

      case ProviderFilter.topRated:
        // Sắp xếp theo đánh giá (cao nhất)
        _providers.sort((a, b) => b.rating.compareTo(a.rating));
        break;

      case ProviderFilter.lowPrice:
        // Sắp xếp theo giá (thấp nhất)
        _providers.sort((a, b) => a.price.compareTo(b.price));
        break;
    }
  }

  /// Tính tổng tiền (Ví dụ: Giá provider + Phí nền tảng)
  double calculateTotalPrice(double providerPrice) {
    const platformFee = 0.0; // Hiện tại chưa thu phí nền tảng
    return providerPrice + platformFee;
  }
}
