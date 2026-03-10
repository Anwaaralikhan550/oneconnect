import '../models/user_model.dart';
import 'api_client.dart';
import '../utils/media_url.dart';
import '../utils/api_exception.dart';

class UserService {
  final ApiClient _api = ApiClient();

  Future<UserModel> getProfile() async {
    final response = await _api.get('/users/me', auth: true);
    return UserModel.fromJson(response['data']);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profilePhotoUrl,
    String? bio,
    String? address,
    String? country,
    String? gender,
    String? occupation,
    String? dateOfBirth,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (profilePhotoUrl != null) body['profilePhotoUrl'] = profilePhotoUrl;
    if (bio != null) body['bio'] = bio;
    if (address != null) body['address'] = address;
    if (country != null) body['country'] = country;
    if (gender != null) body['gender'] = gender;
    if (occupation != null) body['occupation'] = occupation;
    if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;

    final response = await _api.put('/users/me', body: body, auth: true);
    return UserModel.fromJson(response['data']);
  }

  Future<List<dynamic>> getFavorites() async {
    final response = await _api.get('/users/me/favorites', auth: true);
    return response['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getNotificationPreferences() async {
    final response = await _api.get('/users/me/notification-preferences', auth: true);
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateNotificationPreferences(Map<String, dynamic> prefs) async {
    final response = await _api.put('/users/me/notification-preferences', body: prefs, auth: true);
    return response['data'] as Map<String, dynamic>;
  }

  Future<void> deleteAccount() async {
    await _api.delete('/users/me', auth: true);
  }

  Future<String> uploadProfilePhoto(String filePath) async {
    final response = await _api.uploadFile(
      '/upload/user-profile',
      filePath: filePath,
      fieldName: 'file',
      auth: true,
    );
    final data = response['data'];
    String raw = '';
    if (data is Map<String, dynamic>) {
      raw = (data['fileUrl'] ?? data['url'] ?? data['profilePhotoUrl'] ?? '').toString().trim();
    }
    final resolved = (resolveMediaUrl(raw) ?? raw).trim();
    if (resolved.isEmpty) {
      throw ApiException('Profile upload succeeded but no image URL returned');
    }
    return resolved;
  }

  Future<String> uploadReviewMedia(String filePath) async {
    final response = await _api.uploadFile(
      '/upload/review-media',
      filePath: filePath,
      fieldName: 'file',
      auth: true,
    );
    return response['data']['fileUrl'] as String;
  }
}
