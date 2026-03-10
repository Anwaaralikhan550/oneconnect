import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/partner_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/push_token_service.dart';
import '../utils/token_storage.dart';
import '../utils/api_exception.dart';
import '../utils/media_url.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final PushTokenService _pushTokenService = PushTokenService();

  UserModel? _user;
  PartnerModel? _partner;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _isPartner = false;

  UserModel? get user => _user;
  PartnerModel? get partner => _partner;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isPartner => _isPartner;

  Future<void> checkAuthState() async {
    _isLoggedIn = await TokenStorage.isLoggedIn();
    _isPartner = await TokenStorage.isPartner();
    if (_isLoggedIn) {
      final info = await TokenStorage.getUserInfo();
      if (info['id'] != null) {
        _user = UserModel(
          id: info['id']!,
          name: info['name'] ?? '',
          email: info['email'] ?? '',
        );
      }
      if (!_isPartner) {
        try {
          _user = await _userService.getProfile();
        } catch (_) {
          // Keep fallback cached identity if profile fetch fails.
        }
      }
    }
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      try {
        _user = await _userService.getProfile();
      } catch (_) {
        // Non-blocking: keep register response payload.
      }
      _isLoggedIn = true;
      _isPartner = false;
      _isLoading = false;
      notifyListeners();
      _pushTokenService.registerCurrentDeviceToken();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Unable to register right now. Please check your connection and try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(email: email, password: password);
      try {
        _user = await _userService.getProfile();
      } catch (_) {
        // Non-blocking: keep login response payload.
      }
      _isLoggedIn = true;
      _isPartner = false;
      _isLoading = false;
      notifyListeners();
      _pushTokenService.registerCurrentDeviceToken();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Unable to login right now. Please check your connection and try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> forgotPassword(String email) async {
    await _authService.forgotPassword(email);
  }

  Future<void> partnerForgotPassword(String businessId) async {
    await _authService.partnerForgotPassword(businessId: businessId);
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _partner = null;
    _isLoggedIn = false;
    _isPartner = false;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.deleteAccount();
      await _authService.logout();
      _user = null;
      _partner = null;
      _isLoggedIn = false;
      _isPartner = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Unable to register right now. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> partnerLogin({
    required String businessId,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _partner = await _authService.partnerLogin(
        businessId: businessId,
        password: password,
      );
      _isLoggedIn = true;
      _isPartner = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Unable to login right now. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> partnerRegister(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.partnerRegister(data);
      _isLoading = false;
      notifyListeners();
      return result;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchProfile() async {
    if (!_isLoggedIn) {
      _isLoggedIn = await TokenStorage.isLoggedIn();
    }
    if (_isLoggedIn && !_isPartner) {
      _isPartner = await TokenStorage.isPartner();
    }
    if (!_isLoggedIn || _isPartner) return;

    try {
      _user = await _userService.getProfile();
      if (_user != null) {
        await TokenStorage.saveUserInfo(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          isPartner: false,
        );
      }
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _userService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        profilePhotoUrl: profilePhotoUrl,
        bio: bio,
        address: address,
        country: country,
        gender: gender,
        occupation: occupation,
        dateOfBirth: dateOfBirth,
      );
      if (_user != null) {
        await TokenStorage.saveUserInfo(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Unable to login right now. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadProfilePhoto(String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uploaded = await _userService.uploadProfilePhoto(filePath);
      final resolvedUrl = resolveMediaUrl(uploaded) ?? uploaded;
      if (resolvedUrl.trim().isEmpty) {
        throw ApiException('Profile photo URL is empty after upload');
      }

      // Keep UI immediately in sync even if profile refetch is delayed/fails.
      _mergeUserPhotoUrl(resolvedUrl);

      // Force-save URL through profile update as an extra safety layer.
      try {
        _user = await _userService.updateProfile(profilePhotoUrl: resolvedUrl);
      } catch (_) {
        // Non-blocking fallback: profile might already be updated by upload endpoint.
      }

      // Fetch latest authoritative profile.
      try {
        _user = await _userService.getProfile();
      } catch (_) {
        // Keep locally merged user state if refetch fails.
      }

      _isLoading = false;
      notifyListeners();
      return resolvedUrl;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Unable to upload profile photo. Please try again.';
      debugPrint('AuthProvider.uploadProfilePhoto: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void _mergeUserPhotoUrl(String? profilePhotoUrl) {
    if (_user == null || profilePhotoUrl == null || profilePhotoUrl.trim().isEmpty) return;
    final current = _user!;
    _user = UserModel(
      id: current.id,
      name: current.name,
      email: current.email,
      phone: current.phone,
      profilePhotoUrl: profilePhotoUrl,
      bio: current.bio,
      address: current.address,
      country: current.country,
      gender: current.gender,
      occupation: current.occupation,
      dateOfBirth: current.dateOfBirth,
      locationLat: current.locationLat,
      locationLng: current.locationLng,
      notifySound: current.notifySound,
      notifyVibrate: current.notifyVibrate,
      notifyEmailUpdates: current.notifyEmailUpdates,
      notifySmsUpdates: current.notifySmsUpdates,
      notifyPushUpdates: current.notifyPushUpdates,
      notifyEmailReminders: current.notifyEmailReminders,
      notifySmsReminders: current.notifySmsReminders,
      notifyPushReminders: current.notifyPushReminders,
      createdAt: current.createdAt,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
