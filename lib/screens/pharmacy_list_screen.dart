import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../providers/promotion_provider.dart';
import '../models/amenity_model.dart';
import '../widgets/profile_image.dart';
import 'pharmacy_detail_screen.dart';
import 'search_screen.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/list_screen_header.dart';

class PharmacyListScreen extends StatefulWidget {
  const PharmacyListScreen({super.key});

  @override
  State<PharmacyListScreen> createState() => _PharmacyListScreenState();
}

class _PharmacyListScreenState extends State<PharmacyListScreen>
    with ResponsiveMixin {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false)
          .fetchAmenities('PHARMACY');
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
          ListScreenHeader(
              title: 'Pharmacies',
              categoryIconAsset: 'assets/images/pharmacy_icon_hub.svg',
              onSearch: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            ),
          Expanded(
            child: Consumer<BusinessProvider>(
              builder: (context, provider, child) {
                final amenities = provider.getAmenities('PHARMACY');

                if (provider.isLoading && amenities.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (amenities.isEmpty) {
                  return const Center(child: Text('No pharmacies found'));
                }

                final topItem = amenities.first;
                final frequentlyVisited = amenities.length > 1
                    ? amenities.sublist(1, amenities.length.clamp(0, 4))
                    : <AmenityModel>[];
                final nearbyItems = amenities.length > 4
                    ? amenities.sublist(4)
                    : <AmenityModel>[];

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: rh(20)),
                      _buildTopPharmacySection(topItem),
                      SizedBox(height: rh(30)),
                      _buildSpecialOffersSection(),
                      SizedBox(height: rh(30)),
                      _buildFrequentlyVisitedSection(frequentlyVisited),
                      SizedBox(height: rh(30)),
                      _buildPharmaciesNearLocationSection(nearbyItems),
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


  Widget _buildTopPharmacySection(AmenityModel pharmacy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(15)),
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/figma_award_icon.svg', width: rw(25), height: rw(25), placeholderBuilder: (context) => Icon(Icons.emoji_events, size: rw(25), color: const Color(0xFF0097B2))),
              SizedBox(width: rw(10)),
              Flexible(child: Text('Top Pharmacy of the month', style: GoogleFonts.inter(fontSize: rfs(18), fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.112, height: 1.2), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        SizedBox(height: rh(15)),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PharmacyDetailScreen(pharmacyData: {
              'id': pharmacy.id,
              'name': pharmacy.name,
              'rating': pharmacy.rating.toStringAsFixed(1),
              'reviews': pharmacy.reviewCount.toString(),
              'location': pharmacy.location ?? '',
              'isOpen': pharmacy.isOpen,
              'image': pharmacy.imageUrl,
            }))),
            child: Container(
              width: rw(355),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(rw(25)), border: Border.all(color: Colors.black.withOpacity(0.15), width: 1)),
              padding: EdgeInsets.symmetric(horizontal: rw(6), vertical: rh(3)),
              child: Column(
                children: [
                  SizedBox(
                    width: rw(343),
                    height: rh(135),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(rw(20)),
                          child: SizedBox(width: rw(343), height: rh(135), child: buildProfileImage(pharmacy.imageUrl, fallbackIcon: Icons.local_pharmacy, iconSize: rw(50))),
                        ),
                        Positioned(top: rh(6), left: rw(5), child: Container(padding: EdgeInsets.symmetric(horizontal: rw(5), vertical: rh(5)), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(rw(14))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star, size: rw(20), color: const Color(0xFFFFCD29)), SizedBox(width: rw(2)), Text(pharmacy.rating.toStringAsFixed(1), style: GoogleFonts.roboto(fontSize: rfs(12), fontWeight: FontWeight.w500, color: Colors.black)), SizedBox(width: rw(2)), Text('(${pharmacy.reviewCount})', style: GoogleFonts.inter(fontSize: rfs(10), fontWeight: FontWeight.w500, color: Colors.black))]))),
                        Positioned(bottom: rh(8), right: rw(10), child: Icon(Icons.favorite, size: rw(20), color: const Color(0xFFFF5050))),
                      ],
                    ),
                  ),
                  SizedBox(height: rh(1)),
                  Container(
                    width: rw(343),
                    padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(4)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(pharmacy.name, style: GoogleFonts.oswald(fontSize: rfs(16), fontWeight: FontWeight.w400, color: Colors.black)),
                          Row(children: [SvgPicture.asset('assets/icons/figma_location_icon.svg', width: rw(17), height: rw(17), placeholderBuilder: (context) => Icon(Icons.location_on, size: rw(17), color: Colors.grey)), Text(pharmacy.location ?? '', style: GoogleFonts.oswald(fontSize: rfs(11), fontWeight: FontWeight.w400, color: Colors.black))]),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset('assets/icons/figma_open_door_icon.svg', width: rw(24), height: rw(24), placeholderBuilder: (context) => Icon(Icons.door_front_door, size: rw(24), color: const Color(0xFF073A6A))), Text(pharmacy.isOpen ? 'Open' : 'Closed', style: GoogleFonts.oswald(fontSize: rfs(11), fontWeight: FontWeight.w400, color: pharmacy.isOpen ? const Color(0xFF073A6A) : Colors.red))]),
                          Row(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset('assets/icons/figma_map_icon.svg', width: rw(24), height: rw(24), placeholderBuilder: (context) => Icon(Icons.map, size: rw(24), color: const Color(0xFF6A6A6A))), SizedBox(width: rw(1)), Text('Map', style: GoogleFonts.oswald(fontSize: rfs(11), fontWeight: FontWeight.w400, color: const Color(0xFF073A6A)))]),
                        ]),
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
    return Consumer<PromotionProvider>(
      builder: (context, promoProvider, child) {
        final promos = promoProvider.promotions;
        final offers = promos.isNotEmpty
            ? promos.map((p) => <String, dynamic>{
                  'title': p.title,
                  'originalPrice': p.price != null ? 'Rs ${p.price!.toStringAsFixed(0)}' : '',
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(25)),
              child: Row(children: [SvgPicture.asset('assets/icons/figma_promotion_badge.svg', width: rw(25), height: rw(24), placeholderBuilder: (context) => Icon(Icons.local_offer, size: rw(25), color: const Color(0xFF0097B2))), SizedBox(width: rw(10)), Text('Special offers for you', style: GoogleFonts.inter(fontSize: rfs(18), fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.112, height: 1.2))]),
            ),
            SizedBox(height: rh(15)),
            SizedBox(height: rh(149), child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: rw(20)), itemCount: offers.length, itemBuilder: (context, index) => Padding(padding: EdgeInsets.only(right: rw(25)), child: _buildOfferCard(offers[index])))),
          ],
        );
      },
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return Container(
      width: rw(256),
      height: rh(129),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(rw(15)), boxShadow: [BoxShadow(color: const Color(0xFF9FACDC).withOpacity(0.51), blurRadius: 4.7, offset: const Offset(-4, 4))]),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.only(topLeft: Radius.circular(rw(15)), bottomLeft: Radius.circular(rw(15))), child: (offer['image'] != null && offer['image'].toString().startsWith('http'))
                ? Image.network(offer['image'], width: rw(128), height: rh(129), fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: rw(128), height: rh(129), color: const Color(0xFFF5F5F5), child: Icon(Icons.image, size: rw(40), color: Colors.grey)))
                : Image.asset(offer['image'] ?? 'assets/images/featured_store_1.png', width: rw(128), height: rh(129), fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: rw(128), height: rh(129), color: const Color(0xFFF5F5F5), child: Icon(Icons.image, size: rw(40), color: Colors.grey)))),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offer['title'], style: GoogleFonts.rancho(fontSize: rfs(20), fontWeight: FontWeight.w400, color: const Color(0xFF343434)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: rh(2)),
                  Row(children: [SvgPicture.asset('assets/icons/figma_promotion_badge.svg', width: rw(20), height: rw(20), placeholderBuilder: (context) => Icon(Icons.local_offer, size: rw(20), color: const Color(0xFF0097B2))), SizedBox(width: rw(2)), Expanded(child: Text(offer['discount'], style: GoogleFonts.poppins(fontSize: rfs(12), fontWeight: FontWeight.w400, color: Colors.black)))]),
                  SizedBox(height: rh(4)),
                  Text(offer['description'], style: GoogleFonts.poppins(fontSize: rfs(10), fontWeight: FontWeight.w400, color: const Color(0xFF696969)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Row(children: [
                    Text(offer['salePrice'], style: GoogleFonts.poppins(fontSize: rfs(12), fontWeight: FontWeight.w600, color: const Color(0xFFFF5571))),
                    SizedBox(width: rw(8)),
                    Flexible(child: Text(offer['originalPrice'], style: GoogleFonts.poppins(fontSize: rfs(12), fontWeight: FontWeight.w600, color: const Color(0xFF929292), decoration: TextDecoration.lineThrough), overflow: TextOverflow.ellipsis)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequentlyVisitedSection(List<AmenityModel> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(20)),
          child: Row(children: [SvgPicture.asset('assets/icons/figma_binocular_icon.svg', width: rw(25), height: rw(25), placeholderBuilder: (context) => Icon(Icons.visibility, size: rw(25), color: const Color(0xFF0097B2))), SizedBox(width: rw(15)), Flexible(child: Text('Frequently visited by other members', style: GoogleFonts.inter(fontSize: rfs(18), fontWeight: FontWeight.w700, color: const Color(0xFF282828), letterSpacing: 0.168, height: 1.3)))]),
        ),
        SizedBox(height: rh(15)),
        SizedBox(height: rh(181), child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: rw(15)), itemCount: items.length, itemBuilder: (context, index) => Padding(padding: EdgeInsets.only(right: rw(15)), child: _buildFrequentlyVisitedCard(items[index])))),
      ],
    );
  }

  Widget _buildFrequentlyVisitedCard(AmenityModel pharmacy) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PharmacyDetailScreen(pharmacyData: {
        'id': pharmacy.id,
        'name': pharmacy.name,
        'rating': pharmacy.rating.toStringAsFixed(1),
        'reviews': pharmacy.reviewCount.toString(),
        'location': pharmacy.location ?? '',
        'isOpen': pharmacy.isOpen,
        'image': pharmacy.imageUrl,
      }))),
      child: Container(
        width: rw(322),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(rw(25)), border: Border.all(color: Colors.black.withOpacity(0.15), width: 1)),
        padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(3)),
        child: Column(
          children: [
            SizedBox(
              width: rw(302),
              height: rh(118),
              child: Stack(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(rw(20)), child: SizedBox(width: rw(302), height: rh(118), child: buildProfileImage(pharmacy.imageUrl, fallbackIcon: Icons.local_pharmacy, iconSize: rw(40)))),
                  Positioned(top: rh(5), left: rw(6), child: Container(padding: EdgeInsets.symmetric(horizontal: rw(5), vertical: rh(5)), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(rw(14))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star, size: rw(20), color: const Color(0xFFFFCD29)), SizedBox(width: rw(2)), Text(pharmacy.rating.toStringAsFixed(1), style: GoogleFonts.roboto(fontSize: rfs(12), fontWeight: FontWeight.w500, color: Colors.black)), SizedBox(width: rw(2)), Text('(${pharmacy.reviewCount})', style: GoogleFonts.inter(fontSize: rfs(10), fontWeight: FontWeight.w500, color: Colors.black))]))),
                  Positioned(bottom: rh(8), right: rw(10), child: Icon(Icons.favorite_border, size: rw(20), color: const Color(0xFF8C8C8C))),
                ],
              ),
            ),
            SizedBox(height: rh(1)),
            Container(
              width: rw(302),
              padding: EdgeInsets.symmetric(horizontal: rw(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pharmacy.name, style: GoogleFonts.oswald(fontSize: rfs(15), fontWeight: FontWeight.w400, color: Colors.black)), Row(children: [SvgPicture.asset('assets/icons/figma_location_icon.svg', width: rw(17), height: rw(17), placeholderBuilder: (context) => Icon(Icons.location_on, size: rw(17), color: Colors.grey)), Text(pharmacy.location ?? '', style: GoogleFonts.oswald(fontSize: rfs(11), fontWeight: FontWeight.w300, color: Colors.black))])]),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset('assets/icons/figma_open_door_icon.svg', width: rw(24), height: rw(24), placeholderBuilder: (context) => Icon(Icons.door_front_door, size: rw(24), color: const Color(0xFF073A6A))), Text(pharmacy.isOpen ? 'Open' : 'Closed', style: GoogleFonts.oswald(fontSize: rfs(11), fontWeight: FontWeight.w400, color: pharmacy.isOpen ? const Color(0xFF073A6A) : Colors.red))]), Row(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset('assets/icons/figma_map_icon.svg', width: rw(24), height: rw(24), placeholderBuilder: (context) => Icon(Icons.map, size: rw(24), color: const Color(0xFF6A6A6A))), SizedBox(width: rw(1)), Text('Map', style: GoogleFonts.oswald(fontSize: rfs(11), fontWeight: FontWeight.w400, color: const Color(0xFF073A6A)))])]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmaciesNearLocationSection(List<AmenityModel> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(20)),
          child: Row(children: [SvgPicture.asset('assets/icons/figma_location_filled_icon.svg', width: rw(25), height: rw(25), colorFilter: const ColorFilter.mode(Color(0xFF0097B2), BlendMode.srcIn), placeholderBuilder: (context) => Icon(Icons.location_on, size: rw(25), color: const Color(0xFF0097B2))), SizedBox(width: rw(15)), Text('Pharmacies near your location', style: GoogleFonts.inter(fontSize: rfs(18), fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.112, height: 1.2))]),
        ),
        SizedBox(height: rh(20)),
        Padding(padding: EdgeInsets.symmetric(horizontal: rw(15)), child: Column(children: items.map((pharmacy) => Padding(padding: EdgeInsets.only(bottom: rh(20)), child: _buildNearbyPharmacyCard(pharmacy))).toList())),
      ],
    );
  }

  Widget _buildNearbyPharmacyCard(AmenityModel pharmacy) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PharmacyDetailScreen(pharmacyData: {
        'id': pharmacy.id,
        'name': pharmacy.name,
        'rating': pharmacy.rating.toStringAsFixed(1),
        'reviews': pharmacy.reviewCount.toString(),
        'location': pharmacy.location ?? '',
        'isOpen': pharmacy.isOpen,
        'image': pharmacy.imageUrl,
      }))),
      child: Container(
        width: rw(360),
        height: rh(101),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(rw(25)), border: Border.all(color: Colors.black.withOpacity(0.15), width: 1)),
        padding: EdgeInsets.all(rw(10)),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(rw(100)), child: SizedBox(width: rw(81), height: rw(81), child: buildProfileImage(pharmacy.imageUrl, fallbackIcon: Icons.local_pharmacy, iconSize: rw(30)))),
            SizedBox(width: rw(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(pharmacy.name, style: GoogleFonts.inter(fontSize: rfs(15), fontWeight: FontWeight.w600, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(children: [SvgPicture.asset('assets/icons/figma_location_icon.svg', width: rw(17), height: rw(17), placeholderBuilder: (context) => Icon(Icons.location_on, size: rw(17), color: Colors.grey)), Text(pharmacy.location ?? '', style: GoogleFonts.oswald(fontSize: rfs(11), fontWeight: FontWeight.w300, color: Colors.black))]),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: List.generate(5, (index) => Icon(index < pharmacy.rating.round() ? Icons.star : Icons.star_border, size: rw(15), color: const Color(0xFFFFCD29)))), SizedBox(height: rh(4)), Row(children: [Text(pharmacy.rating.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: rfs(12), fontWeight: FontWeight.w500, color: const Color(0xFF353535), letterSpacing: 0.168)), SizedBox(width: rw(3)), Text('(${pharmacy.reviewCount} Reviews)', style: GoogleFonts.inter(fontSize: rfs(12), fontWeight: FontWeight.w500, color: const Color(0xFF353535), letterSpacing: 0.168))])]),
                ],
              ),
            ),
            Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset('assets/icons/figma_open_door_icon.svg', width: rw(24), height: rw(24), placeholderBuilder: (context) => Icon(Icons.door_front_door, size: rw(24), color: const Color(0xFF073A6A))), Text(pharmacy.isOpen ? 'Open' : 'Closed', style: GoogleFonts.oswald(fontSize: rfs(11), fontWeight: FontWeight.w400, color: pharmacy.isOpen ? const Color(0xFF073A6A) : Colors.red))]), Row(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset('assets/icons/figma_map_icon.svg', width: rw(24), height: rw(24), placeholderBuilder: (context) => Icon(Icons.map, size: rw(24), color: const Color(0xFF6A6A6A))), SizedBox(width: rw(1)), Text('Map', style: GoogleFonts.oswald(fontSize: rfs(11), fontWeight: FontWeight.w400, color: const Color(0xFF073A6A)))])]),
          ],
        ),
      ),
    );
  }
}

