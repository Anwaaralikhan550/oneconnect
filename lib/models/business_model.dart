import 'review_model.dart';
import 'promotion_model.dart';
import '../utils/media_url.dart';

class BusinessMediaModel {
  final String id;
  final String mediaType;
  final String fileUrl;
  final String? fileName;
  final int? fileSizeKb;

  BusinessMediaModel({
    required this.id,
    required this.mediaType,
    required this.fileUrl,
    this.fileName,
    this.fileSizeKb,
  });

  factory BusinessMediaModel.fromJson(Map<String, dynamic> json) {
    return BusinessMediaModel(
      id: json['id'] ?? '',
      mediaType: json['mediaType'] ?? 'PHOTO',
      fileUrl: resolveMediaUrl(json['fileUrl']?.toString()) ?? '',
      fileName: json['fileName'],
      fileSizeKb: json['fileSizeKb'] as int?,
    );
  }
}

class BusinessModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final bool isOpen;
  final String? openingTime;
  final String? closingTime;
  final List<String> operatingDays;
  final List<String> servicesOffered;
  final int followersCount;
  final bool isFollowEnabled;
  final bool isFollowing;
  final String? imageUrl;
  final String? phone;
  final String? description;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? whatsapp;
  final String? websiteUrl;
  final List<ReviewModel> reviews;
  final List<BusinessMediaModel> media;
  final List<PromotionModel> promotions;

  BusinessModel({
    required this.id,
    required this.name,
    required this.category,
    this.rating = 0,
    this.reviewCount = 0,
    this.location,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isOpen = true,
    this.openingTime,
    this.closingTime,
    this.operatingDays = const [],
    this.servicesOffered = const [],
    this.followersCount = 0,
    this.isFollowEnabled = true,
    this.isFollowing = false,
    this.imageUrl,
    this.phone,
    this.description,
    this.facebookUrl,
    this.instagramUrl,
    this.whatsapp,
    this.websiteUrl,
    this.reviews = const [],
    this.media = const [],
    this.promotions = const [],
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    final reviewsList = (json['reviews'] as List?)
        ?.map((r) => ReviewModel.fromJson(r as Map<String, dynamic>))
        .toList() ?? [];
    final mediaList = (json['media'] as List?)
        ?.map((m) => BusinessMediaModel.fromJson(m as Map<String, dynamic>))
        .toList() ?? [];
    final promotionsList = (json['promotions'] as List?)
        ?.map((p) => PromotionModel.fromJson(p as Map<String, dynamic>))
        .toList() ?? [];

    return BusinessModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      location: json['location'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      isOpen: json['isOpen'] ?? true,
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      operatingDays: (json['operatingDays'] as List?)?.map((d) => d.toString()).toList() ?? [],
      servicesOffered: (json['servicesOffered'] as List?)?.map((s) => s.toString()).toList() ?? [],
      followersCount: json['followersCount'] ?? 0,
      isFollowEnabled: json['isFollowEnabled'] ?? true,
      isFollowing: json['isFollowing'] ?? false,
      imageUrl: resolveMediaUrl(json['imageUrl']?.toString()),
      phone: json['phone'],
      description: json['description'],
      facebookUrl: json['facebookUrl'],
      instagramUrl: json['instagramUrl'],
      whatsapp: json['whatsapp'],
      websiteUrl: json['websiteUrl'],
      reviews: reviewsList,
      media: mediaList,
      promotions: promotionsList,
    );
  }

  BusinessModel copyWith({
    double? rating,
    int? reviewCount,
    List<ReviewModel>? reviews,
  }) {
    return BusinessModel(
      id: id,
      name: name,
      category: category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      location: location,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      isOpen: isOpen,
      openingTime: openingTime,
      closingTime: closingTime,
      operatingDays: operatingDays,
      servicesOffered: servicesOffered,
      followersCount: followersCount,
      isFollowEnabled: isFollowEnabled,
      isFollowing: isFollowing,
      imageUrl: imageUrl,
      phone: phone,
      description: description,
      facebookUrl: facebookUrl,
      instagramUrl: instagramUrl,
      whatsapp: whatsapp,
      websiteUrl: websiteUrl,
      reviews: reviews ?? this.reviews,
      media: media,
      promotions: promotions,
    );
  }
}
