import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile/features/provider/data/models/provider_model.dart';
import 'package:mobile/features/provider/data/repositories/provider_repository.dart';
import 'package:mobile/core/services/location_service.dart';

/// ViewModel xử lý logic nghiệp vụ cho Dashboard và các tính năng chính của Nhà cung cấp
class ProviderViewModel extends ChangeNotifier {
  final ProviderRepository _providerRepo;
  final BookingRepository _bookingRepo;

  ProviderViewModel({
    ProviderRepository? providerRepo,
    BookingRepository? bookingRepo,
  })  : _providerRepo = providerRepo ?? ProviderRepository(),
        _bookingRepo = bookingRepo ?? BookingRepository();

  // --- Trạng thái (State) ---
  bool _isLoading = true;
  bool _isOnline = false;
  ProviderModel? _provider;
  List<BookingModel> _bookings = [];
  StreamSubscription<QuerySnapshot>? _jobRequestSubscription;

  // Stream controller để thông báo cho UI khi có yêu cầu công việc mới (để hiện Dialog)
  final _newJobRequestController = StreamController<BookingModel>.broadcast();
  Stream<BookingModel> get newJobRequestStream =>
      _newJobRequestController.stream;

  // --- Getters truy cập trạng thái ---
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  ProviderModel? get provider => _provider;
  List<BookingModel> get bookings => _bookings;

  // --- Các thuộc tính tính toán (Computed Properties) cho UI ---

  /// Số lượng công việc trong ngày hôm nay
  int get jobsTodayCount {
    final now = DateTime.now();
    return _bookings
        .where((b) =>
            b.scheduleAt.year == now.year &&
            b.scheduleAt.month == now.month &&
            b.scheduleAt.day == now.day &&
            b.status != BookingStatus.cancelled)
        .length;
  }

  /// Số lượng công việc đang hoạt động (đã xác nhận)
  int get activeJobCount {
    return _bookings.where((b) => b.status == BookingStatus.confirmed).length;
  }

