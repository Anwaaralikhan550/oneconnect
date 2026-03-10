class PromotionModel {
  final String id;
  final String title;
  final String? businessId;
  final String? imageUrl;
  final double? price;
  final double? discountPct;
  final String? description;
  final bool isActive;
  final String? businessName;
  final DateTime? expiresAt;

  PromotionModel({
    required this.id,
    required this.title,
    this.businessId,
    this.imageUrl,
    this.price,
    this.discountPct,
    this.description,
    this.isActive = true,
    this.businessName,
    this.expiresAt,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    final partner = json['partner'] as Map<String, dynamic>?;
    return PromotionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      businessId: json['businessId'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num?)?.toDouble(),
      discountPct: (json['discountPct'] as num?)?.toDouble(),
      description: json['description'],
      isActive: json['isActive'] ?? true,
      businessName: partner?['businessName'],
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
}
