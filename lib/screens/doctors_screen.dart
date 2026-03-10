import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider_provider.dart';
import '../widgets/sticky_footer.dart';
import 'search_screen.dart';
import 'service_provider_detail_screen.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/list_screen_header.dart';
import '../widgets/service_provider_card.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen>
    with ResponsiveMixin {
  int _selectedTabIndex = 0;

  // Figma exact tab labels
  final List<String> _tabs = [
    'All',
    'General Physician',
    'Pediatric',
    'gynecologist',
    'Cardiac',
    'Dentist',
    'Psychologist',
    'Physiotherapist',
    'ENT',
  ];

  // Doctor categories are built dynamically from backend data


  @override
  void initState() {
    super.initState();
    // Fetch doctors from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProviderProvider>(context, listen: false)
          .fetchByType('DOCTOR', force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        // Figma: gradient from white to #EFEFEF
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFEFEFEF),
            ],
          ),
        ),
        child: Column(
          children: [
            // HEADER - sticky
            ListScreenHeader(
              title: 'Doctors',
              categoryIconAsset: 'assets/icons/header_doctor_icon.svg',
              onSearch: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            ),
            // Main scrollable content (data from backend)
            Expanded(
              child: Consumer<ServiceProviderProvider>(
                builder: (context, provider, child) {
                  final doctors = provider.getProviders('DOCTOR');

                  if (provider.isLoading && doctors.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (doctors.isEmpty) {
                    return const Center(
                      child: Text('No doctors found'),
                    );
                  }

                  // Filter by selected tab
                  final filtered = _selectedTabIndex == 0
                      ? doctors
                      : doctors.where((d) => d.categoryName == _tabs[_selectedTabIndex]).toList();

                  return Column(
                    children: [
                      _buildCategoryTabs(),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text('No doctors in this category'))
                            : RefreshIndicator(
                                onRefresh: () => Provider.of<ServiceProviderProvider>(context, listen: false)
                                    .fetchByType('DOCTOR', force: true),
                                child: SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 25),
                                      ...List.generate(filtered.length, (index) {
                                        final e = filtered[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 15),
                                          child: ServiceProviderCard(
                                            index: index,
                                            isTopRated: e.isTopRated,
                                            name: e.name,
                                            providerId: e.id,
                                            location: e.categoryName ?? e.address ?? e.city ?? '',
                                            rating: e.rating.toStringAsFixed(1),
                                            reviews: e.reviewCount.toString(),
                                            profileImage: e.imageUrl,
                                            fallbackIcon: Icons.person,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ServiceProviderDetailScreen(
                                                    providerName: e.name,
                                                    serviceType: 'Doctor',
                                                    specialty: e.categoryName,
                                                    providerId: e.id,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 100),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StickyFooter(
        selectedIndex: 1,
        onItemTapped: _handleFooterNavigation,
      ),
    );
  }

  // HEADER: same style as Store/Solar list screens

  // Category Tabs: horizontal scroll, gap=10, padding=[10,15]
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: rh(54),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: rw(15),
          vertical: rh(10),
        ),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: EdgeInsets.only(right: rw(10)),
              padding: EdgeInsets.symmetric(
                horizontal: rw(16),
                vertical: rh(9),
              ),
              decoration: BoxDecoration(
                // Active: neutral-600 (dark gray), Inactive: #EFEFEF
                color: isSelected
                    ? const Color(0xFF525252)
                    : const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  _tabs[index],
                  style: GoogleFonts.poppins(
                    fontSize: rfs(13),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.112,
                    height: 1.2,
                    // Active: white, Inactive: rgba(0,0,0,0.5)
                    color: isSelected
                        ? Colors.white
                        : Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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
