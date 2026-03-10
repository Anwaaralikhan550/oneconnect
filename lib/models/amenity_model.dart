import 'review_model.dart';

class AmenityMediaModel {
  final String id;
  final String mediaType;
  final String fileUrl;
  final String? fileName;
  final int? fileSizeKb;

  AmenityMediaModel({
    required this.id,
    required this.mediaType,
    required this.fileUrl,
    this.fileName,
    this.fileSizeKb,
  });

  factory AmenityMediaModel.fromJson(Map<String, dynamic> json) {
    return AmenityMediaModel(
      id: json['id'] ?? '',
      mediaType: json['mediaType'] ?? 'PHOTO',
      fileUrl: json['fileUrl'] ?? '',
      fileName: json['fileName'],
      fileSizeKb: json['fileSizeKb'] as int?,
    );
  }
}

class AmenityModel {
  final String id;
  final String name;
  final String amenityType;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final bool isOpen;
  final double rating;
  final int reviewCount;
  final String? openingTime;
  final String? closingTime;
  final List<String> operatingDays;
  final List<String> servicesOffered;
  final int followersCount;
  final String? imageUrl;
  final String? phone;
  final String? description;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? whatsapp;
  final String? websiteUrl;
  final List<ReviewModel> reviews;
  final List<AmenityMediaModel> media;

  AmenityModel({
    required this.id,
    required this.name,
    required this.amenityType,
    this.location,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isOpen = true,
    this.rating = 0,
    this.reviewCount = 0,
    this.openingTime,
    this.closingTime,
    this.operatingDays = const [],
    this.servicesOffered = const [],
    this.followersCount = 0,
    this.imageUrl,
    this.phone,
    this.description,
    this.facebookUrl,
    this.instagramUrl,
    this.whatsapp,
    this.websiteUrl,
    this.reviews = const [],
    this.media = const [],
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    final reviewsList = (json['reviews'] as List?)
        ?.map((r) => ReviewModel.fromJson(r as Map<String, dynamic>))
        .toList() ?? [];
    final mediaList = (json['media'] as List?)
        ?.map((m) => AmenityMediaModel.fromJson(m as Map<String, dynamic>))
        .toList() ?? [];

    return AmenityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amenityType: json['amenityType'] ?? '',
      location: json['location'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      isOpen: json['isOpen'] ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      operatingDays: (json['operatingDays'] as List?)?.map((d) => d.toString()).toList() ?? [],
      servicesOffered: (json['servicesOffered'] as List?)?.map((s) => s.toString()).toList() ?? [],
      followersCount: json['followersCount'] ?? 0,
      imageUrl: json['imageUrl'],
      phone: json['phone'],
      description: json['description'],
      facebookUrl: json['facebookUrl'],
      instagramUrl: json['instagramUrl'],
      whatsapp: json['whatsapp'],
      websiteUrl: json['websiteUrl'],
      reviews: reviewsList,
      media: mediaList,
    );
  }

  AmenityModel copyWith({
    double? rating,
    int? reviewCount,
    List<ReviewModel>? reviews,
  }) {
    return AmenityModel(
      id: id,
      name: name,
      amenityType: amenityType,
      location: location,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      isOpen: isOpen,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openingTime: openingTime,
      closingTime: closingTime,
      operatingDays: operatingDays,
      servicesOffered: servicesOffered,
      followersCount: followersCount,
      imageUrl: imageUrl,
      phone: phone,
      description: description,
      facebookUrl: facebookUrl,
      instagramUrl: instagramUrl,
      whatsapp: whatsapp,
      websiteUrl: websiteUrl,
      reviews: reviews ?? this.reviews,
      media: media,
    );
  }
}
