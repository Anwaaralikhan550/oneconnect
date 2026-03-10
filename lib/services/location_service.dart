import '../utils/api_exception.dart';
import 'api_client.dart';

class LocationCityGroup {
  final String country;
  final String city;
  final List<String> areas;

  const LocationCityGroup({
    required this.country,
    required this.city,
    required this.areas,
  });

  factory LocationCityGroup.fromJson(Map<String, dynamic> json) {
    return LocationCityGroup(
      country: (json['country'] ?? 'Pakistan').toString(),
      city: (json['city'] ?? '').toString(),
      areas: (json['areas'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList(),
    );
  }
}

class LocationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<LocationCityGroup>> getLocations() async {
    try {
      final response = await _apiClient.get('/locations');
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return data.entries.map((entry) {
          final areas = (entry.value as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList();
          return LocationCityGroup(
            country: 'Pakistan',
            city: entry.key,
            areas: areas,
          );
        }).toList();
      }
      return const [];
    } catch (e) {
      throw ApiException('Failed to load locations: $e');
    }
  }
}
