import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import 'profile_image.dart';
import 'star_rating_row.dart';

/// Shared service provider card used in list screens.
///
/// Figma: white container, borderRadius 25, conditional shadow,
/// profile image (94×89 top-rated / 74×74 normal),
/// "#1 Top Rated" badge #FF3E3E, heart toggle via FavoriteProvider.
class ServiceProviderCard extends StatelessWidget {
  final int index;
  final bool isTopRated;
  final String name;
  final String? providerId;
  final String location;
  final String rating;
  final String reviews;
  final String? profileImage;
  final IconData fallbackIcon;
  final VoidCallback? onTap;
  final String entityType;

  const ServiceProviderCard({
    super.key,
    required this.index,
    this.isTopRated = false,
    required this.name,
    this.providerId,
    required this.location,
    required this.rating,
    required this.reviews,
    this.profileImage,
    this.fallbackIcon = Icons.person,
    this.onTap,
    this.entityType = 'service_provider',
  });

  @override
  Widget build(BuildContext context) {
    final ratingValue = double.tryParse(rating) ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isTopRated
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 25,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isTopRated ? 11 : 15,
              20,
              15,
              isTopRated ? 20 : 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile image
                Container(
                  width: isTopRated ? 94 : 74,
                  height: isTopRated ? 89 : 74,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(isTopRated ? 20 : 37),
                    border: Border.all(
                      color: const Color(0xFF044870),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(isTopRated ? 18 : 35),
                    child: buildProfileImage(
                      profileImage,
                      fallbackIcon: fallbackIcon,
                      iconSize: isTopRated ? 50 : 35,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Provider info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top row: info + heart
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  if (isTopRated) ...[
                                    Text(
                                      '#1 Top Rated',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFFF3E3E),
                                        letterSpacing: 0.168,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                  Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF353535),
                                      letterSpacing: 0.112,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    location,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF044870),
                                      letterSpacing: 0.168,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Heart toggle
                            Consumer<FavoriteProvider>(
                              builder: (context, favProvider, _) {
                                final pid = providerId ?? '';
                                final isFav = entityType == 'amenity'
                                    ? favProvider.isAmenityFavorited(pid)
                                    : entityType == 'business'
                                        ? favProvider.isBusinessFavorited(pid)
                                        : favProvider.isServiceProviderFavorited(pid);
                                return GestureDetector(
                                  onTap: () {
                                    if (providerId != null) {
                                      if (entityType == 'amenity') {
                                        favProvider.toggleAmenityFavorite(providerId!);
                                      } else if (entityType == 'business') {
                                        favProvider.toggleBusinessFavorite(providerId!);
                                      } else {
                                        favProvider.toggleServiceProviderFavorite(providerId!);
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_outline,
                                      size: 22,
                                      color: isFav
                                          ? const Color(0xFFFF5050)
                                          : const Color(0xFF8C8C8C),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Rating section
                        Row(
                          children: [
                            StarRatingRow(
                              rating: ratingValue,
                              starSize: isTopRated ? 15 : 12.5,
                              emptyColor: const Color(0xFFF9F9F9),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$rating ($reviews Reviews)',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF353535),
                                  letterSpacing: 0.168,
                                  height: 1.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