  /// Tổng thu nhập trong ngày hôm nay
  double get incomeToday {
    final now = DateTime.now();
    return _bookings
        .where((b) =>
            b.status == BookingStatus.completed &&
            b.scheduleAt.year == now.year &&
            b.scheduleAt.month == now.month &&
            b.scheduleAt.day == now.day)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Tổng thu nhập trong tháng hiện tại
  double get incomeMonth {
    final now = DateTime.now();
    return _bookings
        .where((b) =>
            b.status == BookingStatus.completed &&
            b.scheduleAt.year == now.year &&
            b.scheduleAt.month == now.month)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Danh sách 5 công việc sắp tới gần nhất
  List<BookingModel> get upcomingJobs {
    final now = DateTime.now();
    final upcoming = _bookings.where((b) {
      // 1. Phải là các trạng thái "đang xử lý" hoặc "sắp tới"
      final isValidStatus = b.status == BookingStatus.pending ||
          b.status == BookingStatus.accepted ||
          b.status == BookingStatus.confirmed ||
          b.status == BookingStatus.waitingPayment;

      // 2. Phải là thời gian trong tương lai
      final isFuture = b.scheduleAt.isAfter(now);

      return isValidStatus && isFuture;
    }).toList();

    // Sắp xếp thời gian tăng dần (việc gần nhất lên đầu)
    upcoming.sort((a, b) => a.scheduleAt.compareTo(b.scheduleAt));
    return upcoming.take(5).toList();
  }

  // --- Các phương thức nghiệp vụ (Methods) ---

  /// Tải dữ liệu ban đầu cho Dashboard
  Future<void> loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    // Nếu chưa đăng nhập, kết thúc loading
    if (userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Lấy thông tin Provider và danh sách Booking song song hoặc tuần tự
      final provider = await _providerRepo.getProviderById(userId);
      final bookings = await _bookingRepo.getBookingProviderId(userId);

      _provider = provider;
      _isOnline = provider?.isOnline ?? false;
      _bookings = bookings;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu dashboard: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Làm mới dữ liệu (Pull-to-refresh)
  Future<void> refreshData() async {
    await loadData();
  }

  /// Bắt đầu lắng nghe các yêu cầu công việc mới theo thời gian thực
  void startListeningToJobRequests() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Hủy đăng ký cũ nếu có để tránh memory leak hoặc duplicate listener
    _jobRequestSubscription?.cancel();

    _jobRequestSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('providerId', isEqualTo: userId)
        .where('status', isEqualTo: BookingStatus.pending)
        .snapshots()
        .listen((snapshot) {
      // Lọc ra các documents được THÊM MỚI (không lấy docs đã có sẵn)
      final addedDocs = snapshot.docChanges
          .where((change) => change.type == DocumentChangeType.added)
          .toList();

      if (addedDocs.isNotEmpty) {
        final doc = addedDocs.last.doc;
        final booking = BookingModel.fromFirestore(doc);

        // Kiểm tra thời gian tạo booking: Chỉ thông báo nếu booking được tạo trong vòng 2 phút gần đây
        // Điều này giúp tránh việc hiển thị lại các booking pending cũ mỗi khi khởi động app
        final diff = DateTime.now().difference(booking.createdAt).inSeconds;
        debugPrint(
            "⏱️ [ProviderViewModel] Chênh lệch thời gian booking mới: $diff giây");

        if (diff < 120) {
          _newJobRequestController.add(booking);
        }
      }
    }, onError: (e) {
      debugPrint("❌ Lỗi Stream Job Request: $e");
    });
  }

  /// Dừng lắng nghe yêu cầu công việc
  void stopListeningToJobRequests() {
    _jobRequestSubscription?.cancel();
  }

  /// Chuyển đổi trạng thái Online/Offline
  /// [value]: true để Bật Online, false để Tắt
  /// [onError]: Callback để UI hiển thị lỗi (String message)
  /// [onSuccess]: Callback để UI hiển thị thông báo thành công (String message)
  Future<bool> toggleOnlineStatus(bool value,
      {Function(String)? onError, Function(String)? onSuccess}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      onError?.call("Bạn cần đăng nhập để sử dụng tính năng này.");
      return false;
    }

    if (value) {
      // --- BẬT TRẠNG THÁI ONLINE ---
      try {
        // 1. Kiểm tra hồ sơ người dùng (bắt buộc có Avatar và SĐT)
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (!userDoc.exists) {
          onError?.call("Không tìm thấy hồ sơ người dùng.");
          return false;
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        final avatar = userData['avatar_url'];
        final String? phone = userData['phone'];

        List<String> missing = [];
        if (avatar == null || (avatar as String).isEmpty)
          missing.add("Ảnh đại diện");
        if (phone == null || phone.isEmpty) missing.add("Số điện thoại");

        if (missing.isNotEmpty) {
          onError?.call(
              "Để nhận việc, bạn cần bổ sung:\n- ${missing.join('\n- ')}\n\nVui lòng vào mục Cá nhân để cập nhật.");
          return false;
        }

        // 2. Lấy vị trí hiện tại của thiết bị
        final position = await LocationService.getCurrentPosition();
        if (position == null) {
          onError?.call(
              "Không thể lấy vị trí hiện tại. Vui lòng kiểm tra quyền truy cập vị trí và GPS.");
          return false;
        }

        final locationData = await LocationService.getLocationDetails(
            position.latitude, position.longitude);
        final address = locationData['full_address'] ?? "Vị trí không xác định";
        final currentUser = FirebaseAuth.instance.currentUser;

        // 3. Cập nhật trạng thái và vị trí lên hệ thống (Firestore)
        final success = await _providerRepo.updateProviderStatus(
          providerId: userId,
          isOnline: true,
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
          name: currentUser?.displayName,
          avatarUrl: avatar ?? currentUser?.photoURL,
        );

        if (success) {
          _isOnline = true;
          notifyListeners();
          onSuccess?.call("Bạn đang online tại:\n$address");
          return true;
        } else {
          onError?.call("Không thể cập nhật trạng thái online.");
          return false;
        }
      } catch (e) {
        onError?.call("Đã xảy ra lỗi khi bật online: $e");
        return false;
      }
    } else {
      // --- TẮT TRẠNG THÁI ONLINE ---
      final success = await _providerRepo.updateProviderStatus(
        providerId: userId,
        isOnline: false,
      );

      if (success) {
        _isOnline = false;
        notifyListeners();
        return true;
      } else {
        onError?.call("Không thể tắt trạng thái online.");
        return false;
      }
    }
  }

  /// Xử lý logic khi hoàn thành công việc
  /// [booking]: Đơn hàng cần hoàn thành
  /// [quantity]: Số lượng thực tế (giờ làm hoặc số lượng sản phẩm)
  Future<void> handleJobCompletion(BookingModel booking, double quantity,
      {Function(String)? onSuccess, Function(String)? onError}) async {
    try {
      // 1. Tính toán lại tổng tiền dựa trên đơn giá và số lượng thực tế
      // Logic: Nếu booking có quantity > 0, ta tính đơn giá = tổng tiền / quantity cũ.
      // Nếu không (trường hợp giờ), giả sử totalPrice ban đầu là đơn giá cho 1 giờ.
      double unitPrice = booking.totalPrice;
      if (booking.quantity > 0) {
        unitPrice = booking.totalPrice / booking.quantity;
      }

      final double newTotal = unitPrice * quantity;

      // 2. Xác định trạng thái tiếp theo của đơn hàng
      String nextStatus = BookingStatus.completed;
      if (booking.priceUnit == 'giờ') {
        // Nếu tính tiền theo giờ, cần chuyển sang trạng thái chờ thanh toán
        // để khách hàng xác nhận hoặc thanh toán khoản phát sinh nếu có
        nextStatus = BookingStatus.waitingPayment;
      }

      // 3. Cập nhật dữ liệu lên Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking.id)
          .update({
        'status': nextStatus,
        'totalPrice': newTotal,
        'quantity': quantity,
      });

      // 4. Làm mới dữ liệu Dashboard
      await loadData();
      onSuccess?.call("Đã cập nhật hoàn thành đơn hàng!");
    } catch (e) {
      onError?.call("Lỗi khi cập nhật đơn hàng: $e");
    }
  }

  @override
  void dispose() {
    _jobRequestSubscription?.cancel();
    _newJobRequestController.close();
    super.dispose();
  }
}
