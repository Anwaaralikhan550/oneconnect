import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// A Figma-accurate "Give A Review" dialog that can be used across all list screens.
///
/// Usage:
/// ```dart
/// GiveReviewDialog.show(
///   context: context,
///   itemName: 'Block-G Park',
///   itemLocation: 'Naval Anchorage',
///   itemRating: 4.5,
///   reviewCount: 10,
///   itemImage: 'assets/images/profile.png', // or network URL
///   onSubmit: (rating, review, hasPhoto, hasVideo) {
///     // Handle submission
///   },
/// );
/// ```
class GiveReviewDialog extends StatefulWidget {
  final String itemName;
  final String itemLocation;
  final double itemRating;
  final int reviewCount;
  final String? itemImage;
  final String? itemTypeHint;
  final Function(int rating, String review, bool hasPhoto, bool hasVideo)? onSubmit;

  const GiveReviewDialog({
    super.key,
    required this.itemName,
    required this.itemLocation,
    this.itemRating = 0.0,
    this.reviewCount = 0,
    this.itemImage,
    this.itemTypeHint,
    this.onSubmit,
  });

  /// Show the review dialog as a bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String itemName,
    required String itemLocation,
    double itemRating = 0.0,
    int reviewCount = 0,
    String? itemImage,
    String? itemTypeHint,
    Function(int rating, String review, bool hasPhoto, bool hasVideo)? onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GiveReviewDialog(
        itemName: itemName,
        itemLocation: itemLocation,
        itemRating: itemRating,
        reviewCount: reviewCount,
        itemImage: itemImage,
        itemTypeHint: itemTypeHint,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<GiveReviewDialog> createState() => _GiveReviewDialogState();
}

class _GiveReviewDialogState extends State<GiveReviewDialog> {
  final TextEditingController _reviewController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  int _selectedRating = 4;
  String? _selectedImagePath;
  bool _isSubmitting = false;

  // Figma base dimensions
  static const double _figmaWidth = 390;

  double _w(double figmaW) {
    final screenWidth = MediaQuery.of(context).size.width;
    return figmaW * screenWidth / _figmaWidth;
  }

