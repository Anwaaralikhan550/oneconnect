import '../models/booking_model.dart';
import 'api_client.dart';

class BookingService {
  final ApiClient _api = ApiClient();

  Future<BookingModel> createBooking({
    required String providerId,
    required String serviceType,
    required DateTime bookingDate,
    double? userLatitude,
    double? userLongitude,
  }) async {
    final response = await _api.post(
      '/bookings',
      auth: true,
      body: {
        'providerId': providerId,
        'serviceType': serviceType.toUpperCase(),
        'bookingDate': bookingDate.toUtc().toIso8601String(),
        if (userLatitude != null) 'userLatitude': userLatitude,
        if (userLongitude != null) 'userLongitude': userLongitude,
      },
    );
    return BookingModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<BookingModel>> getMyBookings({String? status}) async {
    final query = <String, String>{};
    if (status != null && status.trim().isNotEmpty) {
      query['status'] = status.trim().toUpperCase();
    }
    final response = await _api.get(
      '/bookings/me',
      auth: true,
      queryParams: query.isEmpty ? null : query,
    );
    final data = response['data'] as List? ?? const [];
    return data
        .whereType<Map>()
        .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<BookingModel> updateStatus({
    required String bookingId,
    required String status,
  }) async {
    final response = await _api.patch(
      '/bookings/$bookingId/status',
      auth: true,
      body: {'status': status.toUpperCase()},
    );
    return BookingModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
