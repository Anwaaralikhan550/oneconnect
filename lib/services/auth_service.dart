import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/partner_model.dart';
import '../utils/token_storage.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _api.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
    });

    final data = response['data'] as Map<String, dynamic>;
    await TokenStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );

    final user = UserModel.fromJson(data['user']);
    await TokenStorage.saveUserInfo(id: user.id, name: user.name, email: user.email);
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });

    final data = response['data'] as Map<String, dynamic>;
    await TokenStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );

    final user = UserModel.fromJson(data['user']);
    await TokenStorage.saveUserInfo(id: user.id, name: user.name, email: user.email);
    return user;
  }

  Future<void> logout() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      final isPartner = await TokenStorage.isPartner();
      await _api.post(isPartner ? '/partner/logout' : '/auth/logout', body: {
        'refreshToken': refreshToken,
      }, auth: true);
    } catch (e) {
      debugPrint('AuthService.logout: $e');
    } finally {
      await TokenStorage.clearAll();
    }
  }

  Future<void> forgotPassword(String email, {String? redirectUrl}) async {
    await _api.post('/auth/forgot-password', body: {
      'email': email,
      if (redirectUrl != null && redirectUrl.isNotEmpty) 'redirectUrl': redirectUrl,
    });
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _api.post('/auth/reset-password', body: {
      'token': token,
      'newPassword': newPassword,
    });
  }

  Future<void> partnerForgotPassword({
    required String businessId,
    String? redirectUrl,
  }) async {
    await _api.post('/partner/forgot-password', body: {
      'businessId': businessId,
      if (redirectUrl != null && redirectUrl.isNotEmpty) 'redirectUrl': redirectUrl,
    });
  }

  Future<void> partnerResetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _api.post('/partner/reset-password', body: {
      'token': token,
      'newPassword': newPassword,
    });
  }

  // Partner auth
  Future<Map<String, dynamic>> partnerRegister(Map<String, dynamic> data) async {
    final response = await _api.post('/partner/register', body: data);
    return response['data'] as Map<String, dynamic>;
  }

  Future<PartnerModel> partnerLogin({
    required String businessId,
    required String password,
  }) async {
    final response = await _api.post('/partner/login', body: {
      'businessId': businessId,
      'password': password,
    });

    final data = response['data'] as Map<String, dynamic>;
    await TokenStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );

    final partner = PartnerModel.fromJson(data['partner']);
    await TokenStorage.saveUserInfo(
      id: partner.id,
      name: partner.ownerFullName,
      email: partner.businessEmail ?? '',
      isPartner: true,
    );
    return partner;
  }
}