  double _fs(double figmaSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    return figmaSize * screenWidth / _figmaWidth;
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('GiveReviewDialog._pickImage: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit?.call(
        _selectedRating,
        _reviewController.text,
        _selectedImagePath != null,
        false,
      );
    } catch (e) {
      debugPrint('GiveReviewDialog._handleSubmit: $e');
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with back button and title
              _buildHeader(),
              // Profile section
              _buildProfileSection(),
              // Photo/Video buttons
              _buildMediaButtons(),
              // Text area
              _buildTextArea(),
              // Rating section
              _buildRatingSection(),
              // Terms of service
              _buildTermsSection(),
              // Submit button
              _buildSubmitButton(),
              SizedBox(height: _w(10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: _w(10)),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button (chevron rotated)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: _w(87),
              height: _w(25),
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: -1.5708, // 270 degrees in radians
                child: Icon(
                  Icons.expand_less,
                  size: _w(24),
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Title
          Expanded(
            child: Text(
              'Leave a review',
              style: GoogleFonts.inter(
                fontSize: _fs(15),
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: _w(10)),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile image
          Container(
            width: _w(52),
            height: _w(52),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE0E0E0),
            ),
            child: ClipOval(
              child: _buildItemVisual(),
            ),
          ),
          SizedBox(width: _w(15)),
          // Name, location, rating
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                widget.itemName,
                style: GoogleFonts.poppins(
                  fontSize: _fs(14),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF353535),
                  letterSpacing: 0.112,
                  height: 1.2,
                ),
              ),
              SizedBox(height: _w(4)),
              // Location
              Text(
                widget.itemLocation,
                style: GoogleFonts.inter(
                  fontSize: _fs(12),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF353535),
                  letterSpacing: 0.168,
                  height: 1.3,
                ),
              ),
              SizedBox(height: _w(4)),
              // Stars and review count
              Row(
                children: [
                  // Stars
                  Row(
                    children: List.generate(5, (index) {
                      final isFilled = index < widget.itemRating.floor();
                      final isHalf = index == widget.itemRating.floor() &&
                          widget.itemRating % 1 >= 0.5;
                      return Icon(
                        isFilled
                            ? Icons.star
                            : isHalf
                                ? Icons.star_half
                                : Icons.star_border,
                        size: _w(15),
                        color: const Color(0xFFFFC107),
                      );
                    }),
                  ),
                  SizedBox(width: _w(8)),
                  // Rating and count
                  Text(
                    '${widget.itemRating}',
                    style: GoogleFonts.inter(
                      fontSize: _fs(12),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF353535),
                      letterSpacing: 0.168,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(width: _w(4)),
                  Text(
                    '(${widget.reviewCount} Reviews)',
                    style: GoogleFonts.inter(
                      fontSize: _fs(12),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF353535),
                      letterSpacing: 0.168,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemVisual() {
    final image = widget.itemImage?.trim();
    if (image != null && image.isNotEmpty) {
      if (image.startsWith('http')) {
        return Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultImage(),
        );
      }
      if (image.startsWith('assets/')) {
        if (image.toLowerCase().endsWith('.svg')) {
          return Container(
            color: const Color(0xFFE0E0E0),
            padding: EdgeInsets.all(_w(12)),
            child: SvgPicture.asset(
              image,
              fit: BoxFit.contain,
            ),
          );
        }
        return Image.asset(
          image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultImage(),
        );
      }
    }
    return _buildDefaultImage();
  }

  String? _defaultIconAssetForItem() {
    final hint = (widget.itemTypeHint ?? '').toLowerCase().trim();
    if (hint.isNotEmpty) {
      if (hint.contains('laundry')) return 'assets/images/laundry_icon.svg';
      if (hint.contains('plumber')) return 'assets/images/plumber_icon.svg';
      if (hint.contains('electric')) return 'assets/images/electrician_icon.svg';
      if (hint.contains('painter')) return 'assets/images/painter_icon.svg';
      if (hint.contains('carpenter')) return 'assets/images/carpenter_icon.svg';
      if (hint.contains('barber')) return 'assets/images/barber_icon.svg';
      if (hint.contains('maid') || hint.contains('cleaning')) return 'assets/images/maid_icon.svg';
      if (hint.contains('salon') || hint.contains('beauty')) return 'assets/images/salon_icon.svg';
      if (hint.contains('doctor') || hint.contains('healthcare') || hint.contains('clinic') || hint.contains('hospital')) {
        return 'assets/icons/doctor_icon.svg';
      }
      if (hint.contains('water')) return 'assets/images/water_icon.svg';
      if (hint.contains('gas')) return 'assets/images/gas_icon.svg';
      if (hint.contains('bank')) return 'assets/images/bank_icon.svg';
      if (hint.contains('solar')) return 'assets/images/solar_panel_icon.svg';
      if (hint.contains('restaurant') || hint.contains('eatery') || hint.contains('home chef')) return 'assets/images/restaurant_icon.svg';
      if (hint.contains('cafe')) return 'assets/images/cafe_icon_hub.svg';
      if (hint.contains('park')) return 'assets/images/park_icon.svg';
      if (hint.contains('masjid') || hint.contains('mosque')) return 'assets/images/mosque_icon.svg';
      if (hint.contains('gym')) return 'assets/images/gym_icon.svg';
      if (hint.contains('school')) return 'assets/images/school_icon_hub.svg';
      if (hint.contains('pharmacy')) return 'assets/images/pharmacy_icon_hub.svg';
      if (hint.contains('real estate') || hint.contains('property')) return 'assets/images/real_estate_icon.svg';
      if (hint.contains('admin')) return 'assets/images/admin_icon_hub.svg';
      if (hint.contains('store') || hint.contains('grocery') || hint.contains('shop') || hint.contains('business')) return 'assets/images/store_icon.svg';
    }

    final text = widget.itemName.toLowerCase().trim();
    if (text.contains('laundry') || text.contains('dry clean')) return 'assets/images/laundry_icon.svg';
    if (text.contains('plumber')) return 'assets/images/plumber_icon.svg';
    if (text.contains('electric')) return 'assets/images/electrician_icon.svg';
    if (text.contains('painter')) return 'assets/images/painter_icon.svg';
    if (text.contains('carpenter')) return 'assets/images/carpenter_icon.svg';
    if (text.contains('barber')) return 'assets/images/barber_icon.svg';
    if (text.contains('maid') || text.contains('cleaning')) return 'assets/images/maid_icon.svg';
    if (text.contains('salon') || text.contains('beauty')) return 'assets/images/salon_icon.svg';
    if (text.contains('doctor') || text.contains('clinic') || text.contains('hospital')) return 'assets/icons/doctor_icon.svg';
    if (text.contains('water')) return 'assets/images/water_icon.svg';
    if (text.contains('gas')) return 'assets/images/gas_icon.svg';
    if (text.contains('bank')) return 'assets/images/bank_icon.svg';
    if (text.contains('solar')) return 'assets/images/solar_panel_icon.svg';
    if (text.contains('restaurant') || text.contains('eatery') || text.contains('home chef')) return 'assets/images/restaurant_icon.svg';
    if (text.contains('cafe')) return 'assets/images/cafe_icon_hub.svg';
    if (text.contains('park')) return 'assets/images/park_icon.svg';
    if (text.contains('masjid') || text.contains('mosque')) return 'assets/images/mosque_icon.svg';
    if (text.contains('gym')) return 'assets/images/gym_icon.svg';
    if (text.contains('school')) return 'assets/images/school_icon_hub.svg';
    if (text.contains('pharmacy')) return 'assets/images/pharmacy_icon_hub.svg';
    if (text.contains('real estate') || text.contains('property')) return 'assets/images/real_estate_icon.svg';
    if (text.contains('admin')) return 'assets/images/admin_icon_hub.svg';
    if (text.contains('healthcare')) return 'assets/images/healthcare_icon_hub.svg';
    if (text.contains('store') || text.contains('grocery') || text.contains('shop')) return 'assets/images/store_icon.svg';
    return null;
  }

  Widget _buildDefaultImage() {
    final asset = _defaultIconAssetForItem();
    if (asset != null) {
      return Container(
        color: const Color(0xFFE0E0E0),
        padding: EdgeInsets.all(_w(12)),
        child: SvgPicture.asset(
          asset,
          fit: BoxFit.contain,
        ),
      );
    }
    return Container(
      color: const Color(0xFFE0E0E0),
      child: Icon(
        Icons.store,
        size: _w(24),
        color: Colors.grey,
      ),
    );
  }

  Widget _buildMediaButtons() {
    return Container(
      padding: EdgeInsets.all(_w(10)),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Photo button - opens image picker
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: _selectedImagePath != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.file(
                          File(_selectedImagePath!),
                          width: _w(70),
                          height: _w(70),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImagePath = null),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, size: _w(14), color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                : CustomPaint(
                    painter: DashedBorderPainter(
                      color: const Color(0xFFBCBCBC),
                      strokeWidth: 1,
                      borderRadius: 5,
                      dashWidth: 4,
                      dashSpace: 3,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _w(22),
                        vertical: _w(17),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: _w(25),
                            color: const Color(0xFFBCBCBC),
                          ),
                          Text(
                            'Photo',
                            style: GoogleFonts.inter(
                              fontSize: _fs(11),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFBCBCBC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          SizedBox(width: _w(10)),
          // Video button - dashed border per Figma (placeholder, video not supported yet)
          CustomPaint(
            painter: DashedBorderPainter(
              color: const Color(0xFFBCBCBC),
              strokeWidth: 1,
              borderRadius: 5,
              dashWidth: 4,
              dashSpace: 3,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _w(22),
                vertical: _w(17),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.videocam_outlined,
                    size: _w(25),
                    color: const Color(0xFFBCBCBC),
                  ),
                  Text(
                    'Video',
                    style: GoogleFonts.inter(
                      fontSize: _fs(11),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFBCBCBC),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _w(15), vertical: _w(10)),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Text input area - user types directly in the container per Figma
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: _w(100)),
            padding: EdgeInsets.all(_w(15)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pen icon
                Icon(
                  Icons.edit_outlined,
                  size: _w(20),
                  color: const Color(0xFF9AA0B6),
                ),
                SizedBox(width: _w(8)),
                // Text field with "Share your experience" placeholder
                Expanded(
                  child: TextField(
                    controller: _reviewController,
                    maxLines: null,
                    maxLength: 3000,
                    decoration: InputDecoration(
                      hintText: 'Share your experience',
                      hintStyle: GoogleFonts.inter(
                        fontSize: _fs(16),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9AA0B6),
                        height: 1.1,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: _fs(16),
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: _w(8)),
          // Character count
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.info_outline,
                size: _w(14),
                color: const Color(0xFF6D758F),
              ),
              SizedBox(width: _w(4)),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _reviewController,
                builder: (context, value, child) {
                  return Text(
                    '${value.text.length}/3000',
                    style: GoogleFonts.inter(
                      fontSize: _fs(12),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6D758F),
                      height: 1.25,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _w(20),
        vertical: _w(10),
      ),
      child: Row(
        children: [
          // Rating label
          Text(
            'Rating:',
            style: GoogleFonts.inter(
              fontSize: _fs(15),
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: 0.168,
              height: 1.3,
            ),
          ),
          SizedBox(width: _w(8)),
          // Star buttons
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  size: _w(28),
                  color: const Color(0xFFFFC107),
                ),
              );
            }),
          ),
          SizedBox(width: _w(8)),
          // Rating text
          Text(
            _getRatingText(_selectedRating),
            style: GoogleFonts.inter(
              fontSize: _fs(12),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF353535),
              letterSpacing: 0.168,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _w(5)),
      child: Text(
        'Please follow the review guidelines when writing reviews',
        style: GoogleFonts.inter(
          fontSize: _fs(11),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF8E8E8E),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: _w(15)),
      child: GestureDetector(
        onTap: _isSubmitting ? null : _handleSubmit,
        child: Container(
          width: _w(324),
          height: _w(48),
          decoration: BoxDecoration(
            color: _isSubmitting ? const Color(0xFF3499AF).withOpacity(0.6) : const Color(0xFF3499AF),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: _isSubmitting
              ? SizedBox(
                  width: _w(24),
                  height: _w(24),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Submit',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: _fs(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Custom painter for dashed border - matching Figma exactly
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1,
    this.borderRadius = 5,
    this.dashWidth = 4,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        dashPath.addPath(
          metric.extractPath(start, end),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
