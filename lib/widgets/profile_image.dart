import 'package:flutter/material.dart';
import '../utils/media_url.dart';

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

  final resolved = resolveMediaUrl(imageUrl);
  if (resolved == null || resolved.isEmpty) return fallback;

  if (resolved.startsWith('http')) {
    return Image.network(
      resolved,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }

  return Image.asset(
    resolved,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => fallback,
  );
}
