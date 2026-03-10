import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A standardized "Photos and Videos" section used across all detail screens.
///
/// Displays a small-large-small (75-150-75) photo layout with 3 teal dot
/// indicators. Supports a PageView carousel when more than 3 images are
/// provided.
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
  int _currentPage = 0;
  late PageController _pageController;

  double _w(double v) =>
      (v / widget.designWidth) * MediaQuery.of(context).size.width;
  double _h(double v) =>
      (v / widget.designHeight) * MediaQuery.of(context).size.height;
  double _fs(double v) =>
      (v / widget.designWidth) * MediaQuery.of(context).size.width;

  /// Split imageUrls into pages of 3.
  List<List<String>> get _pages {
    final urls = widget.imageUrls;
    if (urls.isEmpty) return [[]]; // single page with placeholders
    final pages = <List<String>>[];
    for (var i = 0; i < urls.length; i += 3) {
      pages.add(urls.sublist(i, (i + 3).clamp(0, urls.length)));
    }
    return pages;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    final pageCount = pages.length;

    // Determine which dot is active:
    // - With 1 page: middle dot (index 1) is active
    // - With multiple pages: dot index maps to page index (0, 1, 2)
    final activeDot = pageCount <= 1 ? 1 : _currentPage.clamp(0, 2);

    return Container(
      padding: EdgeInsets.symmetric(vertical: _h(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
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

          // Photo Row (PageView carousel)
          SizedBox(
            height: _h(150),
            child: pageCount <= 1
                ? _buildPhotoRow(pages.first)
                : PageView.builder(
                    controller: _pageController,
                    itemCount: pageCount,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) =>
                        _buildPhotoRow(pages[index]),
                  ),
          ),
          SizedBox(height: _h(20)),

          // Dot Indicators
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

  /// Builds the small-large-small photo row for a single page of up to 3 URLs.
  Widget _buildPhotoRow(List<String> urls) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPhotoFrame(_w(75), _h(150), urls.isNotEmpty ? urls[0] : null),
        SizedBox(width: _w(25)),
        _buildPhotoFrame(
            _w(150), _h(150), urls.length > 1 ? urls[1] : (urls.isNotEmpty ? urls[0] : null)),
        SizedBox(width: _w(25)),
        _buildPhotoFrame(
            _w(75), _h(150), urls.length > 2 ? urls[2] : (urls.isNotEmpty ? urls[0] : null)),
      ],
    );
  }

  /// A single rounded photo container with shadow and error fallback.
  Widget _buildPhotoFrame(double width, double height, String? url) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 19,
            offset: const Offset(5, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey[300],
                  child: Center(
                      child: Icon(Icons.photo, color: Colors.grey[400])),
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: Center(
                    child: Icon(Icons.photo, color: Colors.grey[400])),
              ),
      ),
    );
  }

  /// A single dot indicator.
  Widget _buildDot(int dotIndex, int activeDot) {
    final isActive = dotIndex == activeDot;
    return Container(
      width: dotIndex == 1 ? _w(50) : _w(20),
      height: _h(12),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF3195AB)
            : const Color(0xFF3DCED5),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

