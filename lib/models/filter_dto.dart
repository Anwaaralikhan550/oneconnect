class FilterDto {
  final String? category;
  final String? entityType;
  final String? locationMode;
  final String? priceTier;
  final String? sortBy;
  final String? area;
  final double? minRating;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final int? page;
  final int? limit;

  const FilterDto({
    this.category,
    this.entityType,
    this.locationMode,
    this.priceTier,
    this.sortBy,
    this.area,
    this.minRating,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.page,
    this.limit,
  });

  String get cacheKey => toQueryParams().entries.map((e) => '${e.key}=${e.value}').join('&');

  Map<String, String> toQueryParams() {
    final map = <String, String>{};
    if (category != null && category!.isNotEmpty) map['category'] = category!;
    if (entityType != null && entityType!.isNotEmpty) map['entityType'] = entityType!;
    if (locationMode != null && locationMode!.isNotEmpty) map['locationMode'] = locationMode!;
    if (priceTier != null && priceTier!.isNotEmpty) map['priceTier'] = priceTier!;
    if (sortBy != null && sortBy!.isNotEmpty) map['sortBy'] = sortBy!;
    if (area != null && area!.isNotEmpty) map['area'] = area!;
    if (minRating != null) map['minRating'] = minRating!.toString();
    if (latitude != null) map['latitude'] = latitude!.toString();
    if (longitude != null) map['longitude'] = longitude!.toString();
    if (radiusKm != null) map['radiusKm'] = radiusKm!.toString();
    if (page != null) map['page'] = page!.toString();
    if (limit != null) map['limit'] = limit!.toString();
    return map;
  }

  FilterDto copyWith({
    String? category,
    String? entityType,
    String? locationMode,
    String? priceTier,
    String? sortBy,
    String? area,
    double? minRating,
    double? latitude,
    double? longitude,
    double? radiusKm,
    int? page,
    int? limit,
  }) {
    return FilterDto(
      category: category ?? this.category,
      entityType: entityType ?? this.entityType,
      locationMode: locationMode ?? this.locationMode,
      priceTier: priceTier ?? this.priceTier,
      sortBy: sortBy ?? this.sortBy,
      area: area ?? this.area,
      minRating: minRating ?? this.minRating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}
