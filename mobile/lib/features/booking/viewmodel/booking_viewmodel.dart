import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Removed
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

// --- Kết quả trả về của quá trình đặt lịch ---
sealed class BookingResult {}

class BookingSuccess extends BookingResult {
  final BookingModel booking;
  BookingSuccess(this.booking);
}

class BookingRequiresPayment extends BookingResult {
  final BookingModel booking;
  final double amount;
  final String orderInfo;
  BookingRequiresPayment(this.booking, this.amount, this.orderInfo);
}

class BookingFailure extends BookingResult {
  final String error;
  BookingFailure(this.error);
}
// ----------------------------------------------

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

  int _quantity = 1; // NEW State

  // Getters
  List<ProviderModel> get providers => _providers;
  bool get isLoading => _isLoading;
  bool get isCreatingBooking => _isCreatingBooking;
  String get priceUnit => _priceUnit;
  String get serviceName => _serviceName;
  ProviderFilter get selectedFilter => _selectedFilter;
  PaymentMethod get paymentMethod => _paymentMethod;
  String? get error => _error;

  int get quantity => _quantity; // NEW Getter

  BookingModel? _currentBooking;
  BookingModel? get currentBooking => _currentBooking;

  /// Set price unit from external source (e.g. previous screen)
  void setPriceUnit(String unit) {
    _priceUnit = unit;
    if (_priceUnit == 'giờ') {
      _paymentMethod = PaymentMethod.cash;
    }
    notifyListeners();
  }

  /// Load providers và service data
  Future<void> loadProviders({
    required double userLat,
    required double userLng,
    String? serviceId,
    DateTime? bookingTime, // NEW
  }) async {
    _isLoading = true;
    _error = null;
    _quantity = 1; // Reset quantity
    notifyListeners();

    try {
      // 1. Load service data để lấy priceUnit
      if (serviceId != null) {
        await _loadServiceData(serviceId);
      }
      // 2. Load providers
      List<ProviderModel> allProviders;
      // if (bookingTime != null) {
      //   // Filter by availability if time is known
      //   allProviders =
      //       await _providerRepository.getAvailableProviders(bookingTime);
      // } else {
      allProviders = await _providerRepository.getProviders();
      // }

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

      // Nếu là giờ -> Chỉ cho phép Tiền mặt (Trả sau)
      if (_priceUnit == 'giờ') {
        _paymentMethod = PaymentMethod.cash;
      }
    } catch (e) {
      print("⚠️ [VM] Không lấy được service data: $e");
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
    // Nếu là giờ -> Không cho đổi sang online (vì chưa chốt giá)
    if (_priceUnit == 'giờ' && method == PaymentMethod.momo) {
      return;
    }
    _paymentMethod = method;
    notifyListeners();
  }

  /// Sắp xếp providers theo filter đã chọn
  void _sortProviders(double userLat, double userLng) {
    if (_providers.isEmpty) return;

    switch (_selectedFilter) {
      case ProviderFilter.nearest:
        _providers.sort((a, b) {
          final distA = DistanceService.calculateDistance(
              userLat, userLng, a.latitude, a.longitude);
          final distB = DistanceService.calculateDistance(
              userLat, userLng, b.latitude, b.longitude);
          return distA.compareTo(distB);
        });
        break;
      case ProviderFilter.topRated:
        _providers.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ProviderFilter.lowPrice:
        _providers.sort((a, b) => a.price.compareTo(b.price));
        break;
    }
  }

  /// Tăng giảm số lượng
  void updateQuantity(int delta) {
    int newQuantity = _quantity + delta;
    if (newQuantity < 1) newQuantity = 1;
    _quantity = newQuantity;
    notifyListeners();
  }

  /// Tính tổng tiền
  double calculateTotalPrice(double providerPrice) {
    const platformFee = 0.0;
    // Nếu là giờ, giá hiển thị là giá/giờ, tổng tiền ban đầu = giá * 1 giờ (ước tính)
    // Nếu là đơn vị khác, tổng tiền = giá * số lượng
    if (_priceUnit == 'giờ') {
      return providerPrice + platformFee; // Giá 1 giờ
    }
    return (providerPrice * _quantity) + platformFee;
  }

  /// Gửi yêu cầu đặt lịch (Bước 1: Pending -> Chờ Provider Confirm)
  Future<BookingModel?> createBookingRequest({
    required ProviderModel provider,
    required String serviceId,
    required DateTime scheduledAt,
    required String address,
    required double totalPrice,
    required PaymentMethod paymentMethod,
    String? note,
    required double userLat, // NEW
    required double userLng, // NEW
  }) async {
    _isCreatingBooking = true;
    _error = null;
    notifyListeners();

    try {
      print(
          "🚀 [BookingVM] Creating request to Provider: ${provider.id} | Service: $serviceId");

      // Convert Payment Method
      final paymentMethodStr = paymentMethod == PaymentMethod.cash
          ? BookingPaymentMethod.COD
          : BookingPaymentMethod.eWallet;

      // Create Booking object
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Vui lòng đăng nhập");

      final bookingId = const Uuid().v4();
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
        note: note ?? "",
        quantity: _quantity,
        priceUnit: _priceUnit,
        latitude: userLat, // Save coordinates
        longitude: userLng, // Save coordinates
      );

      await _bookingRepository.createBooking(booking);

      print(
          "✅ [BookingVM] Booking Created: ${booking.id} | Status: ${booking.status}");
      _currentBooking = booking; // Assign to state
      return booking;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isCreatingBooking = false;
      notifyListeners();
    }
  }
  // --- Real-time Booking Logic ---

  /// Helper cho WaitingForProviderDialog (Legacy)
  Stream<BookingModel> streamBooking(String bookingId) {
    return _bookingRepository.streamBooking(bookingId);
  }

  StreamSubscription<BookingModel>? _trackingSubscription;
  BookingModel? _trackingBooking;
  BookingModel? get trackingBooking => _trackingBooking;

  /// Bắt đầu theo dõi đơn hàng (Real-time)
  void startTrackingBooking(String bookingId) {
    stopTrackingBooking(); // Cancel existing if any
    _error = null;
    notifyListeners();

    try {
      _trackingSubscription =
          _bookingRepository.streamBooking(bookingId).listen((booking) {
        _trackingBooking = booking;
        notifyListeners();
      }, onError: (e) {
        _error = "Lỗi theo dõi đơn hàng: $e";
        notifyListeners();
      });
    } catch (e) {
      _error = "Không thể theo dõi đơn hàng: $e";
      notifyListeners();
    }
  }

  /// Dừng theo dõi
  void stopTrackingBooking() {
    _trackingSubscription?.cancel();
    _trackingSubscription = null;
    _trackingBooking = null;
  }

  @override
  void dispose() {
    stopTrackingBooking();
    super.dispose();
  }

  /// Hủy đơn hàng (khi timeout hoặc user hủy)
  Future<void> cancelBooking(String bookingId, {String reason = ""}) async {
    try {
      await _bookingRepository.updateBookingStatus(
          bookingId, BookingStatus.cancelled);
      // Note is updated separately if needed, or update repo to support note
    } catch (e) {
      debugPrint("Error cancelling booking: $e");
    }
  }
}
