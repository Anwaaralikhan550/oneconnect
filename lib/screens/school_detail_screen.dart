import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../providers/business_provider.dart';
import '../providers/favorite_provider.dart';
import '../models/amenity_model.dart';
import '../widgets/give_review_dialog.dart';
import '../widgets/profile_image.dart';
import '../widgets/photos_and_videos_section.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/member_reviews_section.dart';
import '../widgets/partner_media_gallery.dart';
import '../widgets/special_offers_section.dart';


import '../widgets/review_us_section.dart' as review_widgets;
import '../widgets/location_section.dart';
import '../widgets/detail_screen_header.dart';
import '../widgets/facilities_section.dart';
import '../utils/contact_utils.dart';

class SchoolDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? schoolData;

  const SchoolDetailScreen({super.key, this.schoolData});

  @override
  State<SchoolDetailScreen> createState() => _SchoolDetailScreenState();
}

class _SchoolDetailScreenState extends State<SchoolDetailScreen>
    with ResponsiveMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.schoolData?['id'] as String?;
      if (id != null) {
        Provider.of<BusinessProvider>(context, listen: false).fetchAmenityDetail(id);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessProvider>(
      builder: (context, provider, _) {
    final detail = provider.getAmenityDetail(widget.schoolData?['id'] ?? '');
    final phone = (detail?.phone ?? widget.schoolData?['phone']?.toString() ?? '').trim();
    final whatsapp =
        (detail?.whatsapp ?? widget.schoolData?['whatsapp']?.toString() ?? phone).trim();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          DetailScreenHeader(
            title: 'School',
            iconAssetPath: 'assets/images/school_icon_hub.svg',
            fallbackIcon: Icons.school,
            onShare: () {
              final name = detail?.name ?? widget.schoolData?['name'] ?? 'School';
              Share.share('Check out $name on OneConnect!');
            },
          ),
          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: rh(10)),
                  _buildProfileSection(detail),
                  SizedBox(height: rh(10)),
                  _buildTimingAndDistanceSection(),
                  SizedBox(height: rh(9)),
                  LocationSection(
              locationText: detail?.location ?? widget.schoolData?['location'] ?? '',
            ),
                  if (phone.isNotEmpty || whatsapp.isNotEmpty) ...[
                    SizedBox(height: rh(9)),
                    _buildContactCard(context, phone: phone, whatsapp: whatsapp),
                  ],
                  SizedBox(height: rh(9)),
                  FacilitiesSection(
                    items: const [
                      FacilityItem(icon: Icons.computer, label: 'Computer Lab'),
                      FacilityItem(icon: Icons.science, label: 'Science Lab'),
                      FacilityItem(icon: Icons.local_library, label: 'Library'),
                      FacilityItem(icon: Icons.sports_soccer, label: 'Sports'),
                    ],
                    notice: Container(
                      padding: EdgeInsets.all(rw(10)),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                      child: Text('Admissions Open for 2025-26', style: GoogleFonts.inter(fontSize: rfs(11), fontWeight: FontWeight.w500, color: const Color(0xFF2E7D32), height: 16 / 11), textAlign: TextAlign.center),
                    ),
                  ),
                  SizedBox(height: rh(10)),
                  PhotosAndVideosSection(imageUrls: detail?.media.isNotEmpty == true ? detail!.media.map((m) => m.fileUrl).toList() : (detail?.imageUrl?.isNotEmpty == true ? [detail!.imageUrl!] : [])),
                  SizedBox(height: rh(10)),
                  SpecialOffersSection(promotions: detail?.promotions ?? const []),
                  SizedBox(height: rh(10)),
                  review_widgets.ReviewUsSection(
              entityName: detail?.name ?? widget.schoolData?['name'] ?? 'School',
              entityImageUrl: detail?.imageUrl ?? widget.schoolData?['image'],
              displayMetric: "${detail?.reviewCount ?? widget.schoolData?['reviewCount'] ?? widget.schoolData?['reviews'] ?? 0} Reviews",
              fallbackIcon: Icons.school,
              onGiveReview: () {
                GiveReviewDialog.show(
                  context: context,
                  itemName: detail?.name ?? widget.schoolData?['name'] ?? 'School',
                  itemLocation: detail?.location ?? widget.schoolData?['location'] ?? '',
                  itemRating: detail?.rating ?? double.tryParse(widget.schoolData?['rating']?.toString() ?? '0') ?? 0.0,
                  reviewCount: detail?.reviewCount ?? int.tryParse(widget.schoolData?['reviewCount']?.toString() ?? widget.schoolData?['reviews']?.toString() ?? '0') ?? 0,
                  itemImage: detail?.imageUrl ?? widget.schoolData?['image'],
                  itemTypeHint: 'SCHOOL',
                  onSubmit: (rating, review, hasPhoto, hasVideo) async {
                    final entityId = widget.schoolData?['id'] as String?;
                    if (entityId == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot submit review: missing entity ID'), backgroundColor: Colors.red));
                      }
                      return;
                    }
                    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
                    final ratingText = rating >= 4 ? 'Excellent' : rating >= 3 ? 'Good' : rating >= 2 ? 'Average' : 'Poor';
                    final success = await reviewProvider.submitAmenityReview(entityId, rating: rating.toDouble(), ratingText: ratingText, reviewText: review.isNotEmpty ? review : null);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Review submitted!' : (reviewProvider.error ?? 'Failed')), backgroundColor: success ? Colors.green : Colors.red));
                      if (success) { final submitted = reviewProvider.lastSubmittedReview; if (submitted != null) { Provider.of<BusinessProvider>(context, listen: false).applySubmittedAmenityReview(entityId, submitted); } }
                    }
                  },
                );
              },
            ),
                  SizedBox(height: rh(10)),
                  MemberReviewsSection(
              reviews: detail?.reviews ?? [],
              fallbackIcon: Icons.school,
              onVote: (reviewId, voteType) => _handleVote(reviewId, voteType),
              mediaItems: (detail?.media ?? const [])
                  .map((m) => PartnerGalleryItem(id: m.id, mediaType: m.mediaType, fileUrl: m.fileUrl))
                  .toList(),
            ),
                  SizedBox(height: rh(30)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }


  Widget _buildContactCard(
    BuildContext context, {
    required String phone,
    required String whatsapp,
  }) {
    final String effectiveWhatsapp = whatsapp.isNotEmpty ? whatsapp : phone;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
      padding: EdgeInsets.symmetric(horizontal: rw(15), vertical: rw(15)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () async => callPhoneNumber(context, phone),
              child: Row(
                children: [
                  SvgPicture.asset('assets/icons/phone_icon.svg', width: rw(19), height: rw(19)),
                  SizedBox(width: rw(5)),
                  Flexible(
                    child: Text(
                      phone.isNotEmpty ? phone : 'No phone available',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: rfs(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: rw(40)),
          Flexible(
            child: GestureDetector(
              onTap: () async => openWhatsAppForNumber(context, effectiveWhatsapp),
              child: Row(
                children: [
                  SvgPicture.asset('assets/icons/whatsapp_icon.svg', width: rw(25), height: rw(25)),
                  SizedBox(width: rw(5)),
                  Flexible(
                    child: Text(
                      effectiveWhatsapp.isNotEmpty ? effectiveWhatsapp : 'N/A',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: rfs(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000000),
                      ),
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

  // PROFILE SECTION
  Widget _buildProfileSection(AmenityModel? detail) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: rw(15), vertical: rh(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile Icon - 90x90
          ClipOval(
            child: SizedBox(
              width: rw(90),
              height: rw(90),
              child: buildProfileImage(detail?.imageUrl ?? widget.schoolData?['image'], fallbackIcon: Icons.school, iconSize: 50),
            ),
          ),
          SizedBox(width: rw(15)),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row with heart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name and Location Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name - Poppins SemiBold 14px #353535
                          Text(
                            detail?.name ?? widget.schoolData?['name'] ?? 'School',
                            style: GoogleFonts.poppins(
                              fontSize: rfs(14),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF353535),
                              letterSpacing: 0.112,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: rh(4)),
                          // Location - Inter Medium 12px #353535
                          Text(
                            detail?.location ?? widget.schoolData?['location'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: rfs(12),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF353535),
                              letterSpacing: 0.168,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Heart icon - 20x20
                    Consumer<FavoriteProvider>(
                      builder: (context, favProvider, _) {
                        final amenityId = widget.schoolData?['id'] as String?;
                        final isFav = favProvider.isAmenityFavorited(amenityId ?? '');
                        return GestureDetector(
                          onTap: () {
                            if (amenityId != null) {
                              favProvider.toggleAmenityFavorite(amenityId);
                            }
                          },
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: rw(20),
                            color: isFav ? Colors.red : Colors.black,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: rh(4)),
                // Star and Review Row - gap=8
                Row(
                  children: [
                    // 5 Stars - 15x15 each
                    Row(
                      children: List.generate(5, (index) {
                        final ratingVal = detail?.rating ?? double.tryParse(widget.schoolData?['rating']?.toString() ?? '') ?? 4.8;
                        return Icon(
                          index < ratingVal.floor() ? Icons.star : (index < ratingVal ? Icons.star_half : Icons.star_border),
                          size: rw(15),
                          color: const Color(0xFFFFCD29),
                        );
                      }),
                    ),
                    SizedBox(width: rw(8)),
                    // Rating text - Inter Medium 12px #353535
                    Text(
                      detail != null ? detail.rating.toStringAsFixed(1) : (widget.schoolData?['rating'] ?? '4.8'),
                      style: GoogleFonts.inter(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF353535),
                        letterSpacing: 0.168,
                      ),
                    ),
                    SizedBox(width: rw(4)),
                    Flexible(
                      child: Text(
                        '(${detail?.reviewCount ?? widget.schoolData?['reviewCount'] ?? widget.schoolData?['reviews'] ?? '250'} Reviews)',
                        style: GoogleFonts.inter(
                          fontSize: rfs(12),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF353535),
                          letterSpacing: 0.168,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TIMING AND DISTANCE SECTION
  Widget _buildTimingAndDistanceSection() {
    final detail = Provider.of<BusinessProvider>(context, listen: false)
        .getAmenityDetail(widget.schoolData?['id'] ?? '');
    final opening = detail?.openingTime?.toString() ??
        widget.schoolData?['openingTime']?.toString();
    final closing = detail?.closingTime?.toString() ??
        widget.schoolData?['closingTime']?.toString();
    final timeText = (opening != null &&
            opening.isNotEmpty &&
            closing != null &&
            closing.isNotEmpty)
        ? '$opening - $closing'
        : '8:00 am - 2:00 pm';
    final days = detail?.operatingDays ??
        ((widget.schoolData?['operatingDays'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[]);
    final daysText = days.isNotEmpty ? days.join(', ') : 'Monday - Saturday';
    final distanceText = widget.schoolData?['distance']?.toString() ?? '2.5 Km away';

    return Container(
      width: rw(360),
      padding: EdgeInsets.symmetric(horizontal: rw(25), vertical: rh(15)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFF3F3F3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // School Timing - Left side
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tick Circle Icon - 25x25, teal color
                SvgPicture.asset(
                  'assets/icons/doctor_tick_circle.svg',
                  width: rw(25),
                  height: rw(25),
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0097B2),
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (context) => Icon(
                    Icons.check_circle,
                    size: rw(25),
                    color: const Color(0xFF0097B2),
                  ),
                ),
                SizedBox(width: rw(5)),
                // Text Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // School Hours - Roboto Medium 15px
                      Text(
                        'School Hours',
                        style: GoogleFonts.roboto(
                          fontSize: rfs(15),
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: rh(2)),
                      // Time - Roboto Regular 13px
                      Text(
                        timeText,
                        style: GoogleFonts.roboto(
                          fontSize: rfs(13),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: rh(2)),
                      // Days - Roboto Regular 12px, #727272
                      Text(
                        daysText,
                        style: GoogleFonts.roboto(
                          fontSize: rfs(12),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF727272),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Distance - Right side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Distance Icon - 25x24.943
              SvgPicture.asset(
                'assets/icons/doctor_distance_icon.svg',
                width: rw(25),
                height: rw(24.943),
                placeholderBuilder: (context) => Icon(
                  Icons.directions_walk,
                  size: rw(25),
                  color: const Color(0xFF0097B2),
                ),
              ),
              SizedBox(width: rw(5)),
              // Text Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance - Roboto Medium 15px
                  Text(
                    'Distance',
                    style: GoogleFonts.roboto(
                      fontSize: rfs(15),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: rh(2)),
                  // Km away - Roboto Regular 13px, #202020
                   Text(
                     distanceText,
                    style: GoogleFonts.roboto(
                      fontSize: rfs(13),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF202020),
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








  void _handleVote(String reviewId, String voteType) {
    final amenityId = widget.schoolData?['id'] as String?;
    if (amenityId == null) return;
    Provider.of<BusinessProvider>(context, listen: false)
        .voteAmenityReview(amenityId, reviewId, voteType);
  }
}








