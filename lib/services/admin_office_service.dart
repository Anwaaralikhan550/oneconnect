import '../models/search_result_model.dart';
import 'api_client.dart';

class AdminOfficeService {
  final ApiClient _api = ApiClient();

  Future<List<AdminOfficeModel>> getAll({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get('/admin-offices', queryParams: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
    final data = response['data'] as List;
    return data.map((e) => AdminOfficeModel.fromJson(e)).toList();
  }

  Future<AdminOfficeModel> getById(String id) async {
    final response = await _api.get('/admin-offices/$id');
    return AdminOfficeModel.fromJson(response['data']);
  }
}
