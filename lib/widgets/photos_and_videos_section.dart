import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A standardized "Photos and Videos" section used across all detail screens.
///
/// Displays a centered large image with smaller left/right previews.
class PhotosAndVideosSection extends StatefulWidget {
  final List<String> imageUrls;
  final double designWidth;
  final double designHeight;

  const PhotosAndVideosSection({
    super.key,
    this.imageUrls = const [],
    this.designWidth = 390,
    this.designHeight = 844,
  });

  @override
  State<PhotosAndVideosSection> createState() => _PhotosAndVideosSectionState();
}

class _PhotosAndVideosSectionState extends State<PhotosAndVideosSection> {
  static const double _centerCardW = 150;
  static const double _sideCardW = 75;
  static const double _cardH = 165;
  static const double _cardRadius = 20;
  static const double _designViewportFraction = 137.5 / 390; // 75-150-75 with ~25 gap

  int _currentPage = 0;
  late final PageController _pageController;
  double _pageOffset = 0;

  double _w(double v) =>
      (v / widget.designWidth) * MediaQuery.of(context).size.width;
  double _h(double v) =>
      (v / widget.designHeight) * MediaQuery.of(context).size.height;
  double _fs(double v) =>
      (v / widget.designWidth) * MediaQuery.of(context).size.width;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _designViewportFraction);
    _pageController.addListener(() {
      if (!mounted) return;
      setState(() {
        _pageOffset = _pageController.page ?? _currentPage.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.imageUrls;
    final itemCount = imageUrls.isEmpty ? 1 : imageUrls.length;

    final activeDot = itemCount <= 1 ? 1 : (_currentPage % 3);

    return Container(
      padding: EdgeInsets.symmetric(vertical: _h(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _w(20)),
            child: Text(
              'Photos and Videos',
              style: GoogleFonts.poppins(
                fontSize: _fs(14),
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.112,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: _h(15)),
          SizedBox(
            height: _h(_cardH),
            child: imageUrls.isEmpty
                ? Center(
                    child: _buildPhotoFrame(
                      _w(_centerCardW),
                      _h(_cardH),
                      null,
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: imageUrls.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final distance = (_pageOffset - index).abs().clamp(0.0, 1.0);
                      final width =
                          _w(_centerCardW) - ((_w(_centerCardW) - _w(_sideCardW)) * distance);

                      return Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOut,
                          width: width,
                          height: _h(_cardH),
                          child: _buildPhotoFrame(width, _h(_cardH), imageUrls[index]),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: _h(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(0, activeDot),
              SizedBox(width: _w(8)),
              _buildDot(1, activeDot),
              SizedBox(width: _w(8)),
              _buildDot(2, activeDot),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoFrame(double width, double height, String? url) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_w(_cardRadius)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 19,
            offset: const Offset(5, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_w(_cardRadius)),
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.photo, color: Colors.grey[400]),
                  ),
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.photo, color: Colors.grey[400]),
                ),
              ),
      ),
    );
  }

  Widget _buildDot(int dotIndex, int activeDot) {
    final isActive = dotIndex == activeDot;
    return Container(
      width: dotIndex == 1 ? _w(50) : _w(20),
      height: _h(12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3195AB) : const Color(0xFF3DCED5),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
