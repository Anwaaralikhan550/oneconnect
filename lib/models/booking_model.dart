class BookingModel {
  final String bookingId;
  final String customerId;
  final String providerId;
  final String serviceType;
  final String status;
  final DateTime bookingDate;
  final DateTime createdAt;
  final double? userLatitude;
  final double? userLongitude;

  final String? providerName;
  final String? providerPhone;
  final String? providerImageUrl;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerImageUrl;

  BookingModel({
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.serviceType,
    required this.status,
    required this.bookingDate,
    required this.createdAt,
    this.userLatitude,
    this.userLongitude,
    this.providerName,
    this.providerPhone,
    this.providerImageUrl,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerImageUrl,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;
    return BookingModel(
      bookingId: (json['bookingId'] ?? '').toString(),
      customerId: (json['customerId'] ?? '').toString(),
      providerId: (json['providerId'] ?? '').toString(),
      serviceType: (json['serviceType'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      bookingDate: DateTime.tryParse((json['bookingDate'] ?? '').toString()) ?? DateTime.now(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      userLatitude: (json['userLatitude'] as num?)?.toDouble(),
      userLongitude: (json['userLongitude'] as num?)?.toDouble(),
      providerName: provider?['name']?.toString(),
      providerPhone: provider?['phone']?.toString(),
      providerImageUrl: provider?['imageUrl']?.toString(),
      customerName: customer?['name']?.toString(),
      customerPhone: customer?['phone']?.toString(),
      customerEmail: customer?['email']?.toString(),
      customerImageUrl: customer?['profilePhotoUrl']?.toString(),
    );
  }
}
