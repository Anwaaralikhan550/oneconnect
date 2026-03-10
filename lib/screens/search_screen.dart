import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/filter_dto.dart';
import '../providers/auth_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/sticky_footer.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/figma_filter_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin, ResponsiveMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Recent searches list
  final List<String> _recentSearches = [];

  // Dynamic search suggestions state
  bool _showSuggestions = false;
  String _selectedLocationFilter = 'Area';
  String _selectedCategoryFilter = 'Service';
  String _selectedPriceFilter = 'Rs';

  // Debounce timer for search suggestions
  Timer? _debounceTimer;

  // Focus listener references (stored for cleanup in dispose)
  FocusScopeNode? _focusScopeNode;
  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();

    // Add listener for real-time search suggestions
    _searchController.addListener(_onSearchTextChanged);

    // Fetch popular searches from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      searchProvider.fetchPopular(force: true);
      searchProvider.fetchHistory();

      // Focus listener to hide suggestions when search bar loses focus
      _focusScopeNode = FocusScope.of(context);
      _focusListener = () {
        if (!(_focusScopeNode?.hasPrimaryFocus ?? false)) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _showSuggestions = false;
              });
            }
          });
        }
      };
      _focusScopeNode!.addListener(_focusListener);
    });
  }

  void _onSearchTextChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _debounceTimer?.cancel();
      setState(() {
        _showSuggestions = false;
      });
      Provider.of<SearchProvider>(context, listen: false).fetchSuggestions('');
      return;
    }

    // Debounce: wait 300ms after user stops typing before fetching suggestions
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        Provider.of<SearchProvider>(context, listen: false)
            .fetchSuggestions(query);
        setState(() {
          _showSuggestions = true;
        });
      }
    });
  }

  void _performSearch(String searchTerm) {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Add to recent searches if not already present
    final query = searchTerm.trim();
    if (query.isNotEmpty) {
      Provider.of<SearchProvider>(context, listen: false).saveToHistory(query);
    }
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        // Keep only last 5 recent searches
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }

    // Check if searching for specific service
    final lowerQuery = query.toLowerCase();
    if (lowerQuery == 'property' ||
        lowerQuery.contains('property') ||
        lowerQuery == 'real estate' ||
        lowerQuery.contains('real estate')) {
      Navigator.pushNamed(context, '/property');
    } else if (lowerQuery == 'electrician' || lowerQuery.contains('electrician')) {
      Navigator.pushNamed(context, '/electricians');
    } else {
      // Navigate to search results screen
      Navigator.pushNamed(
        context,
        '/search-results',
        arguments: {
          'query': searchTerm,
          'filter': _activeFilterDto.toQueryParams(),
        },
      );
    }
  }

  FilterDto get _activeFilterDto => FilterDto(
        latitude: Provider.of<AuthProvider>(context, listen: false).user?.locationLat,
        longitude: Provider.of<AuthProvider>(context, listen: false).user?.locationLng,
        category: _selectedCategoryFilter == 'Service'
            ? 'Service'
            : (_selectedCategoryFilter == 'Type' || _selectedCategoryFilter == 'Brand'
                ? 'Shop'
                : null),
        locationMode: _selectedLocationFilter == 'Distance'
            ? 'DISTANCE'
            : (_selectedLocationFilter == 'Block' ? 'BLOCK' : 'AREA'),
        priceTier: _selectedPriceFilter == 'Rs++'
            ? 'RS_PLUS_PLUS'
            : (_selectedPriceFilter == 'Rs+' ? 'RS_PLUS' : 'RS'),
        minRating: _selectedPriceFilter == 'Rs++'
            ? 4.0
            : (_selectedPriceFilter == 'Rs+' ? 3.5 : null),
      );

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
  }

  @override
  void dispose() {
    _focusScopeNode?.removeListener(_focusListener);
    _debounceTimer?.cancel();
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header Section
                  _buildResponsiveHeaderSection(context),
                  SizedBox(height: rw(15)),
                  // Search Input Field
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(15),
                      vertical: rw(20),
                    ),
                    child: _buildSearchInputField(context),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dynamic Search Suggestions - Show only when typing
                          if (_showSuggestions) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: rw(15),
                              ),
                              child: _buildResponsiveSearchSuggestions(context),
                            ),
                            SizedBox(
                                height: rw(20)),
                          ],

                          // Recent Searches Section
                          _buildResponsiveRecentSearchesSection(context),

                          SizedBox(height: rw(30)),

                          // Popular Searches in Shops Section
                          _buildResponsivePopularShopsSection(context),

                          SizedBox(height: rw(30)),

                          // Popular Searches in Services Section
                          _buildResponsivePopularServicesSection(context),

                          SizedBox(height: rw(20)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      bottomNavigationBar:
          const StickyFooter(selectedIndex: 1), // Search is index 1
    );
  }

  Widget _buildResponsiveHeaderSection(BuildContext context) {
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

  Widget _buildSearchInputField(BuildContext context) {
    return TextFormField(
                      controller: _searchController,
                      onTap: () {
                        if (_searchController.text.isNotEmpty) {
                          _onSearchTextChanged();
                        }
                      },
      onFieldSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _performSearch(value);
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
    );
  }

  Widget _buildResponsiveRecentSearchesSection(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        final backendHistory = provider.history
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        final backendEntries = backendHistory
            .map((e) => {
                  'id': (e['id'] ?? '').toString(),
                  'query': (e['query'] ?? '').toString().trim(),
                })
            .where((e) => (e['query'] ?? '').toString().isNotEmpty)
            .toList();

        final merged = <Map<String, String>>[];
        final seen = <String>{};

        for (final entry in backendEntries) {
          final query = entry['query']!.toLowerCase();
          if (seen.add(query)) {
            merged.add({'id': entry['id']!, 'query': entry['query']!});
          }
        }

        for (final search in _recentSearches) {
          final key = search.toLowerCase();
          if (seen.add(key)) {
            merged.add({'id': '', 'query': search});
          }
        }

        if (merged.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Searches',
                style: GoogleFonts.inter(
                  fontSize: rfs(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: rw(15)),
              ...merged.take(5).map(
                    (entry) => _buildRecentSearchItem(
                      context,
                      entry['query'] ?? '',
                      historyId: entry['id'],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentSearchItem(
    BuildContext context,
    String searchText, {
    String? historyId,
  }) {
    return GestureDetector(
      onTap: () {
        _searchController.text = searchText;
        _performSearch(searchText);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: rw(12)),
            child: Row(
              children: [
            // History icon - teal color
            SvgPicture.asset(
              'assets/icons/Reload Time.svg',
              width: rw(18),
              height: rw(18),
                          colorFilter: const ColorFilter.mode(
                Color(0xFF3195AB), // Green/Teal color
                            BlendMode.srcIn,
                          ),
                        ),
            SizedBox(width: rw(12)),
            // Search text
                Expanded(
              child: Text(
                searchText,
                style: GoogleFonts.inter(
                  fontSize: rfs(14),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF333333), // Dark gray/black
                      ),
                    ),
                  ),
            // X icon to clear - teal color
                GestureDetector(
                  onTap: () {
                setState(() {
                  _recentSearches.remove(searchText);
                });
                if (historyId != null && historyId.isNotEmpty) {
                  Provider.of<SearchProvider>(context, listen: false)
                      .deleteFromHistory(id: historyId);
                }
              },
                          child: SvgPicture.asset(
                            'assets/icons/close_icon.svg',
                width: rw(16),
                height: rw(16),
                            colorFilter: const ColorFilter.mode(
                  Color(0xFF3195AB), // Green/Teal color
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
      ),
    );
  }

  Widget _buildResponsivePopularShopsSection(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        final shops = _extractPopularShops(provider.popular);
        if (shops.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rw(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Text(
                'Popular searches in Shops',
                style: GoogleFonts.inter(
                  fontSize: rfs(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333), // Dark gray/black
                ),
              ),
              SizedBox(height: rw(15)),
              // Popular Search Tags
              Wrap(
                spacing: rw(10),
                runSpacing: rw(10),
                children: shops
                    .map((shop) =>
                        _buildResponsivePopularSearchTag(context, shop))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsivePopularServicesSection(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        final services = _extractPopularServices(provider.popular);
        if (services.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rw(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Text(
                'Popular searches in Services',
                style: GoogleFonts.inter(
                  fontSize: rfs(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333), // Dark gray/black
                ),
              ),
              SizedBox(height: rw(15)),
              // Popular Search Tags
              Wrap(
                spacing: rw(10),
                runSpacing: rw(10),
                children: services
                    .map((service) =>
                        _buildResponsivePopularSearchTag(context, service))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _extractPopularShops(Map<String, dynamic>? popular) {
    if (popular == null) return const [];
    final values = <String>[];
    final seen = <String>{};

    for (final raw in (popular['topBusinesses'] as List?) ?? const []) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final name = (map['name'] ?? '').toString().trim();
      if (name.isNotEmpty && seen.add(name.toLowerCase())) {
        values.add(name);
      }
    }
    for (final raw in (popular['topAmenities'] as List?) ?? const []) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final name = (map['name'] ?? '').toString().trim();
      if (name.isNotEmpty && seen.add(name.toLowerCase())) {
        values.add(name);
      }
    }
    return values.isNotEmpty ? values.take(8).toList() : const [];
  }

  List<String> _extractPopularServices(Map<String, dynamic>? popular) {
    if (popular == null) return const [];
    final values = <String>[];
    final seen = <String>{};
    for (final raw in (popular['topServices'] as List?) ?? const []) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final serviceType = (map['serviceType'] ?? '').toString().trim();
      final name = (map['name'] ?? '').toString().trim();
      final display = serviceType.isNotEmpty ? serviceType : name;
      if (display.isNotEmpty && seen.add(display.toLowerCase())) {
        values.add(display);
      }
    }
    return values.isNotEmpty ? values.take(8).toList() : const [];
  }

  Widget _buildResponsivePopularSearchTag(BuildContext context, String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _performSearch(text);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: rw(16),
          vertical: rw(10),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // White background
          borderRadius: BorderRadius.circular(rw(20)),
          border: Border.all(
            color: const Color(0xFFDDDDDD), // Light gray border
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: rfs(14),
            fontWeight: FontWeight.w400,
            color: const Color(0xFF333333), // Dark gray/black text
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveSearchSuggestions(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        final suggestions = provider.suggestions.take(3).toList();
        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: rw(15)),
          child: Column(
            children: suggestions
                .map((suggestion) => _buildResponsiveSuggestionItem(
                    context, suggestion.name, suggestion.type))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveSuggestionItem(
      BuildContext context, String text, String category) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _debounceTimer?.cancel();
        setState(() {
          _showSuggestions = false;
        });
        // Trigger search action - could navigate to results or filter existing content
        _performSearch(text);
      },
      child: Container(
        width: double.infinity,
        height: rh(64), // Increased height to accommodate text content
        margin: EdgeInsets.only(
            bottom: rw(10)), // Proper spacing between suggestions
        padding: EdgeInsets.symmetric(
          horizontal: rw(16), // Precise padding matching Figma
          vertical: rw(12),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // Pure white background
          borderRadius:
          BorderRadius.circular(rw(12)), // Rounded corners matching Figma
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000)
                  .withOpacity(0.08), // Subtle shadow for depth
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container - rounded square with exact grey background from Figma
            Container(
              width: rw(34), // Icon container size from Figma
              height: rw(34),
              decoration: BoxDecoration(
                color: const Color(
                    0xFFF2F2F2), // Exact icon background color from Figma
                borderRadius: BorderRadius.circular(rw(8)), // Rounded square
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/search_icon.svg',
                  width: rw(18), // Icon size
                  height: rw(18),
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF898989), // Icon color matching Figma
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            SizedBox(
                width: rw(14)), // Spacing between icon and text

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Minimize column size
                children: [
                  // Main suggestion text - matching Figma typography
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, // Medium weight for main text
                      fontSize: rfs(15),
                      height: 1.2, // Reduced line height to prevent overflow
                      letterSpacing: -0.2, // Tight letter spacing
                      color: const Color(0xFF000000), // Pure black text
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(
                      height:
                          rw(2)), // Reduced spacing

                  // Category text - secondary information
                  Text(
                    category,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400, // Regular weight for category
                      fontSize: rfs(12),
                      height: 1.1, // Reduced line height
                      letterSpacing: -0.1,
                      color: const Color(0xFF898989), // Grey color for category text
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
    );
  }
}

