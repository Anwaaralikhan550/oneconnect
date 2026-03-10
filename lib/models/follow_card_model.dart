import '../utils/media_url.dart';

class FollowCardModel {
  final String id;
  final String entityType;
  final String name;
  final String subtitle;
  final String? imageUrl;
  final int followersCount;
  final bool isFollowing;
  final bool isFollowEnabled;
  final bool isProfessionalProfileEnabled;
  final bool isVerified;
  final String location;

  const FollowCardModel({
    required this.id,
    required this.entityType,
    required this.name,
    required this.subtitle,
    this.imageUrl,
    this.followersCount = 0,
    this.isFollowing = false,
    this.isFollowEnabled = false,
    this.isProfessionalProfileEnabled = false,
    this.isVerified = true,
    this.location = '',
  });

  factory FollowCardModel.fromJson(Map<String, dynamic> json) {
    return FollowCardModel(
      id: (json['id'] ?? '').toString(),
      entityType: (json['entityType'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      imageUrl: resolveMediaUrl(json['imageUrl']?.toString()),
      followersCount: json['followersCount'] as int? ?? 0,
      isFollowing: json['isFollowing'] == true,
      isFollowEnabled: json['isFollowEnabled'] == true,
      isProfessionalProfileEnabled: json['isProfessionalProfileEnabled'] == true,
      isVerified: json['isVerified'] != false,
      location: (json['location'] ?? '').toString(),
    );
  }

  FollowCardModel copyWith({
    int? followersCount,
    bool? isFollowing,
  }) {
    return FollowCardModel(
      id: id,
      entityType: entityType,
      name: name,
      subtitle: subtitle,
      imageUrl: imageUrl,
      followersCount: followersCount ?? this.followersCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowEnabled: isFollowEnabled,
      isProfessionalProfileEnabled: isProfessionalProfileEnabled,
      isVerified: isVerified,
      location: location,
    );
  }
}
