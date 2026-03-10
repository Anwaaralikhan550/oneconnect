import 'package:flutter/material.dart';

class SlideMenu extends StatefulWidget {
  const SlideMenu({super.key});

  @override
  State<SlideMenu> createState() => _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu> {
  bool _isMenuOpen = false;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  String _searchQuery = '';

  // Services data - exactly as shown in Figma
  final List<Map<String, dynamic>> _allServices = [
    {'name': 'Laundry', 'icon': Icons.dry_cleaning, 'route': '/laundry'},
    {'name': 'Electrician', 'icon': Icons.electrical_services, 'route': '/electricians'},
    {'name': 'Plumber', 'icon': Icons.plumbing, 'route': '/plumber'},
    {'name': 'Painter', 'icon': Icons.format_paint, 'route': '/painter'},
    {'name': 'Beauty', 'icon': Icons.face, 'route': '/beauty'},
    {'name': 'Barber', 'icon': Icons.content_cut, 'route': '/barber'},
    {'name': 'Maid', 'icon': Icons.cleaning_services, 'route': '/maid'},
    {'name': 'Carpenter', 'icon': Icons.handyman, 'route': '/carpenter'},
  ];

  List<Map<String, dynamic>> get _filteredServices {
    if (_searchQuery.isEmpty) {
      return _allServices;
    }

    // Enhanced search: Check both name and common keywords
    return _allServices.where((service) {
      final serviceName = service['name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      // Direct name match
      if (serviceName.contains(query)) {
        return true;
      }

      // Keyword matching for better search experience
      final keywords = _getServiceKeywords(serviceName);
      return keywords.any((keyword) => keyword.contains(query));
    }).toList();
  }

  List<String> _getServiceKeywords(String serviceName) {
    switch (serviceName) {
      case 'laundry':
        return ['wash', 'clean', 'clothes', 'dry', 'iron'];
      case 'electrician':
        return ['electric', 'wiring', 'power', 'light', 'socket', 'repair'];
      case 'plumber':
        return ['pipe', 'water', 'leak', 'drain', 'toilet', 'sink'];
      case 'painter':
        return ['paint', 'wall', 'color', 'interior', 'exterior'];
      case 'barber':
        return ['hair', 'cut', 'salon', 'style', 'shave'];
      case 'beauty':
        return ['salon', 'makeup', 'facial', 'spa', 'cosmetic'];
      case 'maid':
        return ['clean', 'house', 'cleaning', 'domestic', 'home'];
      case 'carpenter':
        return ['wood', 'furniture', 'door', 'window', 'repair'];
      default:
        return [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToService(String serviceName, String route) {
    _closeMenu();

    // Navigate to the specific service screen
    Navigator.pushNamed(context, route);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigating to $serviceName services'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF00879F),
        ),
      );
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00879F),
      body: Stack(
        children: [
          // Main Screen (State=Menu Closed)
          if (!_isMenuOpen) _buildMainScreen(),

          // Menu Open State
          if (_isMenuOpen) _buildMenuOpenState(),
        ],
      ),
    );
  }

  Widget _buildMainScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF00879F),
      child: Column(
        children: [
          // Header with hamburger menu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildHamburgerButton(),
                  const Spacer(),
                  const Text(
                    'OneConnect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 33),
                ],
              ),
            ),
          ),
          // Main content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Text(
                  'Main Screen Content\n\nTap the hamburger menu to see the slide menu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF00879F),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOpenState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth,
      height: screenHeight,
      color: const Color(0xFF00879F),
      child: Stack(
        children: [
          // Services Screen (left panel)
          _buildServicesScreen(),

          // Main Screen Preview (right panel)
          _buildMainScreenPreview(),
        ],
      ),
    );
  }

  Widget _buildHamburgerButton() {
    return GestureDetector(
      onTap: _toggleMenu,
      child: SizedBox(
        width: 33,
        height: 31,
        child: Stack(
          children: [
            // Hamburger lines
            Positioned(
              left: 1,
              top: 6,
              child: Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: 1,
              top: 14,
              child: Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: 1,
              top: 22,
              child: Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Small circle
            Positioned(
              right: 1,
              top: 17,
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    // Responsive positioning and sizing - adjust left offset for better visibility
    final leftOffset = isSmallScreen ? -20.0 : isTablet ? -50.0 : -75.0;
    final topOffset = isSmallScreen ? 23.0 : 23.0;
    final servicesWidth = isSmallScreen
        ? screenWidth * 0.95
        : isTablet
            ? screenWidth * 0.75
            : 595.0;
    final servicesHeight = isSmallScreen
        ? screenHeight * 0.79
        : isTablet
            ? screenHeight * 0.79
            : 666.0;

    // Scale factors for responsive positioning
    final scaleFactor = isSmallScreen ? 0.9 : isTablet ? 0.95 : 1.0;

    return Positioned(
      left: leftOffset,
      top: topOffset,
      child: Container(
        width: servicesWidth,
        height: servicesHeight,
        color: const Color(0xFF00879F),
        child: Stack(
          children: [
            // Close Button (moved more to the left for better visibility)
            Positioned(
              left: isSmallScreen ? 75 : isTablet ? 90 : 101,
              top: 0,
              child: _buildCloseButton(),
            ),

            // Title Text (centered in services panel)
            Positioned(
              left: 20,
              right: 20,
              top: 44 * scaleFactor,
              child: SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    'Which service are you looking for today',
                    style: TextStyle(
                      fontFamily: 'Afacad',
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 20 : isTablet ? 23 : 25,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            ),

            // Search Bar (centered and fully visible)
            Positioned(
              left: 20,
              right: 20,
              top: 114 * scaleFactor,
              child: _buildSearchBar(isSmallScreen: isSmallScreen, isTablet: isTablet),
            ),

            // Service Items - positioned with responsive scaling
            ..._buildServiceItems(scaleFactor: scaleFactor),

            // "See all services" button (centered)
            Positioned(
              left: 20,
              right: 20,
              top: (630 * scaleFactor).clamp(0, servicesHeight - 50),
              child: GestureDetector(
                onTap: () {
                  _closeMenu();
                  Navigator.pushNamed(context, '/all-services');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      'See all services',
                      style: TextStyle(
                        fontFamily: 'Afacad',
                        fontWeight: FontWeight.w700,
                        fontSize: isSmallScreen ? 14 : 16,
                        color: const Color(0xFFFFDE59),
                        height: 1.33,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Animated Rectangle (background highlight) - responsive
            if (!isSmallScreen)
              Positioned(
                left: 335 * scaleFactor,
                top: 196 * scaleFactor,
                child: Container(
                  width: 260,
                  height: 470,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity( 0.35),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreenPreview() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    // Responsive positioning and sizing for main screen preview
    final previewLeft = isSmallScreen
        ? screenWidth * 0.65
        : isTablet
            ? screenWidth * 0.6
            : 288.0;
    final previewTop = isSmallScreen
        ? screenHeight * 0.25
        : isTablet
            ? screenHeight * 0.25
            : 208.0;
    final previewWidth = isSmallScreen
        ? screenWidth * 0.3
        : isTablet
            ? screenWidth * 0.35
            : 233.0;
    final previewHeight = isSmallScreen
        ? screenHeight * 0.6
        : isTablet
            ? screenHeight * 0.6
            : 504.0;

    return Positioned(
      left: previewLeft,
      top: previewTop,
      child: Container(
        width: previewWidth,
        height: previewHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity( 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Column(
            children: [
              // Header preview with responsive height
              Container(
                height: previewHeight * 0.16,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    colors: [
                      Color(0xFF5DE0E6),
                      Color(0xFF054870),
                    ],
                    stops: [0.0, 0.55],
                  ),
                ),
                child: Center(
                  child: Text(
                    'OneConnect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 10 : isTablet ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Content area
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      'Main Screen\nContent',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF00879F),
                        fontSize: isSmallScreen ? 10 : isTablet ? 12 : 14,
                      ),
                    ),
                  ),
                ),
              ),
              // Footer preview with responsive height
              Container(
                height: previewHeight * 0.12,
                color: const Color(0xFFF5F6F7),
                child: Center(
                  child: Text(
                    'Footer',
                    style: TextStyle(
                      color: const Color(0xFF00879F),
                      fontSize: isSmallScreen ? 8 : isTablet ? 10 : 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: _closeMenu,
      child: SizedBox(
        width: 53,
        height: 40,
        child: Stack(
          children: [
            // Top line (rotated)
            Positioned(
              left: -2.1,
              top: -5.9,
              child: Transform.rotate(
                angle: 0.785398, // 45 degrees in radians
                child: Container(
                  width: 36.1,
                  height: 3,
                  color: Colors.white,
                ),
              ),
            ),
            // Bottom line (rotated)
            Positioned(
              left: -2.28,
              top: -7,
              child: Transform.rotate(
                angle: -0.785398, // -45 degrees in radians
                child: Container(
                  width: 36.1,
                  height: 3,
                  color: Colors.white,
                ),
              ),
            ),
            // Circle
            Positioned(
              left: 12,
              top: 7,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar({bool isSmallScreen = false, bool isTablet = false}) {
    final fontSize = isSmallScreen ? 12.0 : isTablet ? 13.0 : 14.0;
    final hintFontSize = isSmallScreen ? 11.0 : isTablet ? 12.0 : 13.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity( 0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity( 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.white,
            size: isSmallScreen ? 18 : 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              enableInteractiveSelection: false,
              contextMenuBuilder: (context, state) => const SizedBox.shrink(),
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
              ),
              decoration: InputDecoration(
                hintText: isSmallScreen
                    ? 'Search services...'
                    : 'Search services (e.g., cleaning, repair)...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity( 0.7),
                  fontSize: hintFontSize,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                if (_filteredServices.isNotEmpty) {
                  _navigateToService(
                    _filteredServices.first['name'],
                    _filteredServices.first['route'],
                  );
                }
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              child: Icon(
                Icons.clear,
                color: Colors.white.withOpacity( 0.7),
                size: isSmallScreen ? 16 : 18,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildServiceItems({double scaleFactor = 1.0}) {
    final servicesToShow = _filteredServices.length > 8 ? _filteredServices.take(8).toList() : _filteredServices;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    List<Widget> items = [];

    // Center all service items with responsive positioning
    for (int i = 0; i < servicesToShow.length; i++) {
      final service = servicesToShow[i];
      final topPosition = (190 + (i * 55.0)) * scaleFactor;

      // Service Item Row - centered layout
      items.add(
        Positioned(
          left: 20,
          right: 20,
          top: topPosition,
          child: GestureDetector(
            onTap: () => _navigateToService(service['name'], service['route']),
            child: SizedBox(
              height: isSmallScreen ? 40 : 45,
              child: Row(
                children: [
                  // Spacer for centering
                  Expanded(flex: 1, child: Container()),

                  // Service Icon
                  Container(
                    width: isSmallScreen ? 30 : 35,
                    height: isSmallScreen ? 30 : 35,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity( 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      service['icon'],
                      color: Colors.white,
                      size: isSmallScreen ? 16 : 20,
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Service Text
                  SizedBox(
                    width: isSmallScreen ? 80 : 100,
                    child: Text(
                      service['name'],
                      style: TextStyle(
                        fontFamily: 'Afacad',
                        fontWeight: FontWeight.w700,
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white,
                        height: 1.33,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Spacer for centering
                  Expanded(flex: 1, child: Container()),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Show "No results" if search returns empty - centered
    if (_filteredServices.isEmpty && _searchQuery.isNotEmpty) {
      items.add(
        Positioned(
          left: 20,
          right: 20,
          top: 200 * scaleFactor,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No services found',
                style: TextStyle(
                  fontFamily: 'Afacad',
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return items;
  }

}
