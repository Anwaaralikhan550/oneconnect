import '../models/promotion_model.dart';
import 'api_client.dart';

class PromotionService {
  final ApiClient _api = ApiClient();

  Future<List<PromotionModel>> getAll({
    bool activeOnly = true,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get('/promotions', queryParams: {
      'active': activeOnly.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    });
    final data = response['data'] as List;
    return data.map((e) => PromotionModel.fromJson(e)).toList();
  }
}
