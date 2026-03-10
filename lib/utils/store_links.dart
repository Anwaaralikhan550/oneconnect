import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class StoreLinks {
  static const String _androidUrl = String.fromEnvironment(
    'ONECONNECT_PLAY_STORE_URL',
    defaultValue: '',
  );
  static const String _iosUrl = String.fromEnvironment(
    'ONECONNECT_APP_STORE_URL',
    defaultValue: '',
  );

  static String get currentUrl => Platform.isIOS ? _iosUrl.trim() : _androidUrl.trim();

  static Future<bool> openStoreListing() async {
    final value = currentUrl;
    if (value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

