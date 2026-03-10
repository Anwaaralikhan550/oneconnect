import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../providers/promotion_provider.dart';
import '../providers/property_provider.dart';
import '../models/property_model.dart';
import '../utils/contact_utils.dart';
import '../widgets/profile_image.dart';
import '../widgets/photos_and_videos_section.dart';
import 'property_detail_screen.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/separator_line.dart';
import '../utils/map_utils.dart';

class PropertyAgentScreen extends StatefulWidget {
  final Map<String, dynamic>? agentData;

  const PropertyAgentScreen({super.key, this.agentData});

  @override
  State<PropertyAgentScreen> createState() => _PropertyAgentScreenState();
}

class _PropertyAgentScreenState extends State<PropertyAgentScreen>
    with ResponsiveMixin {
  Map<String, dynamic> _effectiveAgentData = const {};
  List<PropertyModel> _effectiveProperties = const [];

  Map<String, dynamic> _resolveAgentData(List<PropertyModel> properties) {
    final base = Map<String, dynamic>.from(widget.agentData ?? const {});
    final partner = properties.firstWhere(
      (p) => p.partner != null,
      orElse: () => properties.isNotEmpty ? properties.first : PropertyModel(id: '', title: ''),
    ).partner;

    if (partner != null) {
      base['id'] ??= partner.id;
      base['partnerId'] ??= partner.id;
      base['name'] ??= partner.businessName ?? partner.ownerFullName;
      base['businessId'] ??= partner.businessId;
      base['location'] ??= partner.address ?? partner.city;
      base['image'] ??= partner.profilePhotoUrl;
      base['isOpen'] ??= partner.isBusinessOpen;
      base['openingTime'] ??= partner.openingTime;
      base['closingTime'] ??= partner.closingTime;
      base['phone'] ??= partner.phone;
      base['rating'] ??= partner.rating.toStringAsFixed(1);
    }

    if ((base['reviewCount'] == null || '${base['reviewCount']}' == '0') && properties.isNotEmpty) {
      base['reviewCount'] = properties.length;
    }
    return base;
  }

  String _aStr(String key, {String fallback = ''}) {
    final value = _effectiveAgentData[key];
    if (value == null) return fallback;
    final out = value.toString().trim();
    return out.isEmpty ? fallback : out;
  }

  bool _aBool(String key, {bool fallback = false}) {
    final value = _effectiveAgentData[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  String _to12Hour(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return raw;
    try {
      return DateFormat.jm().format(DateFormat('HH:mm').parseStrict(raw));
    } catch (_) {
      return raw;
    }
  }

  List<String> _mediaUrlsFromProperties() {
    final urls = <String>[];
    for (final p in _effectiveProperties) {
      if ((p.mainImageUrl ?? '').isNotEmpty) urls.add(p.mainImageUrl!);
      for (final img in p.images) {
        if (img.imageUrl.isNotEmpty) urls.add(img.imageUrl);
      }
    }
    return urls.toSet().take(12).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PromotionProvider>(context, listen: false)
          .fetchPromotions();
      final partnerId = widget.agentData?['partnerId']?.toString() ?? widget.agentData?['id']?.toString();
      Provider.of<PropertyProvider>(context, listen: false)
          .fetchProperties(partnerId: (partnerId != null && partnerId.isNotEmpty) ? partnerId : null, force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(
      builder: (context, propertyProvider, _) {
        _effectiveProperties = propertyProvider.properties;
        _effectiveAgentData = _resolveAgentData(_effectiveProperties);
        return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section - Fixed at top
          _buildHeader(),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  SizedBox(height: rh(15)),
                  _buildCategoryAndIdSection(),
                  SizedBox(height: rh(15)),
                  _buildOpenNowAndDistanceSection(),
                  SizedBox(height: rh(15)),
                  _buildLocationSection(),
                  SizedBox(height: rh(15)),
                  _buildContactSection(),
                  SizedBox(height: rh(15)),
                  _buildAgentInfoSection(),
                  SizedBox(height: rh(15)),
                  _buildSpecialOffersSection(),
                  SizedBox(height: rh(15)),
                  _buildServicesOfferedSection(),
                  SizedBox(height: rh(5)),
                  const SeparatorLine(color: Color(0x1A000000)),
                  SizedBox(height: rh(10)),
                  PhotosAndVideosSection(imageUrls: _mediaUrlsFromProperties()),
                  SizedBox(height: rh(5)),
                  const SeparatorLine(color: Color(0x1A000000)),
                  SizedBox(height: rh(10)),
                  _buildReviewsSection(),
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

  // HEADER - Figma: gap 90px between elements, back icon 25x25, logo 70x70, share 21x21
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        height: rh(70),
        padding: EdgeInsets.symmetric(horizontal: rw(42)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back Button - Figma: 35x25 container, 25x25 icon
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: SizedBox(
                width: rw(35),
                height: rw(25),
                child: SvgPicture.asset(
                  'assets/icons/figma_back_icon.svg',
                  width: rw(25),
                  height: rw(25),
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            // Agent Logo - Figma: 70x70
            Container(
              width: rw(70),
              height: rw(70),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: buildProfileImage(
                  _aStr('image'),
                  fallbackIcon: Icons.business,
                  iconSize: 35,
                ),
              ),
            ),
            // Share Button - Figma: 21x20.787
            GestureDetector(
              onTap: () async {
                final name = _aStr('name', fallback: 'Property Agent');
                final location = _aStr('location', fallback: 'Address not available');
                await Share.share(
                  'Check out $name at $location on OneConnect!',
                  subject: name,
                );
              },
              child: SizedBox(
                width: rw(21),
                height: rw(20.787),
                child: Icon(
                  Icons.ios_share,
                  size: rw(21),
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PROFILE SECTION - Figma: Inter Bold 20px, #353535, tracking 0.112px
  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: rh(5)),
      child: Center(
        child: Text(
          _aStr('name', fallback: 'PROPERTY AGENT').toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: rfs(20),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF353535),
            letterSpacing: 0.112,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // CATEGORY AND ID SECTION - Figma exact specs
  Widget _buildCategoryAndIdSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(15)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and Rating Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Category Row - Figma: gap 8px
              Row(
                children: [
                  // Category Badge - Figma: bg #F2F2F2, padding 5px, rounded 5px
                  Container(
                    padding: EdgeInsets.all(rw(5)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Category',
                      style: GoogleFonts.poppins(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF353535),
                        letterSpacing: 0.168,
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(width: rw(8)),
                  // Real Estate text - Figma: Inter Medium 14px
                  Text(
                    'Real Estate',
                    style: GoogleFonts.inter(
                      fontSize: rfs(14),
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
              SizedBox(height: rh(4)),
              // Stars and Reviews Row - Figma: gap 8px
              Row(
                children: [
                  // 5 Stars - Figma: 15x15 each
                  Row(
                    children: List.generate(5, (index) {
                      final rating = double.tryParse(_aStr('rating', fallback: '0')) ?? 0.0;
                      final fullStars = rating.floor();
                      final hasHalf = (rating - fullStars) >= 0.5;
                      return Icon(
                        index < fullStars ? Icons.star : (index == fullStars && hasHalf ? Icons.star_half : Icons.star_border),
                        size: rw(15),
                        color: const Color(0xFFFFCD29),
                      );
                    }),
                  ),
                  SizedBox(width: rw(8)),
                  // Rating text - Figma: Inter Bold 12px
                  Text(
                    _aStr('rating', fallback: '0.0'),
                    style: GoogleFonts.inter(
                      fontSize: rfs(12),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF353535),
                      letterSpacing: 0.168,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(width: rw(2)),
                  Flexible(
                    child: Text(
                      '(${_aStr('reviewCount', fallback: '0')} Reviews)',
                      style: GoogleFonts.inter(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF353535),
                        letterSpacing: 0.168,
                        height: 1.3,
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
          SizedBox(width: rw(10)),
          // ID Badge Section - Figma: 65x42
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: rw(85)),
            child: Row(
            children: [
              // Badge Icon - Figma: 40x42 with 30x30 vector
              SizedBox(
                width: rw(40),
                height: rw(42),
                child: Center(
                  child: Icon(
                    Icons.verified,
                    size: rw(30),
                    color: const Color(0xFFFFCD29),
                  ),
                ),
              ),
              // ID Text Column - Figma: padding left 5px
              Padding(
                padding: EdgeInsets.only(left: rw(5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '#ID',
                      style: GoogleFonts.inter(
                        fontSize: rfs(12),
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 1,
                      ),
                    ),
                    Text(
                      '40',
                      style: GoogleFonts.inter(
                        fontSize: rfs(14),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          ),
        ],
      ),
    );
  }

  // OPEN NOW AND DISTANCE SECTION - Figma: border 2px #F3F3F3, rounded 15px, padding 25px horizontal, 15px vertical
  Widget _buildOpenNowAndDistanceSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
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
          // Open Now - Left side
          Expanded(
            flex: 6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tick Circle Icon - Figma: 25x25, teal color
                SvgPicture.asset(
                  'assets/icons/doctor_tick_circle.svg',
                  width: rw(25),
                  height: rw(25),
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0097B2),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: rw(5)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Open now - Figma: Roboto Medium 15px
                      Text(
                        _aBool('isOpen', fallback: true) ? 'Open now' : 'Closed',
                        style: GoogleFonts.roboto(
                          fontSize: rfs(15),
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: rh(2)),
                      // Time - Figma: Roboto Regular 13px
                      Text(
                        ((_aStr('openingTime').isNotEmpty &&
                                    _aStr('closingTime').isNotEmpty)
                                ? '${_to12Hour(_aStr('openingTime'))} - ${_to12Hour(_aStr('closingTime'))}'
                                : '10:00 am - 10:00 pm'),
                        style: GoogleFonts.roboto(
                          fontSize: rfs(13),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: rh(2)),
                      // Days - Figma: Roboto Regular 12px, #727272
                      Text(
                        ((_effectiveAgentData['operatingDays'] is List &&
                                    (_effectiveAgentData['operatingDays'] as List).isNotEmpty)
                                ? (_effectiveAgentData['operatingDays'] as List).map((e) => e.toString()).join(', ')
                                : 'Monday - Sunday'),
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
          SizedBox(width: rw(10)),
          // Distance - Right side with padding
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Distance Icon - Figma: 25x24.943
                SvgPicture.asset(
                  'assets/icons/doctor_distance_icon.svg',
                  width: rw(25),
                  height: rw(24.943),
                ),
                SizedBox(width: rw(5)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Distance - Figma: Roboto Medium 15px
                      Text(
                        'Distance',
                        style: GoogleFonts.roboto(
                          fontSize: rfs(15),
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: rh(2)),
                      // Km away - Figma: Roboto Regular 13px, #202020
                      Text(
                        _aStr('distance', fallback: 'N/A'),
                        style: GoogleFonts.roboto(
                          fontSize: rfs(13),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF202020),
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
        ],
      ),
    );
  }

  // LOCATION SECTION - Figma: bg #F4F4F4, rounded 15px, padding 25px h, 15px v
  Widget _buildLocationSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
      padding: EdgeInsets.symmetric(horizontal: rw(25), vertical: rh(15)),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Location Icon - Figma: 22.5x20.512, red color
          SvgPicture.asset(
            'assets/icons/figma_location_filled_icon.svg',
            width: rw(22.5),
            height: rw(20.512),
            colorFilter: const ColorFilter.mode(
              Color(0xFFE53935),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: rw(5)),
          // Address - Figma: Roboto Regular 14px, width 148px
          Expanded(
            child: Text(
              _aStr('location', fallback: 'Address not available'),
              style: GoogleFonts.roboto(
                fontSize: rfs(14),
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: rw(10)),
          // View on Map Button - Figma: bg dimgrey (#696969), rounded 5px, 106x25
          GestureDetector(
            onTap: () async {
              final lat = (_effectiveAgentData['latitude'] as num?)?.toDouble() ??
                  (_effectiveAgentData['lat'] as num?)?.toDouble() ??
                  (_effectiveAgentData['locationLat'] as num?)?.toDouble();
              final lng = (_effectiveAgentData['longitude'] as num?)?.toDouble() ??
                  (_effectiveAgentData['lng'] as num?)?.toDouble() ??
                  (_effectiveAgentData['locationLng'] as num?)?.toDouble();
              if (lat != null && lng != null) {
                await openMapAtCoordinates(
                  context,
                  latitude: lat,
                  longitude: lng,
                  label: _aStr('name'),
                );
                return;
              }
              final location = _aStr('location', fallback: 'Address not available');
              await openMapForQuery(context, location);
            },
            child: Container(
              width: rw(106),
              height: rh(25),
              decoration: BoxDecoration(
                color: const Color(0xFF696969),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
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
          ),
        ],
      ),
    );
  }

  // CONTACT SECTION - Figma: border 2px #F3F3F3, rounded 15px, gap 60px
  Widget _buildContactSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(15)),
      padding: EdgeInsets.symmetric(vertical: rh(15)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFF3F3F3),
          width: 2,
        ),
      ),
      child: _aStr('phone').isNotEmpty
          ? Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        final phone = _aStr('phone');
                        final phoneUrl = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(phoneUrl)) {
                          await launchUrl(phoneUrl);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/doctor_phone_icon.svg',
                            width: rw(18.75),
                            height: rw(18.75),
                          ),
                          SizedBox(width: rw(5)),
                          Flexible(
                            child: Text(
                              _aStr('phone'),
                              style: GoogleFonts.inter(
                                fontSize: rfs(13),
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: rw(24)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () async {
                        final whatsappNumber =
                            _aStr('whatsapp', fallback: _aStr('phone'));
                        await openWhatsAppForNumber(context, whatsappNumber);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/whatsapp_icon.svg',
                            width: rw(25),
                            height: rw(25),
                          ),
                          SizedBox(width: rw(5)),
                          Flexible(
                            child: Text(
                              _aStr('whatsapp', fallback: _aStr('phone')),
                              style: GoogleFonts.inter(
                                fontSize: rfs(13),
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'Contact unavailable',
                style: GoogleFonts.inter(
                  fontSize: rfs(13),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
    );
  }

  // AGENT INFO / REVIEW US SECTION - Figma: bg neutral-50, border top/bottom #E3E3E3
  Widget _buildAgentInfoSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: rh(15)),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Color(0xFFE3E3E3), width: 1),
          bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rw(27.5)),
        child: Row(
          children: [
            // Agent Avatar and Info - gap 5px
            Expanded(
              child: Row(
                children: [
                // Avatar - Figma: 42x42 circle with 5px padding
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(5)),
                  child: Container(
                    width: rw(42),
                    height: rw(42),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: rw(42),
                        height: rw(42),
                        child: buildProfileImage(
                          _aStr('image'),
                          fallbackIcon: Icons.person,
                          iconSize: 25,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: rw(5)),
                // Name and Followers Column
                Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Row with verified icon - Figma: Poppins Medium 15px, #141414
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _aStr('name', fallback: 'Property Agent'),
                            style: GoogleFonts.poppins(
                              fontSize: rfs(15),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF141414),
                              height: 16 / 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Count row - aligned with other detail screens
                    Text(
                      '${_effectiveProperties.length} Listings',
                      style: GoogleFonts.inter(
                        fontSize: rfs(14),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF727272),
                      ),
                    ),
                  ],
                  ),
                ),
                ],
              ),
            ),
            SizedBox(width: rw(10)),
            // Give a Review Button - Figma: bg #3195AB, rounded 20px, padding 14px h, 8px v
            GestureDetector(
              onTap: () {
                // Handle review
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
      ),
    );
  }

  // SPECIAL OFFERS / PROMOTIONS SECTION
  Widget _buildSpecialOffersSection() {
    return Consumer2<PromotionProvider, PropertyProvider>(
      builder: (context, promoProvider, propertyProvider, child) {
        final promos = promoProvider.promotions;
        final selectedAgentId = _aStr('partnerId', fallback: _aStr('id'));
        final properties = selectedAgentId.isEmpty
            ? propertyProvider.properties
            : propertyProvider.properties
                .where((p) => (p.partnerId ?? p.partner?.id) == selectedAgentId)
                .toList();

        // Prefer real properties, then promotions, then fallback
        List<Map<String, dynamic>> offers;
        if (properties.isNotEmpty) {
          offers = properties.take(4).map((p) => <String, dynamic>{
            'title': p.title,
            'location': p.location ?? '',
            'image': p.mainImageUrl ?? '',
            'isHot': p.listingStatus == 'SUPER_HOT',
            'property': p,
          }).toList();
        } else if (promos.isNotEmpty) {
          offers = promos.map((p) => <String, dynamic>{
            'title': p.title,
            'location': p.description ?? '',
            'image': p.imageUrl ?? '',
            'isHot': true,
          }).toList();
        } else {
          offers = [];
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header - Figma: gap 10px, mdi:fire 25x25, Inter Bold 18px
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(15)),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: rw(25),
                    color: const Color(0xFFF24822),
                  ),
                  SizedBox(width: rw(10)),
                  Text(
                    'Super Hot Offers',
                    style: GoogleFonts.inter(
                      fontSize: rfs(18),
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 0.112,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: rh(10)),
            // Special Offers Horizontal ListView - Figma: gap 25px, padding 15px
            if (offers.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: rh(20)),
                  child: Text(
                    'No offers available',
                    style: GoogleFonts.inter(
                      fontSize: rfs(14),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: rh(280),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: rw(15), vertical: rh(5)),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: rw(25)),
                      child: _buildSpecialOfferCard(offers[index]),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  // SPECIAL OFFER CARD - Figma: 268 width, border 1px rgba(0,0,0,0.15), rounded 25px, padding 10px
  Widget _buildSpecialOfferCard(Map<String, dynamic> offer) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(
              property: offer['property'] as PropertyModel?,
            ),
          ),
        );
      },
      child: Container(
        width: rw(268),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.black.withOpacity(0.15),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(rw(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - Figma: 248x130, rounded 20px
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: rw(248),
                height: rh(120),
                child: buildProfileImage(
                  offer['image']?.toString(),
                  fallbackIcon: Icons.home,
                  iconSize: 50,
                ),
              ),
            ),
            SizedBox(height: rh(5)),
            // Business Name Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Hot Badge Row - Figma: gap 2px
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title - Figma: Inter SemiBold 16px
                      Expanded(
                        child: Text(
                          offer['title'],
                          style: GoogleFonts.inter(
                            fontSize: rfs(15),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (offer['isHot'] == true)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: rw(20),
                              color: const Color(0xFFF24822),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: rw(5),
                                vertical: rh(3),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF24822),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Super hot',
                                style: GoogleFonts.inter(
                                  fontSize: rfs(9),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: rh(3)),
                  // Location Row - Figma: gap 5px
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/figma_location_icon.svg',
                        width: rw(15),
                        height: rw(15),
                        placeholderBuilder: (context) => Icon(
                          Icons.location_on,
                          size: rw(15),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: rw(5)),
                      Expanded(
                        child: Text(
                          offer['location'],
                          style: GoogleFonts.inter(
                            fontSize: rfs(10),
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.75),
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
            SizedBox(height: rh(5)),
            // Buttons Row - Figma: gap 10px
            Row(
              children: [
                // Ask for Price Button - Figma: border 1px #A8A8A8, rounded 10px
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: rh(8)),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFA8A8A8),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Ask for Price',
                        style: GoogleFonts.inter(
                          fontSize: rfs(13),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFBFBFBF),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: rw(10)),
                // More Detail Button - Figma: bg #0097B2, rounded 10px
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: rh(8)),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0097B2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'More Detail',
                        style: GoogleFonts.inter(
                          fontSize: rfs(13),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // SERVICES OFFERED SECTION - Figma: border top #D2D2D2
  Widget _buildServicesOfferedSection() {
    final dynamicServices = <String>{
      ..._effectiveProperties.map((p) => (p.propertyType ?? '').trim()).where((e) => e.isNotEmpty),
      'BUY',
      'SELL',
    }.toList();

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFD2D2D2), width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: rh(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header - Figma: padding 20px h, 10px v
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(20), vertical: rh(10)),
            child: Text(
              'Services Offered',
              style: GoogleFonts.inter(
                fontSize: rfs(18),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          // Services Grid - Figma: padding 25px h, 10px v, gap 50px
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(25), vertical: rh(10)),
            child: Wrap(
              spacing: rw(20),
              runSpacing: rh(20),
              children: dynamicServices
                  .take(6)
                  .map((label) => _buildServiceChip('', _normalizeServiceLabel(label)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeServiceLabel(String value) {
    final v = value.trim().toUpperCase();
    if (v == 'RENTAL') return 'Rental';
    if (v == 'SALE') return 'Sale';
    if (v == 'BUY') return 'Buy';
    if (v == 'SELL') return 'Sell';
    return value.isEmpty ? 'Property' : value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  // SERVICE CHIP - Figma: gap 10px, Inter Medium 15px
  Widget _buildServiceChip(String iconPath, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getServiceIcon(label),
          size: rw(25),
          color: Colors.black,
        ),
        SizedBox(width: rw(10)),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: rfs(15),
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  IconData _getServiceIcon(String label) {
    switch (label) {
      case 'Rental':
        return Icons.description_outlined;
      case 'Buy':
        return Icons.shopping_bag_outlined;
      case 'Sell':
        return Icons.sell_outlined;
      case 'Contractor':
        return Icons.roofing_outlined;
      case 'Builder':
        return Icons.build_outlined;
      default:
        return Icons.home_work_outlined;
    }
  }


  // REVIEWS SECTION - Figma: Property Reviews title
  Widget _buildReviewsSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: rh(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header - Figma: Inter Bold 18px, #272727, padding 15px
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(15)),
            child: Text(
              'Property Reviews',
              style: GoogleFonts.inter(
                fontSize: rfs(18),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF272727),
              ),
            ),
          ),
          SizedBox(height: rh(15)),
          // No reviews available from backend
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: rh(20)),
              child: Text(
                'No reviews yet',
                style: GoogleFonts.inter(
                  fontSize: rfs(14),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
