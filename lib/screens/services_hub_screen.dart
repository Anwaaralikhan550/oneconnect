import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/service_provider_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/search_provider.dart';
import '../models/service_provider_model.dart';
import '../models/filter_dto.dart';
import '../widgets/sticky_footer.dart';
import '../utils/profile_image_picker.dart';
import '../widgets/figma_filter_sheet.dart';
import '../widgets/profile_image.dart';
import 'service_provider_detail_screen.dart';

class ServicesHubScreen extends StatefulWidget {
  const ServicesHubScreen({super.key});

  @override
  State<ServicesHubScreen> createState() => _ServicesHubScreenState();
}

class _ServicesHubScreenState extends State<ServicesHubScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Heart icon states for each provider
  final List<bool> _heartStates = [false, false, false];

  // Filter state variables
  String _selectedCategory = 'All';
  final RangeValues _priceRange = const RangeValues(0, 1000);
  final double _minRating = 0.0;
  String _selectedLocationFilter = 'Area';
  String _selectedPriceFilter = 'Rs';

  // Services expansion state
  bool _isServicesExpanded = false;

  File? _profileImage;
  Timer? _suggestionDebounce;
  bool _showSuggestions = false;

  static const List<String> _serviceTypes = [
    'LAUNDRY',
    'PLUMBER',
    'ELECTRICIAN',
    'PAINTER',
    'CARPENTER',
    'BARBER',
    'MAID',
    'SALON',
    'REAL_ESTATE',
    'DOCTOR',
    'WATER',
    'GAS',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchProfile();
      final provider = Provider.of<ServiceProviderProvider>(context, listen: false);
      Provider.of<FavoriteProvider>(context, listen: false).hydrateFavorites();
      final filter = _activeFilterDto;
      for (final type in _serviceTypes) {
        provider.fetchByType(type, filter: filter, force: true);
      }
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
    _suggestionDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    _suggestionDebounce?.cancel();

    if (query.isEmpty) {
      setState(() => _showSuggestions = false);
      Provider.of<SearchProvider>(context, listen: false).fetchSuggestions('');
      return;
    }

    _suggestionDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      await Provider.of<SearchProvider>(context, listen: false)
          .fetchSuggestions(query);
      if (mounted) setState(() => _showSuggestions = true);
    });
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _suggestionDebounce?.cancel();
    setState(() => _showSuggestions = false);
    _submitSearch();
  }

  void _showFilterOptions() {
    showFigmaFilterSheet(
      context,
      selectedLocation: _selectedLocationFilter,
      selectedCategory: _selectedCategory,
      selectedPrice: _selectedPriceFilter,
      categoryOptions: const [
        'All',
        'Laundry',
        'Plumber',
        'Electrician',
        'Painter',
        'Cleaning',
      ],
    ).then((selection) {
      if (selection == null || !mounted) return;
      setState(() {
        _selectedLocationFilter = selection.location;
        _selectedCategory = selection.category;
        _selectedPriceFilter = selection.price;
      });
      _refetchFilteredProviders();
    });
  }

  FilterDto get _activeFilterDto => FilterDto(
        latitude: Provider.of<AuthProvider>(context, listen: false).user?.locationLat,
        longitude: Provider.of<AuthProvider>(context, listen: false).user?.locationLng,
        locationMode: _selectedLocationFilter == 'Distance'
            ? 'DISTANCE'
            : (_selectedLocationFilter == 'Block' ? 'BLOCK' : 'AREA'),
        category: _selectedCategory == 'All' ? null : 'Service',
        priceTier: _selectedPriceFilter == 'Rs++'
            ? 'RS_PLUS_PLUS'
            : (_selectedPriceFilter == 'Rs+' ? 'RS_PLUS' : 'RS'),
        minRating: _selectedPriceFilter == 'Rs++'
            ? 4.0
            : (_selectedPriceFilter == 'Rs+' ? 3.5 : null),
        sortBy: _selectedLocationFilter == 'Distance' ? 'NEAR_ME' : null,
      );

  Future<void> _refetchFilteredProviders() async {
    final provider = Provider.of<ServiceProviderProvider>(context, listen: false);
    final filter = _activeFilterDto;
    for (final type in _serviceTypes) {
      await provider.fetchByType(type, filter: filter, force: true);
    }
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();

    final lowerQuery = query.toLowerCase();
    if (lowerQuery == 'property' ||
        lowerQuery.contains('property') ||
        lowerQuery == 'real estate' ||
        lowerQuery.contains('real estate')) {
      Navigator.pushNamed(context, '/property');
      return;
    }
    if (lowerQuery == 'electrician' || lowerQuery.contains('electrician')) {
      Navigator.pushNamed(context, '/electricians');
      return;
    }

    Navigator.pushNamed(
      context,
      '/search-results',
      arguments: {
        'query': query,
        'filter': _activeFilterDto.toQueryParams(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Sticky Header Section (Header + Title + Search)
          _buildStickyHeader(),
          
          // Scrollable Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _refetchFilteredProviders();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),
                    
                    // Center Content
                    _buildCenterContent(),
                    
                    // Add bottom padding to account for safe area
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Sticky Footer
      bottomNavigationBar: const StickyFooter(
        selectedIndex: 0, // Home is selected for Services Hub
      ),
    );
  }


  Widget _buildStickyHeader() {
    return Column(
      children: [
        // Header Section
        _buildHeader(),

        const SizedBox(height: 15),

        // Main Title
        _buildMainTitle(),

        const SizedBox(height: 15),

        // Search Section
        _buildSearchSection(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 215,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/services_hub_header_bg.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
          children: [
            SizedBox(height: 30),
            
            // Top section with back button and notification/settings
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back icon from Figma
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: SvgPicture.asset(
                        'assets/images/back_arrow_icon.svg',
                        width: 35,
                        height: 35,
                      ),
                    ),
                  ),
                  
                  // Notification and Setting icons
                  Row(
                    children: [
                      // Notification icon
                      Transform.translate(
                        offset: const Offset(20, 0),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.pushNamed(context, '/notification'),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: SvgPicture.asset(
                                  'assets/images/NotificationIcon.svg',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFFFD700),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Settings icon
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.pushNamed(context, '/settings'),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: SvgPicture.asset(
                                'assets/images/settings_icon.svg',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
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

            // Center section with OneConnect logo and photo frame
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Transform.translate(
                  offset: Offset(0, -10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    // OneConnect Logo from Figma
                    Flexible(
                      child: SizedBox(
                        height: 66,
                        child: Image.asset(
                          'assets/images/oneconnect_logo.png',
                          height: 66,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Profile Photo Frame from Figma
                    Transform.translate(
                      offset: Offset(8, -4),
                      child: GestureDetector(
                        onTap: _updateProfileImage,
                        child: SizedBox(
                          width: 61,
                          height: 61,
                          child: _profileImage != null
                              ? Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF044870), width: 2),
                                    image: DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF044870), width: 2),
                                  ),
                                  child: ClipOval(
                                    child: buildProfileImage(
                                      Provider.of<AuthProvider>(context).user?.profilePhotoUrl,
                                      fallbackIcon: Icons.person,
                                      iconSize: 30,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildMainTitle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive font size based on screen width
          double fontSize = constraints.maxWidth > 400 ? 25 : 
                           constraints.maxWidth > 350 ? 22 : 20;
          
          // Responsive max width - use 90% of available space, max 380px
          double maxWidth = (constraints.maxWidth * 0.90).clamp(280.0, 380.0);
          
          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              child: Text(
                'Which service are you looking for today',
                style: TextStyle(
                  fontFamily: 'Afacad',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Center(
                child: _buildSearchBar(constraints.maxWidth),
              ),
              if (_showSuggestions)
                Consumer<SearchProvider>(
                  builder: (context, searchProvider, _) {
                    final suggestions = searchProvider.suggestions.take(5).toList();
                    if (suggestions.isEmpty) return const SizedBox.shrink();
                    final panelHeight = (suggestions.length * 56.0).clamp(56.0, 180.0);
                    return Container(
                      width: (constraints.maxWidth * 0.90).clamp(320.0, 380.0),
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: panelHeight,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: suggestions.length,
                          itemBuilder: (_, index) {
                            final s = suggestions[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.search, size: 18, color: Color(0xFF4A4A4A)),
                              title: Text(
                                s.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
                              ),
                              subtitle: Text(
                                s.type,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A8A)),
                              ),
                              onTap: () => _onSuggestionTap(s.name),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(double availableWidth) {
    // Responsive width: 90% of available space, min 320px, max 380px
    double searchBarWidth = (availableWidth * 0.90).clamp(320.0, 380.0);
    
    return Container(
      width: searchBarWidth,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Color(0xFFE8E8E8), width: 1),
      ),
      child: Stack(
        children: [
          // Search Glass Icon
          Positioned(
            left: 10,
            top: 10,
            child: SizedBox(
              width: 25,
              height: 25,
              child: SvgPicture.asset(
                'assets/images/search_glass_icon.svg',
                width: 25,
                height: 25,
              ),
            ),
          ),
          
          // Text Field - responsive positioning
          Positioned(
            left: 45,
            right: 70,
            top: 0,
            bottom: 0,
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _submitSearch(),
              enableInteractiveSelection: false,
              contextMenuBuilder: (context, state) => const SizedBox.shrink(),
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: TextStyle(
                  fontSize: searchBarWidth > 320 ? 14 : 12,
                  color: Color(0xFF999999),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(
                fontSize: searchBarWidth > 320 ? 14 : 12,
                color: Colors.black,
              ),
            ),
          ),
          
          // Vertical Line - responsive positioning
          Positioned(
            right: 44,
            top: 10,
            child: SizedBox(
              width: 25,
              height: 25,
              child: SvgPicture.asset(
                'assets/images/vertical_line.svg',
                width: 25,
                height: 25,
              ),
            ),
          ),
          
          // Filter Icon - responsive positioning
          Positioned(
            right: 9,
            top: 10,
            child: GestureDetector(
              onTap: _showFilterOptions,
              child: SizedBox(
                width: 25,
                height: 25,
                child: SvgPicture.asset(
                  'assets/images/filter_icon.svg',
                  width: 25,
                  height: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Services Main Section
        _buildServicesMainSection(),
        
        // Best Service Provider Section
        _buildBestServiceProviderSection(),
        
        // Review Section
        _buildReviewSection(),
      ],
    );
  }

  Widget _buildServicesMainSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          // Services and Arrow button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      _isServicesExpanded = !_isServicesExpanded;
                    });
                  },
                  icon: AnimatedRotation(
                    turns: _isServicesExpanded ? 0.5 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down, size: 30),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Always visible first row (4 services)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildServiceItem('assets/images/laundry_icon.svg', 'Laundry'),
                _buildServiceItem('assets/images/plumber_icon.svg', 'Plumber'),
                _buildServiceItem('assets/images/electrician_icon.svg', 'Electrician'),
                _buildServiceItem('assets/images/painter_icon.svg', 'Painter'),
              ],
            ),
          ),
          
          // Expandable section with remaining services
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isServicesExpanded
                ? Column(
                    children: [
                      SizedBox(height: 20),
                      _buildExpandedServicesGrid(),
                      SizedBox(height: 20),
                    ],
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedServicesGrid() {
    final List<Map<String, String>> remainingServices = [
      {'icon': 'assets/images/carpenter_icon.svg', 'label': 'Carpenter'},
      {'icon': 'assets/images/barber_icon.svg', 'label': 'Barber'},
      {'icon': 'assets/images/maid_icon.svg', 'label': 'Maid'},
      {'icon': 'assets/images/salon_icon.svg', 'label': 'Salon'},
      {'icon': 'assets/images/real_estate_icon.svg', 'label': 'Real Estate'},
      {'icon': 'assets/images/health_icon.svg', 'label': 'Health'},
      {'icon': 'assets/images/Water Icon.svg', 'label': 'Water'},
      {'icon': 'assets/images/Gas Icon.png', 'label': 'Gas'},
    ];

    // Build rows of 4 items each to match the first row layout
    List<Widget> rows = [];
    for (int i = 0; i < remainingServices.length; i += 4) {
      int end = (i + 4 < remainingServices.length) ? i + 4 : remainingServices.length;
      List<Map<String, String>> rowItems = remainingServices.sublist(i, end);

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...rowItems.map((item) => _buildServiceItem(item['icon']!, item['label']!)),
              // Add empty spacers if row has less than 4 items
              ...List.generate(4 - rowItems.length, (_) => SizedBox(width: 70)),
            ],
          ),
        ),
      );

      // Add spacing between rows
      if (end < remainingServices.length) {
        rows.add(const SizedBox(height: 20));
      }
    }

    return Column(children: rows);
  }

  Widget _buildServiceItem(String iconPath, String label) {
    return GestureDetector(
      onTap: () {
        final lower = label.toLowerCase();
        if (lower == 'electrician') {
          Navigator.pushNamed(context, '/electricians');
        } else if (lower == 'plumber') {
          Navigator.pushNamed(context, '/plumber');
        } else if (lower == 'painter') {
          Navigator.pushNamed(context, '/painter');
        } else if (lower == 'laundry') {
          Navigator.pushNamed(context, '/laundry');
        } else if (lower == 'barber') {
          Navigator.pushNamed(context, '/barber');
        } else if (lower == 'maid') {
          Navigator.pushNamed(context, '/maid');
        } else if (lower == 'salon' || lower == 'beauty') {
          Navigator.pushNamed(context, '/beauty');
        } else if (lower == 'carpenter') {
          Navigator.pushNamed(context, '/carpenter');
        } else if (lower == 'water') {
          Navigator.pushNamed(context, '/water');
        } else if (lower == 'gas') {
          Navigator.pushNamed(context, '/gas');
        } else if (lower == 'real estate' || lower == 'property') {
          Navigator.pushNamed(context, '/property');
        } else if (lower == 'health' || lower == 'healthcare' || lower == 'doctors') {
          Navigator.pushNamed(context, '/doctors');
        } else {
          // For services without dedicated screens, show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label service coming soon!'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 70,
              height: 73,
              child: iconPath.endsWith('.svg')
                  ? SvgPicture.asset(
                      iconPath,
                      width: 70,
                      height: 73,
                      fit: BoxFit.contain,
                      allowDrawingOutsideViewBox: false,
                      excludeFromSemantics: true,
                    )
                  : Image.asset(
                      iconPath,
                      width: 70,
                      height: 73,
                      fit: BoxFit.contain,
                    ),
            ),
            // Removed bottom label to avoid duplicate text when SVG already includes labels
          ],
        ),
      ),
    );
  }


  Widget _buildBestServiceProviderSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final designWidth = 390.0;
    final scale = (screenWidth / designWidth).clamp(0.8, 1.2);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5 * scale),
            child: Text(
              'Best Service Provider',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF272727),
                height: 1.21,
              ),
            ),
          ),
          SizedBox(height: 15 * scale),
          Consumer<ServiceProviderProvider>(
            builder: (context, spProvider, _) {
              if (spProvider.isLoading) {
                return SizedBox(
                  height: 145 * scale,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              if (spProvider.error != null && spProvider.error!.isNotEmpty) {
                return SizedBox(
                  height: 145 * scale,
                  child: Center(
                    child: Text(
                      spProvider.error!,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        color: const Color(0xFFB00020),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final providers = _getProvidersForSelectedCategory(spProvider);
              if (providers.isEmpty) {
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

              final sorted = List<ServiceProviderModel>.from(providers)
                ..sort((a, b) => b.rating.compareTo(a.rating));

              return SizedBox(
                height: 145 * scale,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final svc = sorted[index];
                    final providerData = {
                      'name': svc.name,
                      'id': svc.id,
                      'profession': svc.serviceType,
                      'services': svc.serviceType,
                      'rating': svc.rating.toStringAsFixed(1),
                      'totalJobs': '${svc.jobsCompleted}',
                      'charges': svc.serviceCharge != null
                          ? 'Rs ${svc.serviceCharge} (Starting)'
                          : '',
                      'image': svc.imageUrl ?? '',
                    };

                    return Container(
                      margin: EdgeInsets.only(right: 15 * scale),
                      child: _buildBestProviderCard(providerData, scale),
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

  List<ServiceProviderModel> _getProvidersForSelectedCategory(ServiceProviderProvider provider) {
    final activeFilter = _activeFilterDto;
    final type = _categoryToServiceType(_selectedCategory);
    if (type != null) {
      return provider.getProviders(type, filter: activeFilter);
    }
    final merged = <ServiceProviderModel>[];
    for (final t in _serviceTypes) {
      merged.addAll(provider.getProviders(t, filter: activeFilter));
    }
    return merged;
  }

  String? _categoryToServiceType(String category) {
    switch (category.toLowerCase()) {
      case 'laundry':
        return 'LAUNDRY';
      case 'plumber':
        return 'PLUMBER';
      case 'electrician':
        return 'ELECTRICIAN';
      case 'painter':
        return 'PAINTER';
      case 'cleaning':
        return 'MAID';
      default:
        return null;
    }
  }

  Widget _buildBestProviderCard(Map<String, dynamic> provider, double scale) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceProviderDetailScreen(
              providerName: provider['name'] as String?,
              serviceType: provider['profession'] as String?,
              providerId: provider['id'] as String?,
            ),
          ),
        );
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
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
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildProfileImage(
                    (provider['image'] ?? '').isNotEmpty ? provider['image'] : null,
                    size: 110 * scale,
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
                      // Bottom section - Metrics
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
          // Heart icon at top right corner
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

  Widget _buildReviewSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final designWidth = 390.0;
    final scale = (screenWidth / designWidth).clamp(0.8, 1.2);

    // Reviews section: only shows data from backend. No hardcoded reviews.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5 * scale),
            child: Text(
              'Customer Reviews',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000000),
                height: 1.33,
              ),
            ),
          ),
          SizedBox(height: 15 * scale),
          Center(
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
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    String name,
    String productName,
    String rating,
    String ratingText,
    String review,
    String dateTime,
    String productImage,
    String profileImage,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.all(15 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section
          Row(
            children: [
              // Product Image (Left)
              Container(
                width: 60 * scale,
                height: 60 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(productImage),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1 * scale,
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              // Reviewer Info (Center)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Afacad',
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      productName,
                      style: TextStyle(
                        fontFamily: 'Afacad',
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFFF0000),
                      ),
                    ),
                    SizedBox(height: 4 * scale),
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
                          style: TextStyle(
                            fontFamily: 'Afacad',
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
              // Profile Image (Right)
              Container(
                width: 50 * scale,
                height: 50 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(profileImage),
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
          // Review Text
          Text(
            review,
            style: TextStyle(
              fontFamily: 'Afacad',
              fontSize: 13 * scale,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF000000),
              height: 1.5,
            ),
          ),
          SizedBox(height: 15 * scale),
          // Bottom Row: Helpful + DateTime
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Helpful ?',
                    style: TextStyle(
                      fontFamily: 'Afacad',
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 18 * scale,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4 * scale),
                  Container(
                    width: 1 * scale,
                    height: 18 * scale,
                    color: Colors.grey[400],
                  ),
                  SizedBox(width: 4 * scale),
                  Icon(
                    Icons.thumb_down_outlined,
                    size: 18 * scale,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              Text(
                dateTime,
                style: TextStyle(
                  fontFamily: 'Afacad',
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

  Widget _buildProfileImage(String? imageUrl, {double size = 45}) {
    final fallback = Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: size,
        color: Colors.grey,
      ),
    );

    if (imageUrl == null || imageUrl.isEmpty) return fallback;

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
