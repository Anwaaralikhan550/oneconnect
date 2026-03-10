import 'api_client.dart';

class FollowService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> toggleFollow({
    required String entityType,
    required String entityId,
  }) async {
    final normalizedType = entityType.trim().toLowerCase();
    final path = normalizedType == 'service'
        ? '/service-providers/$entityId/follow'
        : '/businesses/$entityId/follow';
    final response = await _api.post(path, auth: true);
    return response['data'] as Map<String, dynamic>;
  }
}
