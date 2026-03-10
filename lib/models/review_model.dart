class ReviewModel {
  final String id;
  final double rating;
  final String? ratingText;
  final String? reviewText;
  final String userName;
  final String? userPhotoUrl;
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
    required this.createdAt,
    this.helpfulCount = 0,
    this.unhelpfulCount = 0,
    this.userVote,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingText: json['ratingText'],
      reviewText: json['reviewText'],
      userName: user?['name'] ?? 'Anonymous',
      userPhotoUrl: user?['profilePhotoUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      helpfulCount: json['helpfulCount'] ?? 0,
      unhelpfulCount: json['unhelpfulCount'] ?? 0,
      userVote: json['currentUserVote'],
    );
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
      createdAt: createdAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      unhelpfulCount: unhelpfulCount ?? this.unhelpfulCount,
      userVote: clearUserVote ? null : (userVote ?? this.userVote),
    );
  }
}
