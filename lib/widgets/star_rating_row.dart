import 'package:flutter/material.dart';

/// Shared star rating widget matching Figma designs.
///
/// Two rendering modes:
/// - **Color swap** (default): one icon, filled/empty colors. Used in list cards.
/// - **Icon-based** (`useHalfStars: true`): star / star_half / star_border.
///   Used in detail screens where decimal ratings matter.
class StarRatingRow extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color filledColor;
  final Color emptyColor;
  final bool useHalfStars;
  final double spacing;

  const StarRatingRow({
    super.key,
    required this.rating,
    this.starSize = 15,
    this.filledColor = const Color(0xFFFFCD29),
    this.emptyColor = const Color(0xFFF9F9F9),
    this.useHalfStars = false,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final Widget star;

        if (useHalfStars) {
          // Mode 2: icon-based (detail screens)
          final IconData icon;
          if (index < rating.floor()) {
            icon = Icons.star;
          } else if (index < rating) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }
          star = Icon(icon, size: starSize, color: filledColor);
        } else {
          // Mode 1: color swap (list screens)
          final isFilled = index < rating.floor();
          star = Icon(
            Icons.star,
            size: starSize,
            color: isFilled ? filledColor : emptyColor,
          );
        }

        if (spacing > 0 && index < 4) {
          return Padding(
            padding: EdgeInsets.only(right: spacing),
            child: star,
          );
        }
        return star;
      }),
    );
  }
}
