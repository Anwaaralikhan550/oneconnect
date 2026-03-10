import 'package:flutter/foundation.dart';
import '../services/service_provider_service.dart';
import '../services/business_service.dart';
import '../services/amenity_service.dart';
import '../services/user_service.dart';
import '../utils/api_exception.dart';
import '../utils/token_storage.dart';

class FavoriteProvider extends ChangeNotifier {
  final ServiceProviderService _spService = ServiceProviderService();
  final BusinessService _bizService = BusinessService();
  final AmenityService _amenityService = AmenityService();
  final UserService _userService = UserService();

  // Global set requested for persisted heart UI state.
  final Set<String> _favoriteIds = {};
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  // Stores favorited item IDs by type
  final Set<String> _favoriteServiceProviders = {};
  final Set<String> _favoriteBusinesses = {};
  final Set<String> _favoriteAmenities = {};
  final Set<String> _pendingIds = {};
  bool _isHydrated = false;
  bool get isHydrated => _isHydrated;
  bool isPending(String id) => _pendingIds.contains(id);

  bool isFavorited(String id) =>
      _favoriteServiceProviders.contains(id) ||
      _favoriteBusinesses.contains(id) ||
      _favoriteAmenities.contains(id);

  bool isServiceProviderFavorited(String id) => _favoriteServiceProviders.contains(id);
  bool isBusinessFavorited(String id) => _favoriteBusinesses.contains(id);
  bool isAmenityFavorited(String id) => _favoriteAmenities.contains(id);

  Future<void> hydrateFavorites({bool force = false}) async {
    if (_isHydrated && !force) return;
    final loggedIn = await TokenStorage.isLoggedIn();
    if (!loggedIn) {
      clear();
      return;
    }
    try {
      final favorites = await _userService.getFavorites();
      _favoriteIds.clear();
      _favoriteServiceProviders.clear();
      _favoriteBusinesses.clear();
      _favoriteAmenities.clear();

      for (final item in favorites.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        final targetType = (map['targetType'] ?? '').toString().toUpperCase();

        String id = '';
        if (targetType == 'SERVICE_PROVIDER') {
          final sp = map['serviceProvider'];
          id = (sp is Map ? (sp['id'] ?? '') : '').toString();
          if (id.isNotEmpty) _favoriteServiceProviders.add(id);
        } else if (targetType == 'BUSINESS') {
          final biz = map['business'];
          id = (biz is Map ? (biz['id'] ?? '') : '').toString();
          if (id.isNotEmpty) _favoriteBusinesses.add(id);
        } else if (targetType == 'AMENITY') {
          final amenity = map['amenity'];
          id = (amenity is Map ? (amenity['id'] ?? '') : '').toString();
          if (id.isNotEmpty) _favoriteAmenities.add(id);
        }

        if (id.isNotEmpty) _favoriteIds.add(id);
      }

      _isHydrated = true;
      notifyListeners();
    } catch (_) {
      // Keep silent to avoid blocking UI for non-authenticated sessions.
    }
  }

  Future<void> toggleServiceProviderFavorite(String id) async {
    if (id.isEmpty || _pendingIds.contains(id)) return;
    final loggedIn = await TokenStorage.isLoggedIn();
    if (!loggedIn) return;
    if (!_isHydrated) {
      await hydrateFavorites();
    }

    _pendingIds.add(id);
    final wasLiked = _favoriteServiceProviders.contains(id);
    // Optimistic update
    if (wasLiked) {
      _favoriteServiceProviders.remove(id);
      _favoriteIds.remove(id);
    } else {
      _favoriteServiceProviders.add(id);
      _favoriteIds.add(id);
    }
    notifyListeners();

    try {
      final result = await _spService.toggleFavorite(id);
      if (result) {
        _favoriteServiceProviders.add(id);
        _favoriteIds.add(id);
      } else {
        _favoriteServiceProviders.remove(id);
        _favoriteIds.remove(id);
      }
      notifyListeners();
    } on ApiException {
      // Revert on failure
      if (wasLiked) {
        _favoriteServiceProviders.add(id);
        _favoriteIds.add(id);
      } else {
        _favoriteServiceProviders.remove(id);
        _favoriteIds.remove(id);
      }
      notifyListeners();
    } finally {
      _pendingIds.remove(id);
      notifyListeners();
    }
  }

  Future<void> toggleBusinessFavorite(String id) async {
    if (id.isEmpty || _pendingIds.contains(id)) return;
    final loggedIn = await TokenStorage.isLoggedIn();
    if (!loggedIn) return;
    if (!_isHydrated) {
      await hydrateFavorites();
    }

    _pendingIds.add(id);
    final wasLiked = _favoriteBusinesses.contains(id);
    if (wasLiked) {
      _favoriteBusinesses.remove(id);
      _favoriteIds.remove(id);
    } else {
      _favoriteBusinesses.add(id);
      _favoriteIds.add(id);
    }
    notifyListeners();

    try {
      final result = await _bizService.toggleFavorite(id);
      if (result) {
        _favoriteBusinesses.add(id);
        _favoriteIds.add(id);
      } else {
        _favoriteBusinesses.remove(id);
        _favoriteIds.remove(id);
      }
      notifyListeners();
    } on ApiException {
      if (wasLiked) {
        _favoriteBusinesses.add(id);
        _favoriteIds.add(id);
      } else {
        _favoriteBusinesses.remove(id);
        _favoriteIds.remove(id);
      }
      notifyListeners();
    } finally {
      _pendingIds.remove(id);
      notifyListeners();
    }
  }

  Future<void> toggleAmenityFavorite(String id) async {
    if (id.isEmpty || _pendingIds.contains(id)) return;
    final loggedIn = await TokenStorage.isLoggedIn();
    if (!loggedIn) return;
    if (!_isHydrated) {
      await hydrateFavorites();
    }

    _pendingIds.add(id);
    final wasLiked = _favoriteAmenities.contains(id);
    if (wasLiked) {
      _favoriteAmenities.remove(id);
      _favoriteIds.remove(id);
    } else {
      _favoriteAmenities.add(id);
      _favoriteIds.add(id);
    }
    notifyListeners();

    try {
      final result = await _amenityService.toggleFavorite(id);
      if (result) {
        _favoriteAmenities.add(id);
        _favoriteIds.add(id);
      } else {
        _favoriteAmenities.remove(id);
        _favoriteIds.remove(id);
      }
      notifyListeners();
    } on ApiException {
      if (wasLiked) {
        _favoriteAmenities.add(id);
        _favoriteIds.add(id);
      } else {
        _favoriteAmenities.remove(id);
        _favoriteIds.remove(id);
      }
      notifyListeners();
    } finally {
      _pendingIds.remove(id);
      notifyListeners();
    }
  }

  void clear() {
    _favoriteIds.clear();
    _favoriteServiceProviders.clear();
    _favoriteBusinesses.clear();
    _favoriteAmenities.clear();
    _isHydrated = false;
    notifyListeners();
  }
}
