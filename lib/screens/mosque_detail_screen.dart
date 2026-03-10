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
import '../widgets/location_section.dart';
import '../widgets/facilities_section.dart';
import '../widgets/member_reviews_section.dart';
import '../widgets/partner_media_gallery.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/detail_screen_header.dart';

class MosqueDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? mosqueData;
  const MosqueDetailScreen({super.key, this.mosqueData});

  @override
  State<MosqueDetailScreen> createState() => _MosqueDetailScreenState();
}

class _MosqueDetailScreenState extends State<MosqueDetailScreen>
    with ResponsiveMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.mosqueData?['id'] as String?;
      if (id != null) {
        Provider.of<BusinessProvider>(context, listen: false).fetchAmenityDetail(id);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessProvider>(
      builder: (context, provider, _) {
    final detail = provider.getAmenityDetail(widget.mosqueData?['id'] ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          DetailScreenHeader(
            title: 'Mosque',
            iconAssetPath: 'assets/images/mosque_icon_hub.svg',
            fallbackIcon: Icons.mosque,
            onShare: () {
              final name = detail?.name ?? widget.mosqueData?['name'] ?? 'Mosque';
              final location = detail?.location ?? widget.mosqueData?['location'] ?? '';
              Share.share('Check out $name at $location on OneConnect!');
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: rh(10)),
                  _buildProfileSection(detail),
                  SizedBox(height: rh(10)),
                  _buildPrayerTimesSection(),
                  SizedBox(height: rh(9)),
                  LocationSection(
                    locationText: detail?.location ?? widget.mosqueData?['location'] ?? '',
                  ),
                  SizedBox(height: rh(9)),
                  FacilitiesSection(
                    items: const [
                      FacilityItem(icon: Icons.local_parking, label: 'Parking'),
                      FacilityItem(icon: Icons.water_drop, label: 'Wudu'),
                      FacilityItem(icon: Icons.ac_unit, label: 'AC'),
                      FacilityItem(icon: Icons.accessible, label: 'Accessible'),
                    ],
                    notice: Container(
                      padding: EdgeInsets.all(rw(10)),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                      child: Text('Separate ladies prayer area available', style: GoogleFonts.inter(fontSize: rfs(11), fontWeight: FontWeight.w500, color: const Color(0xFF2E7D32), height: 16 / 11), textAlign: TextAlign.center),
                    ),
                  ),
                  SizedBox(height: rh(10)),
                  PhotosAndVideosSection(imageUrls: detail?.media.isNotEmpty == true ? detail!.media.map((m) => m.fileUrl).toList() : (detail?.imageUrl?.isNotEmpty == true ? [detail!.imageUrl!] : [])),
                  SizedBox(height: rh(10)),
                  _buildReviewUsSection(detail),
                  SizedBox(height: rh(10)),
                  MemberReviewsSection(
                    reviews: detail?.reviews ?? [],
                    fallbackIcon: Icons.mosque,
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


  Widget _buildProfileSection(AmenityModel? detail) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: rw(15), vertical: rh(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(child: SizedBox(width: rw(90), height: rw(90), child: buildProfileImage(detail?.imageUrl ?? widget.mosqueData?['image'], fallbackIcon: Icons.mosque, iconSize: 40))),
          SizedBox(width: rw(15)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(detail?.name ?? widget.mosqueData?['name'] ?? 'Mosque', style: GoogleFonts.poppins(fontSize: rfs(14), fontWeight: FontWeight.w600, color: const Color(0xFF353535), letterSpacing: 0.112, height: 1.2)),
                    SizedBox(height: rh(4)),
                    Text(detail?.location ?? widget.mosqueData?['location'] ?? '', style: GoogleFonts.inter(fontSize: rfs(12), fontWeight: FontWeight.w500, color: const Color(0xFF353535), letterSpacing: 0.168, height: 1.3)),
                  ]),
                  Consumer<FavoriteProvider>(
                    builder: (context, favProvider, _) {
                      final amenityId = widget.mosqueData?['id'] as String?;
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
                ]),
                SizedBox(height: rh(4)),
                Row(children: [Row(children: List.generate(5, (index) {
                  final ratingVal = detail?.rating ?? double.tryParse(widget.mosqueData?['rating']?.toString() ?? '') ?? 4.5;
                  return Icon(
                    index < ratingVal.floor() ? Icons.star : (index < ratingVal ? Icons.star_half : Icons.star_border),
                    size: rw(15),
                    color: const Color(0xFFFFCD29),
                  );
                })), SizedBox(width: rw(8)), Text(detail != null ? detail.rating.toStringAsFixed(1) : (widget.mosqueData?['rating'] ?? '4.5'), style: GoogleFonts.inter(fontSize: rfs(12), fontWeight: FontWeight.w500, color: const Color(0xFF353535), letterSpacing: 0.168)), SizedBox(width: rw(4)), Text('(${detail != null ? detail.reviewCount : (widget.mosqueData?['reviewCount'] ?? widget.mosqueData?['reviews'] ?? '10')} Reviews)', style: GoogleFonts.inter(fontSize: rfs(12), fontWeight: FontWeight.w500, color: const Color(0xFF353535), letterSpacing: 0.168))]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesSection() {
    return Container(
      width: rw(360),
      padding: EdgeInsets.symmetric(horizontal: rw(25), vertical: rh(15)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFF3F3F3), width: 2)),
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/doctor_tick_circle.svg', width: rw(25), height: rw(25), colorFilter: const ColorFilter.mode(Color(0xFF0097B2), BlendMode.srcIn), placeholderBuilder: (context) => Icon(Icons.check_circle, size: rw(25), color: const Color(0xFF0097B2))),
                SizedBox(width: rw(5)),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Prayer Times', style: GoogleFonts.roboto(fontSize: rfs(15), fontWeight: FontWeight.w500, color: Colors.black)),
                  SizedBox(height: rh(2)),
                  Text('Fajr: 5:30 AM', style: GoogleFonts.roboto(fontSize: rfs(13), fontWeight: FontWeight.w400, color: Colors.black)),
                  SizedBox(height: rh(2)),
                  Text('Jummah: 1:30 PM', style: GoogleFonts.roboto(fontSize: rfs(12), fontWeight: FontWeight.w400, color: const Color(0xFF727272))),
                ]),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/icons/doctor_distance_icon.svg', width: rw(25), height: rw(24.943), placeholderBuilder: (context) => Icon(Icons.directions_walk, size: rw(25), color: const Color(0xFF0097B2))),
              SizedBox(width: rw(5)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Distance', style: GoogleFonts.roboto(fontSize: rfs(15), fontWeight: FontWeight.w500, color: Colors.black)),
                SizedBox(height: rh(2)),
                Text(widget.mosqueData?['distance']?.toString() ?? '2.3 Km away', style: GoogleFonts.roboto(fontSize: rfs(13), fontWeight: FontWeight.w400, color: const Color(0xFF202020))),
              ]),
            ],
          ),
        ],
      ),
    );
  }




  Widget _buildReviewUsSection(AmenityModel? detail) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: rh(10), horizontal: rw(20)),
      decoration: const BoxDecoration(color: Color(0xFFFAFAFA), border: Border(top: BorderSide(color: Color(0xFFE3E3E3), width: 1), bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(children: [
              Padding(padding: EdgeInsets.symmetric(horizontal: rw(5)), child: ClipOval(child: SizedBox(width: rw(42), height: rw(42), child: buildProfileImage(detail?.imageUrl ?? widget.mosqueData?['image'], fallbackIcon: Icons.mosque, iconSize: 25)))),
              SizedBox(width: rw(5)),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Flexible(child: Text(detail?.name ?? widget.mosqueData?['name'] ?? 'Mosque', style: GoogleFonts.poppins(fontSize: rfs(15), fontWeight: FontWeight.w500, color: const Color(0xFF141414), height: 16 / 15), maxLines: 1, overflow: TextOverflow.ellipsis))]), Text('${detail?.reviewCount ?? 0} Reviews', style: GoogleFonts.poppins(fontSize: rfs(11), fontWeight: FontWeight.w500, color: const Color(0xFF828282), height: 16 / 11))]),
              ),
            ]),
          ),
          SizedBox(width: rw(10)),
          GestureDetector(onTap: () { GiveReviewDialog.show(context: context, itemName: detail?.name ?? widget.mosqueData?['name'] ?? 'Mosque', itemLocation: detail?.location ?? widget.mosqueData?['location'] ?? 'Location', itemRating: detail?.rating ?? double.tryParse(widget.mosqueData?['rating']?.toString() ?? '4.5') ?? 4.5, reviewCount: detail?.reviewCount ?? int.tryParse(widget.mosqueData?['reviewCount']?.toString() ?? widget.mosqueData?['reviews']?.toString() ?? '10') ?? 10, itemImage: detail?.imageUrl ?? widget.mosqueData?['image'], itemTypeHint: 'MASJID', onSubmit: (rating, review, hasPhoto, hasVideo) async { final entityId = widget.mosqueData?['id'] as String?; if (entityId == null) { if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot submit review: missing entity ID'), backgroundColor: Colors.red)); } return; } final reviewProvider = Provider.of<ReviewProvider>(context, listen: false); final ratingText = rating >= 4 ? 'Excellent' : rating >= 3 ? 'Good' : rating >= 2 ? 'Average' : 'Poor'; final success = await reviewProvider.submitAmenityReview(entityId, rating: rating.toDouble(), ratingText: ratingText, reviewText: review.isNotEmpty ? review : null); if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Review submitted!' : (reviewProvider.error ?? 'Failed to submit review')), backgroundColor: success ? Colors.green : Colors.red)); if (success) { final submitted = reviewProvider.lastSubmittedReview; if (submitted != null) { Provider.of<BusinessProvider>(context, listen: false).applySubmittedAmenityReview(entityId, submitted); } } } }); }, child: Container(width: rw(130), padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(8)), decoration: BoxDecoration(color: const Color(0xFF3195AB), borderRadius: BorderRadius.circular(20)), child: Center(child: Text('Give a Review', style: GoogleFonts.poppins(fontSize: rfs(13), fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center, maxLines: 1)))),
        ],
      ),
    );
  }



  void _handleVote(String reviewId, String voteType) {
    final amenityId = widget.mosqueData?['id'] as String?;
    if (amenityId == null) return;
    Provider.of<BusinessProvider>(context, listen: false)
        .voteAmenityReview(amenityId, reviewId, voteType);
  }
}



