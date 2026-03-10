import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../providers/promotion_provider.dart';
import '../models/amenity_model.dart';
import '../widgets/profile_image.dart';
import 'cafe_detail_screen.dart';
import 'search_screen.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/list_screen_header.dart';

class CafeListScreen extends StatefulWidget {
  const CafeListScreen({super.key});

  @override
  State<CafeListScreen> createState() => _CafeListScreenState();
}

class _CafeListScreenState extends State<CafeListScreen>
    with ResponsiveMixin {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false)
          .fetchAmenities('CAFE');
      Provider.of<PromotionProvider>(context, listen: false)
          .fetchPromotions();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with rounded bottom corners
          ListScreenHeader(
              title: 'Cafes',
              categoryIconAsset: 'assets/images/cafe_icon_hub.svg',
              onSearch: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            ),
          // Main content
          Expanded(
            child: Consumer<BusinessProvider>(
              builder: (context, provider, child) {
                final amenities = provider.getAmenities('CAFE');

                if (provider.isLoading && amenities.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (amenities.isEmpty) {
                  return const Center(child: Text('No Cafes found'));
                }

                final topItem = amenities.first;
                final frequentlyVisited = amenities.length > 1
                    ? amenities.sublist(1, amenities.length.clamp(1, 4))
                    : <AmenityModel>[];
                final nearbyItems = amenities.length > 4
                    ? amenities.sublist(4)
                    : <AmenityModel>[];

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: rh(20)),
                      _buildTopCafeSection(topItem),
                      SizedBox(height: rh(30)),
                      _buildSpecialOffersSection(),
                      SizedBox(height: rh(30)),
                      if (frequentlyVisited.isNotEmpty)
                        _buildFrequentlyVisitedSection(frequentlyVisited),
                      if (frequentlyVisited.isNotEmpty)
                        SizedBox(height: rh(30)),
                      if (nearbyItems.isNotEmpty)
                        _buildCafesNearLocationSection(nearbyItems),
                      if (nearbyItems.isNotEmpty)
                        SizedBox(height: rh(30)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // HEADER: bg=#f2f2f2, rounded bottom corners 50px

  Map<String, dynamic> _amenityToMap(AmenityModel item) {
    return {
      'id': item.id,
      'name': item.name,
      'rating': item.rating.toStringAsFixed(1),
      'reviews': item.reviewCount.toString(),
      'location': item.location ?? '',
      'isOpen': item.isOpen,
      'image': item.imageUrl,
    };
  }

  // Top Cafe of the month Section
  Widget _buildTopCafeSection(AmenityModel topCafe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with award icon
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(15)),
          child: Row(
            children: [
              // Award icon
              SvgPicture.asset(
                'assets/icons/figma_award_icon.svg',
                width: rw(25),
                height: rw(25),
                placeholderBuilder: (context) => Icon(
                  Icons.emoji_events,
                  size: rw(25),
                  color: const Color(0xFF0097B2),
                ),
              ),
              SizedBox(width: rw(10)),
              // Title - Inter Bold 18px
              Flexible(
                child: Text(
                  'Top cafe of the month',
                  style: GoogleFonts.inter(
                    fontSize: rfs(18),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 0.112,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rh(15)),
        // Hero Tab 1: Featured cafe card
        Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CafeDetailScreen(cafeData: _amenityToMap(topCafe)),
                ),
              );
            },
            child: Container(
              width: rw(355),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(25)),
                border: Border.all(
                  color: Colors.black.withOpacity(0.15),
                  width: 1,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: rw(6), vertical: rh(3)),
              child: Column(
                children: [
                  // Cafe Image with rating badge and heart
                  SizedBox(
                    width: rw(343),
                    height: rh(135),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(rw(20)),
                          child: SizedBox(
                            width: rw(343),
                            height: rh(135),
                            child: buildProfileImage(
                              topCafe.imageUrl,
                              fallbackIcon: Icons.local_cafe,
                              iconSize: 50,
                            ),
                          ),
                        ),
                        // Rating badge - top left
                        Positioned(
                          top: rh(6),
                          left: rw(5),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: rw(5), vertical: rh(5)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(rw(14)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: rw(20), color: const Color(0xFFFFCD29)),
                                SizedBox(width: rw(2)),
                                Text(
                                  topCafe.rating.toStringAsFixed(1),
                                  style: GoogleFonts.roboto(
                                    fontSize: rfs(12),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: rw(2)),
                                Text(
                                  '(${topCafe.reviewCount})',
                                  style: GoogleFonts.inter(
                                    fontSize: rfs(10),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Heart icon - bottom right
                        Positioned(
                          bottom: rh(8),
                          right: rw(10),
                          child: Icon(
                            Icons.favorite,
                            size: rw(20),
                            color: const Color(0xFFFF5050),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: rh(1)),
                  // Business info row
                  Container(
                    width: rw(343),
                    padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(4)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Name + Distance
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name - Oswald 16px
                            Text(
                              topCafe.name,
                              style: GoogleFonts.oswald(
                                fontSize: rfs(16),
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            // Distance row
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/figma_location_icon.svg',
                                  width: rw(17),
                                  height: rw(17),
                                  placeholderBuilder: (context) => Icon(
                                    Icons.location_on,
                                    size: rw(17),
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  topCafe.location ?? '',
                                  style: GoogleFonts.oswald(
                                    fontSize: rfs(11),
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Right: Open + Map
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Open row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/figma_open_door_icon.svg',
                                  width: rw(24),
                                  height: rw(24),
                                  placeholderBuilder: (context) => Icon(
                                    Icons.door_front_door,
                                    size: rw(24),
                                    color: const Color(0xFF073A6A),
                                  ),
                                ),
                                Text(
                                  topCafe.isOpen ? 'Open' : 'Closed',
                                  style: GoogleFonts.oswald(
                                    fontSize: rfs(11),
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF073A6A),
                                  ),
                                ),
                              ],
                            ),
                            // Map row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/figma_map_icon.svg',
                                  width: rw(24),
                                  height: rw(24),
                                  placeholderBuilder: (context) => Icon(
                                    Icons.map,
                                    size: rw(24),
                                    color: const Color(0xFF6A6A6A),
                                  ),
                                ),
                                SizedBox(width: rw(1)),
                                Text(
                                  'Map',
                                  style: GoogleFonts.oswald(
                                    fontSize: rfs(11),
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF073A6A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Special Offers Section
  Widget _buildSpecialOffersSection() {
    return Consumer<PromotionProvider>(
      builder: (context, promoProvider, child) {
        final promos = promoProvider.promotions;
        final offers = promos.isNotEmpty
            ? promos.map((p) => <String, dynamic>{
                  'title': p.title,
                  'originalPrice': p.price != null ? 'Rs ${p.price!.toStringAsFixed(0)}' : '',
                  'discountedPrice': p.discountPct != null ? '${p.discountPct!.toStringAsFixed(0)}% OFF' : '',
                  'salePrice': p.discountPct != null ? '${p.discountPct!.toStringAsFixed(0)}% OFF' : '',
                  'discount': p.discountPct != null ? '${p.discountPct!.toStringAsFixed(0)}% OFF' : '',
                  'description': p.description ?? '',
                  'image': p.imageUrl ?? 'assets/images/featured_store_1.png',
                }).toList()
            : <Map<String, dynamic>>[];
        if (offers.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(25)),
            child: Text('No offers available', style: GoogleFonts.inter(fontSize: rfs(14), fontWeight: FontWeight.w400, color: const Color(0xFF696969))),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with badge icon
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(25)),
              child: Row(
                children: [
                  // Promotion badge icon
                  SvgPicture.asset(
                    'assets/icons/figma_promotion_badge.svg',
                    width: rw(25),
                    height: rw(24),
                    placeholderBuilder: (context) => Icon(
                      Icons.local_offer,
                      size: rw(25),
                      color: const Color(0xFF0097B2),
                    ),
                  ),
                  SizedBox(width: rw(10)),
                  // Title - Inter Bold 18px
                  Text(
                    'Special offers for you',
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
            SizedBox(height: rh(15)),
            // Horizontal scrollable offers
            SizedBox(
              height: rh(149),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: rw(20)),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: rw(25)),
                    child: _buildOfferCard(offers[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Offer Card
  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return Container(
      width: rw(256),
      height: rh(129),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9FACDC).withOpacity(0.51),
            blurRadius: 4.7,
            offset: const Offset(-4, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Photo
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(rw(15)),
              bottomLeft: Radius.circular(rw(15)),
            ),
            child: (offer['image'] != null && offer['image'].toString().startsWith('http'))
                ? Image.network(
                    offer['image'],
                    width: rw(128),
                    height: rh(129),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: rw(128),
                        height: rh(129),
                        color: const Color(0xFFF5F5F5),
                        child: Icon(Icons.image, size: rw(40), color: Colors.grey),
                      );
                    },
                  )
                : Image.asset(
                    offer['image'] ?? 'assets/images/featured_store_1.png',
                    width: rw(128),
                    height: rh(129),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: rw(128),
                        height: rh(129),
                        color: const Color(0xFFF5F5F5),
                        child: Icon(Icons.image, size: rw(40), color: Colors.grey),
                      );
                    },
                  ),
          ),
          // Product Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - Rancho 20px
                  Text(
                    offer['title'],
                    style: GoogleFonts.rancho(
                      fontSize: rfs(20),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF343434),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: rh(2)),
                  // Discount row
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/figma_promotion_badge.svg',
                        width: rw(20),
                        height: rw(20),
                        placeholderBuilder: (context) => Icon(
                          Icons.local_offer,
                          size: rw(20),
                          color: const Color(0xFF0097B2),
                        ),
                      ),
                      SizedBox(width: rw(2)),
                      Expanded(
                        child: Text(
                          offer['discount'],
                          style: GoogleFonts.poppins(
                            fontSize: rfs(12),
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: rh(4)),
                  // Description
                  Text(
                    offer['description'],
                    style: GoogleFonts.poppins(
                      fontSize: rfs(10),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF696969),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Prices row
                  Row(
                    children: [
                      // Sale price
                      Text(
                        offer['salePrice'],
                        style: GoogleFonts.poppins(
                          fontSize: rfs(12),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF5571),
                        ),
                      ),
                      SizedBox(width: rw(8)),
                      // Original price - strikethrough
                      Flexible(
                        child: Text(
                          offer['originalPrice'],
                          style: GoogleFonts.poppins(
                            fontSize: rfs(12),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF929292),
                            decoration: TextDecoration.lineThrough,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Frequently Visited Section
  Widget _buildFrequentlyVisitedSection(List<AmenityModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with binocular icon
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(20)),
          child: Row(
            children: [
              // Binocular icon
              SvgPicture.asset(
                'assets/icons/figma_binocular_icon.svg',
                width: rw(25),
                height: rw(25),
                placeholderBuilder: (context) => Icon(
                  Icons.visibility,
                  size: rw(25),
                  color: const Color(0xFF0097B2),
                ),
              ),
              SizedBox(width: rw(15)),
              // Title - Inter Bold 18px #282828
              Flexible(
                child: Text(
                  'Frequently visited by other members',
                  style: GoogleFonts.inter(
                    fontSize: rfs(18),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF282828),
                    letterSpacing: 0.168,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rh(15)),
        // Horizontal scrollable cards
        SizedBox(
          height: rh(181),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: rw(15)),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: rw(15)),
                child: _buildFrequentlyVisitedCard(items[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // Frequently Visited Card
  Widget _buildFrequentlyVisitedCard(AmenityModel cafe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CafeDetailScreen(cafeData: _amenityToMap(cafe)),
          ),
        );
      },
      child: Container(
        width: rw(322),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(25)),
          border: Border.all(
            color: Colors.black.withOpacity(0.15),
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(3)),
        child: Column(
          children: [
            // Image with rating and heart
            SizedBox(
              width: rw(302),
              height: rh(118),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(rw(20)),
                    child: SizedBox(
                      width: rw(302),
                      height: rh(118),
                      child: buildProfileImage(
                        cafe.imageUrl,
                        fallbackIcon: Icons.local_cafe,
                        iconSize: 40,
                      ),
                    ),
                  ),
                  // Rating badge - top left
                  Positioned(
                    top: rh(5),
                    left: rw(6),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: rw(5), vertical: rh(5)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rw(14)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: rw(20), color: const Color(0xFFFFCD29)),
                          SizedBox(width: rw(2)),
                          Text(
                            cafe.rating.toStringAsFixed(1),
                            style: GoogleFonts.roboto(
                              fontSize: rfs(12),
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: rw(2)),
                          Text(
                            '(${cafe.reviewCount})',
                            style: GoogleFonts.inter(
                              fontSize: rfs(10),
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Heart icon - bottom right
                  Positioned(
                    bottom: rh(8),
                    right: rw(10),
                    child: Icon(
                      Icons.favorite_border,
                      size: rw(20),
                      color: const Color(0xFF8C8C8C),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: rh(1)),
            // Business Name section
            Container(
              width: rw(302),
              padding: EdgeInsets.symmetric(horizontal: rw(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Name + Distance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name - Oswald 15px
                      Text(
                        cafe.name,
                        style: GoogleFonts.oswald(
                          fontSize: rfs(15),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      // Distance row
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/figma_location_icon.svg',
                            width: rw(17),
                            height: rw(17),
                            placeholderBuilder: (context) => Icon(
                              Icons.location_on,
                              size: rw(17),
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            cafe.location ?? '',
                            style: GoogleFonts.oswald(
                              fontSize: rfs(11),
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Right: Open + Map
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Open row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/figma_open_door_icon.svg',
                            width: rw(24),
                            height: rw(24),
                            placeholderBuilder: (context) => Icon(
                              Icons.door_front_door,
                              size: rw(24),
                              color: const Color(0xFF073A6A),
                            ),
                          ),
                          Text(
                            cafe.isOpen ? 'Open' : 'Closed',
                            style: GoogleFonts.oswald(
                              fontSize: rfs(11),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF073A6A),
                            ),
                          ),
                        ],
                      ),
                      // Map row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/figma_map_icon.svg',
                            width: rw(24),
                            height: rw(24),
                            placeholderBuilder: (context) => Icon(
                              Icons.map,
                              size: rw(24),
                              color: const Color(0xFF6A6A6A),
                            ),
                          ),
                          SizedBox(width: rw(1)),
                          Text(
                            'Map',
                            style: GoogleFonts.oswald(
                              fontSize: rfs(11),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF073A6A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cafes Near Your Location Section
  Widget _buildCafesNearLocationSection(List<AmenityModel> nearbyItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with location icon
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(20)),
          child: Row(
            children: [
              // Location icon
              SvgPicture.asset(
                'assets/icons/figma_location_filled_icon.svg',
                width: rw(25),
                height: rw(25),
                colorFilter: const ColorFilter.mode(
                  Color(0xFF0097B2),
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => Icon(
                  Icons.location_on,
                  size: rw(25),
                  color: const Color(0xFF0097B2),
                ),
              ),
              SizedBox(width: rw(15)),
              // Title - Inter Bold 18px
              Text(
                'Cafes near your location',
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
        SizedBox(height: rh(20)),
        // List of cafe cards
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(15)),
          child: Column(
            children: nearbyItems.map((cafe) {
              return Padding(
                padding: EdgeInsets.only(bottom: rh(20)),
                child: _buildNearbyCafeCard(cafe),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Nearby Cafe Card
  Widget _buildNearbyCafeCard(AmenityModel cafe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CafeDetailScreen(cafeData: _amenityToMap(cafe)),
          ),
        );
      },
      child: Container(
        width: rw(360),
        height: rh(101),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(25)),
          border: Border.all(
            color: Colors.black.withOpacity(0.15),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(rw(10)),
        child: Row(
          children: [
            // Thumbnail - 81x81 rounded
            ClipRRect(
              borderRadius: BorderRadius.circular(rw(100)),
              child: SizedBox(
                width: rw(81),
                height: rw(81),
                child: buildProfileImage(
                  cafe.imageUrl,
                  fallbackIcon: Icons.local_cafe,
                  iconSize: 30,
                ),
              ),
            ),
            SizedBox(width: rw(10)),
            // Info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Name - Inter SemiBold 15px
                  Text(
                    cafe.name,
                    style: GoogleFonts.inter(
                      fontSize: rfs(15),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Distance row
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/figma_location_icon.svg',
                        width: rw(17),
                        height: rw(17),
                        placeholderBuilder: (context) => Icon(
                          Icons.location_on,
                          size: rw(17),
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        cafe.location ?? '',
                        style: GoogleFonts.oswald(
                          fontSize: rfs(11),
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  // Rating row
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stars row
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < cafe.rating.floor() ? Icons.star : Icons.star_border,
                            size: rw(15),
                            color: const Color(0xFFFFCD29),
                          );
                        }),
                      ),
                      SizedBox(height: rh(4)),
                      // Rating text
                      Row(
                        children: [
                          Text(
                            cafe.rating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontSize: rfs(12),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF353535),
                              letterSpacing: 0.168,
                            ),
                          ),
                          SizedBox(width: rw(3)),
                          Text(
                            '(${cafe.reviewCount} Reviews)',
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
                ],
              ),
            ),
            // Right: Open + Map
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Open row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/figma_open_door_icon.svg',
                      width: rw(24),
                      height: rw(24),
                      placeholderBuilder: (context) => Icon(
                        Icons.door_front_door,
                        size: rw(24),
                        color: const Color(0xFF073A6A),
                      ),
                    ),
                    Text(
                      cafe.isOpen ? 'Open' : 'Closed',
                      style: GoogleFonts.oswald(
                        fontSize: rfs(11),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF073A6A),
                      ),
                    ),
                  ],
                ),
                // Map row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/figma_map_icon.svg',
                      width: rw(24),
                      height: rw(24),
                      placeholderBuilder: (context) => Icon(
                        Icons.map,
                        size: rw(24),
                        color: const Color(0xFF6A6A6A),
                      ),
                    ),
                    SizedBox(width: rw(1)),
                    Text(
                      'Map',
                      style: GoogleFonts.oswald(
                        fontSize: rfs(11),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF073A6A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




