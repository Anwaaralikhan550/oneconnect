import '../models/amenity_model.dart';
import '../models/review_model.dart';
import '../models/filter_dto.dart';
import 'api_client.dart';
import '../utils/api_exception.dart';

class AmenityService {
  final ApiClient _api = ApiClient();

  Future<List<AmenityModel>> getByType(
    String type, {
    FilterDto? filter,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{'type': type};
    params.addAll((filter ?? FilterDto(page: page, limit: limit)).toQueryParams());
    final response = await _api.get('/amenities', queryParams: params);
    final data = response['data'] as List;
    return data.map((e) => AmenityModel.fromJson(e)).toList();
  }

  Future<AmenityModel> getById(String id) async {
    final response = await _api.get('/amenities/$id');
    return AmenityModel.fromJson(response['data']);
  }

  Future<ReviewModel> addReview(String id, {
    required double rating,
    String? ratingText,
    String? reviewText,
    String? mediaUrl,
    String? mediaType,
  }) async {
    final response = await _api.post('/amenities/$id/reviews', auth: true, body: {
      'rating': rating,
      if (ratingText != null) 'ratingText': ratingText,
      if (reviewText != null) 'reviewText': reviewText,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (mediaType != null) 'mediaType': mediaType,
    });
    return ReviewModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<bool> toggleFavorite(String id) async {
    final response = await _api.post('/amenities/$id/favorite', auth: true);
    final favorited = response['data']?['favorited'];
    if (favorited is! bool) {
      throw ApiException('Invalid favorite response from server');
    }
    return favorited;
  }

  Future<Map<String, dynamic>> voteReview(String amenityId, String reviewId, String voteType) async {
    final response = await _api.post(
      '/amenities/$amenityId/reviews/$reviewId/vote',
      auth: true,
      body: {'voteType': voteType},
    );
    return response['data'] as Map<String, dynamic>;
  }
}
