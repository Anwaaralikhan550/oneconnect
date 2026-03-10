import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../models/filter_dto.dart';
import '../utils/map_utils.dart';
import '../widgets/sticky_footer.dart';
import '../widgets/profile_image.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/figma_filter_sheet.dart';

class BusinessesAndAmenitiesHubScreen extends StatefulWidget {
  final String? category;
  const BusinessesAndAmenitiesHubScreen({super.key, this.category});

  @override
  State<BusinessesAndAmenitiesHubScreen> createState() =>
      _BusinessesAndAmenitiesHubScreenState();
}

class _BusinessesAndAmenitiesHubScreenState
    extends State<BusinessesAndAmenitiesHubScreen> with ResponsiveMixin, TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _businessesExpanded = false;
  bool _amenitiesExpanded = false;
  String _selectedLocationFilter = 'Area';
  String _selectedCategoryFilter = 'Service';
  String _selectedPriceFilter = 'Rs';

  late AnimationController _businessesAnimController;
  late AnimationController _amenitiesAnimController;
  late Animation<double> _businessesAnimation;
  late Animation<double> _amenitiesAnimation;

  static const List<String> _businessCodes = <String>[
    'STORE',
    'SOLAR',
    'BANK',
    'RESTAURANT',
    'REAL_ESTATE',
    'HOME_CHEF',
  ];

  static const List<String> _amenityCodes = <String>[
    'MASJID',
    'PARK',
    'GYM',
    'HEALTHCARE',
    'SCHOOL',
    'PHARMACY',
    'CAFE',
    'ADMIN',
  ];

  @override
  void initState() {
    super.initState();
    _businessesAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _amenitiesAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _businessesAnimation = CurvedAnimation(
      parent: _businessesAnimController,
      curve: Curves.easeInOut,
    );
    _amenitiesAnimation = CurvedAnimation(
      parent: _amenitiesAnimController,
      curve: Curves.easeInOut,
    );

    // Fetch featured businesses and amenities from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _primeFeaturedData();
      Provider.of<FavoriteProvider>(context, listen: false).hydrateFavorites();
    });
  }

  Future<void> _primeFeaturedData() async {
    final filter = _activeFilterDto;
    final provider = Provider.of<BusinessProvider>(context, listen: false);
    for (final category in _businessCodes) {
      await provider.fetchBusinesses(category, filter: filter, force: true);
    }
    for (final type in _amenityCodes) {
      await provider.fetchAmenities(type, filter: filter, force: true);
    }
  }

  FilterDto get _activeFilterDto => FilterDto(
      latitude: Provider.of<AuthProvider>(context, listen: false).user?.locationLat,
      longitude: Provider.of<AuthProvider>(context, listen: false).user?.locationLng,
      locationMode: _selectedLocationFilter == 'Distance'
          ? 'DISTANCE'
          : (_selectedLocationFilter == 'Block' ? 'BLOCK' : 'AREA'),
      category: _selectedCategoryFilter == 'Service'
          ? 'Service'
          : (_selectedCategoryFilter == 'Type' || _selectedCategoryFilter == 'Brand'
              ? 'Shop'
              : null),
      priceTier: _selectedPriceFilter == 'Rs++'
          ? 'RS_PLUS_PLUS'
          : (_selectedPriceFilter == 'Rs+' ? 'RS_PLUS' : 'RS'),
      minRating: _selectedPriceFilter == 'Rs++'
          ? 4.0
          : (_selectedPriceFilter == 'Rs+' ? 3.5 : null),
      sortBy: _selectedLocationFilter == 'Distance' ? 'NEAR_ME' : null,
    );

  @override
  void dispose() {
    _searchController.dispose();
    _businessesAnimController.dispose();
    _amenitiesAnimController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    Navigator.pushNamed(context, '/search-results', arguments: query);
  }

  Future<void> _openFilterSheet() async {
    final selection = await showFigmaFilterSheet(
      context,
      selectedLocation: _selectedLocationFilter,
      selectedCategory: _selectedCategoryFilter,
      selectedPrice: _selectedPriceFilter,
    );
    if (selection == null || !mounted) return;
    setState(() {
      _selectedLocationFilter = selection.location;
      _selectedCategoryFilter = selection.category;
      _selectedPriceFilter = selection.price;
    });
    await _primeFeaturedData();
  }

  void _toggleBusinesses() {
    setState(() {
      _businessesExpanded = !_businessesExpanded;
      if (_businessesExpanded) {
        _businessesAnimController.forward();
      } else {
        _businessesAnimController.reverse();
      }
    });
  }

  void _toggleAmenities() {
    setState(() {
      _amenitiesExpanded = !_amenitiesExpanded;
      if (_amenitiesExpanded) {
        _amenitiesAnimController.forward();
      } else {
        _amenitiesAnimController.reverse();
      }
    });
  }

  // Businesses icons based on Figma: Store, Solar, Bank, Restaurant, Real Estate, Home Chef
  final List<Map<String, String>> _businesses = [
    {'icon': 'assets/images/store_icon_hub.svg', 'label': 'Store'},
    {'icon': 'assets/images/solar_icon_hub.svg', 'label': 'Solar'},
    {'icon': 'assets/images/bank_icon_hub.svg', 'label': 'Bank'},
    {'icon': 'assets/images/restaurant_icon_hub.svg', 'label': 'Restaurant'},
    {'icon': 'assets/images/real_estate_icon_hub.svg', 'label': 'Real Estate'},
    {'icon': 'assets/images/home_chef_icon_hub.svg', 'label': 'Home Chef'},
  ];

  // Amenities icons based on Figma: Masjid, Park, Gym, Healthcare, School, Pharmacy, Cafe, Admin
  final List<Map<String, String>> _amenities = [
    {'icon': 'assets/images/mosque_icon_hub.svg', 'label': 'Masjid'},
    {'icon': 'assets/images/park_icon_hub.svg', 'label': 'Park'},
    {'icon': 'assets/images/gym_icon_hub.svg', 'label': 'Gym'},
    {'icon': 'assets/images/healthcare_icon_hub.svg', 'label': 'Healthcare'},
    {'icon': 'assets/images/school_icon_hub.svg', 'label': 'School'},
    {'icon': 'assets/images/pharmacy_icon_hub.svg', 'label': 'Pharmacy'},
    {'icon': 'assets/images/cafe_icon_hub.svg', 'label': 'Cafe'},
    {'icon': 'assets/images/admin_icon_hub.svg', 'label': 'Admin'},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with banner image and OneConnect logo
          _buildHeader(),

          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - Afacad font, 25px
                  _buildMainTitle(),

                  // Search bar with filter icon
                  _buildSearchBar(),

                  const SizedBox(height: 15),

                  // Businesses Section
                  _buildBusinessesSection(),

                  // Amenities Section
                  _buildAmenitiesSection(),

                  // Featured Section
                  _buildFeaturedSection(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: StickyFooter(
        selectedIndex: 1,
        onItemTapped: (index) => _handleFooterNavigation(index),
      ),
    );
  }

  Widget _buildHeader() {
    // Header is 215px height in Figma design
    return SizedBox(
      width: double.infinity,
      height: rh(215),
      child: Stack(
        children: [
          // Original header image - unchanged
          Positioned.fill(
            child: Image.asset(
              'assets/images/hub_header_complete.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF8BC34A).withOpacity(0.8),
                        const Color(0xFF4CAF50).withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/oneconnect_logo_header.svg',
                      width: rw(231),
                      height: rh(52),
                      placeholderBuilder: (context) => Text(
                        '1.CONNECT',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Invisible tap area for back button (overlays existing back icon in image)
          Positioned(
            top: MediaQuery.of(context).padding.top + rh(10),
            left: rw(20),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: rw(35),
                height: rw(35),
                color: Colors.transparent,
              ),
            ),
          ),

          // Invisible tap areas for notification and settings icons
          Positioned(
            top: MediaQuery.of(context).padding.top + rh(10),
            right: rw(20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/notification'),
                  child: Container(
                    width: rw(26),
                    height: rw(26),
                    color: Colors.transparent,
                  ),
                ),
                SizedBox(width: rw(3)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                  child: Container(
                    width: rw(26),
                    height: rw(26),
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTitle() {
    // Figma: Afacad Medium 25px, line height 25px
    return Padding(
      padding: EdgeInsets.fromLTRB(
        rw(15),
        rh(15),
        rw(15),
        0,
      ),
      child: Text(
        'Find Community businesses and amenities at ease',
        style: GoogleFonts.afacad(
          fontSize: rfs(25),
          fontWeight: FontWeight.w500,
          color: Colors.black,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    // Figma: Search bar is 306x38, border radius 100, outer border 2px #EBEBEB
    return Padding(
      padding: EdgeInsets.fromLTRB(
        rw(42),
        rh(15),
        rw(42),
        0,
      ),
      child: Container(
        height: rh(38),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: const Color(0xFFEBEBEB),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search glass icon - 19x19 based on Figma
            Padding(
              padding: EdgeInsets.only(left: rw(15)),
              child: SvgPicture.asset(
                'assets/images/search_glass_hub.svg',
                width: rw(19),
                height: rw(19),
                colorFilter: const ColorFilter.mode(
                  Color(0xFF4A4A4A),
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => Icon(
                  Icons.search,
                  color: const Color(0xFF4A4A4A),
                  size: rw(19),
                ),
              ),
            ),

            // Search text field
            Expanded(
              child: Center(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submitSearch(),
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                    fontSize: rfs(14),
                    color: const Color(0xFF4A4A4A),
                  ),
                  decoration: InputDecoration(
                    hintText: '',
                    hintStyle: TextStyle(
                      color: const Color(0xFF999999),
                      fontSize: rfs(14),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: rw(8),
                      vertical: 0,
                    ),
                  ),
                ),
              ),
            ),

            // Vertical line separator - 1x21
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(5)),
              child: SvgPicture.asset(
                'assets/images/vertical_line_hub.svg',
                width: rw(1),
                height: rh(21),
                placeholderBuilder: (context) => Container(
                  width: 1,
                  height: rh(21),
                  color: const Color(0xFFE0E0E0),
                ),
              ),
            ),

            // Filter icon - 25x25
            Padding(
              padding: EdgeInsets.only(right: rw(10)),
              child: GestureDetector(
                onTap: _openFilterSheet,
                child: SvgPicture.asset(
                  'assets/images/filter_icon_hub.svg',
                  width: rw(25),
                  height: rw(25),
                  placeholderBuilder: (context) => Icon(
                    Icons.tune,
                    color: const Color(0xFF4A4A4A),
                    size: rw(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessesSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, rh(15), 0, 0),
      padding: EdgeInsets.symmetric(vertical: rh(10)),
      color: Colors.white,
      child: Column(
        children: [
          // Header with expand/collapse arrow on right - Inter 18px w700
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Businesses',
                  style: GoogleFonts.inter(
                    fontSize: rfs(18),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: _toggleBusinesses,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(rw(8)),
                    child: AnimatedBuilder(
                      animation: _businessesAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _businessesAnimation.value * 3.14159,
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: const Color(0xFF4A4A4A),
                        size: rw(28),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // First row of icons - always visible (first 4 icons)
          SizedBox(height: rh(15)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(24)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _businesses.take(4).map((item) {
                return _buildCategoryIcon(item['icon']!, item['label']!);
              }).toList(),
            ),
          ),

          // Second row of icons - animated expand/collapse (remaining icons)
          SizeTransition(
            sizeFactor: _businessesAnimation,
            axisAlignment: -1.0,
            child: Column(
              children: [
                SizedBox(height: rh(15)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(24)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: _businesses.skip(4).map((item) {
                      return Padding(
                        padding: EdgeInsets.only(right: rw(30)),
                        child: _buildCategoryIcon(item['icon']!, item['label']!),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, rh(5), 0, 0),
      padding: EdgeInsets.symmetric(vertical: rh(10)),
      color: Colors.white,
      child: Column(
        children: [
          // Header with expand/collapse arrow on right - Inter 18px w700
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amenities',
                  style: GoogleFonts.inter(
                    fontSize: rfs(18),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: _toggleAmenities,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(rw(8)),
                    child: AnimatedBuilder(
                      animation: _amenitiesAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _amenitiesAnimation.value * 3.14159,
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: const Color(0xFF4A4A4A),
                        size: rw(28),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // First row of icons - always visible (first 4 icons)
          SizedBox(height: rh(15)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(24)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _amenities.take(4).map((item) {
                return _buildCategoryIcon(item['icon']!, item['label']!);
              }).toList(),
            ),
          ),

          // Second row of icons - animated expand/collapse (remaining icons)
          SizeTransition(
            sizeFactor: _amenitiesAnimation,
            axisAlignment: -1.0,
            child: Column(
              children: [
                SizedBox(height: rh(15)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(24)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _amenities.skip(4).map((item) {
                      return _buildCategoryIcon(item['icon']!, item['label']!);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String iconPath, String label) {
    // Figma: 50x50 icon container, Inter 12px label
    return GestureDetector(
      onTap: () => _handleCategoryTap(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: rw(50),
            height: rw(50),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(rw(25)),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: rw(30),
                height: rw(30),
                placeholderBuilder: (context) => Icon(
                  _getIconForLabel(label),
                  size: rw(26),
                  color: const Color(0xFF4A4A4A),
                ),
              ),
            ),
          ),
          SizedBox(height: rh(8)),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: rfs(12),
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    // Figma: Featured tab is 390x213
    return Container(
      margin: EdgeInsets.fromLTRB(0, rh(15), 0, 0),
      padding: EdgeInsets.symmetric(vertical: rh(5)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title - Inter 18px w700
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(15)),
            child: Text(
              'Featured Businesses and Amenities',
              style: GoogleFonts.inter(
                fontSize: rfs(18),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: rh(15)),

          // Horizontal scroll cards - 287x166 each
          Consumer<BusinessProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return SizedBox(
                  height: rh(166),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              if (provider.error != null && provider.error!.isNotEmpty) {
                return SizedBox(
                  height: rh(166),
                  child: Center(
                    child: Text(
                      provider.error!,
                      style: TextStyle(
                        fontSize: rfs(12),
                        color: const Color(0xFFB00020),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final activeFilter = _activeFilterDto;
              final featuredItems = <Map<String, dynamic>>[
                for (final category in _businessCodes)
                  ...provider.getBusinesses(category, filter: activeFilter).map((b) => <String, dynamic>{
                        'entityType': 'business',
                        'id': b.id,
                        'image': b.imageUrl,
                        'logo': b.imageUrl,
                        'title': b.name,
                        'name': b.name,
                        'category': b.category,
                        'rating': b.rating.toStringAsFixed(1),
                        'reviews': b.reviewCount.toString(),
                        'reviewCount': b.reviewCount,
                        'hasRating': b.rating > 0 || b.reviewCount > 0,
                        'location': b.location ?? '',
                        'isOpen': (b.openingTime?.isNotEmpty == true ||
                                b.closingTime?.isNotEmpty == true ||
                                b.operatingDays.isNotEmpty)
                            ? b.isOpen
                            : null,
                        'phone': b.phone,
                        'whatsapp': b.whatsapp,
                        'openingTime': b.openingTime,
                        'closingTime': b.closingTime,
                        'operatingDays': b.operatingDays,
                        'servicesOffered': b.servicesOffered,
                        'followersCount': b.followersCount,
                      }),
                for (final type in _amenityCodes)
                  ...provider.getAmenities(type, filter: activeFilter).map((a) => <String, dynamic>{
                        'entityType': 'amenity',
                        'id': a.id,
                        'image': a.imageUrl,
                        'logo': a.imageUrl,
                        'title': a.name,
                        'name': a.name,
                        'category': a.amenityType,
                        'rating': a.rating.toStringAsFixed(1),
                        'reviews': a.reviewCount.toString(),
                        'reviewCount': a.reviewCount,
                        'hasRating': a.rating > 0 || a.reviewCount > 0,
                        'location': a.location ?? '',
                        'isOpen': (a.openingTime?.isNotEmpty == true ||
                                a.closingTime?.isNotEmpty == true ||
                                a.operatingDays.isNotEmpty)
                            ? a.isOpen
                            : null,
                        'phone': a.phone,
                        'whatsapp': a.whatsapp,
                        'openingTime': a.openingTime,
                        'closingTime': a.closingTime,
                        'operatingDays': a.operatingDays,
                        'servicesOffered': a.servicesOffered,
                        'followersCount': a.followersCount,
                      }),
              ];

              if (featuredItems.isEmpty) {
                return SizedBox(
                  height: rh(166),
                  child: Center(
                    child: Text(
                      'No featured items',
                      style: TextStyle(
                        fontSize: rfs(14),
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: rh(166),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: rw(15)),
                  itemCount: featuredItems.length,
                  itemBuilder: (context, index) {
                    return _buildFeaturedCard(featuredItems[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> item) {
    // Figma: Hero Tab is 287x166
    return GestureDetector(
      onTap: () {
        final entityType = (item['entityType'] ?? 'business').toString().toLowerCase();
        final category = (item['category'] ?? '').toString().toUpperCase();

        if (entityType == 'business' && category == 'STORE') {
          Navigator.pushNamed(
            context,
            '/grocery-store',
            arguments: {
              'id': item['id']?.toString() ?? '',
              'name': item['name'] ?? item['title'] ?? '',
              'category': item['category'] ?? '',
              'rating': item['rating'] ?? '0.0',
              'reviewCount': item['reviewCount'] ?? item['reviews'] ?? 0,
              'reviews': item['reviews'] ?? '0',
              'location': item['location'] ?? '',
              'isOpen': item['isOpen'] == true,
              'openingTime': item['openingTime'],
              'closingTime': item['closingTime'],
              'operatingDays': item['operatingDays'] ?? const <String>[],
              'servicesOffered': item['servicesOffered'] ?? const <String>[],
              'followersCount': item['followersCount'] ?? 0,
              'image': item['image'],
              'logo': item['logo'] ?? item['image'],
              'phone': item['phone'],
              'whatsapp': item['whatsapp'],
            },
          );
          return;
        }

        final route = _routeForFeaturedItem(entityType, category);
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        width: rw(287),
        height: rh(166),
        margin: EdgeInsets.only(right: rw(15)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Image - 274x107
          Expanded(
            flex: 107,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(rw(12)),
                    topRight: Radius.circular(rw(12)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: buildProfileImage(
                      item['image'],
                      fallbackIcon: Icons.store,
                      iconSize: 40,
                    ),
                  ),
                ),

                // Heart icon - top right
                Positioned(
                  top: rh(8),
                  right: rw(8),
                  child: Consumer<FavoriteProvider>(
                    builder: (context, favProvider, _) {
                      final id = (item['id'] ?? '').toString();
                      final entityType = (item['entityType'] ?? 'business')
                          .toString()
                          .toLowerCase();
                      final isFav = entityType == 'amenity'
                          ? favProvider.isAmenityFavorited(id)
                          : favProvider.isBusinessFavorited(id);
                      return GestureDetector(
                        onTap: id.isEmpty
                            ? null
                            : () {
                                if (entityType == 'amenity') {
                                  favProvider.toggleAmenityFavorite(id);
                                } else {
                                  favProvider.toggleBusinessFavorite(id);
                                }
                              },
                        child: SizedBox(
                          width: rw(20),
                          height: rw(20),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? const Color(0xFFFF5050) : Colors.white,
                            size: rw(17),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Rating badge - top left
                if (item['hasRating'] == true)
                  Positioned(
                    top: rh(8),
                    left: rw(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(8),
                        vertical: rh(4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rw(15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: const Color(0xFFFFCD29),
                            size: rw(14),
                          ),
                          SizedBox(width: rw(4)),
                          Text(
                            item['rating'] ?? '',
                            style: GoogleFonts.roboto(
                              fontSize: rfs(12),
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          if ((item['reviews'] ?? '').toString().isNotEmpty) ...[
                            SizedBox(width: rw(4)),
                            Text(
                              '(${item['reviews']})',
                              style: GoogleFonts.inter(
                                fontSize: rfs(10),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Business Name section - 258x48
          Expanded(
            flex: 59,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rw(10),
                vertical: rh(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side - Name and location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Business name - Oswald 15px
                        Text(
                          item['title'],
                          style: GoogleFonts.oswald(
                            fontSize: rfs(15),
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: rh(2)),
                        // Location row
                        if ((item['location'] ?? '').toString().trim().isNotEmpty)
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/location_pin_featured.svg',
                                width: rw(12),
                                height: rw(12),
                                placeholderBuilder: (context) => Icon(
                                  Icons.location_on,
                                  size: rw(12),
                                  color: const Color(0xFF666666),
                                ),
                              ),
                              SizedBox(width: rw(4)),
                              Expanded(
                                child: Text(
                                  item['location'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: rfs(10),
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Right side - Open and Map buttons
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Open button
                      if (item['isOpen'] != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/open_door_icon.svg',
                              width: rw(16),
                              height: rw(16),
                              placeholderBuilder: (context) => Icon(
                                Icons.door_front_door_outlined,
                                size: rw(16),
                                color: (item['isOpen'] == true)
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFE53935),
                              ),
                            ),
                            SizedBox(width: rw(2)),
                            Text(
                              item['isOpen'] == true ? 'Open' : 'Closed',
                              style: GoogleFonts.oswald(
                                fontSize: rfs(11),
                                fontWeight: FontWeight.w400,
                                color: (item['isOpen'] == true)
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: rh(4)),
                      // Map button
                      GestureDetector(
                        onTap: () async {
                          final query = (item['location'] ?? item['title'] ?? '').toString().trim();
                          if (query.isEmpty) return;
                          await openMapForQuery(context, query);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/map_icon_featured.svg',
                              width: rw(16),
                              height: rw(16),
                              placeholderBuilder: (context) => Icon(
                                Icons.map_outlined,
                                size: rw(16),
                                color: const Color(0xFF4A4A4A),
                              ),
                            ),
                            SizedBox(width: rw(2)),
                            Text(
                              'Map',
                              style: GoogleFonts.oswald(
                                fontSize: rfs(11),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF4A4A4A),
                              ),
                            ),
                          ],
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
      ),
    );
  }

  String? _routeForFeaturedItem(String entityType, String category) {
    if (entityType == 'business') {
      switch (category) {
        case 'SOLAR':
          return '/solar';
        case 'BANK':
          return '/banks';
        case 'RESTAURANT':
          return '/restaurants';
        case 'REAL_ESTATE':
          return '/property';
        case 'HOME_CHEF':
          return '/home-chefs';
        case 'STORE':
          return '/stores';
      }
    } else if (entityType == 'amenity') {
      switch (category) {
        case 'MASJID':
          return '/mosques';
        case 'PARK':
          return '/parks';
        case 'GYM':
          return '/gyms';
        case 'HEALTHCARE':
          return '/healthcare';
        case 'SCHOOL':
          return '/schools';
        case 'PHARMACY':
          return '/pharmacies';
        case 'CAFE':
          return '/cafes';
        case 'ADMIN':
          return '/admin';
      }
    }
    return null;
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'store':
        return Icons.store;
      case 'solar':
        return Icons.solar_power;
      case 'bank':
        return Icons.account_balance;
      case 'restaurant':
        return Icons.restaurant;
      case 'real estate':
        return Icons.home_work;
      case 'home chef':
        return Icons.restaurant_menu;
      case 'masjid':
        return Icons.mosque;
      case 'park':
        return Icons.park;
      case 'gym':
        return Icons.fitness_center;
      case 'healthcare':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'cafe':
        return Icons.local_cafe;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.category;
    }
  }

  void _handleCategoryTap(String label) {
    final lower = label.toLowerCase();
    if (lower == 'healthcare') {
      Navigator.pushNamed(context, '/healthcare');
    } else if (lower == 'store') {
      Navigator.pushNamed(context, '/stores');
    } else if (lower == 'solar') {
      Navigator.pushNamed(context, '/solar');
    } else if (lower == 'bank') {
      Navigator.pushNamed(context, '/banks');
    } else if (lower == 'restaurant') {
      Navigator.pushNamed(context, '/restaurants');
    } else if (lower == 'home chef') {
      Navigator.pushNamed(context, '/home-chefs');
    } else if (lower == 'real estate') {
      Navigator.pushNamed(context, '/property');
    } else if (lower == 'park') {
      Navigator.pushNamed(context, '/parks');
    } else if (lower == 'masjid') {
      Navigator.pushNamed(context, '/mosques');
    } else if (lower == 'gym') {
      Navigator.pushNamed(context, '/gyms');
    } else if (lower == 'school') {
      Navigator.pushNamed(context, '/schools');
    } else if (lower == 'pharmacy') {
      Navigator.pushNamed(context, '/pharmacies');
    } else if (lower == 'cafe') {
      Navigator.pushNamed(context, '/cafes');
    } else if (lower == 'admin') {
      Navigator.pushNamed(context, '/admin');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label coming soon!'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF007A8E),
        ),
      );
    }
  }

  void _handleFooterNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/all-services');
        break;
      case 2:
        debugPrint('Scan tapped');
        break;
      case 3:
        debugPrint('Call tapped');
        break;
      case 4:
        debugPrint('Profile tapped');
        break;
    }
  }



}

