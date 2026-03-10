import '../utils/media_url.dart';

class ReviewModel {
  final String id;
  final double rating;
  final String? ratingText;
  final String? reviewText;
  final String userName;
  final String? userPhotoUrl;
  final String? mediaUrl;
  final String? mediaType;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final int helpfulCount;
  final int unhelpfulCount;
  final String? userVote; // null, "helpful", or "unhelpful"

  ReviewModel({
    required this.id,
    required this.rating,
    this.ratingText,
    this.reviewText,
    required this.userName,
    this.userPhotoUrl,
    this.mediaUrl,
    this.mediaType,
    this.mediaUrls = const [],
    required this.createdAt,
    this.helpfulCount = 0,
    this.unhelpfulCount = 0,
    this.userVote,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final mediaNode = json['media'];
    final mediaMap = mediaNode is Map<String, dynamic> ? mediaNode : null;
    final mediaList = mediaNode is List ? mediaNode : null;
    final firstMedia = mediaList != null && mediaList.isNotEmpty && mediaList.first is Map<String, dynamic>
        ? mediaList.first as Map<String, dynamic>
        : null;
    final createdAtRaw = json['createdAt']?.toString();
    final parsedCreatedAt = createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null;
    final resolvedSingleMedia = _resolve(
      json['mediaUrl'] ??
          json['imageUrl'] ??
          json['photoUrl'] ??
          json['fileUrl'] ??
          mediaMap?['fileUrl'] ??
          mediaMap?['mediaUrl'] ??
          firstMedia?['fileUrl'] ??
          firstMedia?['mediaUrl'],
    );

    final collectedMedia = <String>[];
    final mediaFromList = <dynamic>[
      if (json['imageUrls'] is List) ...(json['imageUrls'] as List),
      if (mediaList != null) ...mediaList,
    ];
    for (final item in mediaFromList) {
      if (item is String) {
        final url = _resolve(item);
        if (url != null && url.isNotEmpty && !collectedMedia.contains(url)) {
          collectedMedia.add(url);
        }
      } else if (item is Map<String, dynamic>) {
        final url = _resolve(item['fileUrl'] ?? item['mediaUrl'] ?? item['imageUrl']);
        if (url != null && url.isNotEmpty && !collectedMedia.contains(url)) {
          collectedMedia.add(url);
        }
      }
    }
    if (resolvedSingleMedia != null &&
        resolvedSingleMedia.isNotEmpty &&
        !collectedMedia.contains(resolvedSingleMedia)) {
      collectedMedia.insert(0, resolvedSingleMedia);
    }

    return ReviewModel(
      id: json['id'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingText: json['ratingText']?.toString(),
      reviewText: (json['reviewText'] ?? json['comment'])?.toString(),
      userName: (user?['name'] ?? json['userName'] ?? json['authorName'])?.toString() ?? 'Anonymous',
      userPhotoUrl: _resolve(json['userPhotoUrl'] ?? user?['profilePhotoUrl']),
      mediaUrl: resolvedSingleMedia,
      mediaType: (json['mediaType'] ?? mediaMap?['mediaType'] ?? firstMedia?['mediaType'])?.toString(),
      mediaUrls: collectedMedia,
      createdAt: parsedCreatedAt ?? DateTime.now(),
      helpfulCount: json['helpfulCount'] ?? 0,
      unhelpfulCount: json['unhelpfulCount'] ?? 0,
      userVote: json['currentUserVote'],
    );
  }

  static String? _resolve(dynamic url) {
    final raw = url?.toString();
    if (raw == null || raw.trim().isEmpty) return null;
    return resolveMediaUrl(raw);
  }

  ReviewModel copyWith({
    int? helpfulCount,
    int? unhelpfulCount,
    String? userVote,
    bool clearUserVote = false,
  }) {
    return ReviewModel(
      id: id,
      rating: rating,
      ratingText: ratingText,
      reviewText: reviewText,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      mediaUrls: mediaUrls,
      createdAt: createdAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      unhelpfulCount: unhelpfulCount ?? this.unhelpfulCount,
      userVote: clearUserVote ? null : (userVote ?? this.userVote),
    );
  }
}
