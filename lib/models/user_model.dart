class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhotoUrl;
  final String? bio;
  final String? address;
  final String? country;
  final String? gender;
  final String? occupation;
  final DateTime? dateOfBirth;
  final double? locationLat;
  final double? locationLng;
  final bool? notifySound;
  final bool? notifyVibrate;
  final bool? notifyEmailUpdates;
  final bool? notifySmsUpdates;
  final bool? notifyPushUpdates;
  final bool? notifyEmailReminders;
  final bool? notifySmsReminders;
  final bool? notifyPushReminders;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhotoUrl,
    this.bio,
    this.address,
    this.country,
    this.gender,
    this.occupation,
    this.dateOfBirth,
    this.locationLat,
    this.locationLng,
    this.notifySound,
    this.notifyVibrate,
    this.notifyEmailUpdates,
    this.notifySmsUpdates,
    this.notifyPushUpdates,
    this.notifyEmailReminders,
    this.notifySmsReminders,
    this.notifyPushReminders,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profilePhotoUrl: json['profilePhotoUrl'],
      bio: json['bio'],
      address: json['address'],
      country: json['country'],
      gender: json['gender'],
      occupation: json['occupation'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth']) : null,
      locationLat: (json['locationLat'] as num?)?.toDouble(),
      locationLng: (json['locationLng'] as num?)?.toDouble(),
      notifySound: json['notifySound'],
      notifyVibrate: json['notifyVibrate'],
      notifyEmailUpdates: json['notifyEmailUpdates'],
      notifySmsUpdates: json['notifySmsUpdates'],
      notifyPushUpdates: json['notifyPushUpdates'],
      notifyEmailReminders: json['notifyEmailReminders'],
      notifySmsReminders: json['notifySmsReminders'],
      notifyPushReminders: json['notifyPushReminders'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    if (phone != null) 'phone': phone,
    if (bio != null) 'bio': bio,
    if (address != null) 'address': address,
    if (country != null) 'country': country,
    if (gender != null) 'gender': gender,
    if (occupation != null) 'occupation': occupation,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
    if (locationLat != null) 'locationLat': locationLat,
    if (locationLng != null) 'locationLng': locationLng,
  };
}
