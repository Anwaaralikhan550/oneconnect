import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared header for list screens (barber, electricians, plumber, etc.).
///
/// Figma: Container #F1F1F1, bottom radius 50, back arrow #3195AB,
/// title Inter 25px #515151, search icon #156385.
class ListScreenHeader extends StatelessWidget {
  final String title;
  final String? categoryIconAsset;
  final double? iconWidth;
  final double? iconHeight;
  final double iconOffsetY;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;

  const ListScreenHeader({
    super.key,
    required this.title,
    this.categoryIconAsset,
    this.iconWidth,
    this.iconHeight,
    this.iconOffsetY = 0,
    this.onBack,
    this.onSearch,
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
    final double iconOverlap = categoryIconAsset != null ? rw(20) : 0;
    final bool keepOriginalIconColors =
        (categoryIconAsset ?? '').endsWith('fluent_real_estate_filled.svg');

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
                  // Search icon
                  GestureDetector(
                    onTap: onSearch,
                    child: Container(
                      width: rw(56),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/search_header.svg',
                        width: rw(24),
                        height: rw(24),
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF156385),
                          BlendMode.srcIn,
                        ),
                        placeholderBuilder: (_) => Icon(
                          Icons.search,
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
        if (categoryIconAsset != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: -rw(27 + extraOffset + iconOffsetY),
            child: Center(
              child: SizedBox(
                width: rw(iconWidth ?? 59),
                height: rw(iconHeight ?? 59),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SvgPicture.asset(
                    categoryIconAsset!,
                    colorFilter: keepOriginalIconColors
                        ? null
                        : const ColorFilter.mode(
                            Color(0xFF515151),
                            BlendMode.srcIn,
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
