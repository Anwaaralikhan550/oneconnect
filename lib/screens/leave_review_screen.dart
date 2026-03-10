import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../widgets/profile_image.dart';
import '../mixins/responsive_mixin.dart';

class LeaveReviewScreen extends StatefulWidget {
  final String? entityId;
  final String? entityName;
  final String? entityLocation;
  final double? entityRating;
  final int? reviewCount;
  final String? entityImage;
  /// 'service_provider' or 'business'
  final String entityType;

  const LeaveReviewScreen({
    super.key,
    this.entityId,
    this.entityName,
    this.entityLocation,
    this.entityRating,
    this.reviewCount,
    this.entityImage,
    this.entityType = 'business',
  });

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen>
    with ResponsiveMixin {
  final TextEditingController _reviewController = TextEditingController();
  bool _isPhotoSelected = true;
  double _selectedRating = 4.5;
  final int _maxCharacters = 3000;





  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 3.5) return 'Good';
    if (rating >= 2.5) return 'Average';
    if (rating >= 1.5) return 'Poor';
    return 'Very Poor';
  }

  IconData _fallbackIconForEntity() {
    final text = (widget.entityName ?? '').toLowerCase();
    if (text.contains('doctor') || text.contains('clinic') || text.contains('hospital')) {
      return Icons.local_hospital_outlined;
    }
    if (text.contains('mosque') || text.contains('masjid')) return Icons.mosque_outlined;
    if (text.contains('park')) return Icons.park_outlined;
    if (text.contains('school')) return Icons.school_outlined;
    if (text.contains('pharmacy')) return Icons.local_pharmacy_outlined;
    if (text.contains('gym')) return Icons.fitness_center_outlined;
    if (text.contains('restaurant') || text.contains('cafe')) return Icons.restaurant_outlined;
    if (text.contains('bank')) return Icons.account_balance_outlined;
    if (text.contains('property') || text.contains('real estate')) return Icons.home_work_outlined;
    if (text.contains('plumber')) return Icons.plumbing_outlined;
    if (text.contains('electric')) return Icons.electrical_services_outlined;
    if (text.contains('barber') || text.contains('salon')) return Icons.content_cut_outlined;
    return widget.entityType == 'service_provider' ? Icons.person_outline : Icons.store_outlined;
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(rw(8)),
            child: Icon(
              Icons.arrow_back_ios,
              color: const Color(0xFF515151),
              size: rw(20),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Leave a review',
          style: GoogleFonts.inter(
            fontSize: rfs(18),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF515151),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Entity Information Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: rw(15),
                vertical: rw(20),
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Circular Profile Image
                  Container(
                    width: rw(60),
                    height: rw(60),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: buildProfileImage(
                        widget.entityImage,
                        fallbackIcon: _fallbackIconForEntity(),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: rw(12)),
                  
                  // Name, Location, and Rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          widget.entityName ?? 'Unknown',
                          style: GoogleFonts.inter(
                            fontSize: rfs(16),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        SizedBox(height: rw(4)),
                        // Location
                        Text(
                          widget.entityLocation ?? '',
                          style: GoogleFonts.inter(
                            fontSize: rfs(14),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF515151),
                          ),
                        ),
                        SizedBox(height: rw(6)),
                        // Rating
                        Row(
                          children: [
                            // Stars
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                final r = widget.entityRating ?? 0;
                                if (index < r.floor()) {
                                  return Icon(
                                    Icons.star,
                                    color: const Color(0xFFFFCD29),
                                    size: rw(16),
                                  );
                                } else {
                                  return Icon(
                                    Icons.star_border,
                                    color: const Color(0xFFFFCD29),
                                    size: rw(16),
                                  );
                                }
                              }),
                            ),
                            SizedBox(width: rw(6)),
                            // Rating Text
                            Text(
                              '${(widget.entityRating ?? 0).toStringAsFixed(1)} (${widget.reviewCount ?? 0} Reviews)',
                              style: GoogleFonts.inter(
                                fontSize: rfs(12),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF515151),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Photo and Video Upload Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: rw(15),
                vertical: rw(20),
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Photo Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPhotoSelected = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: rw(15),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _isPhotoSelected
                                ? Colors.black
                                : const Color(0xFFCCCCCC),
                            width: _isPhotoSelected ? 2 : 1,
                            style: _isPhotoSelected
                                ? BorderStyle.solid
                                : BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(
                            rw(8),
                          ),
                        ),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/lucide_camera.svg',
                              width: rw(24),
                              height: rw(24),
                              colorFilter: ColorFilter.mode(
                                _isPhotoSelected
                                    ? Colors.black
                                    : const Color(0xFFAAAAAA),
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(height: rw(8)),
                            Text(
                              'Photo',
                              style: GoogleFonts.inter(
                                fontSize: rfs(14),
                                fontWeight: FontWeight.w500,
                                color: _isPhotoSelected
                                    ? Colors.black
                                    : const Color(0xFFAAAAAA),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: rw(15)),
                  
                  // Video Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPhotoSelected = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: rw(15),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _isPhotoSelected
                                ? const Color(0xFFCCCCCC)
                                : Colors.black,
                            width: _isPhotoSelected ? 1 : 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            rw(8),
                          ),
                        ),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/lucide_camera.svg',
                              width: rw(24),
                              height: rw(24),
                              colorFilter: ColorFilter.mode(
                                _isPhotoSelected
                                    ? const Color(0xFFAAAAAA)
                                    : Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(height: rw(8)),
                            Text(
                              'Video',
                              style: GoogleFonts.inter(
                                fontSize: rfs(14),
                                fontWeight: FontWeight.w500,
                                color: _isPhotoSelected
                                    ? const Color(0xFFAAAAAA)
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Review Input Field
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: rw(15),
                vertical: rw(20),
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      TextField(
                        controller: _reviewController,
                        maxLines: 8,
                        maxLength: null, // Remove maxLength to hide default counter
                        style: GoogleFonts.inter(
                          fontSize: rfs(14),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF333333),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Share your experience',
                          hintStyle: GoogleFonts.inter(
                            fontSize: rfs(14),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFAAAAAA),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              rw(8),
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFFCCCCCC),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              rw(8),
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFFCCCCCC),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              rw(8),
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFFCCCCCC),
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.only(
                            left: rw(40),
                            right: rw(12),
                            top: rw(12),
                            bottom: rw(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      // Pen icon positioned at top-left with hint text
                      Positioned(
                        left: rw(12),
                        top: rw(12),
                        child: SvgPicture.asset(
                          'assets/icons/Pen.svg',
                          width: rw(20),
                          height: rw(20),
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFAAAAAA),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: rw(8)),
                  // Character counter below text field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFFAAAAAA),
                        size: rw(16),
                      ),
                      SizedBox(width: rw(4)),
                      Text(
                        '${_reviewController.text.length}/$_maxCharacters',
                        style: GoogleFonts.inter(
                          fontSize: rfs(12),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Rating Selection Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: rw(15),
                vertical: rw(20),
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Rating:',
                    style: GoogleFonts.inter(
                      fontSize: rfs(16),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(width: rw(15)),
                  // Star Rating
                  GestureDetector(
                    onTap: () {
                      // Handle star tap for rating selection
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        final isFilled = starValue <= _selectedRating;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRating = index + 1.0;
                            });
                          },
                          child: Icon(
                            isFilled ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFFCD29),
                            size: rw(24),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(width: rw(10)),
                  Text(
                    _getRatingText(_selectedRating),
                    style: GoogleFonts.inter(
                      fontSize: rfs(14),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF515151),
                    ),
                  ),
                ],
              ),
            ),
            
            // Guidelines Text
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: rw(15),
                vertical: rw(15),
              ),
              child: Text(
                'Please follow the review guidelines when writing reviews',
                style: GoogleFonts.inter(
                  fontSize: rfs(12),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6A6A6A),
                ),
              ),
            ),
            
            SizedBox(height: rw(20)),
            
            // Submit Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: rw(15),
              ),
              child: Container(
                width: double.infinity,
                height: rh(50),
                decoration: BoxDecoration(
                  color: const Color(0xFF3195AB),
                  borderRadius: BorderRadius.circular(rw(8)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      if (widget.entityId == null) {
                        Navigator.pop(context);
                        return;
                      }
                      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
                      final ratingText = _getRatingText(_selectedRating);
                      bool success;
                      if (widget.entityType == 'service_provider') {
                        success = await reviewProvider.submitServiceProviderReview(
                          widget.entityId!,
                          rating: _selectedRating,
                          ratingText: ratingText,
                          reviewText: _reviewController.text.isNotEmpty ? _reviewController.text : null,
                        );
                      } else {
                        success = await reviewProvider.submitBusinessReview(
                          widget.entityId!,
                          rating: _selectedRating,
                          ratingText: ratingText,
                          reviewText: _reviewController.text.isNotEmpty ? _reviewController.text : null,
                        );
                      }
                      if (mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review submitted!'), backgroundColor: Colors.green),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(reviewProvider.error ?? 'Failed to submit review'), backgroundColor: Colors.red),
                          );
                        }
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(
                      rw(8),
                    ),
                    child: Center(
                      child: Text(
                        'Submit',
                        style: GoogleFonts.inter(
                          fontSize: rfs(16),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: rw(30)),
          ],
        ),
      ),
    );
  }
}

