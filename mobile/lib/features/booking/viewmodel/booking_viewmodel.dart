import 'package:flutter/foundation.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/booking/data/repositories/booking_repository.dart';

class BookingViewmodel extends ChangeNotifier {
  final BookingRepository _bookingRepository = BookingRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> createBooking({
    required String customerId,
    required String serviceId,
    required String address,
    required DateTime scheduleAt,
    double totalPrice = 0,
    String paymentMethod = 'COD',
  }) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      final String bookingId = 'BK-${DateTime.now().millisecondsSinceEpoch}';
      final newBooking = BookingModel(
        id: bookingId,
        customerId: customerId,
        serviceId: serviceId,
        providerId: '',
        scheduleAt: scheduleAt,
        address: address,
        status: BookingStatus.pending,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );
      await _bookingRepository.createBooking(newBooking);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
