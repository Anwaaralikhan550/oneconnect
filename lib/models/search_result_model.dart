class SearchSuggestion {
  final String name;
  final String type; // 'service', 'business', 'amenity'
  final String? subType;

  SearchSuggestion({required this.name, required this.type, this.subType});

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      subType: json['subType'],
    );
  }
}

class AdminOfficeModel {
  final String id;
  final String name;
  final String officeType;
  final double rating;
  final String? phone;
  final bool isOpen;
  final String? address;
  final String? imageUrl;

  AdminOfficeModel({
    required this.id,
    required this.name,
    required this.officeType,
    this.rating = 0,
    this.phone,
    this.isOpen = true,
    this.address,
    this.imageUrl,
  });

  factory AdminOfficeModel.fromJson(Map<String, dynamic> json) {
    return AdminOfficeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      officeType: json['officeType'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      phone: json['phone'],
      isOpen: json['isOpen'] ?? true,
      address: json['address'],
      imageUrl: json['imageUrl'],
    );
  }
}
