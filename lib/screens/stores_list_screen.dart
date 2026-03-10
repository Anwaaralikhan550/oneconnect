import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../providers/promotion_provider.dart';
import '../widgets/profile_image.dart';
import 'grocery_store_screen.dart';
import 'search_screen.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/list_screen_header.dart';

class StoresListScreen extends StatefulWidget {
  const StoresListScreen({super.key});

  @override
  State<StoresListScreen> createState() => _StoresListScreenState();
}

class _StoresListScreenState extends State<StoresListScreen>
    with ResponsiveMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false)
          .fetchBusinesses('STORE');
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
              title: 'Stores',
              categoryIconAsset: 'assets/images/store_icon_hub.svg',
              onSearch: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            ),
          // Main content
          Expanded(
            child: Consumer<BusinessProvider>(
              builder: (context, provider, child) {
                final businesses = provider.getBusinesses('STORE');

                if (provider.isLoading && businesses.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (businesses.isEmpty) {
                  return const Center(child: Text('No stores found'));
                }

                // Map flat list to sections
                final topStore = businesses.first;
                final frequentlyVisited = businesses.length > 1
                    ? businesses.sublist(1, businesses.length.clamp(0, 4))
                    : <dynamic>[];
                final nearbyStores = businesses.length > 4
                    ? businesses.sublist(4)
                    : <dynamic>[];

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: rh(25)),
                      _buildTopStoreSection(topStore),
                      SizedBox(height: rh(30)),
                      _buildSpecialOffersSection(),
                      SizedBox(height: rh(30)),
                      if (frequentlyVisited.isNotEmpty)
                        _buildFrequentlyVisitedSection(frequentlyVisited),
                      if (frequentlyVisited.isNotEmpty)
                        SizedBox(height: rh(30)),
                      if (nearbyStores.isNotEmpty)
                        _buildStoresNearLocationSection(nearbyStores),
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


  Widget _buildTopStoreSection(dynamic store) {
    // Top Store of the month section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with award icon
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(15)),
          child: Row(
            children: [
              // Award icon - ri:award-fill 25x25 #0097b2
              SvgPicture.asset(
                'assets/icons/figma_award_icon.svg',
                width: rw(25),
                height: rw(25),
              ),
              SizedBox(width: rw(10)),
              // Title
              Flexible(
                child: Text(
                  'Top Store of the month',
                  style: GoogleFonts.inter(
                    fontSize: rfs(18),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF282828),
                    letterSpacing: 0.168,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rh(15)),
        // Hero Tab 1: Featured store card
        Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroceryStoreScreen(storeData: {
                    'id': store.id,
                    'name': store.name,
                    'rating': store.rating.toStringAsFixed(1),
                    'reviewCount': store.reviewCount,
                    'reviews': store.reviewCount.toString(),
                    'location': store.location ?? '',
                    'isOpen': store.isOpen,
                    'image': store.imageUrl,
                    'phone': store.phone,
                  }),
                ),
              );
            },
            child: Container(
              width: rw(355),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(rw(6)),
              child: Column(
                children: [
                  // Store Image with rating badge and heart
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
                            child: buildProfileImage(store.imageUrl, fallbackIcon: Icons.store, iconSize: 50),
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
                                  '${store.rating.toStringAsFixed(1)} (${store.reviewCount})',
                                  style: GoogleFonts.inter(
                                    fontSize: rfs(12),
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
                        // Left: Name + Location
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.name,
                                style: GoogleFonts.oswald(
                                  fontSize: rfs(16),
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/figma_location_icon.svg',
                                    width: rw(17),
                                    height: rw(17),
                                  ),
                                  Text(
                                    store.location ?? '',
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
                        ),
                        // Right: Open + Map
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/figma_open_door_icon.svg',
                                  width: rw(24),
                                  height: rw(24),
                                ),
                                Text(
                                  store.isOpen ? 'Open' : 'Closed',
                                  style: GoogleFonts.oswald(
                                    fontSize: rfs(11),
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF063A6A),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/figma_map_icon.svg',
                                  width: rw(24),
                                  height: rw(24),
                                ),
                                SizedBox(width: rw(1)),
                                Text(
                                  'Map',
                                  style: GoogleFonts.oswald(
                                    fontSize: rfs(11),
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF063A6A),
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

  Widget _buildSpecialOffersSection() {
    // Special Offers section
    return Consumer<PromotionProvider>(
      builder: (context, promoProvider, child) {
        final promos = promoProvider.promotions;
        final businessIds = Provider.of<BusinessProvider>(context, listen: false)
            .getBusinesses('STORE')
            .map((b) => b.id)
            .toSet();
        final offers = promos
            .where((p) => p.businessId != null && businessIds.contains(p.businessId))
            .map((p) => <String, dynamic>{
                  'title': p.title,
                  'originalPrice': p.price != null ? 'Rs ${p.price!.toStringAsFixed(0)}' : '',
                  'salePrice': p.discountPct != null ? '${p.discountPct!.toStringAsFixed(0)}% OFF' : '',
                  'discount': p.discountPct != null ? '${p.discountPct!.toStringAsFixed(0)}% OFF' : '',
                  'description': p.description ?? '',
                  'image': p.imageUrl ?? 'assets/images/featured_store_1.png',
                })
            .toList();
        if (offers.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(25)),
            child: Text('No offers available', style: GoogleFonts.inter(fontSize: rfs(14), fontWeight: FontWeight.w400, color: const Color(0xFF696969))),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(25)),
              child: Row(
                children: [
                  // Promotion badge icon
                  SvgPicture.asset(
                    'assets/icons/figma_promotion_badge.svg',
                    width: rw(25),
                    height: rw(24),
                  ),
                  SizedBox(width: rw(10)),
                  Flexible(
                    child: Text(
                      'Special offers for you',
                      style: GoogleFonts.inter(
                        fontSize: rfs(18),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 0.11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: rh(15)),
            // Horizontal scroll of product cards
            SizedBox(
              height: rh(149),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: rw(20)),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(offers[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> offer) {
    return Container(
      width: rw(256),
      height: rh(129),
      margin: EdgeInsets.only(right: rw(25)),
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
          // Right side content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(rw(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    offer['title'] ?? 'Product',
                    style: GoogleFonts.rancho(
                      fontSize: rfs(20),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF343434),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Discount row with badge
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/figma_promotion_badge.svg',
                        width: rw(20),
                        height: rw(20),
                      ),
                      SizedBox(width: rw(4)),
                      Flexible(
                        child: Text(
                          offer['discount'] ?? 'Up to 15% off',
                          style: GoogleFonts.poppins(
                            fontSize: rfs(12),
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Description
                  Text(
                    offer['description'] ?? 'offer valid only for weekend',
                    style: GoogleFonts.poppins(
                      fontSize: rfs(10),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF696969),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Prices
                  Row(
                    children: [
                      Text(
                        offer['salePrice'] ?? 'Rs. 470',
                        style: GoogleFonts.poppins(
                          fontSize: rfs(12),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF5571), // Exact Figma color
                        ),
                      ),
                      SizedBox(width: rw(8)),
                      Text(
                        offer['originalPrice'] ?? 'Rs. 550',
                        style: GoogleFonts.poppins(
                          fontSize: rfs(12),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF929292), // Exact Figma color
                          decoration: TextDecoration.lineThrough,
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

  Widget _buildFrequentlyVisitedSection(List<dynamic> items) {
    // Frequently visited section
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with binocular icon
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(5)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/figma_binocular_icon.svg',
                  width: rw(25),
                  height: rw(25),
                ),
                SizedBox(width: rw(15)),
                Expanded(
                  child: Text(
                    'Frequently visited by other members',
                    style: GoogleFonts.inter(
                      fontSize: rfs(18),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF282828),
                      letterSpacing: 0.168,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: rh(15)),
          // Horizontal scroll of store cards
          SizedBox(
            height: rh(181),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildFrequentStoreCard(items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequentStoreCard(dynamic store) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroceryStoreScreen(storeData: {
              'id': store.id,
              'name': store.name,
              'rating': store.rating.toStringAsFixed(1),
              'reviewCount': store.reviewCount,
              'reviews': store.reviewCount.toString(),
              'location': store.location ?? '',
              'isOpen': store.isOpen,
              'image': store.imageUrl,
              'phone': store.phone,
            }),
          ),
        );
      },
      child: Container(
        width: rw(322),
        height: rh(181),
        margin: EdgeInsets.only(right: rw(15)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(25)),
          // Exact Figma: border 1px solid rgba(0,0,0,0.15)
          border: Border.all(
            color: Colors.black.withOpacity(0.15),
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(3)),
        child: Column(
          children: [
            // Store Image with rating badge - Figma aspect ratio 282/110.5
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
                      child: buildProfileImage(store.imageUrl, fallbackIcon: Icons.store, iconSize: 50),
                    ),
                  ),
                  // Rating badge - exact Figma position
                  Positioned(
                    top: rh(5.5),
                    left: rw(6.5),
                    child: Container(
                      padding: EdgeInsets.all(rw(5)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rw(14)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: rw(20), color: const Color(0xFFFFCD29)),
                          SizedBox(width: rw(1)),
                          Text(
                            store.rating.toStringAsFixed(1),
                            style: GoogleFonts.roboto(
                              fontSize: rfs(12),
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: rw(1)),
                          Text(
                            '(${store.reviewCount})',
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
                  // Heart icon - exact Figma position
                  Positioned(
                    bottom: rh(5),
                    right: rw(10),
                    child: Container(
                      width: rw(20),
                      height: rw(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF8C8C8C), width: 1),
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: rw(15),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: rh(1)),
            // Business info row
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: rw(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Name + Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            store.name,
                            style: GoogleFonts.oswald(
                              fontSize: rfs(15),
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/figma_location_icon.svg',
                                width: rw(17),
                                height: rw(17),
                              ),
                              Flexible(
                                child: Text(
                                  store.location ?? '',
                                  style: GoogleFonts.oswald(
                                    fontSize: rfs(11),
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Right: Open + Map
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma_open_door_icon.svg',
                              width: rw(24),
                              height: rw(24),
                            ),
                            Text(
                              store.isOpen ? 'Open' : 'Closed',
                              style: GoogleFonts.oswald(
                                fontSize: rfs(11),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF073A6A), // Exact Figma color
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma_map_icon.svg',
                              width: rw(24),
                              height: rw(24),
                            ),
                            SizedBox(width: rw(1)),
                            Text(
                              'Map',
                              style: GoogleFonts.oswald(
                                fontSize: rfs(11),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF073A6A), // Exact Figma color
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoresNearLocationSection(List<dynamic> items) {
    // Stores near your location section
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with location icon
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(5)),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/figma_location_filled_icon.svg',
                  width: rw(25),
                  height: rw(25),
                ),
                SizedBox(width: rw(15)),
                Flexible(
                  child: Text(
                    'Store near your location',
                    style: GoogleFonts.inter(
                      fontSize: rfs(18),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF282828),
                      letterSpacing: 0.168,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: rh(20)),
          // Vertical list of store cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildNearbyStoreCard(items[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyStoreCard(dynamic store) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroceryStoreScreen(storeData: {
              'id': store.id,
              'name': store.name,
              'rating': store.rating.toStringAsFixed(1),
              'reviewCount': store.reviewCount,
              'reviews': store.reviewCount.toString(),
              'location': store.location ?? '',
              'isOpen': store.isOpen,
              'image': store.imageUrl,
              'phone': store.phone,
            }),
          ),
        );
      },
      child: Container(
        width: rw(360),
        height: rh(101),
        margin: EdgeInsets.only(bottom: rh(20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(rw(10)),
        child: Row(
          children: [
            // Store Image - circular
            ClipOval(
              child: SizedBox(
                width: rw(81),
                height: rw(81),
                child: buildProfileImage(store.imageUrl, fallbackIcon: Icons.store, iconSize: 50),
              ),
            ),
            SizedBox(width: rw(1)),
            // Business info
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: rw(10)),
                child: Row(
                  children: [
                    // Left: Name + Location + Stars + Rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Store name
                          Text(
                            store.name,
                            style: GoogleFonts.inter(
                              fontSize: rfs(15),
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: rh(2)),
                          // Location row
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/figma_location_icon.svg',
                                width: rw(17),
                                height: rw(17),
                              ),
                              Flexible(
                                child: Text(
                                  store.location ?? '',
                                  style: GoogleFonts.oswald(
                                    fontSize: rfs(11),
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: rh(3)),
                          // Stars row
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                Icons.star,
                                size: rw(15),
                                color: i < 4 ? const Color(0xFFFFCD29) : const Color(0xFFF1F1F1),
                              );
                            }),
                          ),
                          SizedBox(height: rh(2)),
                          // Rating text
                          Row(
                            children: [
                              Text(
                                store.rating.toStringAsFixed(1),
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
                                  '(${store.reviewCount} Reviews)',
                                  style: GoogleFonts.inter(
                                    fontSize: rfs(12),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF353535),
                                    letterSpacing: 0.168,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Right: Open + Map
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma_open_door_icon.svg',
                              width: rw(24),
                              height: rw(24),
                            ),
                            Text(
                              store.isOpen ? 'Open' : 'Closed',
                              style: GoogleFonts.oswald(
                                fontSize: rfs(11),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF063A6A),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma_map_icon.svg',
                              width: rw(24),
                              height: rw(24),
                            ),
                            SizedBox(width: rw(1)),
                            Text(
                              'Map',
                              style: GoogleFonts.oswald(
                                fontSize: rfs(11),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF063A6A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



