import '../models/property_model.dart';
import 'api_client.dart';

class PropertyService {
  final ApiClient _api = ApiClient();

  Future<List<PropertyModel>> getAll({
    String? type,
    String? partnerId,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (type != null) params['propertyType'] = type;
    if (partnerId != null && partnerId.isNotEmpty) params['partnerId'] = partnerId;

    final response = await _api.get('/properties', queryParams: params);
    final data = response['data'] as List;
    return data.map((e) => PropertyModel.fromJson(e)).toList();
  }

  Future<PropertyModel> getById(String id) async {
    final response = await _api.get('/properties/$id');
    return PropertyModel.fromJson(response['data']);
  }
}
