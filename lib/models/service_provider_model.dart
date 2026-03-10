import 'review_model.dart';
import '../utils/media_url.dart';

class ServiceProviderModel {
  final String id;
  final String name;
  final String? phone;
  final String serviceType;
  final double rating;
  final int reviewCount;
  final String? address;
  final String? city;
  final double? serviceCharge;
  final bool isTopRated;
  final int jobsCompleted;
  final String? vendorId;
  final String? responseTime;
  final String? workingSince;
  final String? openingTime;
  final String? closingTime;
  final String? imageUrl;
  final int followersCount;
  final bool isFollowEnabled;
  final bool isProfessionalProfileEnabled;
  final bool isFollowing;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final List<String> skills;

  // Doctor-specific
  final int? patientsCount;
  final String? doctorId;
  final int? experienceYears;
  final String? hospitalName;
  final double? consultationCharge;

  // Category info
  final String? categoryName;
  final String? categorySlug;

  // Detail fields (populated by getById)
  final List<ReviewModel> reviews;
  final List<MediaItem> media;

  ServiceProviderModel({
    required this.id,
    required this.name,
    this.phone,
    required this.serviceType,
    this.rating = 0,
    this.reviewCount = 0,
    this.address,
    this.city,
    this.serviceCharge,
    this.isTopRated = false,
    this.jobsCompleted = 0,
    this.vendorId,
    this.responseTime,
    this.workingSince,
    this.openingTime,
    this.closingTime,
    this.imageUrl,
    this.followersCount = 0,
    this.isFollowEnabled = false,
    this.isProfessionalProfileEnabled = false,
    this.isFollowing = false,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.skills = const [],
    this.patientsCount,
    this.doctorId,
    this.experienceYears,
    this.hospitalName,
    this.consultationCharge,
    this.categoryName,
    this.categorySlug,
    this.reviews = const [],
    this.media = const [],
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    final skillsList = (json['skills'] as List?)
        ?.map((s) => s is Map ? (s['tagName'] ?? '') as String : s.toString())
        .toList() ?? [];

    final category = json['category'] as Map<String, dynamic>?;

    final reviewsList = (json['reviews'] as List?)
        ?.map((r) => ReviewModel.fromJson(r as Map<String, dynamic>))
        .toList() ?? [];

    final mediaList = ((json['media'] as List?) ?? (json['partner']?['media'] as List?))
        ?.map((m) => MediaItem.fromJson(m as Map<String, dynamic>))
        .toList() ?? [];

    return ServiceProviderModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      serviceType: json['serviceType'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      address: json['address'],
      city: json['city'],
      serviceCharge: (json['serviceCharge'] as num?)?.toDouble(),
      isTopRated: json['isTopRated'] ?? false,
      jobsCompleted: json['jobsCompleted'] ?? 0,
      vendorId: json['vendorId'],
      responseTime: json['responseTime'],
      workingSince: json['workingSince'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      imageUrl: resolveMediaUrl(json['imageUrl']?.toString()),
      followersCount: json['followersCount'] ?? 0,
      isFollowEnabled: json['isFollowEnabled'] ?? false,
      isProfessionalProfileEnabled:
          json['isProfessionalProfileEnabled'] ?? false,
      isFollowing: json['isFollowing'] ?? false,
      latitude: (json['latitude'] as num?)?.toDouble() ??
          (json['lat'] as num?)?.toDouble() ??
          (json['locationLat'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble() ??
          (json['lng'] as num?)?.toDouble() ??
          (json['locationLng'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      skills: skillsList,
      patientsCount: json['patientsCount'],
      doctorId: json['doctorId'],
      experienceYears: json['experienceYears'],
      hospitalName: json['hospitalName'],
      consultationCharge: (json['consultationCharge'] as num?)?.toDouble(),
      categoryName: category?['name'],
      categorySlug: category?['slug'],
      reviews: reviewsList,
      media: mediaList,
    );
  }

  ServiceProviderModel copyWithReviews(List<ReviewModel> newReviews) {
    return copyWith(reviews: newReviews);
  }

  ServiceProviderModel copyWith({
    double? rating,
    int? reviewCount,
    List<ReviewModel>? reviews,
  }) {
    return ServiceProviderModel(
      id: id,
      name: name,
      phone: phone,
      serviceType: serviceType,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      address: address,
      city: city,
      serviceCharge: serviceCharge,
      isTopRated: isTopRated,
      jobsCompleted: jobsCompleted,
      vendorId: vendorId,
      responseTime: responseTime,
      workingSince: workingSince,
      openingTime: openingTime,
      closingTime: closingTime,
      imageUrl: imageUrl,
      followersCount: followersCount,
      isFollowEnabled: isFollowEnabled,
      isProfessionalProfileEnabled: isProfessionalProfileEnabled,
      isFollowing: isFollowing,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      skills: skills,
      patientsCount: patientsCount,
      doctorId: doctorId,
      experienceYears: experienceYears,
      hospitalName: hospitalName,
      consultationCharge: consultationCharge,
      categoryName: categoryName,
      categorySlug: categorySlug,
      reviews: reviews ?? this.reviews,
      media: media,
    );
  }
}

class MediaItem {
  final String id;
  final String mediaType; // PHOTO or VIDEO
  final String fileUrl;
  final String? fileName;
  final int? fileSizeKb;
  final DateTime? createdAt;

  MediaItem({
    required this.id,
    required this.mediaType,
    required this.fileUrl,
    this.fileName,
    this.fileSizeKb,
    this.createdAt,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
    id: json['id'] ?? '',
    mediaType: json['mediaType'] ?? 'PHOTO',
    fileUrl: resolveMediaUrl(json['fileUrl']?.toString()) ?? '',
    fileName: json['fileName'],
    fileSizeKb: json['fileSizeKb'] as int?,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString())
        : null,
  );
}
