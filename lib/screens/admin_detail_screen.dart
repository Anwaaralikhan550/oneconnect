import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/admin_office_provider.dart';
import '../providers/business_provider.dart';
import '../providers/review_provider.dart';
import '../models/search_result_model.dart';
import '../models/amenity_model.dart';
import '../widgets/give_review_dialog.dart';
import '../widgets/profile_image.dart';
import '../widgets/photos_and_videos_section.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/location_section.dart';
import '../widgets/facilities_section.dart';
import '../widgets/member_reviews_section.dart';
import '../widgets/partner_media_gallery.dart';

class AdminDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? adminData;
  const AdminDetailScreen({super.key, this.adminData});

  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen>
    with ResponsiveMixin {
  String? get _officeId => widget.adminData?['id']?.toString();

  @override
  void initState() {
    super.initState();
    final id = _officeId;
    if (id != null && id.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AdminOfficeProvider>(context, listen: false).fetchDetail(id);
        Provider.of<BusinessProvider>(context, listen: false).fetchAmenityDetail(id);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer2<AdminOfficeProvider, BusinessProvider>(
      builder: (context, adminProvider, businessProvider, _) {
        final adminDetail = _officeId != null ? adminProvider.getDetail(_officeId!) : null;
        final amenityDetail = _officeId != null ? businessProvider.getAmenityDetail(_officeId!) : null;
        final dynamic detail = amenityDetail ?? adminDetail;
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              _buildHeader(detail),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: rh(10)),
                      _buildProfileSection(detail),
                      SizedBox(height: rh(10)),
                      _buildOfficeHoursSection(detail),
                      SizedBox(height: rh(9)),
                      LocationSection(
                locationText: detail is AmenityModel ? (detail.location ?? '') : (detail is AdminOfficeModel ? (detail.address ?? '') : (widget.adminData?['location'] ?? '')),
              ),
                      SizedBox(height: rh(9)),
                      _buildServicesSection(detail),
                      SizedBox(height: rh(10)),
                      _buildContactInfoSection(detail),
                      SizedBox(height: rh(10)),
                      PhotosAndVideosSection(
                        imageUrls: detail is AmenityModel 
                          ? (detail.media.isNotEmpty ? detail.media.map((m) => m.fileUrl).toList() : (detail.imageUrl != null ? [detail.imageUrl!] : []))
                          : (detail is AdminOfficeModel && detail.imageUrl != null ? [detail.imageUrl!] : [])
                      ),
                      SizedBox(height: rh(10)),
                      _buildReviewUsSection(detail),
                      SizedBox(height: rh(10)),
                      MemberReviewsSection(
                reviews: detail is AmenityModel ? detail.reviews : const [],
                fallbackIcon: Icons.admin_panel_settings,
                sectionTitle: 'Resident Reviews',
                mediaItems: detail is AmenityModel 
                  ? detail.media.map((m) => PartnerGalleryItem(id: m.id, mediaType: m.mediaType, fileUrl: m.fileUrl)).toList()
                  : ((detail is AdminOfficeModel && detail.imageUrl != null && detail.imageUrl!.isNotEmpty)
                    ? [PartnerGalleryItem(id: detail.id, mediaType: 'PHOTO', fileUrl: detail.imageUrl!)]
                    : const []),
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

  Widget _buildServicesSection(dynamic detail) {
    List<FacilityItem> serviceItems = [];
    if (detail is AmenityModel && detail.servicesOffered.isNotEmpty) {
      serviceItems = detail.servicesOffered.map((s) => FacilityItem(
        icon: _getServiceIcon(s),
        label: s,
      )).toList();
    } else {
      serviceItems = const [
        FacilityItem(icon: Icons.description, label: 'Documents'),
        FacilityItem(icon: Icons.receipt_long, label: 'Payments'),
        FacilityItem(icon: Icons.report_problem, label: 'Complaints'),
        FacilityItem(icon: Icons.support_agent, label: 'Support'),
      ];
    }
    return FacilitiesSection(
      title: 'Services',
      items: serviceItems,
      notice: Container(
        padding: EdgeInsets.all(rw(10)),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Online services available 24/7',
          style: GoogleFonts.inter(
            fontSize: rfs(11),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1565C0),
            height: 16 / 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceName) {
    final s = serviceName.toLowerCase();
    if (s.contains('document') || s.contains('file') || s.contains('form')) return Icons.description;
    if (s.contains('pay') || s.contains('bill') || s.contains('tax')) return Icons.receipt_long;
    if (s.contains('complain') || s.contains('issue')) return Icons.report_problem;
    if (s.contains('support') || s.contains('help')) return Icons.support_agent;
    if (s.contains('security')) return Icons.security;
    if (s.contains('maintenance')) return Icons.build;
    return Icons.check_circle_outline;
  }

  Widget _buildHeader(dynamic detail) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: rh(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox(
                      width: rw(35),
                      height: rw(35),
                      child: SvgPicture.asset(
                        'assets/icons/figma_back_icon.svg',
                        width: rw(35),
                        height: rw(35),
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF0097B2),
                          BlendMode.srcIn,
                        ),
                        placeholderBuilder: (context) => Icon(
                          Icons.arrow_back,
                          size: rw(35),
                          color: const Color(0xFF0097B2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: rw(60)),
                  Text(
                    'Administration',
                    style: GoogleFonts.inter(
                      fontSize: rfs(22),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF515151),
                      letterSpacing: -0.28,
                    ),
                  ),
                  SizedBox(width: rw(60)),
                  GestureDetector(
                    onTap: () {
                      final name = detail is AmenityModel ? detail.name : (detail is AdminOfficeModel ? detail.name : (widget.adminData?['name'] ?? 'Office'));
                      final location = detail is AmenityModel ? (detail.location ?? '') : (detail is AdminOfficeModel ? (detail.address ?? '') : (widget.adminData?['location'] ?? ''));
                      Share.share('Check out $name at $location on OneConnect!');
                    },
                    child: SizedBox(
                      width: rw(21),
                      height: rw(21),
                      child: Icon(
                        Icons.share_outlined,
                        size: rw(25),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: rh(15)),
              child: SvgPicture.asset(
                'assets/images/admin_icon_hub.svg',
                width: rw(55),
                height: rh(55),
                placeholderBuilder: (context) => Icon(
                  Icons.admin_panel_settings,
                  size: rw(45),
                  color: const Color(0xFF4B4B4B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(dynamic detail) {
    final officeName = detail is AmenityModel ? detail.name : (detail is AdminOfficeModel ? detail.name : (widget.adminData?['name'] ?? 'Office'));
    final officeAddress = detail is AmenityModel ? (detail.location ?? '') : (detail is AdminOfficeModel ? (detail.address ?? '') : (widget.adminData?['location'] ?? ''));
    final rating = detail is AmenityModel ? detail.rating : (detail is AdminOfficeModel ? detail.rating : (double.tryParse(widget.adminData?['rating']?.toString() ?? '0') ?? 0.0));
    final officeImage = detail is AmenityModel ? detail.imageUrl : (detail is AdminOfficeModel ? detail.imageUrl : widget.adminData?['image']);
    final int fullStars = rating.floor();
    final bool hasHalfStar = (rating - fullStars) >= 0.25;
    final int reviewCount = detail is AmenityModel ? detail.reviewCount : (detail is AdminOfficeModel ? (detail.rating * 10).round() : (int.tryParse(widget.adminData?['reviewCount']?.toString() ?? widget.adminData?['reviews']?.toString() ?? '0') ?? 0));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: rw(15), vertical: rh(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: SizedBox(
              width: rw(90),
              height: rw(90),
              child: buildProfileImage(officeImage, fallbackIcon: Icons.admin_panel_settings, iconSize: 50),
            ),
          ),
          SizedBox(width: rw(15)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            officeName,
                            style: GoogleFonts.poppins(
                              fontSize: rfs(14),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF353535),
                              letterSpacing: 0.112,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: rh(4)),
                          Text(
                            officeAddress,
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
                    Icon(Icons.favorite_border, size: rw(20), color: Colors.black),
                  ],
                ),
                SizedBox(height: rh(4)),
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < fullStars ? Icons.star : (index == fullStars && hasHalfStar ? Icons.star_half : Icons.star_border),
                          size: rw(15),
                          color: const Color(0xFFFFCD29),
                        ),
                      ),
                    ),
                    SizedBox(width: rw(8)),
                    Text(
                      rating.toStringAsFixed(1),
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
                        '($reviewCount Reviews)',
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

  Widget _buildOfficeHoursSection(dynamic detail) {
    final bool isOpen = detail is AmenityModel ? detail.isOpen : (detail is AdminOfficeModel ? detail.isOpen : true);
    final opening = detail is AmenityModel ? detail.openingTime : (widget.adminData?['openingTime']?.toString());
    final closing = detail is AmenityModel ? detail.closingTime : (widget.adminData?['closingTime']?.toString());
    
    List operatingDays = [];
    if (detail is AmenityModel) {
      operatingDays = detail.operatingDays;
    } else if (widget.adminData?['operatingDays'] is List) {
      operatingDays = widget.adminData!['operatingDays'] as List;
    }

    return Container(
      width: rw(360),
      padding: EdgeInsets.symmetric(horizontal: rw(25), vertical: rh(15)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF3F3F3), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Office Hours',
                              style: GoogleFonts.roboto(
                                fontSize: rfs(15),
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (detail != null) ...[
                            SizedBox(width: rw(8)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: rw(6), vertical: rh(1)),
                              decoration: BoxDecoration(
                                color: isOpen ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isOpen ? 'Open' : 'Closed',
                                style: GoogleFonts.roboto(
                                  fontSize: rfs(10),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: rh(2)),
                      Text(
                        ((opening != null && opening.isNotEmpty && closing != null && closing.isNotEmpty)
                                ? '$opening - $closing'
                                : '9:00 AM - 5:00 PM'),
                        style: GoogleFonts.roboto(
                          fontSize: rfs(13),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: rh(2)),
                      Text(
                        (operatingDays.isNotEmpty
                                ? operatingDays.map((e) => e.toString()).join(', ')
                                : 'Monday - Saturday'),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distance',
                    style: GoogleFonts.roboto(
                      fontSize: rfs(15),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: rh(2)),
                  Text(
                    widget.adminData?['distance']?.toString() ?? '3.2 Km away',
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

  Widget _buildContactInfoSection(dynamic detail) {
    final phone = detail is AmenityModel ? detail.phone : (detail is AdminOfficeModel ? detail.phone : (widget.adminData?['phone']?.toString()));
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
          SizedBox(
            width: rw(149),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Info',
                  style: GoogleFonts.inter(
                    fontSize: rfs(10),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 16 / 10,
                  ),
                ),
                SizedBox(height: rh(10)),
                Row(
                  children: [
                    Icon(Icons.phone, size: rw(20), color: const Color(0xFF0097B2)),
                    SizedBox(width: rw(5)),
                    Flexible(
                      child: Text(
                        phone ?? '051-593452',
                        style: GoogleFonts.inter(
                          fontSize: rfs(14),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: rh(5)),
                Row(
                  children: [
                    Icon(Icons.email, size: rw(20), color: const Color(0xFF0097B2)),
                    SizedBox(width: rw(5)),
                    Flexible(
                      child: Text(
                        'admin@nac.pk',
                        style: GoogleFonts.inter(
                          fontSize: rfs(12),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF353535),
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
          SizedBox(width: rw(34)),
          Container(
            width: rw(149),
            padding: EdgeInsets.all(rw(10)),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Walk-in appointments available',
                style: GoogleFonts.inter(
                  fontSize: rfs(11),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2E7D32),
                  height: 16 / 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewUsSection(dynamic detail) {
    final name = detail is AmenityModel ? detail.name : (detail is AdminOfficeModel ? detail.name : (widget.adminData?['name'] ?? 'Office'));
    final rating = detail is AmenityModel ? detail.rating : (detail is AdminOfficeModel ? detail.rating : (double.tryParse(widget.adminData?['rating']?.toString() ?? '0') ?? 0.0));
    final reviewCount = detail is AmenityModel ? detail.reviewCount : (detail is AdminOfficeModel ? (detail.rating * 10).round() : (int.tryParse(widget.adminData?['reviewCount']?.toString() ?? widget.adminData?['reviews']?.toString() ?? '0') ?? 0));
    final image = detail is AmenityModel ? detail.imageUrl : (detail is AdminOfficeModel ? detail.imageUrl : widget.adminData?['image']);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: rh(10), horizontal: rw(20)),
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
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(5)),
                  child: ClipOval(
                    child: SizedBox(
                      width: rw(42),
                      height: rw(42),
                      child: buildProfileImage(image, fallbackIcon: Icons.admin_panel_settings, iconSize: 50),
                    ),
                  ),
                ),
                SizedBox(width: rw(5)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: rfs(14),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF141414),
                                height: 16 / 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${rating.toStringAsFixed(1)} Rating',
                        style: GoogleFonts.poppins(
                          fontSize: rfs(11),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF828282),
                          height: 16 / 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: rw(10)),
          GestureDetector(
            onTap: () {
              GiveReviewDialog.show(
                context: context,
                itemName: name,
                itemLocation: detail is AmenityModel ? (detail.location ?? '') : (detail is AdminOfficeModel ? (detail.address ?? '') : (widget.adminData?['location'] ?? '')),
                itemRating: rating,
                reviewCount: reviewCount,
                itemImage: image,
                itemTypeHint: 'ADMIN',
                onSubmit: (ratingVal, review, hasPhoto, hasVideo) async {
                  final entityId = _officeId ?? widget.adminData?['id'] as String?;
                  if (entityId == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot submit review: missing entity ID'), backgroundColor: Colors.red));
                    }
                    return;
                  }
                  final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
                  final ratingText = ratingVal >= 4 ? 'Excellent' : ratingVal >= 3 ? 'Good' : ratingVal >= 2 ? 'Average' : 'Poor';
                  final success = await reviewProvider.submitBusinessReview(entityId, rating: ratingVal.toDouble(), ratingText: ratingText, reviewText: review.isNotEmpty ? review : null);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Review submitted!' : (reviewProvider.error ?? 'Failed')), backgroundColor: success ? Colors.green : Colors.red));
                  }
                },
              );
            },
            child: Container(
              width: rw(130),
              padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(8)),
              decoration: BoxDecoration(
                color: const Color(0xFF3195AB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Give a Review',
                  style: GoogleFonts.poppins(
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
}