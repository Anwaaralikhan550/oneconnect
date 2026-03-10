import '../models/search_result_model.dart';
import '../models/filter_dto.dart';
import 'api_client.dart';

class SearchService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> search(
    String query, {
    FilterDto? filter,
    String? category,
  }) async {
    final normalized = query.trim();
    final params = <String, String>{'q': normalized};
    params.addAll(filter?.toQueryParams() ?? const {});
    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }

    final response = await _api.get('/search', queryParams: params);
    return response['data'] as Map<String, dynamic>;
  }

  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    final response = await _api.get('/search/suggestions', queryParams: {'q': query.trim()});
    final data = response['data'] as List;
    return data.map((e) => SearchSuggestion.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getPopular({FilterDto? filter}) async {
    final response = await _api.get(
      '/search/popular',
      queryParams: filter?.toQueryParams(),
      auth: true,
    );
    return response['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getHistory() async {
    final response = await _api.get('/search/history', auth: true);
    return response['data'] as List<dynamic>;
  }

  Future<void> saveHistory(String query) async {
    await _api.post('/search/history', body: {'query': query}, auth: true);
  }

  Future<void> deleteHistory({String? id}) async {
    final path = id != null ? '/search/history/$id' : '/search/history';
    await _api.delete(path, auth: true);
  }
}
