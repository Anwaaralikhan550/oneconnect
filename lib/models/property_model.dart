class PropertyModel {
  final String id;
  final String? partnerId;
  final String? serviceProviderId;
  final String title;
  final String? location;
  final int? beds;
  final int? baths;
  final int? kitchen;
  final String? propertyType;
  final String? purpose;
  final String? listingStatus;
  final double? price;
  final String? mainImageUrl;
  final String? description;
  final double? sqft;
  final double? latitude;
  final double? longitude;
  final List<PropertyImage> images;
  final PropertyAgentModel? partner;
  final PropertyServiceProviderModel? serviceProvider;

  PropertyModel({
    required this.id,
    this.partnerId,
    this.serviceProviderId,
    required this.title,
    this.location,
    this.beds,
    this.baths,
    this.kitchen,
    this.propertyType,
    this.purpose,
    this.listingStatus,
    this.price,
    this.mainImageUrl,
    this.description,
    this.sqft,
    this.latitude,
    this.longitude,
    this.images = const [],
    this.partner,
    this.serviceProvider,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? '',
      partnerId: json['partnerId'],
      serviceProviderId: json['serviceProviderId'],
      title: json['title'] ?? '',
      location: json['location'],
      beds: json['beds'],
      baths: json['baths'],
      kitchen: json['kitchen'],
      propertyType: json['propertyType'],
      purpose: json['purpose'],
      listingStatus: json['listingStatus'],
      price: (json['price'] as num?)?.toDouble(),
      mainImageUrl: json['mainImageUrl'],
      description: json['description'],
      sqft: (json['sqft'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble() ??
          (json['lat'] as num?)?.toDouble() ??
          (json['locationLat'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble() ??
          (json['lng'] as num?)?.toDouble() ??
          (json['locationLng'] as num?)?.toDouble(),
      images: (json['images'] as List?)
          ?.map((i) => PropertyImage.fromJson(i))
          .toList() ?? [],
      partner: json['partner'] is Map<String, dynamic>
          ? PropertyAgentModel.fromJson(json['partner'] as Map<String, dynamic>)
          : null,
      serviceProvider: json['serviceProvider'] is Map<String, dynamic>
          ? PropertyServiceProviderModel.fromJson(json['serviceProvider'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PropertyAgentModel {
  final String id;
  final String? businessId;
  final String? businessName;
  final String? ownerFullName;
  final String? profilePhotoUrl;
  final String? openingTime;
  final String? closingTime;
  final bool isBusinessOpen;
  final String? address;
  final String? city;
  final double rating;
  final String? phone;

  PropertyAgentModel({
    required this.id,
    this.businessId,
    this.businessName,
    this.ownerFullName,
    this.profilePhotoUrl,
    this.openingTime,
    this.closingTime,
    this.isBusinessOpen = false,
    this.address,
    this.city,
    this.rating = 0,
    this.phone,
  });

  factory PropertyAgentModel.fromJson(Map<String, dynamic> json) {
    final phones = (json['phones'] as List?) ?? const [];
    String? phone;
    if (phones.isNotEmpty && phones.first is Map) {
      final p = phones.first as Map;
      final cc = (p['countryCode'] ?? '').toString();
      final pn = (p['phoneNumber'] ?? '').toString();
      phone = '$cc$pn'.trim();
    }

    return PropertyAgentModel(
      id: json['id'] ?? '',
      businessId: json['businessId'],
      businessName: json['businessName'],
      ownerFullName: json['ownerFullName'],
      profilePhotoUrl: json['profilePhotoUrl'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      isBusinessOpen: json['isBusinessOpen'] ?? false,
      address: json['address'],
      city: json['city'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      phone: phone,
    );
  }
}

class PropertyServiceProviderModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String? serviceType;

  PropertyServiceProviderModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.serviceType,
  });

  factory PropertyServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return PropertyServiceProviderModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
      serviceType: json['serviceType'],
    );
  }
}

class PropertyImage {
  final String id;
  final String imageUrl;
  final int sortOrder;

  PropertyImage({required this.id, required this.imageUrl, this.sortOrder = 0});

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}
