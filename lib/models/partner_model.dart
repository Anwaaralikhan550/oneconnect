import 'promotion_model.dart';

class PartnerMediaModel {
  final String id;
  final String mediaType;
  final String fileUrl;
  final String? fileName;
  final int? fileSizeKb;
  final DateTime? createdAt;

  PartnerMediaModel({
    required this.id,
    required this.mediaType,
    required this.fileUrl,
    this.fileName,
    this.fileSizeKb,
    this.createdAt,
  });

  factory PartnerMediaModel.fromJson(Map<String, dynamic> json) {
    return PartnerMediaModel(
      id: json['id'] ?? '',
      mediaType: json['mediaType'] ?? 'IMAGE',
      fileUrl: json['fileUrl'] ?? '',
      fileName: json['fileName'],
      fileSizeKb: json['fileSizeKb'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}

class PartnerCategoryModel {
  final String id;
  final String categoryId;
  final String categoryName;
  final String categorySlug;

  PartnerCategoryModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categorySlug,
  });

  factory PartnerCategoryModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return PartnerCategoryModel(
      id: json['id'] ?? '',
      categoryId: category?['id'] ?? json['categoryId'] ?? '',
      categoryName: category?['name'] ?? '',
      categorySlug: category?['slug'] ?? '',
    );
  }
}

class PartnerModel {
  final String id;
  final String businessId;
  final String businessName;
  final String ownerFullName;
  final String? businessEmail;
  final String businessType;
  final String status;
  final String? address;
  final String? area;
  final String? city;
  final String? country;
  final bool isBusinessOpen;
  final String? openingTime;
  final String? closingTime;
  final double rating;
  final String? profilePhotoUrl;
  final String? description;
  final bool followUsEnabled;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? whatsapp;
  final String? websiteUrl;
  final List<PartnerPhone> phones;
  final List<String> operatingDays;
  final List<PartnerMediaModel> media;
  final List<PromotionModel> promotions;
  final List<PartnerCategoryModel> partnerCategories;

  PartnerModel({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.ownerFullName,
    this.businessEmail,
    required this.businessType,
    this.status = 'PENDING_REVIEW',
    this.address,
    this.area,
    this.city,
    this.country,
    this.isBusinessOpen = false,
    this.openingTime,
    this.closingTime,
    this.rating = 0,
    this.profilePhotoUrl,
    this.description,
    this.followUsEnabled = true,
    this.facebookUrl,
    this.instagramUrl,
    this.whatsapp,
    this.websiteUrl,
    this.phones = const [],
    this.operatingDays = const [],
    this.media = const [],
    this.promotions = const [],
    this.partnerCategories = const [],
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] ?? '',
      businessId: json['businessId'] ?? '',
      businessName: json['businessName'] ?? '',
      ownerFullName: json['ownerFullName'] ?? '',
      businessEmail: json['businessEmail'],
      businessType: json['businessType'] ?? '',
      status: json['status'] ?? 'PENDING_REVIEW',
      address: json['address'],
      area: json['area'],
      city: json['city'],
      country: json['country'],
      isBusinessOpen: json['isBusinessOpen'] ?? false,
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      profilePhotoUrl: json['profilePhotoUrl'],
      description: json['description'],
      followUsEnabled: json['followUsEnabled'] ?? true,
      facebookUrl: json['facebookUrl'],
      instagramUrl: json['instagramUrl'],
      whatsapp: json['whatsapp'],
      websiteUrl: json['websiteUrl'],
      phones: (json['phones'] as List?)
          ?.map((p) => PartnerPhone.fromJson(p))
          .toList() ?? [],
      operatingDays: (json['operatingDays'] as List?)
          ?.map((d) => (d['dayCode'] ?? '') as String)
          .toList() ?? [],
      media: (json['media'] as List?)
          ?.map((m) => PartnerMediaModel.fromJson(m))
          .toList() ?? [],
      promotions: (json['promotions'] as List?)
          ?.map((p) => PromotionModel.fromJson(p))
          .toList() ?? [],
      partnerCategories: (json['partnerCategories'] as List?)
          ?.map((c) => PartnerCategoryModel.fromJson(c))
          .toList() ?? [],
    );
  }

  PartnerModel copyWith({
    String? id,
    String? businessId,
    String? businessName,
    String? ownerFullName,
    String? businessEmail,
    String? businessType,
    String? status,
    String? address,
    String? area,
    String? city,
    String? country,
    bool? isBusinessOpen,
    String? openingTime,
    String? closingTime,
    double? rating,
    String? profilePhotoUrl,
    String? description,
    bool? followUsEnabled,
    String? facebookUrl,
    String? instagramUrl,
    String? whatsapp,
    String? websiteUrl,
    List<PartnerPhone>? phones,
    List<String>? operatingDays,
    List<PartnerMediaModel>? media,
    List<PromotionModel>? promotions,
    List<PartnerCategoryModel>? partnerCategories,
  }) {
    return PartnerModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      ownerFullName: ownerFullName ?? this.ownerFullName,
      businessEmail: businessEmail ?? this.businessEmail,
      businessType: businessType ?? this.businessType,
      status: status ?? this.status,
      address: address ?? this.address,
      area: area ?? this.area,
      city: city ?? this.city,
      country: country ?? this.country,
      isBusinessOpen: isBusinessOpen ?? this.isBusinessOpen,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      rating: rating ?? this.rating,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      description: description ?? this.description,
      followUsEnabled: followUsEnabled ?? this.followUsEnabled,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      whatsapp: whatsapp ?? this.whatsapp,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      phones: phones ?? this.phones,
      operatingDays: operatingDays ?? this.operatingDays,
      media: media ?? this.media,
      promotions: promotions ?? this.promotions,
      partnerCategories: partnerCategories ?? this.partnerCategories,
    );
  }
}

class PartnerPhone {
  final String phoneNumber;
  final String countryCode;
  final bool isPrimary;

  PartnerPhone({
    required this.phoneNumber,
    this.countryCode = '+92',
    this.isPrimary = false,
  });

  factory PartnerPhone.fromJson(Map<String, dynamic> json) {
    return PartnerPhone(
      phoneNumber: json['phoneNumber'] ?? '',
      countryCode: json['countryCode'] ?? '+92',
      isPrimary: json['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'countryCode': countryCode,
    'isPrimary': isPrimary,
  };
}
