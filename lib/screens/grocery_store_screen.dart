import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/business_provider.dart';
import '../providers/review_provider.dart';
import '../models/business_model.dart';
import '../models/promotion_model.dart';
import '../utils/contact_utils.dart';
import '../widgets/give_review_dialog.dart';
import '../widgets/member_reviews_section.dart';
import '../widgets/partner_media_gallery.dart';
import '../widgets/photos_and_videos_section.dart';
import '../widgets/profile_image.dart';
import '../mixins/responsive_mixin.dart';
import '../utils/map_utils.dart';

class GroceryStoreScreen extends StatefulWidget {
  final Map<String, dynamic>? storeData;

  const GroceryStoreScreen({super.key, this.storeData});

  @override
  State<GroceryStoreScreen> createState() => _GroceryStoreScreenState();
}

class _GroceryStoreScreenState extends State<GroceryStoreScreen>
    with ResponsiveMixin {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.storeData?['id']?.toString();
      if (id != null && id.isNotEmpty) {
        Provider.of<BusinessProvider>(context, listen: false)
            .fetchBusinessDetail(id);
      }
    });
  }

  /// Returns fresh data merged from provider, falling back to constructor data.
  Map<String, dynamic>? get _storeData {
    final id = widget.storeData?['id']?.toString();
    if (id != null && id.isNotEmpty) {
      final detail = Provider.of<BusinessProvider>(context, listen: false)
          .getBusinessDetail(id);
      if (detail != null) {
        return {
          ...?widget.storeData,
          'id': detail.id,
          'name': detail.name,
          'category': detail.category,
          'rating': detail.rating,
          'reviewCount': detail.reviewCount,
          'location': detail.location,
          'isOpen': detail.isOpen,
          'image': detail.imageUrl,
          'phone': detail.phone,
          'openingTime': detail.openingTime,
          'closingTime': detail.closingTime,
          'operatingDays': detail.operatingDays,
          'servicesOffered': detail.servicesOffered,
          'followersCount': detail.followersCount,
          'whatsapp': detail.whatsapp,
          'promotions': detail.promotions,
          'media': detail.media,
        };
      }
    }
    return widget.storeData;
  }

  BusinessModel? get _detail {
    final id = widget.storeData?['id']?.toString();
    if (id != null && id.isNotEmpty) {
      return Provider.of<BusinessProvider>(context, listen: false).getBusinessDetail(id);
    }
    return null;
  }

  // Helper method to safely parse double from dynamic value
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // Helper method to safely parse int from dynamic value
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    final parts = time.split(':');
    if (parts.length != 2) return time;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final isPm = hour >= 12;
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final suffix = isPm ? 'pm' : 'am';
    return '$h:$minute $suffix';
  }




  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<BusinessProvider>(
      builder: (context, _, __) => Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top spacing
            SizedBox(height: MediaQuery.of(context).padding.top + rw(20)),
            
            // Header
            _buildHeader(context, screenWidth),
            SizedBox(height: rh(20)),

            // Store Name
            _buildProfileSection(context),
            SizedBox(height: rh(20)),

            // Category and Rating Card
            _buildCategoryAndRating(context),
            SizedBox(height: rh(12)),

            // Operating Hours Card
            _buildOperatingHoursCard(context),
            SizedBox(height: rh(12)),

            // Address Card
            _buildAddressCard(context),
            SizedBox(height: rh(12)),

            // Contact Card
            _buildContactCard(context),
            SizedBox(height: rh(12)),

            // Services Offered Section
            _buildServicesSection(context),
            SizedBox(height: rh(12)),

            // Review Card
            _buildStoreReviewPromptCard(context),
            SizedBox(height: rh(12)),

            // Promotions Section
            _buildPromotionsSection(context),
            SizedBox(height: rh(12)),

            // Photos and Videos Section
            PhotosAndVideosSection(
              imageUrls: _detail?.media.isNotEmpty == true
                  ? _detail!.media.map((m) => m.fileUrl).toList()
                  : ((_detail?.imageUrl?.isNotEmpty ?? false) ? [_detail!.imageUrl!] : const []),
            ),
            SizedBox(height: rh(12)),
            MemberReviewsSection(
              reviews: _detail?.reviews ?? const [],
              fallbackIcon: Icons.store,
              onVote: (reviewId, voteType) => _handleVote(reviewId, voteType),
              mediaItems: (_detail?.media ?? const [])
                  .map(
                    (m) => PartnerGalleryItem(
                      id: m.id,
                      mediaType: m.mediaType,
                      fileUrl: m.fileUrl,
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + rw(20)),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: 35,
              height: 35,
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/back_arrow.svg',
                  width: 14.11,
                  height: 14.11,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF000000),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          // Store Logo
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.red,
            ),
            clipBehavior: Clip.antiAlias,
            child: buildProfileImage(
              _storeData?['logo'] ?? _storeData?['image'],
              fallbackIcon: Icons.store,
              iconSize: 35,
            ),
          ),

          // Share Icon
          GestureDetector(
            onTap: () {
              final name = _storeData?['name'] ?? 'Grocery Store';
              final location = _storeData?['location'] ?? '';
              Share.share('Check out $name at $location on OneConnect!');
            },
            child: SizedBox(
              width: 35,
              height: 35,
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/share_icon.svg',
                  width: 21,
                  height: 20.79,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final String storeName = _storeData?['name'] ?? 'ABBASSI CASH AND CARRY';

    return Container(
      padding: EdgeInsets.symmetric(vertical: rw(5)),
      child: Column(
        children: [
          Text(
            storeName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF353535),
              letterSpacing: 0.112,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAndRating(BuildContext context) {
    final String category = _storeData?['category'] ?? 'Grocery Store';
    final double rating = _parseDouble(_storeData?['rating']) ?? 4.5;
    final int reviewCount = _parseInt(_storeData?['reviewCount']) ?? 10;
    final fullStoreId = _storeData?['id']?.toString() ?? '18';
    final String storeId = fullStoreId.length > 8 ? fullStoreId.substring(0, 8) : fullStoreId;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
      padding: EdgeInsets.symmetric(
        horizontal: rw(12),
        vertical: rw(10),
      ),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
        // Category Section
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(8),
                  vertical: rw(4),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(rw(5)),
                ),
                child: Text(
                  'Category',
                  style: GoogleFonts.poppins(
                    fontSize: rfs(12),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF353535),
                  ),
                ),
              ),
              SizedBox(height: rw(4)),
              Text(
                category,
                style: GoogleFonts.inter(
                  fontSize: rfs(14),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF353535),
                ),
              ),
            ],
          ),
        ),

        // Star Rating Section
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: SvgPicture.asset(
                      'assets/icons/star_icon.svg',
                      width: 15,
                      height: 15,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$rating ($reviewCount Reviews)',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // ID Badge Section
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/id_badge_icon.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '#ID ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      storeId,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000),
                      ),
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

  Widget _buildOperatingHoursCard(BuildContext context) {
    final bool isOpen = _storeData?['isOpen'] ?? false;
    final String openingTime = _formatTime(_storeData?['openingTime']?.toString());
    final String closingTime = _formatTime(_storeData?['closingTime']?.toString());
    final List<String> days = (_storeData?['operatingDays'] as List?)?.map((d) => d.toString()).toList() ?? [];
    final String daysText = days.isNotEmpty ? days.join(' - ') : 'Days not available';
    final String timeText = (openingTime.isNotEmpty && closingTime.isNotEmpty)
        ? '$openingTime - $closingTime'
        : 'Hours not available';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
      padding: EdgeInsets.symmetric(
        horizontal: rw(15),
        vertical: rw(15),
      ),
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
        children: [
          // Open Status Section
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/check_circle_icon.svg',
                  width: rw(25),
                  height: rw(25),
                ),
                SizedBox(width: rw(5)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOpen ? 'Open now' : 'Closed',
                      style: GoogleFonts.roboto(
                        fontSize: rfs(15),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: rw(2)),
                    Text(
                      timeText,
                      style: GoogleFonts.roboto(
                        fontSize: rfs(13),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: rw(2)),
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

          // Distance Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/distance_icon.svg',
                    width: rw(23),
                    height: rw(23),
                  ),
                  SizedBox(width: rw(5)),
                  Text(
                    'Distance',
                    style: GoogleFonts.roboto(
                      fontSize: rfs(15),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ],
              ),
              SizedBox(height: rw(2)),
              Padding(
                padding: EdgeInsets.only(right: rw(10)),
                child: Text(
                  _storeData?['distance']?.toString() ?? '2.3 Km away',
                  style: GoogleFonts.roboto(
                    fontSize: rfs(13),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF202020),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
      padding: EdgeInsets.symmetric(
        horizontal: rw(15),
        vertical: rw(15),
      ),
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
        children: [
          SvgPicture.asset(
            'assets/icons/location_pin_icon.svg',
            width: rw(17),
            height: rw(19),
            colorFilter: const ColorFilter.mode(
              Color(0xFFE53935),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: rw(5)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: rw(5)),
              child: Text(
                _storeData?['location'] ?? 'Address not available',
                style: GoogleFonts.inter(
                  fontSize: rfs(14),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF000000),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(width: rw(10)),
          GestureDetector(
            onTap: () async {
              final location = _storeData?['location'] ?? '';
              await openMapForQuery(context, '$location');
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: rw(12),
                vertical: rw(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF727272),
                borderRadius: BorderRadius.circular(rw(8)),
              ),
              child: Text(
                'View on Map',
                style: GoogleFonts.inter(
                  fontSize: rfs(12),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    final String phone = _storeData?['phone']?.toString() ?? '';
    final String whatsapp = _storeData?['whatsapp']?.toString() ?? phone;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
      padding: EdgeInsets.symmetric(
        horizontal: rw(15),
        vertical: rw(15),
      ),
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
          // Phone Section
          Flexible(
            child: GestureDetector(
              onTap: () async {
                await callPhoneNumber(context, phone);
              },
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/phone_icon.svg',
                    width: rw(19),
                    height: rw(19),
                  ),
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

          // WhatsApp Section
          Flexible(
            child: GestureDetector(
              onTap: () async {
                await openWhatsAppForNumber(context, whatsapp);
              },
              child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/whatsapp_icon.svg',
                  width: rw(25),
                  height: rw(25),
                ),
                SizedBox(width: rw(5)),
                Flexible(
                  child: Text(
                    whatsapp.isNotEmpty ? whatsapp : 'N/A',
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

  Widget _buildServicesSection(BuildContext context) {
    final List<String> services = (_storeData?['servicesOffered'] as List?)
            ?.map((s) => s.toString())
            .toList() ??
        [];
    final List<String> displayServices = services.isNotEmpty
        ? services
        : const ['Not specified', 'Not specified', 'Not specified', 'Not specified'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
      padding: EdgeInsets.symmetric(
        horizontal: rw(12),
        vertical: rw(20),
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Services Offered',
            style: GoogleFonts.inter(
              fontSize: rfs(20),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
            ),
          ),
          SizedBox(height: rw(20)),

          // Services Grid
          Column(
            children: [
                // First Row
                Row(
                  children: [
                    Expanded(
                      child: _buildServiceItem(context,
                        'assets/images/iconamoon_delivery-fill.svg',
                        displayServices.isNotEmpty ? displayServices[0] : 'Not specified',
                      ),
                    ),
                    SizedBox(width: rw(20)),
                    Expanded(
                      child: _buildServiceItem(context,
                        'assets/images/tabler_shopping-cart-check.svg',
                        displayServices.length > 1 ? displayServices[1] : 'Not specified',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: rw(24)),
                // Second Row
                Row(
                  children: [
                    Expanded(
                      child: _buildServiceItem(context,
                        'assets/images/material-symbols_shopping-bag-speed.svg',
                        displayServices.length > 2 ? displayServices[2] : 'Not specified',
                      ),
                    ),
                    SizedBox(width: rw(20)),
                    Expanded(
                      child: _buildServiceItem(context,
                        'assets/images/ic_round-payment.svg',
                        displayServices.length > 3 ? displayServices[3] : 'Not specified',
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

  Widget _buildServiceItem(BuildContext context, String iconPath, String label) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: rw(24),
          height: rw(24),
        ),
        SizedBox(width: rw(12)),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: rfs(12),
              fontWeight: FontWeight.w400,
              color: const Color(0xFF353535),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreReviewPromptCard(BuildContext context) {
    final String storeName = _storeData?['name'] ?? 'Abbasi Cash and Carry';
    final int followers = _parseInt(_storeData?['followersCount']) ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
      padding: EdgeInsets.symmetric(
        horizontal: rw(12),
        vertical: rw(15),
      ),
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
        children: [
          // Circular Logo
          Container(
            width: rw(60),
            height: rw(60),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: buildProfileImage(
              _storeData?['logo'] ?? _storeData?['image'],
              fallbackIcon: Icons.store,
              iconSize: 30,
            ),
          ),
          SizedBox(width: rw(15)),
          
          // Store Name and Followers
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: GoogleFonts.inter(
                    fontSize: rfs(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                ),
                SizedBox(height: rw(4)),
                Text(
                  '$followers Followers',
                  style: GoogleFonts.inter(
                    fontSize: rfs(14),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF727272),
                  ),
                ),
              ],
            ),
          ),
          
          // Give a Review Button
          GestureDetector(
            onTap: () {
              GiveReviewDialog.show(
                context: context,
                itemName: storeName,
                itemLocation: _storeData?['location'] ?? 'Location',
                itemRating: _parseDouble(_storeData?['rating']) ?? 4.5,
                reviewCount: _parseInt(_storeData?['reviewCount'] ?? _storeData?['reviews']) ?? 10,
                itemImage: _storeData?['logo'] ?? _storeData?['image'],
                itemTypeHint: 'STORE',
                onSubmit: (rating, review, hasPhoto, hasVideo) async {
                  final businessId = _storeData?['id']?.toString();
                  if (businessId == null || businessId.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot submit review: missing business ID'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  final reviewProvider =
                      Provider.of<ReviewProvider>(context, listen: false);
                  final ratingText = rating >= 4
                      ? 'Excellent'
                      : rating >= 3
                          ? 'Good'
                          : rating >= 2
                              ? 'Average'
                              : 'Poor';
                  final success = await reviewProvider.submitBusinessReview(
                    businessId,
                    rating: rating.toDouble(),
                    ratingText: ratingText,
                    reviewText: review.isNotEmpty ? review : null,
                  );

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Review submitted!'
                            : (reviewProvider.error ?? 'Failed to submit review'),
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );

                  if (success) {
                    final submitted = reviewProvider.lastSubmittedReview;
                    if (submitted != null) {
                      Provider.of<BusinessProvider>(context, listen: false)
                          .applySubmittedBusinessReview(businessId, submitted);
                    } else {
                      await Provider.of<BusinessProvider>(context, listen: false)
                          .refreshBusinessDetail(businessId);
                    }
                  }
                },
              );
            },
            child: Container(
              width: rw(130),
              padding: EdgeInsets.symmetric(
                horizontal: rw(8),
                vertical: rh(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF3195AB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Give a Review',
                  style: GoogleFonts.inter(
                    fontSize: rfs(13),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsSection(BuildContext context) {
    final promotions = _detail?.promotions ?? [];
    return Column(
      children: [
        // Header with Red Promotion Icon
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(15)),
          child: Row(
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xFFE53935),
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/lsicon_badge-promotion-filled.png',
                  width: rw(30),
                  height: rw(30),
                ),
              ),
              SizedBox(width: rw(10)),
              Text(
                'Special offers for you',
                style: GoogleFonts.inter(
                  fontSize: rfs(18),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF000000),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rw(15)),

        // Horizontal Scrolling Promotion Cards - Increased height
        SizedBox(
          height: rh(180), // Increased from 0.35 * screenWidth
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: rw(15)),
            children: [
              if (promotions.isNotEmpty)
                ...promotions.expand((p) => [
                      _buildPromotionCard(context, p),
                      SizedBox(width: rw(15)),
                    ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionCard(BuildContext context, PromotionModel? promo) {
    return Container(
      width: rw(312), // Responsive width
      padding: EdgeInsets.all(rw(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          Container(
            width: rw(90),
            height: rw(90),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rw(10)),
              image: promo?.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(promo!.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage('assets/images/Product Photo (1).png'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(width: rw(12)),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Name
                Text(
                  promo?.title ?? 'Promotion',
                  style: GoogleFonts.inter(
                    fontSize: rfs(15),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: rw(5)),
                
                // Discount Badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF000000),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/images/lsicon_badge-promotion-filled.png',
                        width: rw(18),
                        height: rw(18),
                      ),
                    ),
                    SizedBox(width: rw(4)),
                    Flexible(
                      child: Text(
                        promo?.discountPct != null ? 'Up to ${promo!.discountPct!.toStringAsFixed(0)}% off' : 'Special offer',
                        style: GoogleFonts.inter(
                          fontSize: rfs(13),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF000000),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: rw(6)),
                
                // Tagline
                Text(
                  promo?.description ?? 'No description available',
                  style: GoogleFonts.inter(
                    fontSize: rfs(11),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF727272),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: rw(8)),
                
                // Pricing
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      promo?.price != null ? 'Rs. ${promo!.price!.toStringAsFixed(0)}' : 'Rs. --',
                      style: GoogleFonts.inter(
                        fontSize: rfs(16),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE53935),
                      ),
                    ),
                    SizedBox(width: rw(6)),
                    Text(
                      promo?.discountPct != null && promo?.price != null
                          ? 'Rs. ${(promo!.price! / (1 - (promo.discountPct! / 100))).toStringAsFixed(0)}'
                          : '',
                      style: GoogleFonts.inter(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF727272),
                        decoration: TextDecoration.lineThrough,
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

  void _handleVote(String reviewId, String voteType) {
    final businessId = _storeData?['id']?.toString();
    if (businessId == null || businessId.isEmpty) return;
    Provider.of<BusinessProvider>(context, listen: false)
        .voteBusinessReview(businessId, reviewId, voteType);
  }

}



