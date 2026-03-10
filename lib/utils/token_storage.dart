import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _isPartnerKey = 'is_partner';
  static const _rememberMeKey = 'remember_me';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);

    // Cleanup legacy plain-text token storage.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  static Future<String?> getAccessToken() async {
    final secure = await _secureStorage.read(key: _accessTokenKey);
    if (secure != null && secure.isNotEmpty) return secure;

    // Fallback for older installs; migrate on read.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_accessTokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _secureStorage.write(key: _accessTokenKey, value: legacy);
      await prefs.remove(_accessTokenKey);
      return legacy;
    }
    return null;
  }

  static Future<String?> getRefreshToken() async {
    final secure = await _secureStorage.read(key: _refreshTokenKey);
    if (secure != null && secure.isNotEmpty) return secure;

    // Fallback for older installs; migrate on read.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_refreshTokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _secureStorage.write(key: _refreshTokenKey, value: legacy);
      await prefs.remove(_refreshTokenKey);
      return legacy;
    }
    return null;
  }

  static Future<void> saveUserInfo({
    required String id,
    required String name,
    required String email,
    bool isPartner = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setBool(_isPartnerKey, isPartner);
  }

  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(_userIdKey),
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
    };
  }

  static Future<bool> isPartner() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isPartnerKey) ?? false;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAll() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_isPartnerKey);
    await prefs.remove(_rememberMeKey);
  }
}
