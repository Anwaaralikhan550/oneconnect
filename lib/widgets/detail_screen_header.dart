import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared header for detail screens (cafe, gym, school, pharmacy, etc.).
///
/// Matches ListScreenHeader layout: Stack with overlapping icon at bottom.
/// Uses share icon on right instead of search.
class DetailScreenHeader extends StatelessWidget {
  final String title;
  final String? iconAssetPath;
  final IconData? fallbackIcon;
  final double? iconWidth;
  final double? iconHeight;
  final VoidCallback? onBack;
  final VoidCallback? onShare;

  const DetailScreenHeader({
    super.key,
    required this.title,
    this.iconAssetPath,
    this.fallbackIcon,
    this.iconWidth,
    this.iconHeight,
    this.onBack,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    double rw(double v) => (v / 390) * sw;
    double rh(double v) => (v / 844) * sh;
    double rfs(double v) => (v / 390) * sw;

    final double actualIconW = (iconWidth ?? 59);
    final double extraOffset = (actualIconW - 59) / 2;
    final double iconOverlap = iconAssetPath != null ? rw(20) : 0;

    return Padding(
      padding: EdgeInsets.only(bottom: iconOverlap),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Header background
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(rw(50)),
                bottomRight: Radius.circular(rw(50)),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  top: rh(38),
                  bottom: rh(32) + iconOverlap,
                ),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: onBack ?? () => Navigator.pop(context),
                      child: Container(
                        width: rw(56),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/back_arrow_teal.svg',
                          width: rw(20),
                          height: rw(20),
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF3195AB),
                            BlendMode.srcIn,
                          ),
                          placeholderBuilder: (_) => Icon(
                            Icons.arrow_back_ios,
                            size: rw(20),
                            color: const Color(0xFF3195AB),
                          ),
                        ),
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: rfs(27),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF515151),
                            letterSpacing: -0.28,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Share icon
                    GestureDetector(
                      onTap: onShare,
                      child: Container(
                        width: rw(56),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/share.svg',
                          width: rw(24),
                          height: rw(24),
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF156385),
                            BlendMode.srcIn,
                          ),
                          placeholderBuilder: (_) => Icon(
                            Icons.share,
                            size: rw(24),
                            color: const Color(0xFF156385),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Category icon — overlapping at bottom center
          if (iconAssetPath != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: -rw(27 + extraOffset),
              child: Center(
                child: SizedBox(
                  width: rw(iconWidth ?? 59),
                  height: rw(iconHeight ?? 59),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SvgPicture.asset(
                      iconAssetPath!,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF515151),
                        BlendMode.srcIn,
                      ),
                      placeholderBuilder: (_) => Icon(
                        fallbackIcon ?? Icons.category,
                        size: rw(45),
                        color: const Color(0xFF515151),
                      ),
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
