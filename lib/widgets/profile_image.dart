import 'package:flutter/material.dart';

/// Shared image widget that handles network URLs, local assets, and fallbacks.
/// Used across all list screens to display provider/business/amenity images.
Widget buildProfileImage(
  String? imageUrl, {
  IconData fallbackIcon = Icons.person,
  double iconSize = 35,
}) {
  final fallback = Container(
    color: const Color(0xFFF5F5F5),
    child: Icon(fallbackIcon, size: iconSize, color: Colors.grey),
  );

  if (imageUrl == null || imageUrl.isEmpty) return fallback;

  if (imageUrl.startsWith('http')) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }

  return Image.asset(
    imageUrl,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => fallback,
  );
}
