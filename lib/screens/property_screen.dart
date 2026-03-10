import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import 'search_screen.dart';
import '../models/property_model.dart';
import '../widgets/profile_image.dart';
import '../widgets/list_screen_header.dart';
import 'property_agent_screen.dart';
import '../mixins/responsive_mixin.dart';

class PropertyScreen extends StatefulWidget {
  final String? partnerId;
  final String? agentName;

  const PropertyScreen({super.key, this.partnerId, this.agentName});

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen>
    with ResponsiveMixin {
  void _openAgentFromProperty(PropertyModel property) {
    final partner = property.partner;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyAgentScreen(
          agentData: {
            'id': property.partnerId ?? partner?.id,
            'partnerId': property.partnerId ?? partner?.id,
            'name': partner?.businessName ?? partner?.ownerFullName ?? 'Property Agent',
            'image': partner?.profilePhotoUrl,
            'location': partner?.address ?? partner?.city ?? property.location ?? '',
            'rating': (partner?.rating ?? 0).toStringAsFixed(1),
            'phone': partner?.phone,
            'isOpen': partner?.isBusinessOpen ?? false,
            'openingTime': partner?.openingTime,
            'closingTime': partner?.closingTime,
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _agentSummaries(List<PropertyModel> properties) {
    final byPartner = <String, List<PropertyModel>>{};
    for (final p in properties) {
      final pid = p.partnerId ?? p.partner?.id;
      if (pid == null || pid.isEmpty) continue;
      byPartner.putIfAbsent(pid, () => []).add(p);
    }

    final agents = byPartner.entries.map((entry) {
      final list = entry.value;
      final first = list.first;
      return <String, dynamic>{
        'id': entry.key,
        'partnerId': entry.key,
        'name': first.partner?.businessName ?? first.partner?.ownerFullName ?? 'Property Agent',
        'image': first.partner?.profilePhotoUrl,
        'location': first.partner?.address ?? first.partner?.city ?? first.location ?? '',
        'rating': first.partner?.rating ?? 0.0,
        'listingCount': list.length,
      };
    }).toList();

    agents.sort((a, b) => (b['listingCount'] as int).compareTo(a['listingCount'] as int));
    return agents;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties(
        partnerId: widget.partnerId,
        force: true,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          ListScreenHeader(
            title: 'Real Estate',
            categoryIconAsset: 'assets/icons/fluent_real_estate_filled.svg',
            onSearch: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          // Scrollable Content
          Expanded(
            child: Consumer<PropertyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.properties.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final properties = provider.properties;
                final featuredListings = properties.take(2).toList();
                final rentals = properties.where((p) => p.purpose == 'RENTAL').toList();
                if (rentals.isEmpty && properties.length > 1) {
                  rentals.addAll(properties.take(2));
                }
                final superHotSales = properties.where((p) => p.listingStatus == 'SUPER_HOT').toList();
                if (superHotSales.isEmpty && properties.length > 2) {
                  superHotSales.addAll(properties.skip(2).take(2));
                } else if (superHotSales.isEmpty && properties.isNotEmpty) {
                  superHotSales.addAll(properties.take(2));
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: rh(15)),
                      _buildFeaturedListingsSection(featuredListings),
                      SizedBox(height: rh(15)),
                      _buildTopAgentsSection(properties),
                      SizedBox(height: rh(15)),
                      _buildRentalsSection(rentals),
                      SizedBox(height: rh(15)),
                      _buildAgentsNearYouSection(properties),
                      SizedBox(height: rh(15)),
                      _buildSuperHotSaleSection(superHotSales),
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


  Widget _buildFeaturedListingsSection(List<PropertyModel> listings) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/figma_binocular_icon.svg',
                width: rw(25),
                height: rw(25),
              ),
              SizedBox(width: rw(15)),
              Flexible(
                child: Text(
                  'Featured Listings',
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
          SizedBox(height: rh(15)),
          // Featured Card
          ...listings
              .take(1)
              .map((property) => _buildFeaturedCard(property)),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(PropertyModel property) {
    return GestureDetector(
      onTap: () => _openAgentFromProperty(property),
      child: Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: rw(360)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.black.withOpacity(0.15),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(rw(10)),
      child: Row(
        children: [
          // Property Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: rw(100),
              height: rh(98),
              child: buildProfileImage(property.mainImageUrl, fallbackIcon: Icons.home, iconSize: 50),
            ),
          ),
          SizedBox(width: rw(10)),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(5)),
                  child: Text(
                    property.title,
                    style: GoogleFonts.inter(
                      fontSize: rfs(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: rh(5)),
                // Location
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(5)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/figma_location_icon.svg',
                        width: rw(25),
                        height: rw(25),
                      ),
                      SizedBox(width: rw(5)),
                      Expanded(
                        child: Text(
                          property.location ?? '',
                          style: GoogleFonts.inter(
                            fontSize: rfs(11),
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withOpacity(0.75),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: rh(5)),
                // Buttons Row
                Row(
                  children: [
                    // Ask for Price Button
                    Expanded(
                      child: Container(
                        height: rh(33),
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
                              fontSize: rfs(14),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFBFBFBF),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: rw(10)),
                    // More Detail Button
                    Expanded(
                      child: Container(
                        height: rh(33),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0097B2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'More Detail',
                            style: GoogleFonts.inter(
                              fontSize: rfs(14),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
      ),
    );
  }

  Widget _buildTopAgentsSection(List<PropertyModel> properties) {
    final agents = _agentSummaries(properties).take(3).toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/figma_award_icon.svg',
                width: rw(25),
                height: rw(25),
              ),
              SizedBox(width: rw(10)),
              Flexible(
                child: Text(
                  'Top 3 Agents',
                  style: GoogleFonts.inter(
                    fontSize: rfs(18),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF282828),
                    letterSpacing: 0.168,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: rh(15)),
          if (agents.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: rh(20)),
                child: Text(
                  'No agents found',
                  style: GoogleFonts.inter(
                    fontSize: rfs(14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF888888),
                  ),
                ),
              ),
            )
          else
            Column(
              children: agents
                  .map(
                    (a) => Padding(
                      padding: EdgeInsets.only(bottom: rh(8)),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PropertyAgentScreen(agentData: a),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: rw(12), vertical: rh(10)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              ClipOval(
                                child: SizedBox(
                                  width: rw(36),
                                  height: rw(36),
                                  child: buildProfileImage(a['image'], fallbackIcon: Icons.business, iconSize: 18),
                                ),
                              ),
                              SizedBox(width: rw(10)),
                              Expanded(
                                child: Text(
                                  '${a['name']} (${a['listingCount']})',
                                  style: GoogleFonts.inter(
                                    fontSize: rfs(13),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF282828),
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
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }


  Widget _buildRentalsSection(List<PropertyModel> rentals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(15)),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/figma_store_icon.svg',
                width: rw(20),
                height: rw(20),
              ),
              SizedBox(width: rw(10)),
              Expanded(
                child: Text(
                  'Rentals near you',
                  style: GoogleFonts.inter(
                    fontSize: rfs(18),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF282828),
                    letterSpacing: 0.168,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rh(15)),
        // Rentals Horizontal ListView
        SizedBox(
          height: rh(276),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: rw(15)),
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: rw(10)),
                child: _buildRentalCard(rentals[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRentalCard(PropertyModel property) {
    // Build thumbnail list from property images, with fallbacks
    final thumbnailUrls = property.images.take(3).map((img) => img.imageUrl).toList();
    while (thumbnailUrls.length < 3) {
      thumbnailUrls.add('');
    }

    return GestureDetector(
      onTap: () => _openAgentFromProperty(property),
      child: Container(
      width: rw(346),
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
          // Images Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail Column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: index < 2 ? rh(5) : 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: rw(35),
                        height: rw(35),
                        child: buildProfileImage(
                          thumbnailUrls[index].isNotEmpty ? thumbnailUrls[index] : null,
                          fallbackIcon: Icons.home,
                          iconSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: rw(10)),
              // Main Image
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: rh(117),
                    child: buildProfileImage(property.mainImageUrl, fallbackIcon: Icons.home, iconSize: 50),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: rh(10)),
          // Content Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(5)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Content
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Flexible(
                          child: Text(
                            property.title,
                            style: GoogleFonts.inter(
                              fontSize: rfs(16),
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: rh(5)),
                        // Location Row
                        Flexible(
                          flex: 2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/figma_location_icon.svg',
                                width: rw(25),
                                height: rw(25),
                              ),
                              SizedBox(width: rw(5)),
                              Expanded(
                                child: Text(
                                  property.location ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: rfs(12),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black.withOpacity(0.75),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: rh(5)),
                        // Amenities Row
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildAmenityChip(Icons.bed, '${property.beds ?? 1} Bed'),
                                SizedBox(width: rw(15)),
                                _buildAmenityChip(Icons.bathtub, '${property.baths ?? 1} Bath'),
                                SizedBox(width: rw(15)),
                                _buildAmenityChip(Icons.kitchen, '${property.kitchen ?? 1} Kitchen'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right Content - Type Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(5),
                      vertical: rh(5),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      property.purpose == 'SALE' ? 'Sale' : 'Rental',
                      style: GoogleFonts.poppins(
                        fontSize: rfs(15),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF353535),
                        letterSpacing: 0.168,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: rh(10)),
          // Buttons Row
          Row(
            children: [
              // Ask for Price Button
              Expanded(
                child: Container(
                  height: rh(33),
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
                        fontSize: rfs(14),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFBFBFBF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              SizedBox(width: rw(10)),
              // More Detail Button
              Expanded(
                child: Container(
                  height: rh(33),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0097B2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'More Detail',
                      style: GoogleFonts.inter(
                        fontSize: rfs(14),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildAmenityChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: rw(20),
          color: Colors.black,
        ),
        SizedBox(width: rw(5)),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: rfs(12),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAgentsNearYouSection(List<PropertyModel> properties) {
    final agents = _agentSummaries(properties).take(6).toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/figma_award_icon.svg',
                      width: rw(25),
                      height: rw(25),
                    ),
                    SizedBox(width: rw(10)),
                    Flexible(
                      child: Text(
                        'Agents near you',
                        style: GoogleFonts.inter(
                          fontSize: rfs(18),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF272727),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'See all',
                style: GoogleFonts.inter(
                  fontSize: rfs(12),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C6C6C),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: rh(10)),
          if (agents.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: rh(20)),
                child: Text(
                  'No agents found',
                  style: GoogleFonts.inter(
                    fontSize: rfs(14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF888888),
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: rw(8),
              runSpacing: rh(8),
              children: agents
                  .map(
                    (a) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyAgentScreen(agentData: a),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(6)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          a['name'].toString(),
                          style: GoogleFonts.inter(
                            fontSize: rfs(12),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF282828),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }


  Widget _buildSuperHotSaleSection(List<PropertyModel> sales) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
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
              Flexible(
                child: Text(
                  'Super Hot Sale',
                  style: GoogleFonts.inter(
                    fontSize: rfs(18),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 0.112,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rh(15)),
        // Super Hot Sale Horizontal ListView
        SizedBox(
          height: rh(252),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: rw(15)),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: rw(10)),
                child: _buildSuperHotSaleCard(sales[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuperHotSaleCard(PropertyModel property) {
    return GestureDetector(
      onTap: () => _openAgentFromProperty(property),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: rw(248),
              height: rh(130),
              child: buildProfileImage(property.mainImageUrl, fallbackIcon: Icons.home, iconSize: 50),
            ),
          ),
          SizedBox(height: rh(10)),
          // Content
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Hot Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          property.title,
                          style: GoogleFonts.inter(
                            fontSize: rfs(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: rw(5)),
                      // Hot Badge
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
                  SizedBox(height: rh(2)),
                  // Location
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/figma_location_icon.svg',
                        width: rw(17),
                        height: rw(17),
                      ),
                      SizedBox(width: rw(5)),
                      Expanded(
                        child: Text(
                          property.location ?? '',
                          style: GoogleFonts.inter(
                            fontSize: rfs(11),
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
          ),
          SizedBox(height: rh(10)),
          // Buttons Row
          Row(
            children: [
              // Ask for Price Button
              Expanded(
                child: Container(
                  height: rh(33),
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
                        fontSize: rfs(14),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFBFBFBF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              SizedBox(width: rw(10)),
              // More Detail Button
              Expanded(
                child: Container(
                  height: rh(33),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0097B2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'More Detail',
                      style: GoogleFonts.inter(
                        fontSize: rfs(14),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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


}
