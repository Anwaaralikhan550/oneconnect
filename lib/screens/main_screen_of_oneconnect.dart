import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/search_provider.dart';
import '../providers/promotion_provider.dart';
import '../providers/favorite_provider.dart';
import '../models/filter_dto.dart';
import '../utils/map_utils.dart';
import '../widgets/side_menu_controller.dart';
import '../widgets/sticky_footer.dart';
import '../widgets/profile_image.dart';
import '../utils/profile_image_picker.dart';
import '../utils/media_url.dart';
import 'service_provider_detail_screen.dart';
import 'location_picker_screen.dart';
import '../widgets/figma_filter_sheet.dart';

class MainScreenOfOneConnect extends StatefulWidget {
  const MainScreenOfOneConnect({super.key});

  @override
  State<MainScreenOfOneConnect> createState() => _MainScreenOfOneConnectState();
}

class _MainScreenOfOneConnectState extends State<MainScreenOfOneConnect>
    with TickerProviderStateMixin {
  final SideMenuController _sideMenuController = SideMenuController();
  File? _profileImage;
  String _selectedFilter = 'featured';
  Position? _currentPosition;
  String _selectedLocationLabel = 'Current Location';
  double? _selectedLocationLat;
  double? _selectedLocationLng;
  String _selectedSearchLocationFilter = 'Area';
  String _selectedSearchCategoryFilter = 'Service';
  String _selectedSearchPriceFilter = 'Rs';
  bool _showAllCustomerReviews = false;

  FilterDto _activeSearchFilterDto() {
    String? sortBy;
    String? locationMode;
    if (_selectedFilter == 'Near You') {
      sortBy = 'NEAR_ME';
      locationMode = 'DISTANCE';
    } else if (_selectedFilter == 'Newly Opened') {
      sortBy = 'NEWLY_OPENED';
      locationMode = 'AREA';
    } else {
      sortBy = 'FEATURED';
      locationMode = _selectedSearchLocationFilter == 'Distance'
          ? 'DISTANCE'
          : (_selectedSearchLocationFilter == 'Block' ? 'BLOCK' : 'AREA');
    }

    return FilterDto(
      category: _selectedSearchCategoryFilter == 'Service'
          ? 'Service'
          : (_selectedSearchCategoryFilter == 'Type' ||
                  _selectedSearchCategoryFilter == 'Brand'
              ? 'Shop'
              : null),
      locationMode: locationMode,
      priceTier: _selectedSearchPriceFilter == 'Rs++'
          ? 'RS_PLUS_PLUS'
          : (_selectedSearchPriceFilter == 'Rs+' ? 'RS_PLUS' : 'RS'),
      minRating: _selectedSearchPriceFilter == 'Rs++'
          ? 4.0
          : (_selectedSearchPriceFilter == 'Rs+' ? 3.5 : null),
      sortBy: sortBy,
      latitude: _selectedLocationLat,
      longitude: _selectedLocationLng,
    );
  }

  @override
  void initState() {
    super.initState();
    _sideMenuController.initialize(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      searchProvider.fetchPopular(force: true, filter: _activeSearchFilterDto());
      Provider.of<PromotionProvider>(context, listen: false).fetchPromotions();
      Provider.of<FavoriteProvider>(context, listen: false).hydrateFavorites();
      authProvider.fetchProfile().whenComplete(_initializeLocationContext);
    });
  }

  Future<void> _updateProfileImage() async {
    final File? image = await ProfileImagePicker.showImageSourceDialog(context);
    if (image == null) return;

    setState(() {
      _profileImage = image;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uploadedUrl = await auth.uploadProfilePhoto(image.path);
    if (!mounted) return;

    if (uploadedUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Profile photo upload failed')),
      );
    }
  }

  @override
  void dispose() {
    _sideMenuController.dispose();
    super.dispose();
  }

  List<BoxShadow> _softCardShadow(
    double scale, {
    double opacity = 0.08,
    double blur = 10,
    double spread = 0,
    double yOffset = 2,
  }) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: blur * scale,
        spreadRadius: spread * scale,
        offset: Offset(0, yOffset * scale),
      ),
    ];
  }

  Future<void> _initializeLocationContext() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final cachedLat = auth.user?.locationLat;
      final cachedLng = auth.user?.locationLng;
      if (cachedLat != null && cachedLng != null) {
        _currentPosition = Position(
          longitude: cachedLng,
          latitude: cachedLat,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        if (mounted) {
          setState(() {
            _selectedLocationLabel = 'Current Location';
            _selectedLocationLat = cachedLat;
            _selectedLocationLng = cachedLng;
          });
        }
        return;
      }

      if (!await Geolocator.isLocationServiceEnabled()) return;
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = pos;
        _selectedLocationLabel = 'Current Location';
        _selectedLocationLat = pos.latitude;
        _selectedLocationLng = pos.longitude;
      });
    } catch (_) {
      // Keep UI stable if location is unavailable.
    }
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  double? _extractLatitude(Map<String, dynamic> item) {
    final direct = _asDouble(item['latitude']) ??
        _asDouble(item['lat']) ??
        _asDouble(item['locationLat']);
    if (direct != null) return direct;

    final location = item['location'];
    if (location is Map<String, dynamic>) {
      final nested = _asDouble(location['latitude']) ??
          _asDouble(location['lat']) ??
          _asDouble(location['locationLat']);
      if (nested != null) return nested;
    }

    final coordinates = item['coordinates'] ??
        item['locationCoordinates'] ??
        (location is Map<String, dynamic> ? location['coordinates'] : null);
    if (coordinates is List && coordinates.length >= 2) {
      return _asDouble(coordinates[1]);
    }
    return null;
  }

  double? _extractLongitude(Map<String, dynamic> item) {
    final direct = _asDouble(item['longitude']) ??
        _asDouble(item['lng']) ??
        _asDouble(item['locationLng']);
    if (direct != null) return direct;

    final location = item['location'];
    if (location is Map<String, dynamic>) {
      final nested = _asDouble(location['longitude']) ??
          _asDouble(location['lng']) ??
          _asDouble(location['locationLng']);
      if (nested != null) return nested;
    }

    final coordinates = item['coordinates'] ??
        item['locationCoordinates'] ??
        (location is Map<String, dynamic> ? location['coordinates'] : null);
    if (coordinates is List && coordinates.length >= 2) {
      return _asDouble(coordinates[0]);
    }
    return null;
  }

  String _formatDistanceKm(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.toStringAsFixed(0)} km';
  }

  double? _distanceKmFromUser(Map<String, dynamic> item) {
    final pos = _currentPosition;
    if (pos == null) return null;
    final lat = _extractLatitude(item);
    final lng = _extractLongitude(item);
    if (lat == null || lng == null) return null;

    final meters = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      lat,
      lng,
    );
    if (!meters.isFinite || meters.isNaN) return null;
    return meters / 1000;
  }

  String _distanceLabelForItem(Map<String, dynamic> item) {
    final computedKm = _distanceKmFromUser(item);
    if (computedKm != null) return _formatDistanceKm(computedKm);

    final raw = item['distance'] ?? item['distanceKm'];
    if (raw == null) return '';
    if (raw is num) return _formatDistanceKm(raw.toDouble());
    final rawText = raw.toString().trim();
    if (rawText.isEmpty) return '';
    final parsed = double.tryParse(rawText);
    if (parsed != null) return _formatDistanceKm(parsed);
    return rawText;
  }

  String _imageUrlForItem(Map<String, dynamic> item) {
    final direct = (item['imageUrl'] ?? item['mainImageUrl'] ?? '').toString().trim();
    if (direct.isNotEmpty) return direct;

    final imageUrls = item['imageUrls'];
    if (imageUrls is List) {
      for (final image in imageUrls) {
        final value = image?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    }

    final media = item['media'];
    if (media is List) {
      for (final entry in media.whereType<Map>()) {
        final map = Map<String, dynamic>.from(entry);
        final value = (map['fileUrl'] ?? map['imageUrl'] ?? '').toString().trim();
        if (value.isNotEmpty) return value;
      }
    }

    return '';
  }

  ImageProvider _resolveImageProvider(
    String? image, {
    required String fallbackAsset,
  }) {
    final value = (resolveMediaUrl(image) ?? '').trim();
    if (value.startsWith('http')) return NetworkImage(value);
    if (value.startsWith('assets/')) return AssetImage(value);
    return AssetImage(fallbackAsset);
  }

  String _categoryName(dynamic category) {
    if (category is Map<String, dynamic>) {
      return (category['name'] ?? '').toString();
    }
    return (category ?? '').toString();
  }

  String _mapQueryForItem(Map<String, dynamic> item, {String fallback = ''}) {
    final location = (item['location'] ?? item['address'] ?? item['city'] ?? '').toString().trim();
    if (location.isNotEmpty) return location;

    final lat = _extractLatitude(item);
    final lng = _extractLongitude(item);
    if (lat != null && lng != null) return '$lat,$lng';
    return fallback;
  }

  List<Map<String, dynamic>> _normalizeItems(List? raw) {
    if (raw == null) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  List<Map<String, String>> _normalizeReviewItems(List? raw) {
    if (raw == null) return const [];
    return raw
        .whereType<Map>()
        .map((source) => Map<String, dynamic>.from(source))
        .map((review) {
          final ratingValue = _asDouble(review['rating']) ?? 0;
          final createdAtRaw = (review['createdAt'] ?? '').toString().trim();
          final createdAt = DateTime.tryParse(createdAtRaw);
          final dateLabel = createdAt != null
              ? '${createdAt.toLocal().day}/${createdAt.toLocal().month}/${createdAt.toLocal().year}'
              : createdAtRaw;
          return <String, String>{
            'name': (review['name'] ?? 'Anonymous').toString(),
            'productName': (review['productName'] ?? 'Service').toString(),
            'rating': ratingValue.toStringAsFixed(1),
            'ratingText': (review['ratingText'] ?? '').toString(),
            'review': (review['review'] ?? '').toString(),
            'dateTime': dateLabel,
            'productImage': (review['productImage'] ?? '').toString(),
            'profileImage': (review['profileImage'] ?? '').toString(),
          };
        })
        .where((review) => review['review']!.trim().isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    // Responsive scaling based on design width (390px is common mobile design)
    final designWidth = 390.0;
    final scale = screenWidth / designWidth;
    
    // Clamp scale between 0.8 and 1.2 for very small/large screens
    final responsiveScale = scale.clamp(0.8, 1.2);
    
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Container(
            width: double.infinity,
            color: const Color(0xFF00879F),
            child: Column(
              children: [
                // Main Screen Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFFFFFFF),
                    child: Stack(
                      children: [
                        // Main scrollable content
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              // Header Section (Frame 214)
                              _buildHeaderSection(responsiveScale),

                              SizedBox(height: 15 * responsiveScale),

                              // Category Icons (Navigation Tab)
                              _buildCategoryIcons(responsiveScale),

                              SizedBox(height: 15 * responsiveScale),

                              // Main Content Frame
                              _buildMainContentFrame(responsiveScale),

                              // Add bottom padding for footer
                              SizedBox(height: 140 * responsiveScale),
                            ],
                          ),
                        ),

                        // Footer positioned absolute at bottom
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: const StickyFooter(selectedIndex: 0), // Home is selected
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Side menu overlay
          _sideMenuController.buildSideMenuOverlay(() => setState(() {})),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(double scale) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        return Container(
          width: screenWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(75 * scale),
              bottomRight: Radius.circular(75 * scale),
            ),
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 2.0,
              colors: [
                Color(0xFF5DE0E6),
                Color(0xFF054870),
              ],
              stops: [0.0, 0.55],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + (8 * scale)),
              
              // Top Icon Row (Menu button and Notification/Settings)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Menu button (hamburger)
                    _sideMenuController.buildMenuButton(() => setState(() {})),

                    // Notification and Settings icons
                    _buildTopRightIcons(scale),
                  ],
                ),
              ),
              
              SizedBox(height: 15 * scale),
              
              // Middle section with name and profile
              Padding(
                padding: EdgeInsets.fromLTRB(25 * scale, 0, 15 * scale, 0),
                child: Row(
                  children: [
                    // Name and logo section
                    Expanded(
                      child: _buildMiddleContent(scale),
                    ),

                    // Profile image
                    _buildProfileSection(scale),
                  ],
                ),
              ),
              
              SizedBox(height: 15 * scale),
              
              // Geo Location section
              _buildGeoLocationSection(scale),
              
              SizedBox(height: 15 * scale),
              
        
            ],
          ),
        );
      },
    );
  }


  Widget _buildTopRightIcons(double scale) {
    return SizedBox(
      width: 60 * scale,
      height: 24 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Notification icon with yellow color
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/notification');
            },
            child: SizedBox(
              width: 24 * scale,
              height: 24 * scale,
              child: SvgPicture.asset(
                'assets/images/NotificationIcon.svg',
                width: 24 * scale,
                height: 24 * scale,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFFD700),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          // Settings icon (exact Figma)
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
            child: SizedBox(
              width: 24 * scale,
              height: 24 * scale,
              child: SvgPicture.asset(
                'assets/images/settings_icon.svg',
                width: 24 * scale,
                height: 24 * scale,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleContent(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User name
        Text(
          Provider.of<AuthProvider>(context).user?.name ?? 'Welcome',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 20 * scale,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        SizedBox(height: 10 * scale),
        // OneConnect logo (no shadow)
        Image.asset(
          'assets/images/oneconnect_logo_header.png',
          width: 155 * scale,
          height: 34 * scale,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              'OneConnect',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 28 * scale,
                color: Colors.white,
                letterSpacing: 1.2 * scale,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileSection(double scale) {
    return GestureDetector(
      onTap: _updateProfileImage,
      child: SizedBox(
        width: 70 * scale,
        height: 70 * scale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF044870),
              width: 2 * scale,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(2 * scale),
            child: ClipOval(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: ColoredBox(
                color: Colors.white,
                child: _profileImage != null
                    ? Image.file(_profileImage!, fit: BoxFit.cover)
                    : buildProfileImage(
                        Provider.of<AuthProvider>(context).user?.profilePhotoUrl,
                        fallbackIcon: Icons.person,
                        iconSize: 35,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeoLocationSection(double scale) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<LocationPickResult>(
          context,
          MaterialPageRoute(
            builder: (_) => LocationPickerScreen(
              initialLatitude: _selectedLocationLat ?? _currentPosition?.latitude,
              initialLongitude: _selectedLocationLng ?? _currentPosition?.longitude,
              initialLabel: _selectedLocationLabel,
            ),
          ),
        );

        if (result != null && mounted) {
          setState(() {
            _selectedLocationLabel = result.label;
            _selectedLocationLat = result.latitude;
            _selectedLocationLng = result.longitude;
            _currentPosition = Position(
              longitude: result.longitude,
              latitude: result.latitude,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            );
          });
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pin location icon (no background)
          SvgPicture.asset(
            'assets/icons/Vector.svg',
            width: 16 * scale,
            height: 16 * scale,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
            placeholderBuilder: (_) => Icon(
              Icons.location_on,
              color: Colors.white,
              size: 16 * scale,
            ),
          ),
          SizedBox(width: 2 * scale),
          // Address text
          SizedBox(
            width: 170 * scale,
            child: Text(
              _selectedLocationLabel,
              style: TextStyle(
                fontFamily: 'Roboto Condensed',
                fontWeight: FontWeight.w700,
                fontSize: 13 * scale,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 2 * scale),
          // Chevron down (no background)
          Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 16 * scale,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/search');
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 25,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search for the nearest shops or services',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, height: 22, color: const Color(0xFFE3E3E3)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _openSearchFilterSheet,
              child: Icon(Icons.tune, size: 20, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSearchFilterSheet() async {
    final selection = await showFigmaFilterSheet(
      context,
      selectedLocation: _selectedSearchLocationFilter,
      selectedCategory: _selectedSearchCategoryFilter,
      selectedPrice: _selectedSearchPriceFilter,
    );
    if (selection == null || !mounted) return;
    setState(() {
      _selectedSearchLocationFilter = selection.location;
      _selectedSearchCategoryFilter = selection.category;
      _selectedSearchPriceFilter = selection.price;
      if (selection.location == 'Distance') {
        _selectedFilter = 'Near You';
      } else if (selection.category == 'Type') {
        _selectedFilter = 'Newly Opened';
      } else {
        _selectedFilter = 'featured';
      }
    });
    await Provider.of<SearchProvider>(context, listen: false)
        .fetchPopular(force: true, filter: _activeSearchFilterDto());
  }

  Widget _buildCategoryIcons(double scale) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCategoryTab('assets/images/store_icon.svg', 'Store', true, scale),
          _buildCategoryTab('assets/images/mosque_icon.svg', 'Mosque', false, scale),
          _buildCategoryTab('assets/images/park_icon.svg', 'Park', false, scale),
          _buildCategoryTab('assets/images/education_icon.svg', 'Education', false, scale),
          _buildCategoryTab('assets/images/restaurant_icon.svg', 'Restaurant', false, scale),
          _buildMoreArrowButton(scale),
        ],
      ),
    );
  }

  void _navigateToCategory(String label) {
    String route;
    switch (label.toLowerCase()) {
      case 'store':
        route = '/stores';
        break;
      case 'mosque':
        route = '/mosques';
        break;
      case 'park':
        route = '/parks';
        break;
      case 'education':
        route = '/schools';
        break;
      case 'restaurant':
        route = '/restaurants';
        break;
      default:
        route = '/businesses-hub';
    }
    Navigator.pushNamed(context, route);
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
    }

    if (entityType == 'amenity') {
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

  void _openFeaturedItem(Map<String, dynamic> card) {
    final entityType = (card['entityType'] ?? '').toString().toLowerCase();
    final category = (card['category'] ?? '').toString().toUpperCase();

    if (entityType == 'service') {
      final serviceType = (card['serviceType'] ?? '').toString();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceProviderDetailScreen(
            providerName: (card['title'] ?? '').toString(),
            serviceType: serviceType,
            specialty: (card['specialty'] ?? '').toString().isEmpty
                ? null
                : (card['specialty'] ?? '').toString(),
            providerId: (card['id'] ?? '').toString(),
          ),
        ),
      );
      return;
    }

    if (entityType == 'business' && category == 'STORE') {
      Navigator.pushNamed(
        context,
        '/grocery-store',
        arguments: {
          'name': card['title'],
          'category': card['category'] ?? 'STORE',
          'rating': card['rating'],
          'reviewCount': card['reviewCount'] ?? 0,
          'id': card['id'],
          'image': card['image'],
          'logo': 'assets/images/grocery_store/store_logo.png',
        },
      );
      return;
    }

    final route = _routeForFeaturedItem(entityType, category);
    if (route != null) {
      Navigator.pushNamed(context, route);
      return;
    }

    Navigator.pushNamed(context, '/businesses-hub');
  }

  void _openFollowCard(dynamic card) {
    final entityType = card.entityType.toString().toLowerCase();
    if (entityType == 'service') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceProviderDetailScreen(
            providerName: card.name.toString(),
            serviceType: card.subtitle.toString(),
            providerId: card.id.toString(),
          ),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/grocery-store',
      arguments: {
        'id': card.id,
        'name': card.name,
        'category': card.subtitle,
        'location': card.location,
        'image': card.imageUrl,
      },
    );
  }

  Widget _buildMoreArrowButton(double scale) {
    return _TapAnimatedArrow(
      scale: scale,
      onTap: () {
        Navigator.pushNamed(context, '/businesses-hub');
      },
    );
  }

  Widget _buildCategoryTab(String iconPath, String label, bool isActive, double scale) {
    return GestureDetector(
      onTap: () {
        _navigateToCategory(label);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 26 * scale,
            height: 23 * scale,
            child: SvgPicture.asset(
              iconPath,
              width: 26 * scale,
              height: 23 * scale,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(isActive ? const Color(0xFF0097B2) : const Color(0xFF474747), BlendMode.srcIn),
            ),
          ),
          SizedBox(height: 5 * scale),
          Text(
            label,
            style: GoogleFonts.josefinSans(
              fontWeight: FontWeight.w700,
              fontSize: 10 * scale,
              color: const Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentFrame(double scale) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Selection Tab
            _buildSelectionTab(scale),
            
            SizedBox(height: 10 * scale),
            
            // Featured Tab
            _buildFeaturedTab(scale),
            
            SizedBox(height: 10 * scale),
            
            // Promotion Tab
            _buildPromotionTab(scale),
            
            SizedBox(height: 10 * scale),
            
            // Follow Us Section
            _buildFollowUsSection(scale),
            
            SizedBox(height: 10 * scale),
            
            // Eateries Section
            _buildEateriesSection(scale),
            
            SizedBox(height: 10 * scale),
            
            // Best Service Provider Section
            _buildBestServiceProviderSection(scale),
            
            SizedBox(height: 10 * scale),
            
            // Doctors Frame
            _buildDoctorsFrame(scale),
            
            SizedBox(height: 10 * scale),
            
            // Reviews Section
            _buildReviewsSection(scale),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionTab(double scale) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF6F6F6),
      padding: EdgeInsets.symmetric(vertical: 10 * scale),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15 * scale),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Filter button
            GestureDetector(
              onTap: _openSearchFilterSheet,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 9 * scale, vertical: 2 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18 * scale),
                  boxShadow: _softCardShadow(scale),
                ),
                child: SvgPicture.asset(
                  'assets/images/filter_icon.svg',
                  width: 29 * scale,
                  height: 25 * scale,
                ),
              ),
            ),
            SizedBox(width: 20 * scale),
            _buildTabButton('featured', _selectedFilter == 'featured', scale),
            SizedBox(width: 20 * scale),
            _buildTabButton('Near You', _selectedFilter == 'Near You', scale),
            SizedBox(width: 20 * scale),
            _buildTabButton('Newly Opened', _selectedFilter == 'Newly Opened', scale),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected, double scale) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedFilter = text;
        });
        await Provider.of<SearchProvider>(context, listen: false)
            .fetchPopular(force: true, filter: _activeSearchFilterDto());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 5 * scale),
        decoration: isSelected ? BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18 * scale),
          boxShadow: _softCardShadow(scale),
        ) : null,
        child: Text(
          text,
          style: GoogleFonts.afacad(
            fontWeight: FontWeight.w500,
            fontSize: 13 * scale,
            color: const Color(0xFF000000),
          ),
        ),
      ),
    );
  }


  Widget _buildFeaturedTab(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15 * scale, vertical: 5 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5 * scale),
            child: Text(
              'Featured Amenities',
              style: GoogleFonts.afacad(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000000),
                height: 1.33,
              ),
            ),
          ),
          SizedBox(height: 15 * scale),

          // Horizontal scroll with Featured Amenities cards
          Consumer<SearchProvider>(
            builder: (context, searchProvider, _) {
              final topBusinesses = _normalizeItems(
                searchProvider.popular?['topBusinesses'] as List?,
              );
              final topAmenities = _normalizeItems(
                searchProvider.popular?['topAmenities'] as List?,
              );
              final featuredItems = [
                ...topBusinesses,
                ...topAmenities,
              ];
              final hasBackendData = featuredItems.isNotEmpty;

              if (!hasBackendData) {
                return SizedBox(
                  height: 166 * scale,
                  child: Center(
                    child: Text(
                      'No featured items',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 166 * scale,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredItems.length,
                  itemBuilder: (context, index) {
                    final biz = featuredItems[index];
                    final categoryName = _categoryName(biz['category']);
                    final rating = _asDouble(biz['rating']);
                    final statusRaw = biz['isOpen'];
                    final hasStatus = statusRaw is bool;
                    final distance = _distanceLabelForItem(biz);
                    final cardData = {
                      'image': _imageUrlForItem(biz),
                      'title': (biz['name'] as String?) ?? 'Business',
                      'rating': rating != null ? rating.toStringAsFixed(1) : '',
                      'hasRating': rating != null,
                      'reviews': '(${biz['reviewCount'] ?? 0})',
                      'reviewCount': biz['reviewCount'] ?? 0,
                      'distance': distance,
                      'hasDistance': distance.isNotEmpty,
                      'status': hasStatus ? ((statusRaw == true) ? 'Open' : 'Closed') : '',
                      'hasStatus': hasStatus,
                      'id': (biz['id'] ?? '').toString(),
                      'category': categoryName.isNotEmpty ? categoryName : 'Grocery Store',
                      'entityType': (biz['entityType'] ?? 'business').toString(),
                      'serviceType': (biz['serviceType'] ?? '').toString(),
                      'location': _mapQueryForItem(
                        biz,
                        fallback: (biz['name'] ?? '').toString(),
                      ),
                    };
                    return Container(
                      margin: EdgeInsets.only(right: index < featuredItems.length - 1 ? 15 * scale : 0),
                      child: _buildFeaturedCard(index, scale, cardOverride: cardData),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(int index, double scale, {Map<String, dynamic>? cardOverride}) {
    final card = cardOverride ?? <String, dynamic>{};

    return GestureDetector(
      onTap: () {
        _openFeaturedItem(card);
      },
      child: Container(
      width: 287 * scale,
      height: 166 * scale,
      padding: EdgeInsets.fromLTRB(3 * scale, 3 * scale, 6 * scale, 3 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25 * scale),
        border: Border.all(
          color: Colors.black.withOpacity(0.15),
          width: 1 * scale,
        ),
        boxShadow: _softCardShadow(scale),
      ),
      child: Column(
        children: [
          // Store Image with heart icon and rating
          Container(
            width: 274 * scale,
            height: 107 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20 * scale),
                image: DecorationImage(
                  image: _resolveImageProvider(
                    card['image'],
                    fallbackAsset: 'assets/images/anchored_dumplings_promo.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            child: Stack(
              children: [
                // Heart icon (top-right)
                Positioned(
                  top: 5 * scale,
                  right: 5 * scale,
                  child: Consumer<FavoriteProvider>(
                    builder: (context, favProvider, _) {
                      final id = (card['id'] ?? '').toString();
                      final entityType = (card['entityType'] ?? 'business').toString();
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
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 20 * scale,
                          color: isFav ? const Color(0xFFFF5050) : Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                // Rating badge (top-left)
                Positioned(
                  top: 5.5 * scale,
                  left: 6.5 * scale,
                  child: (card['hasRating'] == true)
                      ? Container(
                          padding: EdgeInsets.all(5 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14 * scale),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/images/star_icon.svg',
                                width: 20 * scale,
                                height: 20 * scale,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFFFCD29),
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 1 * scale),
                              Text(
                                (card['rating'] ?? '').toString(),
                                style: GoogleFonts.oswald(
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF000000),
                                ),
                              ),
                              SizedBox(width: 10 * scale),
                              Text(
                                (card['reviews'] ?? '').toString(),
                                style: GoogleFonts.oswald(
                                  fontSize: 10 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 1 * scale),
          
          // Business Information section
          Container(
            width: 274 * scale,
            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Business name and distance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business name
                      Text(
                        (card['title'] ?? '').toString(),
                        style: GoogleFonts.oswald(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF000000),
                          height: 1.482,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2 * scale),
                      if (card['hasDistance'] == true)
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/location_pin_icon.svg',
                              width: 17 * scale,
                              height: 17 * scale,
                            ),
                            SizedBox(width: 4 * scale),
                            Text(
                              (card['distance'] ?? '').toString(),
                              style: GoogleFonts.oswald(
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF000000),
                                height: 1.48,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Right side - Status and Map actions
                SizedBox(
                  width: 50 * scale,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (card['hasStatus'] == true)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/open_door_icon.svg',
                              width: 17 * scale,
                              height: 17 * scale,
                            ),
                            SizedBox(width: 2 * scale),
                            Flexible(
                              child: Text(
                                (card['status'] ?? '').toString(),
                                style: GoogleFonts.oswald(
                                  fontSize: 11 * scale,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF073A6A),
                                  height: 1.48,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 1 * scale),
                      // Map action
                      GestureDetector(
                        onTap: () async {
                          final query = (card['location'] ?? card['title'] ?? '').toString();
                          await openMapForQuery(context, query);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/map_navigation_icon.svg',
                              width: 14 * scale,
                              height: 14 * scale,
                            ),
                            SizedBox(width: 2 * scale),
                            Text(
                              'Map',
                              style: GoogleFonts.oswald(
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF073A6A),
                                height: 1.48,
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
          ),
        ],
      ),
      ),
    );
  }


  Widget _buildPromotionTab(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5 * scale),
      child: Column(
        children: [
          // Header section
          Container(
            padding: EdgeInsets.fromLTRB(15 * scale, 0, 15 * scale, 0),
            child: Row(
              children: [
                Text(
                  'Promotions',
                  style: GoogleFonts.afacad(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * scale),
          // Horizontal scrollable cards container
          Consumer<PromotionProvider>(
            builder: (context, promoProvider, _) {
              final backendPromos = promoProvider.promotions;

              if (backendPromos.isEmpty) {
                return Container(
                  height: 140 * scale,
                  padding: EdgeInsets.fromLTRB(15 * scale, 10 * scale, 15 * scale, 10 * scale),
                  child: Center(
                    child: Text(
                      'No promotions available',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ),
                );
              }

              return Container(
                height: 140 * scale,
                padding: EdgeInsets.fromLTRB(15 * scale, 10 * scale, 15 * scale, 10 * scale),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: backendPromos.length,
                  itemBuilder: (context, index) {
                    final p = backendPromos[index];
                    final discountText = p.discountPct != null
                        ? 'Up to ${p.discountPct!.toStringAsFixed(0)}% off'
                        : '';
                    final price = p.price != null ? 'Rs. ${p.price!.toStringAsFixed(0)}' : '';
                    final originalPrice = (p.price != null && p.discountPct != null)
                        ? 'Rs. ${(p.price! / (1 - p.discountPct! / 100)).toStringAsFixed(0)}'
                        : '';
                    final promoData = {
                      'image': p.imageUrl ?? '',
                      'productName': p.title,
                      'discount': discountText,
                      'condition': p.description ?? '',
                      'currentPrice': price,
                      'originalPrice': originalPrice,
                    };
                    return Container(
                      margin: EdgeInsets.only(right: index < backendPromos.length - 1 ? 25 * scale : 0),
                      child: _buildPromotionCard(index, scale, promoOverride: promoData),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(int index, double scale, {Map<String, String>? promoOverride}) {
    final promotion = promoOverride ?? <String, String>{};

    return GestureDetector(
      onTap: () {
        // Promotions are for businesses - navigate to stores
        Navigator.pushNamed(context, '/stores');
      },
      child: Container(
      width: 256 * scale,
      height: 129 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15 * scale),
        border: Border.all(
          color: Colors.black.withOpacity(0.1),
          width: 1 * scale,
        ),
        boxShadow: _softCardShadow(scale),
      ),
      child: Row(
        children: [
          // Product image (left side)
          Container(
            width: 128 * scale,
            height: 129 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15 * scale),
                bottomLeft: Radius.circular(15 * scale),
              ),
              image: DecorationImage(
                image: _resolveImageProvider(
                  promotion['image'],
                  fallbackAsset: 'assets/images/anchored_dumplings_promo.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content section (right side)
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(8 * scale, 4 * scale, 8 * scale, 6 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product name
                  Text(
                    promotion['productName'] as String,
                    style: GoogleFonts.rancho(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF343434),
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2 * scale),
                  // Promotion badge and discount text
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/lsicon_badge-promotion-filled.svg',
                        width: 16 * scale,
                        height: 16 * scale,
                      ),
                      SizedBox(width: 2 * scale),
                      Expanded(
                        child: Text(
                          promotion['discount'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11 * scale,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF000000),
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4 * scale),
                  // Offer condition
                  Text(
                    promotion['condition'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 9 * scale,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF696969),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Pricing section
                  Row(
                    children: [
                      Text(
                        promotion['currentPrice'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF5571),
                          height: 1.3,
                        ),
                      ),
                      SizedBox(width: 6 * scale),
                      Text(
                        promotion['originalPrice'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF929292),
                          height: 1.3,
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
      ),
    );
  }

  Widget _buildFollowUsSection(double scale) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        final cards = searchProvider.followCards;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 0 * scale),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: cards.isEmpty
              ? SizedBox(
                  height: 76 * scale,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No follow cards available yet',
                      style: GoogleFonts.afacad(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7A7A7A),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 76 * scale,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final imageUrl = (card.imageUrl ?? '').trim();
                      final avatarProvider = imageUrl.startsWith('http')
                          ? CachedNetworkImageProvider(imageUrl)
                          : _resolveImageProvider(
                              imageUrl,
                              fallbackAsset: 'assets/images/profile_placeholder.png',
                            );

                      return Container(
                        width: 292 * scale,
                        margin: EdgeInsets.only(right: 10 * scale),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15 * scale),
                            onTap: () => _openFollowCard(card),
                            child: Ink(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8 * scale,
                                vertical: 0 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15 * scale),
                                border: Border.all(
                                  color: const Color(0xFFD9D9D9),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8 * scale,
                                    offset: Offset(0, 3 * scale),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52 * scale,
                                    height: 52 * scale,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: avatarProvider,
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFD7D7D7),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10 * scale),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                card.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.afacad(
                                                  fontSize: 17 * scale,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF101010),
                                                ),
                                              ),
                                            ),
                                            if (card.isVerified) ...[
                                              SizedBox(width: 4 * scale),
                                              Icon(
                                                Icons.verified_rounded,
                                                size: 20 * scale,
                                                color: const Color(0xFF11B6D8),
                                              ),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: 2 * scale),
                                        Text(
                                          '${card.followersCount} Followers',
                                          style: GoogleFonts.afacad(
                                            fontSize: 14 * scale,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFE53935),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8 * scale),
                                  GestureDetector(
                                    onTap: () => searchProvider.toggleFollow(card),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14 * scale,
                                        vertical: 5 * scale,
                                      ),
                                      decoration: BoxDecoration(
                                        color: card.isFollowing
                                            ? const Color(0xFF171717)
                                            : const Color(0xFF3B3B3B),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        card.isFollowing ? 'Following' : 'Follow',
                                        style: GoogleFonts.inter(
                                          fontSize: 13 * scale,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }


  Widget _buildEateriesSection(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5 * scale),
            child: Text(
              'Eateries near you',
              style: GoogleFonts.afacad(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000000),
                height: 1.33,
              ),
            ),
          ),
          SizedBox(height: 10 * scale),
          Consumer<SearchProvider>(
            builder: (context, searchProvider, _) {
              final eateryList = _normalizeItems(
                searchProvider.popular?['topEateries'] as List?,
              );
              final hasBackendData = eateryList.isNotEmpty;

              if (!hasBackendData) {
                return SizedBox(
                  height: 125 * scale,
                  child: Center(
                    child: Text(
                      'No eateries found',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 125 * scale,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: eateryList.length,
                  itemBuilder: (context, index) {
                    final biz = eateryList[index];
                    final rating = _asDouble(biz['rating']);
                    final statusRaw = biz['isOpen'];
                    final hasStatus = statusRaw is bool;
                    final distance = _distanceLabelForItem(biz);
                    final eateryData = {
                      'name': (biz['name'] as String?) ?? 'Restaurant',
                      'rating': rating != null ? rating.toStringAsFixed(1) : '',
                      'hasRating': rating != null,
                      'reviews': '(${biz['reviewCount'] ?? 0})',
                      'distance': distance,
                      'hasDistance': distance.isNotEmpty,
                      'cuisine': _categoryName(biz['category']),
                      'status': hasStatus ? ((statusRaw == true) ? 'Open' : 'Closed') : '',
                      'hasStatus': hasStatus,
                      'image': _imageUrlForItem(biz),
                      'id': (biz['id'] ?? '').toString(),
                      'entityType': 'business',
                      'location': _mapQueryForItem(
                        biz,
                        fallback: (biz['name'] ?? '').toString(),
                      ),
                    };
                    return Container(
                      margin: EdgeInsets.only(right: 15 * scale),
                      child: _buildEateryCard(index, scale, eateryOverride: eateryData),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEateryCard(int index, double scale, {Map<String, dynamic>? eateryOverride}) {
    final eatery = eateryOverride ?? <String, dynamic>{};

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/restaurants');
      },
      child: Container(
      width: 350 * scale,
      height: 120 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white,
        borderRadius: BorderRadius.circular(15 * scale),
        border: Border.all(
          color: Colors.black.withOpacity(0.1),
          width: 1 * scale,
        ),
                    boxShadow: _softCardShadow(scale),
                  ),
      child: Stack(
        children: [
          Row(
            children: [
              // Left side - Image
              Container(
                width: 120 * scale,
                height: 120 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15 * scale),
                    bottomLeft: Radius.circular(15 * scale),
                  ),
                  image: DecorationImage(
                    image: _resolveImageProvider(
                      eatery['image'],
                      fallbackAsset: 'assets/images/anchored_dumplings_promo.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Right side - Details
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 8 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top section - Name, Rating, Distance
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Restaurant name with rating
                          Row(
                            children: [
                              Text(
                                (eatery['name'] ?? '').toString(),
                      style: TextStyle(
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF000000),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: 4 * scale),
                              if (eatery['hasRating'] == true)
                                SvgPicture.asset(
                                  'assets/images/star_icon.svg',
                                  width: 16 * scale,
                                  height: 16 * scale,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFFFCD29),
                                    BlendMode.srcIn,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 3 * scale),
                          // Distance with location icon
                          if (eatery['hasDistance'] == true)
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/location_pin_icon.svg',
                                  width: 16 * scale,
                                  height: 16 * scale,
                                ),
                                SizedBox(width: 4 * scale),
                                Text(
                                  (eatery['distance'] ?? '').toString(),
                                  style: TextStyle(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 3 * scale),
                      // Cuisine type (middle)
                      Text(
                        (eatery['cuisine'] ?? '').toString(),
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF000000),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3 * scale),
                      // Bottom row - Open status and Map (vertically stacked)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (eatery['hasStatus'] == true)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/open_door_icon.svg',
                                  width: 18 * scale,
                                  height: 18 * scale,
                                ),
                                SizedBox(width: 4 * scale),
                                Text(
                                  (eatery['status'] ?? '').toString(),
                                  style: TextStyle(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF0097B2),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 3 * scale),
                          // Map link
                          GestureDetector(
                            onTap: () async {
                              final query = (eatery['location'] ?? eatery['name'] ?? '').toString();
                              await openMapForQuery(context, query);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/map_navigation_icon.svg',
                                  width: 16 * scale,
                                  height: 16 * scale,
                                ),
                                SizedBox(width: 4 * scale),
                                Text(
                                  'Map',
                                  style: TextStyle(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF0097B2),
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
          // Heart icon at bottom right corner
          Positioned(
            bottom: 6 * scale,
            right: 6 * scale,
            child: Consumer<FavoriteProvider>(
              builder: (context, favProvider, _) {
                final id = (eatery['id'] ?? '').toString();
                final isFav = favProvider.isBusinessFavorited(id);
                return GestureDetector(
                  onTap: id.isEmpty ? null : () => favProvider.toggleBusinessFavorite(id),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    size: 18 * scale,
                    color: isFav ? const Color(0xFFFF5050) : const Color(0xFF8C8C8C),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }


  Widget _buildBestServiceProviderSection(double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5 * scale),
            child: Text(
              'Best Service Provider',
              style: GoogleFonts.afacad(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000000),
                height: 1.33,
              ),
            ),
          ),
          SizedBox(height: 15 * scale),
          Consumer<SearchProvider>(
            builder: (context, searchProvider, _) {
              final nonDoctorServices = _normalizeItems(
                searchProvider.popular?['topNonDoctorServices'] as List?,
              );
              final hasBackendData = nonDoctorServices.isNotEmpty;

              if (!hasBackendData) {
                return SizedBox(
                  height: 145 * scale,
                  child: Center(
                    child: Text(
                      'No service providers',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 145 * scale,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: nonDoctorServices.length,
                  itemBuilder: (context, index) {
                    final svc = nonDoctorServices[index];
                    final serviceType = (svc['serviceType'] as String?) ?? '';
                    final skills = (svc['skills'] is List)
                        ? (svc['skills'] as List)
                            .map((e) => e is Map
                                ? (e['tagName'] ?? '').toString()
                                : e.toString())
                            .where((e) => e.trim().isNotEmpty)
                            .join(', ')
                        : '';
                    // Capitalize service type for display
                    final profession = serviceType.isNotEmpty
                        ? '${serviceType[0].toUpperCase()}${serviceType.substring(1).toLowerCase()}'
                        : '';
                    final providerData = {
                      'name': (svc['name'] as String?) ?? 'Provider',
                      'profession': profession,
                      'services': skills,
                      'rating': (svc['rating'] as num?)?.toStringAsFixed(1) ?? '0.0',
                      'totalJobs': '${svc['jobsCompleted'] ?? 0}',
                      'charges': svc['serviceCharge'] != null
                          ? 'Rs ${(svc['serviceCharge'] as num).toStringAsFixed(0)} (Starting)'
                          : '',
                      'image': _imageUrlForItem(svc),
                      'id': (svc['id'] ?? '').toString(),
                    };
                    return Container(
                      margin: EdgeInsets.only(right: 15 * scale),
                      child: _buildProviderCard(index, scale, providerOverride: providerData),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(int index, double scale, {Map<String, String>? providerOverride}) {
    final provider = providerOverride ?? <String, String>{};

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ServiceProviderDetailScreen(
            providerName: provider['name'],
            serviceType: provider['profession'] ?? 'Professional Service',
            providerId: provider['id'],
          ),
        ));
      },
      child: Container(
      width: 350 * scale,
      height: 135 * scale,
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15 * scale),
        border: Border.all(
          color: Colors.black.withOpacity(0.1),
          width: 1 * scale,
        ),
        boxShadow: _softCardShadow(scale),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Image
              Center(
                child: Container(
                  width: 110 * scale,
                  height: 119 * scale,
            decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15 * scale),
                    image: DecorationImage(
                      image: _resolveImageProvider(
                        provider['image'],
                        fallbackAsset: 'assets/images/anchored_dumplings_promo.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Right side - Details
          Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 8 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
              children: [
                      // Top section - Name, Profession, Services
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name
                Text(
                            provider['name'] as String,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                          SizedBox(height: 3 * scale),
                          // Profession
                Text(
                            provider['profession'] as String,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 3 * scale),
                          // Services
                          Text(
                            provider['services'] as String,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: 6 * scale),
                      // Bottom section - Metrics (Rating, Total Jobs, Charges)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                          // Rating
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                    Text(
                                'Rating',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 1 * scale),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/star_icon.svg',
                                    width: 12 * scale,
                                    height: 12 * scale,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFFFFCD29),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(width: 2 * scale),
                                  Text(
                                    provider['rating'] as String,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11 * scale,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
                          ),
                          Spacer(),
                          // Total Jobs
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Jobs',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 1 * scale),
                              Text(
                                provider['totalJobs'] as String,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11 * scale,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          // Charges
                          Spacer(),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Charges',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 1 * scale),
                                Text(
                                  provider['charges'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10 * scale,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
          // Heart icon at top right corner (outline only)
          Positioned(
            top: 8 * scale,
            right: 8 * scale,
            child: Consumer<FavoriteProvider>(
              builder: (context, favProvider, _) {
                final id = (provider['id'] ?? '').toString();
                final isFav = favProvider.isServiceProviderFavorited(id);
                return GestureDetector(
                  onTap: id.isEmpty ? null : () => favProvider.toggleServiceProviderFavorite(id),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    size: 20 * scale,
                    color: isFav ? const Color(0xFFFF5050) : const Color(0xFF8C8C8C),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }


  Widget _buildDoctorsFrame(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15 * scale, vertical: 5 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5 * scale),
            child: Text(
              'Best Doctors Near You',
              style: GoogleFonts.afacad(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000000),
                height: 1.33,
              ),
            ),
          ),
          SizedBox(height: 15 * scale),
          // Horizontal scroll with Doctor cards
          Consumer<SearchProvider>(
            builder: (context, searchProvider, _) {
              final doctorsList = _normalizeItems(
                searchProvider.popular?['topDoctors'] as List?,
              );
              final hasBackendData = doctorsList.isNotEmpty;

              if (!hasBackendData) {
                return SizedBox(
                  height: 280 * scale,
                  child: Center(
                    child: Text(
                      'No doctors found',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 280 * scale,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: doctorsList.length,
                  itemBuilder: (context, index) {
                    final doc = doctorsList[index];
                    final doctorData = {
                      'name': (doc['name'] as String?) ?? 'Doctor',
                      'specialty': (doc['categoryName'] as String?) ??
                          _categoryName(doc['category']),
                      'rating': (doc['rating'] as num?)?.toStringAsFixed(1) ?? '0.0',
                      'reviews': '${doc['reviewCount'] ?? 0} Reviews',
                      'image': _imageUrlForItem(doc),
                      'id': (doc['id'] ?? '').toString(),
                    };
                    return Container(
                      margin: EdgeInsets.only(right: index < doctorsList.length - 1 ? 15 * scale : 0),
                      child: _buildDoctorCard(index, scale, doctorOverride: doctorData),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(int index, double scale, {Map<String, String>? doctorOverride}) {
    final doctor = doctorOverride ?? <String, String>{};

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ServiceProviderDetailScreen(
            providerName: doctor['name'],
            serviceType: 'Doctor',
            specialty: doctor['specialty'],
            providerId: doctor['id'],
          ),
        ));
      },
      child: Container(
        width: 200 * scale,
        height: 280 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(
            color: Colors.black.withOpacity(0.15),
            width: 1 * scale,
          ),
          boxShadow: _softCardShadow(scale),
        ),
        child: Column(
          children: [
            // Doctor Image Section (Top Half)
            Container(
              width: 200 * scale,
              height: 140 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20 * scale),
                  topRight: Radius.circular(20 * scale),
                ),
                image: DecorationImage(
                  image: _resolveImageProvider(
                    doctor['image'],
                    fallbackAsset: 'assets/images/doctor1.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Heart icon (top-left)
                  Positioned(
                    top: 8 * scale,
                    left: 8 * scale,
                    child: Consumer<FavoriteProvider>(
                      builder: (context, favProvider, _) {
                        final id = (doctor['id'] ?? '').toString();
                        final isFav = favProvider.isServiceProviderFavorited(id);
                        return GestureDetector(
                          onTap: id.isEmpty ? null : () => favProvider.toggleServiceProviderFavorite(id),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 20 * scale,
                            color: isFav ? const Color(0xFFFF5050) : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Doctor Information Section (Bottom Half)
            Expanded(
              child: Container(
                width: 200 * scale,
                padding: EdgeInsets.all(12 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Doctor Name
                    Text(
                      doctor['name'] as String,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF000000),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4 * scale),
                    // Specialty
                    Text(
                      doctor['specialty'] as String,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000000),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8 * scale),
                    // Rating Stars
                    Center(
                      child: _buildStarRating(double.parse(doctor['rating'] as String), scale),
                    ),
                    SizedBox(height: 4 * scale),
                    // Reviews Count
                    Text(
                      doctor['reviews'] as String,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000000),
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildStarRating(double rating, double scale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          // Full star
          return Icon(
            Icons.star,
            size: 14 * scale,
            color: const Color(0xFFFFCD29),
          );
        } else if (index < rating) {
          // Half star
          return Icon(
            Icons.star_half,
            size: 14 * scale,
            color: const Color(0xFFFFCD29),
          );
        } else {
          // Empty star
          return Icon(
            Icons.star_border,
            size: 14 * scale,
            color: const Color(0xFFFFCD29),
          );
        }
      }),
    );
  }

  Widget _buildReviewsSection(double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5 * scale),
            child: Text(
              'Customer Reviews',
              style: GoogleFonts.afacad(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000000),
                height: 1.33,
              ),
            ),
          ),
          SizedBox(height: 15 * scale),
          Consumer<SearchProvider>(
            builder: (context, searchProvider, _) {
              final reviews = _normalizeReviewItems(
                searchProvider.popular?['latestReviews'] as List?,
              );
              final visibleReviews =
                  _showAllCustomerReviews ? reviews : reviews.take(3).toList();
              if (reviews.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20 * scale),
                    child: Text(
                      'No reviews yet',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  ...List.generate(visibleReviews.length, (index) {
                    final review = visibleReviews[index];
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: index == visibleReviews.length - 1 ? 0 : 12 * scale),
                      child: _buildReviewCard(
                        review['name'] ?? '',
                        review['productName'] ?? '',
                        review['rating'] ?? '0.0',
                        review['ratingText'] ?? '',
                        review['review'] ?? '',
                        review['dateTime'] ?? '',
                        review['productImage'],
                        review['profileImage'],
                        scale,
                      ),
                    );
                  }),
                  if (reviews.length > 3)
                    Padding(
                    padding: EdgeInsets.only(top: 10 * scale),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showAllCustomerReviews = !_showAllCustomerReviews;
                          });
                        },
                        child: Text(
                          _showAllCustomerReviews ? 'See Less' : 'See More',
                          style: GoogleFonts.inter(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3195AB),
                          ),
                        ),
                      ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, String productName, String rating, String ratingText, String review, String dateTime, String? productImage, String? profileImage, double scale) {
    return Container(
      padding: EdgeInsets.all(15 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: _softCardShadow(scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Food Image, Reviewer Info, Profile Picture
          Row(
            children: [
              // Circular Food Image (Left)
              Container(
                width: 60 * scale,
                height: 60 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _resolveImageProvider(
                      productImage,
                      fallbackAsset: 'assets/images/anchored_dumplings_promo.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1 * scale,
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              // Reviewer Information (Center)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: GoogleFonts.afacad(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    // Product Name (Red)
                    Text(
                      productName,
                      style: GoogleFonts.afacad(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFFF0000),
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    // Rating with Star
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16 * scale,
                          color: const Color(0xFFFFCD29),
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          '$rating $ratingText',
                          style: GoogleFonts.afacad(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Profile Picture (Right)
              Container(
                width: 50 * scale,
                height: 50 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _resolveImageProvider(
                      profileImage,
                      fallbackAsset: 'assets/images/profile_placeholder.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1 * scale,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15 * scale),
          // Review Text (Middle Section)
          Text(
            review,
            style: GoogleFonts.afacad(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF000000),
              height: 1.5,
            ),
          ),
          SizedBox(height: 15 * scale),
          // Bottom Section: Helpful & Date/Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Helpful Section (Left)
              Row(
                children: [
                  Text(
                    'Helpful ?',
                    style: GoogleFonts.afacad(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thanks for the feedback!'), duration: Duration(seconds: 1)),
                      );
                    },
                    child: Icon(
                      Icons.thumb_up_outlined,
                      size: 18 * scale,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 4 * scale),
                  Container(
                    width: 1 * scale,
                    height: 18 * scale,
                    color: Colors.grey[400],
                  ),
                  SizedBox(width: 4 * scale),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thanks for the feedback!'), duration: Duration(seconds: 1)),
                      );
                    },
                    child: Icon(
                      Icons.thumb_down_outlined,
                      size: 18 * scale,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              // Date and Time (Right)
              Text(
                dateTime,
                style: GoogleFonts.afacad(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
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
            _buildFooterItem('assets/images/footer_home_complete.svg', 'Home', true),
            _buildFooterItem('assets/images/footer_search_complete.svg', 'Search', false),
            _buildFooterScanItem(),
            _buildFooterItem('assets/images/footer_call_icon.svg', 'Call', false),
            _buildFooterItem('assets/images/figma_profile_icon.svg', 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterItem(String iconPath, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          switch (label) {
            case 'Search':
              Navigator.pushNamed(context, '/search');
              break;
            case 'Call':
              Navigator.pushNamed(context, '/all-services');
              break;
            case 'Profile':
              Navigator.pushNamed(context, '/edit-profile');
              break;
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isActive ? const Color(0xFF0092AC) : const Color(0xFF484C52),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isActive ? const Color(0xFF0092AC) : const Color(0xFF484C52),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterScanItem() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Scanner coming soon'), duration: Duration(seconds: 1)),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0092AC),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/figma_scan_icon.svg',
                width: 32,
                height: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TapAnimatedArrow extends StatefulWidget {
  final double scale;
  final VoidCallback onTap;

  const _TapAnimatedArrow({
    required this.scale,
    required this.onTap,
  });

  @override
  State<_TapAnimatedArrow> createState() => _TapAnimatedArrowState();
}

class _TapAnimatedArrowState extends State<_TapAnimatedArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SvgPicture.asset(
          'assets/images/Vector.svg',
          width: 9 * widget.scale,
          height: 15 * widget.scale,
          colorFilter: const ColorFilter.mode(
            Color(0xFF474747),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
