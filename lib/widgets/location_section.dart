import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/map_utils.dart';

/// Shared location section used across detail screens.
///
/// Figma: bg #F4F4F4, border-radius 15, red location icon,
/// "View on Map" button #696969.
class LocationSection extends StatelessWidget {
  final String? locationText;
  final double? latitude;
  final double? longitude;
  final String? entityName;
  final VoidCallback? onViewMap;

  const LocationSection({
    super.key,
    this.locationText,
    this.latitude,
    this.longitude,
    this.entityName,
    this.onViewMap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double rw(double v) => (v / 390) * screenWidth;
    double rh(double v) => (v / 844) * screenHeight;
    double rfs(double v) => (v / 390) * screenWidth;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
      padding: EdgeInsets.symmetric(horizontal: rw(25), vertical: rh(15)),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Location Icon — Figma: 22.5×20.5, red
          SvgPicture.asset(
            'assets/icons/figma_location_filled_icon.svg',
            width: rw(22.5),
            height: rw(20.512),
            colorFilter: const ColorFilter.mode(
              Color(0xFFE53935),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: rw(5)),
          // Address
          Expanded(
            child: Text(
              locationText ?? 'Location not available',
              style: GoogleFonts.roboto(
                fontSize: rfs(14),
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: rw(10)),
          // View on Map Button
          GestureDetector(
            onTap: onViewMap ??
                () async {
                  if (latitude != null && longitude != null) {
                    await openMapAtCoordinates(
                      context,
                      latitude: latitude!,
                      longitude: longitude!,
                      label: entityName ?? locationText,
                    );
                    return;
                  }
                  await openMapForQuery(context, locationText ?? '');
                },
            child: Container(
              width: rw(106),
              height: rh(25),
              decoration: BoxDecoration(
                color: const Color(0xFF696969),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  'View on Map',
                  style: GoogleFonts.inter(
                    fontSize: rfs(12),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
