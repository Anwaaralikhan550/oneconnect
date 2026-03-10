import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../utils/api_exception.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications({bool unreadOnly = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _service.getAll(unreadOnly: unreadOnly);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    try {
      await _service.markAllRead();
      for (var i = 0; i < _notifications.length; i++) {
        final n = _notifications[i];
        if (!n.isRead) {
          _notifications[i] = NotificationModel(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            isRead: true,
            data: n.data,
            createdAt: n.createdAt,
          );
        }
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark notifications as read';
      debugPrint('NotificationProvider.markAllRead: $e');
      notifyListeners();
    }
  }
}
