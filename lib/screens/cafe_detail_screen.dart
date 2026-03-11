import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/business_provider.dart';
import '../providers/review_provider.dart';
import '../providers/favorite_provider.dart';
import '../models/amenity_model.dart';
import '../widgets/photos_and_videos_section.dart';
import '../widgets/give_review_dialog.dart';
import '../widgets/profile_image.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/member_reviews_section.dart';
import '../widgets/partner_media_gallery.dart';
import '../widgets/special_offers_section.dart';


import '../widgets/review_us_section.dart' as review_widgets;
import '../widgets/location_section.dart';
import '../widgets/detail_screen_header.dart';
import '../utils/contact_utils.dart';

class CafeDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? cafeData;

  const CafeDetailScreen({super.key, this.cafeData});

  @override
  State<CafeDetailScreen> createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends State<CafeDetailScreen>
    with ResponsiveMixin {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.cafeData?['id'] as String?;
      if (id != null) {
        Provider.of<BusinessProvider>(context, listen: false).fetchAmenityDetail(id);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessProvider>(
      builder: (context, provider, _) {
    final detail = provider.getAmenityDetail(widget.cafeData?['id'] ?? '');
    final phone = (detail?.phone ?? widget.cafeData?['phone']?.toString() ?? '').trim();
    final whatsapp =
        (detail?.whatsapp ?? widget.cafeData?['whatsapp']?.toString() ?? phone).trim();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          DetailScreenHeader(
            title: 'Café',
            iconAssetPath: 'assets/images/cafe_icon_hub.svg',
            fallbackIcon: Icons.local_cafe,
            onShare: () {
              final name = detail?.name ?? widget.cafeData?['name'] ?? 'Café';
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
              locationText: detail?.location ?? widget.cafeData?['location'] ?? '',
            ),
                  if (phone.isNotEmpty || whatsapp.isNotEmpty) ...[
                    SizedBox(height: rh(9)),
                    _buildContactCard(context, phone: phone, whatsapp: whatsapp),
                  ],
                  SizedBox(height: rh(9)),
                  _buildMenuHighlightsSection(),
                  SizedBox(height: rh(10)),
                  PhotosAndVideosSection(imageUrls: detail?.media.isNotEmpty == true ? detail!.media.map((m) => m.fileUrl).toList() : (detail?.imageUrl?.isNotEmpty == true ? [detail!.imageUrl!] : [])),
                  SizedBox(height: rh(10)),
                  SpecialOffersSection(promotions: detail?.promotions ?? const []),
                  SizedBox(height: rh(10)),
                  review_widgets.ReviewUsSection(
              entityName: detail?.name ?? widget.cafeData?['name'] ?? 'Café',
              entityImageUrl: detail?.imageUrl ?? widget.cafeData?['image'],
              displayMetric: "${detail?.reviewCount ?? widget.cafeData?['reviewCount'] ?? widget.cafeData?['reviews'] ?? 0} Reviews",
              fallbackIcon: Icons.local_cafe,
              onGiveReview: () {
                GiveReviewDialog.show(
                  context: context,
                  itemName: detail?.name ?? widget.cafeData?['name'] ?? 'Café',
                  itemLocation: detail?.location ?? widget.cafeData?['location'] ?? '',
                  itemRating: detail?.rating ?? double.tryParse(widget.cafeData?['rating']?.toString() ?? '0') ?? 0.0,
                  reviewCount: detail?.reviewCount ?? int.tryParse(widget.cafeData?['reviewCount']?.toString() ?? widget.cafeData?['reviews']?.toString() ?? '0') ?? 0,
                  itemImage: detail?.imageUrl ?? widget.cafeData?['image'],
                  itemTypeHint: 'CAFE',
                  onSubmit: (rating, review, hasPhoto, hasVideo) async {
                    final entityId = widget.cafeData?['id'] as String?;
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
              fallbackIcon: Icons.local_cafe,
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


  // PROFILE SECTION
  Widget _buildProfileSection(AmenityModel? detail) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: rw(15), vertical: rh(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile Icon
          ClipOval(
            child: SizedBox(
              width: rw(90),
              height: rw(90),
              child: buildProfileImage(detail?.imageUrl ?? widget.cafeData?['image'], fallbackIcon: Icons.local_cafe, iconSize: 50),
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
                          // Name
                          Text(
                            detail?.name ?? widget.cafeData?['name'] ?? 'Café',
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
                          // Location
                          Text(
                            detail?.location ?? widget.cafeData?['location'] ?? 'Location not available',
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
                    // Heart icon
                    Consumer<FavoriteProvider>(
                      builder: (context, favProvider, _) {
                        final amenityId = widget.cafeData?['id'] as String?;
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
                // Star and Review Row
                Row(
                  children: [
                    // 5 Stars
                    Row(
                      children: List.generate(5, (index) {
                        final ratingVal = detail?.rating ?? double.tryParse(widget.cafeData?['rating']?.toString() ?? '') ?? 4.9;
                        return Icon(
                          index < ratingVal.floor() ? Icons.star : (index < ratingVal ? Icons.star_half : Icons.star_border),
                          size: rw(15),
                          color: const Color(0xFFFFCD29),
                        );
                      }),
                    ),
                    SizedBox(width: rw(8)),
                    // Rating text
                    Text(
                      detail != null ? detail.rating.toStringAsFixed(1) : (widget.cafeData?['rating'] ?? '4.9'),
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
                        '(${detail != null ? detail.reviewCount : (widget.cafeData?['reviewCount'] ?? widget.cafeData?['reviews'] ?? '0')} Reviews)',
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
        .getAmenityDetail(widget.cafeData?['id'] ?? '');
    final opening = detail?.openingTime?.toString() ??
        widget.cafeData?['openingTime']?.toString();
    final closing = detail?.closingTime?.toString() ??
        widget.cafeData?['closingTime']?.toString();
    final timeText = (opening != null &&
            opening.isNotEmpty &&
            closing != null &&
            closing.isNotEmpty)
        ? '$opening - $closing'
        : '8:00 am - 12:00 am';
    final days = detail?.operatingDays ??
        ((widget.cafeData?['operatingDays'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[]);
    final daysText = days.isNotEmpty ? days.join(', ') : 'All Days';
    final distanceRaw = widget.cafeData?['distance']?.toString().trim();
    final distanceText =
        (distanceRaw != null && distanceRaw.isNotEmpty) ? distanceRaw : '';

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
          // Opening Hours - Left side
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tick Circle Icon
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Opening Hours
                    Text(
                      'Opening Hours',
                      style: GoogleFonts.roboto(
                        fontSize: rfs(15),
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: rh(2)),
                    // Time
                    Text(
                      timeText,
                      style: GoogleFonts.roboto(
                        fontSize: rfs(13),
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: rh(2)),
                    // Days
                    Text(
                      daysText,
                      style: GoogleFonts.roboto(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF727272),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Distance - Right side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Distance Icon
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
                  // Distance
                  Text(
                    'Distance',
                    style: GoogleFonts.roboto(
                      fontSize: rfs(15),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: rh(2)),
                  // Km away
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


  // MENU HIGHLIGHTS SECTION
  Widget _buildMenuHighlightsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: rh(10)),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Color(0xFFE3E3E3), width: 1),
          bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(20)),
            child: Text(
              'Menu Highlights',
              style: GoogleFonts.inter(
                fontSize: rfs(14),
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 16 / 14,
              ),
            ),
          ),
          SizedBox(height: rh(10)),
          // Menu Items Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMenuItem(Icons.coffee, 'Coffee'),
                _buildMenuItem(Icons.cake, 'Pastries'),
                _buildMenuItem(Icons.breakfast_dining, 'Breakfast'),
                _buildMenuItem(Icons.wifi, 'Free WiFi'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: rw(30), color: const Color(0xFF4B4B4B)),
        SizedBox(height: rh(5)),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: rfs(10),
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }




  void _handleVote(String reviewId, String voteType) {
    final amenityId = widget.cafeData?['id'] as String?;
    if (amenityId == null) return;
    Provider.of<BusinessProvider>(context, listen: false)
        .voteAmenityReview(amenityId, reviewId, voteType);
  }
}








