import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_client.dart';

class PushTokenService {
  final ApiClient _api = ApiClient();

  Future<void> registerCurrentDeviceToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token == null || token.isEmpty) return;

      await _api.put(
        '/users/me/device-token',
        auth: true,
        body: {'fcmToken': token},
      );
    } catch (e) {
      debugPrint('PushTokenService.registerCurrentDeviceToken: $e');
    }
  }
}
