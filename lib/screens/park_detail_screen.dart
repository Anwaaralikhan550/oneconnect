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
import '../widgets/review_us_section.dart';
import '../widgets/location_section.dart';
import '../widgets/detail_screen_header.dart';

class ParkDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? parkData;

  const ParkDetailScreen({super.key, this.parkData});

  @override
  State<ParkDetailScreen> createState() => _ParkDetailScreenState();
}

class _ParkDetailScreenState extends State<ParkDetailScreen>
    with ResponsiveMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.parkData?['id'] as String?;
      if (id != null) {
        Provider.of<BusinessProvider>(context, listen: false).fetchAmenityDetail(id);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessProvider>(
      builder: (context, provider, _) {
    final detail = provider.getAmenityDetail(widget.parkData?['id'] ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          DetailScreenHeader(
            title: 'Park',
            iconAssetPath: 'assets/images/park_icon_hub.svg',
            fallbackIcon: Icons.park,
            onShare: () {
              final name = detail?.name ?? widget.parkData?['name'] ?? 'Park';
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
                  _buildOpeningTimeAndDistanceSection(),
                  SizedBox(height: rh(9)),
                  LocationSection(
              locationText: detail?.location ?? widget.parkData?['location'] ?? '',
            ),
                  SizedBox(height: rh(9)),
                  _buildEntryFeeSection(),
                  SizedBox(height: rh(10)),
                  PhotosAndVideosSection(imageUrls: detail?.media.isNotEmpty == true ? detail!.media.map((m) => m.fileUrl).toList() : (detail?.imageUrl?.isNotEmpty == true ? [detail!.imageUrl!] : [])),
                  SizedBox(height: rh(10)),
                  ReviewUsSection(
              entityName: detail?.name ?? widget.parkData?['name'] ?? 'Park',
              entityImageUrl: detail?.imageUrl ?? widget.parkData?['image'],
              displayMetric: "${detail?.reviewCount ?? widget.parkData?['reviewCount'] ?? widget.parkData?['reviews'] ?? 0} Reviews",
              fallbackIcon: Icons.park,
              onGiveReview: () {
                GiveReviewDialog.show(
                  context: context,
                  itemName: detail?.name ?? widget.parkData?['name'] ?? 'Park',
                  itemLocation: detail?.location ?? widget.parkData?['location'] ?? '',
                  itemRating: detail?.rating ?? double.tryParse(widget.parkData?['rating']?.toString() ?? '0') ?? 0.0,
                  reviewCount: detail?.reviewCount ?? int.tryParse(widget.parkData?['reviewCount']?.toString() ?? widget.parkData?['reviews']?.toString() ?? '0') ?? 0,
                  itemImage: detail?.imageUrl ?? widget.parkData?['image'],
                  itemTypeHint: 'PARK',
                  onSubmit: (rating, review, hasPhoto, hasVideo) async {
                    final entityId = widget.parkData?['id'] as String?;
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
              fallbackIcon: Icons.park,
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


  // PROFILE SECTION - Figma: bg white, rounded 10px, padding 5px vertical
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
              child: buildProfileImage(detail?.imageUrl ?? widget.parkData?['image'], fallbackIcon: Icons.park, iconSize: 50),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name - Poppins SemiBold 14px #353535
                        Text(
                          detail?.name ?? widget.parkData?['name'] ?? 'Park',
                          style: GoogleFonts.poppins(
                            fontSize: rfs(14),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF353535),
                            letterSpacing: 0.112,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: rh(4)),
                        // Location - Inter Medium 12px #353535
                        Text(
                          detail?.location ?? widget.parkData?['location'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: rfs(12),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF353535),
                            letterSpacing: 0.168,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                    // Heart icon - 20x20
                    Consumer<FavoriteProvider>(
                      builder: (context, favProvider, _) {
                        final amenityId = widget.parkData?['id'] as String?;
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
                        final ratingVal = detail?.rating ?? double.tryParse(widget.parkData?['rating']?.toString() ?? '') ?? 4.5;
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
                      detail != null ? detail.rating.toStringAsFixed(1) : (widget.parkData?['rating'] ?? '4.5'),
                      style: GoogleFonts.inter(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF353535),
                        letterSpacing: 0.168,
                      ),
                    ),
                    SizedBox(width: rw(4)),
                    Text(
                      '(${detail != null ? detail.reviewCount : (widget.parkData?['reviewCount'] ?? widget.parkData?['reviews'] ?? '10')} Reviews)',
                      style: GoogleFonts.inter(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF353535),
                        letterSpacing: 0.168,
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

  // OPENING TIME AND DISTANCE SECTION - Figma: border 2px #f3f3f3, rounded 15px
  Widget _buildOpeningTimeAndDistanceSection() {
    final detail = Provider.of<BusinessProvider>(context, listen: false)
        .getAmenityDetail(widget.parkData?['id'] ?? '');
    final opening = detail?.openingTime?.toString() ??
        widget.parkData?['openingTime']?.toString();
    final closing = detail?.closingTime?.toString() ??
        widget.parkData?['closingTime']?.toString();
    final timeText = (opening != null &&
            opening.isNotEmpty &&
            closing != null &&
            closing.isNotEmpty)
        ? '$opening - $closing'
        : '9:00 am - 11:00 pm';
    final days = detail?.operatingDays ??
        ((widget.parkData?['operatingDays'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[]);
    final daysText = days.isNotEmpty ? days.join(', ') : 'Monday - Sunday';
    final distanceText = widget.parkData?['distance']?.toString() ?? '2.3 Km away';

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
          // Opening Time - Left side
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
                // Text Column - width 119px
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Opening Time - Roboto Medium 15px
                    Text(
                      'Opening Time',
                      style: GoogleFonts.roboto(
                        fontSize: rfs(15),
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
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
              // Text Column - width 74px
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


  // ENTRY FEE SECTION - Figma: bg neutral-50, border top/bottom #e3e3e3
  Widget _buildEntryFeeSection() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Entry Fee Column - 149px width
          SizedBox(
            width: rw(149),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label - Inter Bold 10px
                Text(
                  'Entry Fee',
                  style: GoogleFonts.inter(
                    fontSize: rfs(10),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 16 / 10,
                  ),
                ),
                SizedBox(height: rh(10)),
                // Money icon and No Fee row
                Row(
                  children: [
                    // Money hand icon - 30x30
                    SvgPicture.asset(
                      'assets/icons/fluent_money_hand_icon.svg',
                      width: rw(30),
                      height: rw(30),
                      placeholderBuilder: (context) => Icon(
                        Icons.money_off,
                        size: rw(30),
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: rw(5)),
                    // No Fee - Inter Bold 20px
                    Text(
                      'No Fee',
                      style: GoogleFonts.inter(
                        fontSize: rfs(20),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 16 / 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: rw(34)),
          // Keep parks clean notice - 149px width
          Container(
            width: rw(149),
            padding: EdgeInsets.all(rw(10)),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDFDF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Keep your parks neat and clean',
                style: GoogleFonts.inter(
                  fontSize: rfs(11),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFF2222),
                  height: 16 / 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }




  // REVIEW CARD - Figma: 344 width, shadow, rounded 15px
  void _handleVote(String reviewId, String voteType) {
    final amenityId = widget.parkData?['id'] as String?;
    if (amenityId == null) return;
    Provider.of<BusinessProvider>(context, listen: false)
        .voteAmenityReview(amenityId, reviewId, voteType);
  }
}




