import '../models/notification_model.dart';
import 'api_client.dart';

class NotificationService {
  final ApiClient _api = ApiClient();

  Future<List<NotificationModel>> getAll({bool unreadOnly = false}) async {
    final params = <String, String>{};
    if (unreadOnly) params['unread'] = 'true';

    final response = await _api.get('/users/me/notifications', queryParams: params, auth: true);
    final data = response['data'] as List;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markAllRead() async {
    await _api.put('/users/me/notifications/read-all', auth: true);
  }
}
