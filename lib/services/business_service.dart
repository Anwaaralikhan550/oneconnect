import '../models/business_model.dart';
import '../models/review_model.dart';
import '../models/filter_dto.dart';
import 'api_client.dart';
import '../utils/api_exception.dart';

class BusinessService {
  final ApiClient _api = ApiClient();

  Future<List<BusinessModel>> getByCategory(
    String category, {
    FilterDto? filter,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{'category': category};
    params.addAll((filter ?? FilterDto(page: page, limit: limit)).toQueryParams());
    final response = await _api.get('/businesses', queryParams: params);
    final data = response['data'] as List;
    return data.map((e) => BusinessModel.fromJson(e)).toList();
  }

  Future<BusinessModel> getById(String id) async {
    final response = await _api.get('/businesses/$id');
    return BusinessModel.fromJson(response['data']);
  }

  Future<ReviewModel> addReview(String id, {
    required double rating,
    String? ratingText,
    String? reviewText,
  }) async {
    final response = await _api.post('/businesses/$id/reviews', auth: true, body: {
      'rating': rating,
      if (ratingText != null) 'ratingText': ratingText,
      if (reviewText != null) 'reviewText': reviewText,
    });
    return ReviewModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<bool> toggleFavorite(String id) async {
    final response = await _api.post('/businesses/$id/favorite', auth: true);
    final favorited = response['data']?['favorited'];
    if (favorited is! bool) {
      throw ApiException('Invalid favorite response from server');
    }
    return favorited;
  }

  Future<Map<String, dynamic>> voteReview(String businessId, String reviewId, String voteType) async {
    final response = await _api.post(
      '/businesses/$businessId/reviews/$reviewId/vote',
      auth: true,
      body: {'voteType': voteType},
    );
    return response['data'] as Map<String, dynamic>;
  }
}
