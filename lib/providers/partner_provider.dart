import 'package:flutter/foundation.dart';
import '../models/partner_model.dart';
import '../models/promotion_model.dart';
import '../models/service_provider_model.dart';
import '../models/business_model.dart';
import '../models/amenity_model.dart';
import '../models/property_model.dart';
import '../services/partner_service.dart';
import '../utils/api_exception.dart';

class PartnerProvider extends ChangeNotifier {
  final PartnerService _service = PartnerService();

  PartnerModel? _partner;
  List<PromotionModel> _promotions = [];
  List<PartnerMediaModel> _media = [];
  List<ServiceProviderModel> _serviceProviders = [];
  List<BusinessModel> _businesses = [];
  List<PropertyModel> _properties = [];
  List<AmenityModel> _amenities = [];
  final Map<String, List<PartnerMediaModel>> _providerMediaByProviderId = {};
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  PartnerModel? get partner => _partner;
  List<PromotionModel> get promotions => _promotions;
  List<PartnerMediaModel> get media => _media;
  List<ServiceProviderModel> get serviceProviders => _serviceProviders;
  List<BusinessModel> get businesses => _businesses;
  List<PropertyModel> get properties => _properties;
  List<AmenityModel> get amenities => _amenities;
  List<PartnerMediaModel> mediaForProvider(String providerId) =>
      _providerMediaByProviderId[providerId] ?? const [];
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  void _setError(Object e) {
    if (e is ApiException) {
      _error = e.message;
    } else {
      _error = e.toString();
    }
    debugPrint('PartnerProvider error: $e');
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _partner = await _service.getProfile();
      _promotions = List.from(_partner!.promotions);
      _media = List.from(_partner!.media);
    } catch (e) {
      _setError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleBusinessOpen(bool value) async {
    final previous = _partner?.isBusinessOpen ?? false;
    _partner = _partner?.copyWith(isBusinessOpen: value);
    notifyListeners();

    try {
      await _service.updateProfile({'isBusinessOpen': value});
      return true;
    } catch (e) {
      _partner = _partner?.copyWith(isBusinessOpen: previous);
      _setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _partner = await _service.updateProfile(updates);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updatePhones(List<PartnerPhone> phones) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updatePhones(phones);
      _partner = _partner?.copyWith(phones: phones);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> uploadProfilePhoto(String filePath) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final url = await _service.uploadProfilePhoto(filePath);
      _partner = _partner?.copyWith(profilePhotoUrl: url);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> uploadMedia(String filePath) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final mediaItem = await _service.uploadMedia(filePath);
      _media.insert(0, mediaItem);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMedia(String id) async {
    final index = _media.indexWhere((m) => m.id == id);
    if (index == -1) return false;

    final removed = _media[index];
    _media.removeAt(index);
    notifyListeners();

    try {
      await _service.deleteMedia(id);
      return true;
    } catch (e) {
      _media.insert(index, removed);
      _setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPromotion(Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final promo = await _service.createPromotion(data);
      _promotions.insert(0, promo);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updatePromotion(String id, Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updatePromotion(id, data);
      final index = _promotions.indexWhere((p) => p.id == id);
      if (index != -1) {
        _promotions[index] = updated;
      }
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deletePromotion(String id) async {
    final index = _promotions.indexWhere((p) => p.id == id);
    if (index == -1) return false;

    final removed = _promotions[index];
    _promotions.removeAt(index);
    notifyListeners();

    try {
      await _service.deletePromotion(id);
      return true;
    } catch (e) {
      _promotions.insert(index, removed);
      _setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadPromotionImage(String filePath) async {
    try {
      return await _service.uploadPromotionImage(filePath);
    } catch (e) {
      _setError(e);
      notifyListeners();
      return null;
    }
  }

  Future<String?> uploadBusinessImage(String filePath) async {
    try {
      return await _service.uploadBusinessImage(filePath);
    } catch (e) {
      _setError(e);
      notifyListeners();
      return null;
    }
  }

  Future<String?> uploadAmenityImage(String filePath) async {
    try {
      return await _service.uploadAmenityImage(filePath);
    } catch (e) {
      _setError(e);
      notifyListeners();
      return null;
    }
  }

  Future<String?> uploadServiceProviderImage(String filePath) async {
    try {
      return await _service.uploadServiceProviderImage(filePath);
    } catch (e) {
      _setError(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> uploadProviderMedia(
    String serviceProviderId,
    String filePath, {
    String mediaType = 'PHOTO',
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final item = await _service.uploadProviderMedia(
        serviceProviderId,
        filePath,
        mediaType: mediaType,
      );
      final existing = List<PartnerMediaModel>.from(
        _providerMediaByProviderId[serviceProviderId] ?? const [],
      );
      _providerMediaByProviderId[serviceProviderId] = [item, ...existing];
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> fetchServiceProviderMedia(String providerId, {bool force = false}) async {
    if (!force && _providerMediaByProviderId.containsKey(providerId)) {
      notifyListeners();
      return;
    }

    try {
      _providerMediaByProviderId[providerId] =
          await _service.getServiceProviderMedia(providerId);
      notifyListeners();
    } catch (e) {
      _setError(e);
      notifyListeners();
    }
  }

  Future<bool> deleteServiceProviderMedia(String providerId, String mediaId) async {
    final existing = List<PartnerMediaModel>.from(
      _providerMediaByProviderId[providerId] ?? const [],
    );
    final index = existing.indexWhere((m) => m.id == mediaId);
    if (index == -1) return false;

    final removed = existing[index];
    existing.removeAt(index);
    _providerMediaByProviderId[providerId] = existing;
    notifyListeners();

    try {
      await _service.deleteServiceProviderMedia(mediaId);
      return true;
    } catch (e) {
      final restored = List<PartnerMediaModel>.from(
        _providerMediaByProviderId[providerId] ?? const [],
      );
      restored.insert(index, removed);
      _providerMediaByProviderId[providerId] = restored;
      _setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadBusinessMedia(String businessId, String filePath, {String mediaType = 'PHOTO'}) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _service.uploadBusinessMedia(businessId, filePath, mediaType: mediaType);
      await fetchBusinesses();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> uploadAmenityMedia(String amenityId, String filePath, {String mediaType = 'PHOTO'}) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _service.uploadAmenityMedia(amenityId, filePath, mediaType: mediaType);
      await fetchAmenities();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Service Providers
  Future<void> fetchServiceProviders() async {
    try {
      _serviceProviders = await _service.getServiceProviders();
      notifyListeners();
    } catch (e) {
      _setError(e);
      notifyListeners();
    }
  }

  Future<bool> createServiceProvider(Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final sp = await _service.createServiceProvider(data);
      _serviceProviders.insert(0, sp);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateServiceProvider(String id, Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateServiceProvider(id, {
        ...data,
        'contentStatus': 'PENDING',
      });
      final index = _serviceProviders.indexWhere((s) => s.id == id);
      if (index != -1) {
        _serviceProviders[index] = updated;
      }
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<List<String>> fetchServiceSkillSuggestions(String serviceType) async {
    try {
      return await _service.getServiceSkillSuggestions(serviceType);
    } catch (e) {
      _setError(e);
      notifyListeners();
      return [];
    }
  }

  Future<bool> deleteServiceProvider(String id) async {
    final index = _serviceProviders.indexWhere((s) => s.id == id);
    if (index == -1) return false;

    final removed = _serviceProviders[index];
    _serviceProviders.removeAt(index);
    notifyListeners();

    try {
      await _service.deleteServiceProvider(id);
      return true;
    } catch (e) {
      _serviceProviders.insert(index, removed);
      _setError(e);
      notifyListeners();
      return false;
    }
  }

  // Businesses
  Future<void> fetchBusinesses() async {
    try {
      final businesses = await _service.getBusinesses();
      final properties = await _service.getProperties();
      _properties = properties;
      _businesses = [
        ...businesses,
        ...properties.map(_mapPropertyToBusinessCard),
      ];
      notifyListeners();
    } catch (e) {
      _setError(e);
      notifyListeners();
    }
  }

  Future<bool> createBusiness(Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final category = (data['category'] ?? '').toString().trim().toUpperCase();
      if (category == 'REAL_ESTATE') {
        final property = await _service.createProperty({
          'title': data['name'],
          'location': data['location'],
          'serviceProviderId': data['serviceProviderId'],
          'propertyType': data['propertyType'] ?? 'House',
          'purpose': data['purpose'] ?? 'RENTAL',
          'listingStatus': data['listingStatus'] ?? 'FEATURED',
          'description': data['description'],
          'mainImageUrl': data['imageUrl'],
          'price': data['price'],
          'sqft': data['sqft'],
          'beds': data['beds'],
          'baths': data['baths'],
          'kitchen': data['kitchen'],
          'imageUrls': (data['imageUrl']?.toString().isNotEmpty == true)
              ? [data['imageUrl']]
              : [],
        });
        _properties.insert(0, property);
        _businesses.insert(0, _mapPropertyToBusinessCard(property));
      } else {
        final biz = await _service.createBusiness(data);
        _businesses.insert(0, biz);
      }
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBusiness(String id) async {
    final isPropertyItem = id.startsWith('property:');
    final index = _businesses.indexWhere((b) => b.id == id);
    if (index == -1) return false;

    final removed = _businesses[index];
    _businesses.removeAt(index);
    notifyListeners();

    try {
      if (isPropertyItem) {
        final propertyId = id.substring('property:'.length);
        await _service.deleteProperty(propertyId);
        _properties.removeWhere((p) => p.id == propertyId);
      } else {
        await _service.deleteBusiness(id);
      }
      return true;
    } catch (e) {
      _businesses.insert(index, removed);
      _setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBusiness(String id, Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (id.startsWith('property:')) {
        final propertyId = id.substring('property:'.length);
        final updatedProperty = await _service.updateProperty(propertyId, {
          'title': data['name'],
          'location': data['location'],
          'serviceProviderId': data['serviceProviderId'],
          'propertyType': data['propertyType'],
          'purpose': data['purpose'],
          'listingStatus': data['listingStatus'],
          'description': data['description'],
          'mainImageUrl': data['imageUrl'],
          'price': data['price'],
          'sqft': data['sqft'],
          'beds': data['beds'],
          'baths': data['baths'],
          'kitchen': data['kitchen'],
        });
        final index = _businesses.indexWhere((b) => b.id == id);
        if (index != -1) _businesses[index] = _mapPropertyToBusinessCard(updatedProperty);
        final pIndex = _properties.indexWhere((p) => p.id == propertyId);
        if (pIndex != -1) _properties[pIndex] = updatedProperty;
      } else {
        final updated = await _service.updateBusiness(id, {
          ...data,
          'contentStatus': 'PENDING',
        });
        final index = _businesses.indexWhere((b) => b.id == id);
        if (index != -1) _businesses[index] = updated;
      }
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Amenities
  Future<void> fetchAmenities() async {
    try {
      _amenities = await _service.getAmenities();
      notifyListeners();
    } catch (e) {
      _setError(e);
      notifyListeners();
    }
  }

  Future<bool> createAmenity(Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final amenity = await _service.createAmenity(data);
      _amenities.insert(0, amenity);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAmenity(String id) async {
    final index = _amenities.indexWhere((a) => a.id == id);
    if (index == -1) return false;

    final removed = _amenities[index];
    _amenities.removeAt(index);
    notifyListeners();

    try {
      await _service.deleteAmenity(id);
      return true;
    } catch (e) {
      _amenities.insert(index, removed);
      _setError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAmenity(String id, Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateAmenity(id, {
        ...data,
        'contentStatus': 'PENDING',
      });
      final index = _amenities.indexWhere((a) => a.id == id);
      if (index != -1) _amenities[index] = updated;
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Service Categories
  Future<List<Map<String, dynamic>>> fetchServiceCategories() async {
    try {
      return await _service.getServiceCategories();
    } catch (e) {
      _setError(e);
      notifyListeners();
      return [];
    }
  }

  void clear() {
    _partner = null;
    _promotions = [];
    _media = [];
    _serviceProviders = [];
    _businesses = [];
    _properties = [];
    _amenities = [];
    _providerMediaByProviderId.clear();
    _isLoading = false;
    _isSaving = false;
    _error = null;
    notifyListeners();
  }

  BusinessModel _mapPropertyToBusinessCard(PropertyModel p) {
    return BusinessModel(
      id: 'property:${p.id}',
      name: p.title,
      category: 'REAL_ESTATE',
      location: p.location,
      imageUrl: p.mainImageUrl,
      description: p.description,
      rating: 0,
      reviewCount: 0,
      media: const [],
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
