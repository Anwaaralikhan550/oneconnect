import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/promotion_provider.dart';
import '../widgets/sticky_footer.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  String? _selectedServiceLabel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchProvider>(context, listen: false).fetchPopular();
      Provider.of<PromotionProvider>(context, listen: false).fetchPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Main Content - Scrollable
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  
                  // Service Hub Section
                  _buildServiceHub(),
                  
                  const SizedBox(height: 20),
                  
                  // Featured Service Provider Section
                  _buildFeaturedServiceProviders(),
                  
                  const SizedBox(height: 20),
                  
                  // Promotions Section
                  _buildPromotionsSection(),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
      // Sticky Footer
      bottomNavigationBar: const StickyFooter(
        selectedIndex: 0, // Home is selected for All Services
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 118,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: Colors.black,
                ),
              ),
              
              // Title
              const Text(
                'All Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              
              // Placeholder for symmetry
              const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHub() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'All Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          
          // Services Grid - Expanded version with more services
          _buildServicesGrid(),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    final List<Map<String, String>> services = [
      {'icon': 'assets/images/laundry_icon.svg', 'label': 'Laundry'},
      {'icon': 'assets/images/plumber_icon.svg', 'label': 'Plumber'},
      {'icon': 'assets/images/electrician_icon.svg', 'label': 'Electrician'},
      {'icon': 'assets/images/painter_icon.svg', 'label': 'Painter'},
      {'icon': 'assets/images/carpenter_icon.svg', 'label': 'Carpenter'},
      {'icon': 'assets/images/barber_icon.svg', 'label': 'Barber'},
      {'icon': 'assets/images/maid_icon.svg', 'label': 'Maid'},
      {'icon': 'assets/images/salon_icon.svg', 'label': 'Salon'},
      {'icon': 'assets/images/real_estate_icon.svg', 'label': 'Real Estate'},
      {'icon': 'assets/images/health_icon.svg', 'label': 'Health'},
      {'icon': 'assets/images/water_icon.svg', 'label': 'Water'},
      {'icon': 'assets/images/gas_icon.svg', 'label': 'Gas'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.8, // Adjust aspect ratio to show labels properly
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildServiceItem(
            services[index]['icon']!,
            services[index]['label']!,
          );
        },
      ),
    );
  }

  Widget _buildServiceItem(String iconPath, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedServiceLabel = label;
        });
        debugPrint('Tapped on $label service');

        // Navigate to specific screens
        final lower = label.toLowerCase();
        if (lower == 'electrician') {
          Navigator.pushNamed(context, '/electricians');
        } else if (lower == 'real estate' || lower == 'property') {
          Navigator.pushNamed(context, '/property');
        } else if (lower == 'plumber') {
          Navigator.pushNamed(context, '/plumber');
        } else if (lower == 'painter') {
          Navigator.pushNamed(context, '/painter');
        } else if (lower == 'carpenter') {
          Navigator.pushNamed(context, '/carpenter');
        } else if (lower == 'laundry') {
          Navigator.pushNamed(context, '/laundry');
        } else if (lower == 'barber') {
          Navigator.pushNamed(context, '/barber');
        } else if (lower == 'maid') {
          Navigator.pushNamed(context, '/maid');
        } else if (lower == 'salon' || lower == 'beauty') {
          Navigator.pushNamed(context, '/beauty');
        } else if (lower == 'water') {
          Navigator.pushNamed(context, '/water');
        } else if (lower == 'gas') {
          Navigator.pushNamed(context, '/gas');
        } else if (lower == 'health' || lower == 'healthcare') {
          Navigator.pushNamed(context, '/doctors');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label service coming soon!'),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF00879F),
            ),
          );
        }
      },
      child: SvgPicture.asset(
        iconPath,
        width: 45,
        height: 50,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => SizedBox(
          width: 70,
          height: 73,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getServiceColor(label),
                  borderRadius: BorderRadius.circular(75),
                ),
                child: Icon(
                  _getServiceIcon(label),
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF383838),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getServiceColor(String label) {
    switch (label.toLowerCase()) {
      case 'laundry': return const Color(0xFFDFD3E3);
      case 'plumber': return const Color(0xFFAFDEFF);
      case 'electrician': return const Color(0xFFF6DFC5);
      case 'painter': return const Color(0xFFCCEBBC);
      case 'carpenter': return const Color(0xFFFBF8B4);
      case 'barber': return const Color(0xFFAFFFD1);
      case 'maid': return const Color(0xFFBDD0FF);
      case 'salon': return const Color(0xFFFFBDBD);
      case 'health': return const Color(0xFFFF4C4C);
      case 'water': return const Color(0xFF02A6C3);
      case 'gas': return const Color(0xFFFFD38D);
      default: return const Color(0xFFE0E0E0);
    }
  }

  IconData _getServiceIcon(String label) {
    switch (label.toLowerCase()) {
      case 'health': return Icons.local_hospital;
      case 'water': return Icons.water_drop;
      case 'gas': return Icons.local_gas_station;
      default: return Icons.build;
    }
  }


  Widget _buildFeaturedServiceProviders() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // Section header - exact Figma spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Featured Service Providers',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF272727),
                    height: 1.21,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Provider cards container - exact Figma layout
          Consumer<SearchProvider>(
            builder: (context, searchProvider, _) {
              final topServices = searchProvider.popular?['topServices'] as List?;
              final hasBackendData = topServices != null && topServices.isNotEmpty;

              if (!hasBackendData) {
                return SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Center(
                    child: Text(
                      'No service providers',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(topServices.length, (index) {
                      final svc = topServices[index] as Map<String, dynamic>;
                      final providerName = (svc['name'] as String?) ?? 'Provider';
                      final providerLocation = (svc['city'] as String?) ?? (svc['address'] as String?) ?? '';
                      final rating = (svc['rating'] as num?)?.toDouble() ?? 0.0;
                      final providerRating = rating.toStringAsFixed(1);
                      final providerReviews = '${svc['reviewCount'] ?? 0}';
                      final providerImage = svc['imageUrl'] as String?;
                      final isTopRated = index == 0; // First card gets the badge

                      return _buildProviderCard(
                        name: providerName,
                        location: providerLocation,
                        rating: providerRating,
                        reviews: providerReviews,
                        imageUrl: providerImage,
                        isTopRated: isTopRated,
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard({
    required String name,
    required String location,
    required String rating,
    required String reviews,
    String? imageUrl,
    bool isTopRated = false,
  }) {
    if (isTopRated) {
      // First provider card - with #1 Top Rated badge (shadow style, square image)
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 25,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile image container
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF044870),
                            width: 2,
                          ),
                        ),
                        child: _buildProfileImage(imageUrl, size: 45),
                      ),
                    ],
                  ),

                  SizedBox(width: 8),

                  // Provider information
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top section with info and heart
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Info column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top rated badge
                                    Text(
                                      '#1 Top Rated',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFF3F3F),
                                        letterSpacing: 0.168,
                                        height: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 4),

                                    // Provider name
                                    SizedBox(
                                      width: 144,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF353535),
                                          letterSpacing: 0.112,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4),

                                    // Location
                                    Text(
                                      location,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF000000),
                                        letterSpacing: 0.168,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Heart icon
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Icon(
                                  Icons.favorite_outline,
                                  size: 16,
                                  color: Color(0xFF8C8C8C),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 4),

                          // Rating section
                          Row(
                            children: [
                              // 5 stars
                              Row(
                                children: List.generate(5, (index) =>
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Icon(
                                      Icons.star,
                                      size: 15,
                                      color: Color(0xFFFFCD29),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),

                              // Rating and reviews
                              Text(
                                '$rating ($reviews Reviews)',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF353535),
                                  letterSpacing: 0.168,
                                  height: 1.3,
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
          ),
        ),
      );
    }

    // Non-top-rated provider card - without badge (border style, circular image)
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Color(0xFFEAEAEA),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile image container (smaller and circular)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF044870),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: _buildProfileImage(imageUrl, size: 30),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 8),

                // Provider information
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top section with info and heart
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Provider name (no badge)
                                  SizedBox(
                                    width: 144,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF353535),
                                        letterSpacing: 0.112,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),

                                  // Location
                                  Text(
                                    location,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF000000),
                                      letterSpacing: 0.168,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Heart icon
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Icon(
                                Icons.favorite_outline,
                                size: 16,
                                color: Color(0xFF8C8C8C),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4),

                        // Rating section
                        Row(
                          children: [
                            // 5 stars
                            Row(
                              children: List.generate(5, (index) =>
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Icon(
                                    Icons.star,
                                    size: 15,
                                    color: Color(0xFFFFCD29),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),

                            // Rating and reviews
                            Text(
                              '$rating ($reviews Reviews)',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF353535),
                                letterSpacing: 0.168,
                                height: 1.3,
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
        ),
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


  Widget _buildPromotionsSection() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                Text(
                  'Promotions',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF272727),
                    height: 1.21,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Promotional banners - horizontal scrolling
          Consumer<PromotionProvider>(
            builder: (context, promoProvider, _) {
              final backendPromos = promoProvider.promotions;
              final selected = _selectedServiceLabel?.toLowerCase();
              final filteredPromos = selected == null
                  ? backendPromos
                  : backendPromos.where((p) {
                      final name = p.businessName?.toLowerCase() ?? '';
                      final title = p.title.toLowerCase();
                      return name.contains(selected) || title.contains(selected);
                    }).toList();

              if (filteredPromos.isEmpty) {
                return SizedBox(
                  height: 135,
                  child: Center(
                    child: Text(
                      'No promotions available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 135,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(filteredPromos.length, (index) {
                      final promo = filteredPromos[index];
                      final imageSource = promo.imageUrl ?? '';
                      final title = promo.title;
                      final fallbackColor = Color(0xFF6B73FF);
                      final bool isLast = index == filteredPromos.length - 1;

                      return Container(
                        width: index == 0 ? 134.6 : 135,
                        height: 135,
                        margin: isLast ? EdgeInsets.zero : const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: _buildPromoImage(
                            imageSource,
                            title,
                            fallbackColor,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromoImage(String imageSource, String title, Color fallbackColor) {
    final fallback = Container(
      color: fallbackColor,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: title.length > 10 ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (imageSource.isEmpty) return fallback;

    if (imageSource.startsWith('http')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.asset(
      imageSource,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }

}

