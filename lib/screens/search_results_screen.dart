import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/filter_dto.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/search_provider.dart';
import '../utils/map_utils.dart';
import '../widgets/profile_image.dart';
import 'grocery_store_screen.dart';
import 'service_provider_detail_screen.dart';
import 'cafe_detail_screen.dart';
import 'gym_detail_screen.dart';
import 'healthcare_detail_screen.dart';
import 'park_detail_screen.dart';
import 'pharmacy_detail_screen.dart';
import 'school_detail_screen.dart';
import 'mosque_detail_screen.dart';
import 'property_screen.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/figma_filter_sheet.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  final Map<String, String>? initialFilterQueryParams;

  const SearchResultsScreen({
    super.key,
    required this.query,
    this.initialFilterQueryParams,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with ResponsiveMixin {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = '';
  String _selectedLocationFilter = 'Area';
  String _selectedCategoryFilter = 'Service';
  String _selectedPriceFilter = 'Rs';

  FilterDto _buildFilterDto() {
    String? locationMode;
    String? sortBy;
    String? priceTier;
    String? category;
    double? minRating;

    if (_selectedLocationFilter == 'Distance') {
      locationMode = 'DISTANCE';
      sortBy = 'NEAR_ME';
    } else if (_selectedLocationFilter == 'Block') {
      locationMode = 'BLOCK';
    } else {
      locationMode = 'AREA';
    }

    if (_selectedPriceFilter == 'Rs+') priceTier = 'RS_PLUS';
    if (_selectedPriceFilter == 'Rs++') {
      priceTier = 'RS_PLUS_PLUS';
      minRating = 4.0;
    }

    if (_selectedCategoryFilter == 'Service') category = 'Service';
    if (_selectedCategoryFilter == 'Type' || _selectedCategoryFilter == 'Brand') {
      category = 'Shop';
    }

    final active = _activeFilter.toLowerCase().trim();
    if (active == 'near me') {
      sortBy = 'NEAR_ME';
      locationMode = 'DISTANCE';
    } else if (active == 'featured') {
      sortBy = 'FEATURED';
    } else if (active == 'rating 4.0+') {
      minRating = 4.0;
    }

    return FilterDto(
      category: category,
      locationMode: locationMode,
      priceTier: priceTier,
      sortBy: sortBy,
      minRating: minRating,
      latitude: Provider.of<AuthProvider>(context, listen: false).user?.locationLat,
      longitude: Provider.of<AuthProvider>(context, listen: false).user?.locationLng,
    );
  }

  Future<void> _reloadSearch() async {
    await Provider.of<SearchProvider>(context, listen: false).search(
      _searchController.text.trim(),
      filter: _buildFilterDto(),
    );
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

      if (selection.location == 'Distance') {
        _activeFilter = 'near me';
      } else if (selection.category == 'Type') {
        _activeFilter = 'featured';
      } else if (selection.category == 'Brand') {
        _activeFilter = 'delivery';
      } else if (selection.price == 'Rs++') {
        _activeFilter = 'Rating 4.0+';
      } else {
        _activeFilter = '';
      }
    });
    await _reloadSearch();
  }

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    final seed = widget.initialFilterQueryParams ?? const <String, String>{};
    if (seed['locationMode'] == 'DISTANCE') _selectedLocationFilter = 'Distance';
    if (seed['locationMode'] == 'BLOCK') _selectedLocationFilter = 'Block';
    if (seed['priceTier'] == 'RS_PLUS') _selectedPriceFilter = 'Rs+';
    if (seed['priceTier'] == 'RS_PLUS_PLUS') _selectedPriceFilter = 'Rs++';
    if (seed['category'] == 'Shop') _selectedCategoryFilter = 'Type';
    if (seed['sortBy'] == 'NEAR_ME') _activeFilter = 'near me';
    if (seed['sortBy'] == 'FEATURED') _activeFilter = 'featured';
    if (seed['minRating'] == '4' || seed['minRating'] == '4.0') {
      _activeFilter = 'Rating 4.0+';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoriteProvider>(context, listen: false).hydrateFavorites();
      _reloadSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header Section
              _buildHeader(),
              SizedBox(height: rw(15)),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Search Bar Section (moved out of header)
                      _buildSearchBar(),
                      
                      // Filter Tags Section
                      _buildFilterTags(),

                      SizedBox(height: rw(15)),

                      // Results Section
                      _buildResultsSection(),

                      // Add bottom padding to account for footer
                      SizedBox(height: rh(140)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Decorative yellow search icon - same as search_screen.dart
          Positioned(
            left: 0,
            right: 0,
            top: rh(110),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/search_icon.svg',
                width: rw(35),
                height: rw(35),
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFFC107), // Yellow color
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Footer
      bottomSheet: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = rw(15);

    return Container(
      width: screenWidth,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2), // Light grey background
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(rw(30)),
          bottomRight: Radius.circular(rw(30)),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + rw(25),
        left: padding,
        right: padding,
        bottom: rw(30),
      ),
      child: Stack(
        children: [
          // Back button - top left
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: rw(35),
                height: rw(35),
                decoration: const BoxDecoration(
                  color: Color(0xFF3195AB), // Green/Teal background
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/back_arrow.svg',
                    width: rw(18),
                    height: rw(18),
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Title - centered
          Center(
            child: Text(
              'Search',
              style: GoogleFonts.inter(
                fontSize: rfs(28),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333), // Dark grey
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rw(15),
        vertical: rw(20),
      ),
      child: TextFormField(
        controller: _searchController,
        onFieldSubmitted: (value) {
          if (value.isNotEmpty) {
            // Check if searching for specific service
            final query = value.toLowerCase().trim();
            if (query == 'property' || query.contains('property') ||
                query == 'real estate' || query.contains('real estate')) {
              Navigator.pushNamed(context, '/property');
            } else if (query == 'electrician' || query.contains('electrician')) {
              Navigator.pushNamed(context, '/electricians');
            } else {
              // Trigger search via provider
              _reloadSearch();
            }
          }
        },
        style: GoogleFonts.inter(
          fontSize: rfs(14),
          fontWeight: FontWeight.w400,
          color: const Color(0xFF333333),
        ),
        decoration: InputDecoration(
          hintText: 'Search for the nearest shops or services',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: GestureDetector(
            onTap: _openFilterSheet,
            child: const Icon(Icons.tune),
          ),
          filled: true,
          fillColor: const Color(0xFFF4F4F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(50)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(50)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(50)),
            borderSide: BorderSide.none,
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: rfs(14),
            fontWeight: FontWeight.w400,
            color: const Color(0xFF898989),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTags() {
    final tags = ['near me', 'featured', 'delivery', 'Rating 4.0+'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: rw(15)),
      child: SizedBox(
        height: rh(50),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: tags.length,
          separatorBuilder: (context, index) => SizedBox(width: rw(10)),
          itemBuilder: (context, index) {
            final isActive = _activeFilter == tags[index];
            return Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activeFilter = _activeFilter == tags[index] ? '' : tags[index];
                  });
                  _reloadSearch();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(12),
                    vertical: rw(8),
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF3195AB) : Colors.white,
                    border: Border.all(color: const Color(0xFFE1E1E1), width: 1),
                    borderRadius: BorderRadius.circular(rw(100)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    tags[index],
                    style: GoogleFonts.inter(
                      fontSize: rfs(12),
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF302F34),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(
                vertical: rw(60)),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Collect all result items from the different categories
        final List<Map<String, dynamic>> allResults = [];
        final results = provider.searchResults;

        if (results != null) {
          if (results['businesses'] is List) {
            for (final item in results['businesses']) {
              final map = Map<String, dynamic>.from(item);
              map['_entityType'] = 'business';
              allResults.add(map);
            }
          }
          if (results['serviceProviders'] is List) {
            for (final item in results['serviceProviders']) {
              final map = Map<String, dynamic>.from(item);
              map['_entityType'] = 'serviceProvider';
              allResults.add(map);
            }
          }
          if (results['amenities'] is List) {
            for (final item in results['amenities']) {
              final map = Map<String, dynamic>.from(item);
              map['_entityType'] = 'amenity';
              allResults.add(map);
            }
          }
        }

        final filteredResults = allResults;

        if (filteredResults.isEmpty && !provider.isLoading) {
          return _buildEmptyResults();
        }

        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: rw(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Results count
              Text(
                '${filteredResults.length} result${filteredResults.length == 1 ? '' : 's'} for "${_searchController.text}"',
                style: GoogleFonts.inter(
                  fontSize: rfs(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2F2F34),
                ),
              ),
              SizedBox(height: rw(30)),
              // Result cards from API data
              ...filteredResults.map((item) {
                final openStatus = _openStatusLabel(item['isOpen']);
                return Column(
                  children: [
                    _buildResultCard(
                      imageUrl: item['imageUrl'] as String?,
                      businessName:
                          (item['name'] as String?) ?? 'Unknown',
                      rating:
                          (item['rating']?.toString()) ?? '0.0',
                      reviewCount:
                          (item['reviewCount']?.toString()) ?? '0',
                      distance: item['distance'] as String? ?? '',
                      openStatus: openStatus,
                      rawItem: item,
                    ),
                    SizedBox(height: rw(30)),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyResults() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: rw(60),
          horizontal: rw(15)),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off,
                size: rw(60),
                color: const Color(0xFF898989)),
            SizedBox(height: rw(15)),
            Text(
              'No results found for "${_searchController.text}"',
              style: GoogleFonts.inter(
                fontSize: rfs(16),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF898989),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({
    String? imageUrl,
    required String businessName,
    required String rating,
    required String reviewCount,
    required String distance,
    required String openStatus,
    required Map<String, dynamic> rawItem,
  }) {
    return GestureDetector(
      onTap: () {
        _navigateToDetail(rawItem);
      },
      child: Container(
      padding: EdgeInsets.all(rw(3)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(rw(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Store Image with heart and rating
          Container(
            width: double.infinity,
            height: rh(139),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0), // Placeholder color
              borderRadius: BorderRadius.circular(rw(20)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(rw(20)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  buildProfileImage(
                    imageUrl,
                    fallbackIcon: Icons.store,
                    iconSize: 50,
                  ),
                  // Rating badge
                  Positioned(
                    top: rw(8),
                    left: rw(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(5),
                        vertical: rw(5),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rw(14)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: const Color(0xFFFFCD29),
                            size: rw(14),
                          ),
                          SizedBox(width: rw(2)),
                          Text(
                            rating,
                            style: GoogleFonts.roboto(
                              fontSize: rfs(12),
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: rw(2)),
                          Text(
                            '($reviewCount)',
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
                  // Heart icon - on top of image, no background container
                  Positioned(
                    top: rw(8),
                    right: rw(8),
                    child: Consumer<FavoriteProvider>(
                      builder: (context, favProvider, _) {
                        final id = (rawItem['id'] ?? '').toString();
                        final entityType =
                            (rawItem['_entityType'] ?? 'business').toString();
                        final isFav = entityType == 'serviceProvider'
                            ? favProvider.isServiceProviderFavorited(id)
                            : entityType == 'amenity'
                                ? favProvider.isAmenityFavorited(id)
                                : favProvider.isBusinessFavorited(id);
                        final isPending = favProvider.isPending(id);
                        return GestureDetector(
                          onTap: id.isEmpty || isPending
                              ? null
                              : () {
                                  if (entityType == 'serviceProvider') {
                                    favProvider.toggleServiceProviderFavorite(id);
                                  } else if (entityType == 'amenity') {
                                    favProvider.toggleAmenityFavorite(id);
                                  } else {
                                    favProvider.toggleBusinessFavorite(id);
                                  }
                                },
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: rw(24),
                            color: isFav ? const Color(0xFFFF5050) : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Business details
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rw(10),
              vertical: rw(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Business info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business name
                      Text(
                        businessName,
                        style: GoogleFonts.oswald(
                          fontSize: rfs(15),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: rw(5)),

                      // Distance
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: const Color(0xFFFF0000),
                            size: rw(17),
                          ),
                          SizedBox(width: rw(5)),
                          Text(
                            distance,
                            style: GoogleFonts.inter(
                              fontSize: rfs(12),
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right side - Action buttons
                Column(
                  children: [
                    // Open status
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/mingcute_open-door-line.svg',
                          width: rw(24),
                          height: rw(24),
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF474747),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: rw(1)),
                        Text(
                          openStatus,
                          style: GoogleFonts.oswald(
                            fontSize: rfs(11),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF073A6A),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: rw(5)),

                    // Map button
                    GestureDetector(
                      onTap: () async {
                        final query = businessName;
                        await openMapForQuery(context, query);
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/map1133.svg',
                            width: rw(18), // Reduced size
                            height: rw(18), // Reduced size
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF6A6A6A),
                              BlendMode.srcIn,
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

  String _openStatusLabel(dynamic isOpen) {
    if (isOpen == true) return 'Open';
    if (isOpen == false) return 'Closed';
    return '';
  }

  void _navigateToDetail(Map<String, dynamic> item) {
    final id = item['id']?.toString();
    final name = (item['name'] as String?) ?? 'Unknown';
    final rating = (item['rating']?.toString()) ?? '0.0';
    final reviewCount = (item['reviewCount']?.toString()) ?? '0';
    final location = item['location']?.toString() ?? '';
    final isOpen = item['isOpen'] == true;
    final image = item['imageUrl'];
    final phone = item['phone'];
    final category = (item['category']?.toString() ?? '').trim().toUpperCase();
    final isRealEstate = category == 'REAL_ESTATE' || category == 'REAL ESTATE';

    if (item['serviceType'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceProviderDetailScreen(
            providerId: id,
            providerName: name,
            serviceType: item['serviceType']?.toString(),
          ),
        ),
      );
      return;
    }

    if (item['amenityType'] != null) {
      final data = {
        'id': id,
        'name': name,
        'rating': rating,
        'reviews': reviewCount,
        'location': location,
        'isOpen': isOpen,
        'image': image,
      };
      final type = item['amenityType']?.toString();
      Widget screen;
      switch (type) {
        case 'CAFE':
          screen = CafeDetailScreen(cafeData: data);
          break;
        case 'GYM':
          screen = GymDetailScreen(gymData: data);
          break;
        case 'HEALTHCARE':
          screen = HealthcareDetailScreen(healthcareData: data);
          break;
        case 'PARK':
          screen = ParkDetailScreen(parkData: data);
          break;
        case 'PHARMACY':
          screen = PharmacyDetailScreen(pharmacyData: data);
          break;
        case 'SCHOOL':
          screen = SchoolDetailScreen(schoolData: data);
          break;
        case 'MASJID':
          screen = MosqueDetailScreen(mosqueData: data);
          break;
        default:
          screen = GroceryStoreScreen(storeData: data);
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      return;
    }

    // Default to business detail
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isRealEstate
            ? PropertyScreen(
                partnerId: item['partnerId']?.toString() ??
                    item['partner']?['id']?.toString() ??
                    id,
              )
            : GroceryStoreScreen(
                storeData: {
                  'id': id,
                  'name': name,
                  'category': item['category']?.toString() ?? '',
                  'rating': rating,
                  'reviewCount': reviewCount,
                  'location': location,
                  'isOpen': isOpen,
                  'image': image,
                  'phone': phone,
                },
              ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 129,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6F7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 31, bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', false),
            _buildNavItem(Icons.search, 'Search', true),
            _buildScanNavItem(),
            _buildNavItem(Icons.phone, 'Call', false),
            _buildNavItem(Icons.person_outline, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: isActive ? const Color(0xFF3195AB) : const Color(0xFF484C52),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w400,
            color: isActive ? const Color(0xFF3195AB) : const Color(0xFF484C52),
          ),
        ),
      ],
    );
  }

  Widget _buildScanNavItem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF02A6C3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }
}


