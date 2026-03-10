import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_image.dart';

/// Shared "Review Us" section for detail screens.
///
/// Figma: Container #FAFAFA with top/bottom borders, avatar 42×42,
/// name Poppins 15/w500, verified icon, "Give a Review" button #3195AB.
class ReviewUsSection extends StatelessWidget {
  final String? entityName;
  final String? entityImageUrl;
  final String displayMetric;
  final IconData fallbackIcon;
  final VoidCallback onGiveReview;

  const ReviewUsSection({
    super.key,
    this.entityName,
    this.entityImageUrl,
    this.displayMetric = '0 Reviews',
    this.fallbackIcon = Icons.store,
    required this.onGiveReview,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    double rw(double v) => (v / 390) * sw;
    double rh(double v) => (v / 844) * sh;
    double rfs(double v) => (v / 390) * sw;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: rh(10), horizontal: rw(20)),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Color(0xFFE3E3E3), width: 1),
          bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar + Info
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(5)),
                  child: ClipOval(
                    child: SizedBox(
                      width: rw(42),
                      height: rw(42),
                      child: buildProfileImage(
                        entityImageUrl,
                        fallbackIcon: fallbackIcon,
                        iconSize: 25,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: rw(5)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entityName ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: rfs(15),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF141414),
                                height: 16 / 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        displayMetric,
                        style: GoogleFonts.poppins(
                          fontSize: rfs(11),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF828282),
                          height: 16 / 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: rw(10)),
          // Give a Review button
          GestureDetector(
            onTap: onGiveReview,
            child: Container(
              width: rw(130),
              padding:
                  EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(8)),
              decoration: BoxDecoration(
                color: const Color(0xFF3195AB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Give a Review',
                  style: GoogleFonts.poppins(
                    fontSize: rfs(13),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
