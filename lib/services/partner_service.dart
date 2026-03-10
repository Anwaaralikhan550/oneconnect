import '../models/partner_model.dart';
import '../models/promotion_model.dart';
import '../models/service_provider_model.dart';
import '../models/business_model.dart';
import '../models/amenity_model.dart';
import '../models/property_model.dart';
import 'api_client.dart';

class PartnerService {
  final ApiClient _api = ApiClient();
  static const Set<String> _allowedBusinessCategories = {
    'STORE', 'SOLAR', 'BANK', 'RESTAURANT', 'REAL_ESTATE', 'HOME_CHEF'
  };
  static const Set<String> _allowedAmenityTypes = {
    'MASJID', 'PARK', 'GYM', 'HEALTHCARE', 'SCHOOL', 'PHARMACY', 'CAFE', 'ADMIN'
  };

  String? _normalizeUrlOrNull(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return null;
    final withScheme = raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : 'https://$raw';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || (!uri.hasScheme || uri.host.isEmpty)) return null;
    return withScheme;
  }

  List<String> _sanitizeDayCodes(dynamic value) {
    final allowed = const {'Su', 'M', 'T', 'W', 'Th', 'F', 'S'};
    final list = (value is List ? value : const [])
        .map((e) => e.toString().trim())
        .where((e) => allowed.contains(e))
        .toList();
    return list.length > 7 ? list.sublist(0, 7) : list;
  }

  List<String> _sanitizeServices(dynamic value) {
    final list = (value is List ? value : const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final seen = <String>{};
    final out = <String>[];
    for (final s in list) {
      final key = s.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      out.add(s);
      if (out.length >= 30) break;
    }
    return out;
  }

  Map<String, dynamic> _sanitizeBusinessPayload(Map<String, dynamic> data) {
    final payload = <String, dynamic>{};
    final name = (data['name'] ?? '').toString().trim();
    final category = (data['category'] ?? '').toString().trim().toUpperCase();
    if (name.isNotEmpty) payload['name'] = name;
    if (_allowedBusinessCategories.contains(category)) payload['category'] = category;

    final location = (data['location'] ?? '').toString().trim();
    if (location.isNotEmpty) payload['location'] = location;
    final phone = (data['phone'] ?? '').toString().trim();
    if (phone.isNotEmpty) payload['phone'] = phone;
    final description = (data['description'] ?? '').toString().trim();
    if (description.isNotEmpty) payload['description'] = description;
    final imageUrl = _normalizeUrlOrNull(data['imageUrl']);
    if (imageUrl != null) payload['imageUrl'] = imageUrl;

    final opening = (data['openingTime'] ?? '').toString().trim();
    final closing = (data['closingTime'] ?? '').toString().trim();
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(opening)) payload['openingTime'] = opening;
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(closing)) payload['closingTime'] = closing;

    final operatingDays = _sanitizeDayCodes(data['operatingDays']);
    if (operatingDays.isNotEmpty) payload['operatingDays'] = operatingDays;
    final servicesOffered = _sanitizeServices(data['servicesOffered']);
    if (servicesOffered.isNotEmpty) payload['servicesOffered'] = servicesOffered;

    final facebook = _normalizeUrlOrNull(data['facebookUrl']);
    if (facebook != null) payload['facebookUrl'] = facebook;
    final instagram = _normalizeUrlOrNull(data['instagramUrl']);
    if (instagram != null) payload['instagramUrl'] = instagram;
    final whatsapp = (data['whatsapp'] ?? '').toString().trim();
    if (whatsapp.isNotEmpty) payload['whatsapp'] = whatsapp;
    final website = _normalizeUrlOrNull(data['websiteUrl']);
    if (website != null) payload['websiteUrl'] = website;
    final contentStatus = (data['contentStatus'] ?? '').toString().trim().toUpperCase();
    if (contentStatus == 'PENDING') payload['contentStatus'] = contentStatus;

    return payload;
  }

  Map<String, dynamic> _sanitizeAmenityPayload(Map<String, dynamic> data) {
    final payload = <String, dynamic>{};
    final name = (data['name'] ?? '').toString().trim();
    final amenityType = (data['amenityType'] ?? '').toString().trim().toUpperCase();
    if (name.isNotEmpty) payload['name'] = name;
    if (_allowedAmenityTypes.contains(amenityType)) payload['amenityType'] = amenityType;

    final location = (data['location'] ?? '').toString().trim();
    if (location.isNotEmpty) payload['location'] = location;
    final phone = (data['phone'] ?? '').toString().trim();
    if (phone.isNotEmpty) payload['phone'] = phone;
    final description = (data['description'] ?? '').toString().trim();
    if (description.isNotEmpty) payload['description'] = description;
    final imageUrl = _normalizeUrlOrNull(data['imageUrl']);
    if (imageUrl != null) payload['imageUrl'] = imageUrl;

    final opening = (data['openingTime'] ?? '').toString().trim();
    final closing = (data['closingTime'] ?? '').toString().trim();
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(opening)) payload['openingTime'] = opening;
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(closing)) payload['closingTime'] = closing;

    final operatingDays = _sanitizeDayCodes(data['operatingDays']);
    if (operatingDays.isNotEmpty) payload['operatingDays'] = operatingDays;
    final servicesOffered = _sanitizeServices(data['servicesOffered']);
    if (servicesOffered.isNotEmpty) payload['servicesOffered'] = servicesOffered;

    final facebook = _normalizeUrlOrNull(data['facebookUrl']);
    if (facebook != null) payload['facebookUrl'] = facebook;
    final instagram = _normalizeUrlOrNull(data['instagramUrl']);
    if (instagram != null) payload['instagramUrl'] = instagram;
    final whatsapp = (data['whatsapp'] ?? '').toString().trim();
    if (whatsapp.isNotEmpty) payload['whatsapp'] = whatsapp;
    final website = _normalizeUrlOrNull(data['websiteUrl']);
    if (website != null) payload['websiteUrl'] = website;
    final contentStatus = (data['contentStatus'] ?? '').toString().trim().toUpperCase();
    if (contentStatus == 'PENDING') payload['contentStatus'] = contentStatus;

    return payload;
  }

  Map<String, dynamic> _sanitizePartnerPropertyPayload(
    Map<String, dynamic> data,
  ) {
    final payload = <String, dynamic>{};

    final serviceProviderId = (data['serviceProviderId'] ?? '').toString().trim();
    if (serviceProviderId.isNotEmpty) payload['serviceProviderId'] = serviceProviderId;

    final title = (data['title'] ?? '').toString().trim();
    if (title.isNotEmpty) payload['title'] = title;

    final location = (data['location'] ?? '').toString().trim();
    if (location.isNotEmpty) payload['location'] = location;

    final type = (data['propertyType'] ?? '').toString().trim();
    if (const ['House', 'Apartment', 'Plot'].contains(type)) {
      payload['propertyType'] = type;
    }

    final purpose = (data['purpose'] ?? '').toString().trim().toUpperCase();
    if (const ['RENTAL', 'SALE'].contains(purpose)) payload['purpose'] = purpose;

    final status = (data['listingStatus'] ?? '').toString().trim().toUpperCase();
    if (const ['SUPER_HOT', 'RENTAL', 'FEATURED'].contains(status)) {
      payload['listingStatus'] = status;
    }

    final description = (data['description'] ?? '').toString().trim();
    if (description.isNotEmpty) payload['description'] = description;

    final mainImageUrl = _normalizeUrlOrNull(data['mainImageUrl']);
    if (mainImageUrl != null) payload['mainImageUrl'] = mainImageUrl;

    final imageUrls = (data['imageUrls'] is List ? data['imageUrls'] as List : const [])
        .map((e) => _normalizeUrlOrNull(e))
        .whereType<String>()
        .toList();
    if (imageUrls.isNotEmpty) payload['imageUrls'] = imageUrls;

    final priceRaw = data['price'];
    final price = priceRaw is num ? priceRaw.toDouble() : double.tryParse('$priceRaw');
    if (price != null) payload['price'] = price;

    final bedsRaw = data['beds'];
    final beds = bedsRaw is int ? bedsRaw : int.tryParse('$bedsRaw');
    if (beds != null) payload['beds'] = beds;

    final bathsRaw = data['baths'];
    final baths = bathsRaw is int ? bathsRaw : int.tryParse('$bathsRaw');
    if (baths != null) payload['baths'] = baths;

    final kitchenRaw = data['kitchen'];
    final kitchen = kitchenRaw is int ? kitchenRaw : int.tryParse('$kitchenRaw');
    if (kitchen != null) payload['kitchen'] = kitchen;

    final sqftRaw = data['sqft'];
    final sqft = sqftRaw is num ? sqftRaw.toDouble() : double.tryParse('$sqftRaw');
    if (sqft != null) payload['sqft'] = sqft;

    return payload;
  }

  Future<PartnerModel> getProfile() async {
    final response = await _api.get('/partner/me', auth: true);
    return PartnerModel.fromJson(response['data']);
  }

  Future<PartnerModel> updateProfile(Map<String, dynamic> updates) async {
    final response = await _api.put('/partner/me', body: updates, auth: true);
    return PartnerModel.fromJson(response['data']);
  }

  Future<void> updatePhones(List<PartnerPhone> phones) async {
    await _api.put('/partner/me/phones', body: {
      'phones': phones.map((p) => p.toJson()).toList(),
    }, auth: true);
  }

  Future<List<PromotionModel>> getPromotions() async {
    final response = await _api.get('/partner/me/promotions', auth: true);
    final data = response['data'] as List;
    return data.map((e) => PromotionModel.fromJson(e)).toList();
  }

  Future<PromotionModel> createPromotion(Map<String, dynamic> data) async {
    final response = await _api.post('/partner/me/promotions', body: data, auth: true);
    return PromotionModel.fromJson(response['data']);
  }

  Future<PromotionModel> updatePromotion(String id, Map<String, dynamic> data) async {
    final response = await _api.put('/partner/me/promotions/$id', body: data, auth: true);
    return PromotionModel.fromJson(response['data']);
  }

  Future<void> deletePromotion(String id) async {
    await _api.delete('/partner/me/promotions/$id', auth: true);
  }

  Future<List<PartnerMediaModel>> getMedia() async {
    final response = await _api.get('/partner/me/media', auth: true);
    final data = response['data'] as List;
    return data.map((e) => PartnerMediaModel.fromJson(e)).toList();
  }

  Future<void> deleteMedia(String id) async {
    await _api.delete('/partner/me/media/$id', auth: true);
  }

  Future<PartnerMediaModel> uploadMedia(String filePath) async {
    final response = await _api.uploadFile(
      '/upload/partner-media',
      filePath: filePath,
      fieldName: 'file',
      auth: true,
    );
    return PartnerMediaModel.fromJson(response['data']);
  }

  Future<String> uploadProfilePhoto(String filePath) async {
    final response = await _api.uploadFile(
      '/upload/partner-profile',
      filePath: filePath,
      fieldName: 'file',
      auth: true,
    );
    return response['data']['fileUrl'] as String;
  }

  Future<String> uploadPromotionImage(String filePath) async {
    final response = await _api.uploadFile(
      '/upload/promotion-image',
      filePath: filePath,
      fieldName: 'file',
      auth: true,
    );
    return response['data']['fileUrl'] as String;
  }

  Future<String> uploadBusinessImage(String filePath) async {
    final response = await _api.uploadFile(
      '/upload/business-image',
      filePath: filePath,
      fieldName: 'file',
      auth: true,
    );
    return response['data']['fileUrl'] as String;
  }

  Future<String> uploadAmenityImage(String filePath) async {
    final response = await _api.uploadFile(
      '/upload/amenity-image',
      filePath: filePath,
      fieldName: 'file',
      auth: true,
    );
    return response['data']['fileUrl'] as String;
  }

  Future<String> uploadServiceProviderImage(String filePath) async {
    final response = await _api.uploadFile(
      '/upload/service-provider-image',
      filePath: filePath,
      fieldName: 'file',
      auth: true,
    );
    return response['data']['fileUrl'] as String;
  }

  Future<PartnerMediaModel> uploadProviderMedia(
    String serviceProviderId,
    String filePath, {
    String mediaType = 'PHOTO',
  }) async {
    final response = await _api.uploadFile(
      '/upload/provider-media',
      filePath: filePath,
      fieldName: 'file',
      fields: {'serviceProviderId': serviceProviderId, 'mediaType': mediaType},
      auth: true,
    );
    return PartnerMediaModel.fromJson(response['data']);
  }

  Future<List<PartnerMediaModel>> getServiceProviderMedia(String providerId) async {
    final response = await _api.get('/partner/me/service-providers/$providerId/media', auth: true);
    final data = response['data'] as List? ?? const [];
    return data.map((e) => PartnerMediaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> deleteServiceProviderMedia(String mediaId) async {
    await _api.delete('/partner/me/service-providers/media/$mediaId', auth: true);
  }

  Future<BusinessMediaModel> uploadBusinessMedia(String businessId, String filePath, {String mediaType = 'PHOTO'}) async {
    final response = await _api.uploadFile(
      '/upload/business-media',
      filePath: filePath,
      fieldName: 'file',
      fields: {'businessId': businessId, 'mediaType': mediaType},
      auth: true,
    );
    return BusinessMediaModel.fromJson(response['data']);
  }

  Future<AmenityMediaModel> uploadAmenityMedia(String amenityId, String filePath, {String mediaType = 'PHOTO'}) async {
    final response = await _api.uploadFile(
      '/upload/amenity-media',
      filePath: filePath,
      fieldName: 'file',
      fields: {'amenityId': amenityId, 'mediaType': mediaType},
      auth: true,
    );
    return AmenityMediaModel.fromJson(response['data']);
  }

  // Service Providers
  Future<List<ServiceProviderModel>> getServiceProviders() async {
    final response = await _api.get('/partner/me/service-providers', auth: true);
    final data = response['data'] as List;
    return data.map((e) => ServiceProviderModel.fromJson(e)).toList();
  }

  Future<ServiceProviderModel> createServiceProvider(Map<String, dynamic> data) async {
    final response = await _api.post('/partner/me/service-providers', body: data, auth: true);
    return ServiceProviderModel.fromJson(response['data']);
  }

  Future<ServiceProviderModel> updateServiceProvider(String id, Map<String, dynamic> data) async {
    final response = await _api.put('/partner/me/service-providers/$id', body: data, auth: true);
    return ServiceProviderModel.fromJson(response['data']);
  }

  Future<void> deleteServiceProvider(String id) async {
    await _api.delete('/partner/me/service-providers/$id', auth: true);
  }

  Future<List<String>> getServiceSkillSuggestions(String serviceType) async {
    final response = await _api.get(
      '/service-providers/suggestions/skills',
      queryParams: {'type': serviceType},
    );
    final data = response['data'] as Map<String, dynamic>;
    final skills = (data['skills'] as List?) ?? const [];
    return skills.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList();
  }

  // Businesses
  Future<List<BusinessModel>> getBusinesses() async {
    final response = await _api.get('/partner/me/businesses', auth: true);
    final data = response['data'] as List;
    return data.map((e) => BusinessModel.fromJson(e)).toList();
  }

  Future<BusinessModel> createBusiness(Map<String, dynamic> data) async {
    final response = await _api.post(
      '/partner/me/businesses',
      body: _sanitizeBusinessPayload(data),
      auth: true,
    );
    return BusinessModel.fromJson(response['data']);
  }

  Future<void> deleteBusiness(String id) async {
    await _api.delete('/partner/me/businesses/$id', auth: true);
  }

  Future<BusinessModel> updateBusiness(String id, Map<String, dynamic> data) async {
    final response = await _api.put(
      '/partner/me/businesses/$id',
      body: _sanitizeBusinessPayload(data),
      auth: true,
    );
    return BusinessModel.fromJson(response['data']);
  }

  // Properties (partner-owned)
  Future<List<PropertyModel>> getProperties() async {
    final response = await _api.get('/partner/me/properties', auth: true);
    final data = response['data'] as List;
    return data.map((e) => PropertyModel.fromJson(e)).toList();
  }

  Future<PropertyModel> createProperty(Map<String, dynamic> data) async {
    final response = await _api.post(
      '/partner/me/properties',
      body: _sanitizePartnerPropertyPayload(data),
      auth: true,
    );
    return PropertyModel.fromJson(response['data']);
  }

  Future<PropertyModel> updateProperty(String id, Map<String, dynamic> data) async {
    final response = await _api.put(
      '/partner/me/properties/$id',
      body: _sanitizePartnerPropertyPayload(data),
      auth: true,
    );
    return PropertyModel.fromJson(response['data']);
  }

  Future<void> deleteProperty(String id) async {
    await _api.delete('/partner/me/properties/$id', auth: true);
  }

  // Amenities
  Future<List<AmenityModel>> getAmenities() async {
    final response = await _api.get('/partner/me/amenities', auth: true);
    final data = response['data'] as List;
    return data.map((e) => AmenityModel.fromJson(e)).toList();
  }

  Future<AmenityModel> createAmenity(Map<String, dynamic> data) async {
    final response = await _api.post(
      '/partner/me/amenities',
      body: _sanitizeAmenityPayload(data),
      auth: true,
    );
    return AmenityModel.fromJson(response['data']);
  }

  Future<void> deleteAmenity(String id) async {
    await _api.delete('/partner/me/amenities/$id', auth: true);
  }

  Future<AmenityModel> updateAmenity(String id, Map<String, dynamic> data) async {
    final response = await _api.put(
      '/partner/me/amenities/$id',
      body: _sanitizeAmenityPayload(data),
      auth: true,
    );
    return AmenityModel.fromJson(response['data']);
  }

  // Service Categories (for dropdown)
  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    // Public endpoint; avoid coupling dropdown population to partner auth state.
    final response = await _api.get('/service-categories');
    final data = response['data'] as List;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
