import '../models/service_provider_model.dart';
import '../models/review_model.dart';
import '../models/filter_dto.dart';
import 'api_client.dart';
import '../utils/api_exception.dart';

class ServiceProviderService {
  final ApiClient _api = ApiClient();

  Future<List<ServiceProviderModel>> getByType(
    String type, {
    FilterDto? filter,
    String? city,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{'type': type};
    params.addAll(
      (filter ?? FilterDto(page: page, limit: limit)).toQueryParams(),
    );
    if (city != null) params['city'] = city;

    final response = await _api.get('/service-providers', queryParams: params);
    final data = response['data'] as List;
    return data.map((e) => ServiceProviderModel.fromJson(e)).toList();
  }

  Future<ServiceProviderModel> getById(String id) async {
    final response = await _api.get('/service-providers/$id');
    return ServiceProviderModel.fromJson(response['data']);
  }

  Future<List<MediaItem>> getProviderMedia(String id) async {
    final response = await _api.get('/providers/$id/media');
    final data = response['data'] as List? ?? const [];
    return data
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReviewModel> addReview(String id, {
    required double rating,
    String? ratingText,
    String? reviewText,
  }) async {
    final response = await _api.post('/service-providers/$id/reviews', auth: true, body: {
      'rating': rating,
      if (ratingText != null) 'ratingText': ratingText,
      if (reviewText != null) 'reviewText': reviewText,
    });
    return ReviewModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<bool> toggleFavorite(String id) async {
    final response = await _api.post('/service-providers/$id/favorite', auth: true);
    final favorited = response['data']?['favorited'];
    if (favorited is! bool) {
      throw ApiException('Invalid favorite response from server');
    }
    return favorited;
  }

  Future<Map<String, dynamic>> voteReview(String providerId, String reviewId, String voteType) async {
    final response = await _api.post(
      '/service-providers/$providerId/reviews/$reviewId/vote',
      auth: true,
      body: {'voteType': voteType},
    );
    return response['data'] as Map<String, dynamic>;
  }
}
