import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../utils/api_exception.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _service = BookingService();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  List<BookingModel> _bookings = [];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  List<BookingModel> get bookings => _bookings;

  Future<bool> createBooking({
    required String providerId,
    required String serviceType,
    required DateTime bookingDate,
    double? userLatitude,
    double? userLongitude,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final booking = await _service.createBooking(
        providerId: providerId,
        serviceType: serviceType,
        bookingDate: bookingDate,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
      );
      _bookings = [booking, ..._bookings];
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateStatus(bookingId: bookingId, status: status);
      _bookings = _bookings
          .map((b) => b.bookingId == bookingId ? updated : b)
          .toList();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyBookings({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _service.getMyBookings(status: status);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
