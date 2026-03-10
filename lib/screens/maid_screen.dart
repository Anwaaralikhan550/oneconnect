import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider_provider.dart';
import '../widgets/sticky_footer.dart';
import 'search_screen.dart';
import 'service_provider_detail_screen.dart';
import '../mixins/responsive_mixin.dart';
import '../widgets/list_screen_header.dart';
import '../widgets/service_provider_card.dart';

class MaidScreen extends StatefulWidget {
  const MaidScreen({super.key});

  @override
  State<MaidScreen> createState() => _MaidScreenState();
}

class _MaidScreenState extends State<MaidScreen>
    with ResponsiveMixin {
  @override
  void initState() {
    super.initState();
    // Fetch maids from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProviderProvider>(context, listen: false)
          .fetchByType('MAID', force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DEBUG: [Maid] screen opened');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFEFEFEF),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            ListScreenHeader(
              title: 'Maids',
              categoryIconAsset: 'assets/icons/maid_header_icon.svg',
              iconWidth: 118,
              iconHeight: 118,
              onSearch: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            ),

            // Main Content - Scrollable List (data from backend)
            Expanded(
              child: Consumer<ServiceProviderProvider>(
                builder: (context, provider, child) {
                  final items = provider.getProviders('MAID');

                  if (provider.isLoading && items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No maids found'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => Provider.of<ServiceProviderProvider>(context, listen: false)
                        .fetchByType('MAID', force: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 25),
                          ...List.generate(items.length, (index) {
                            final e = items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: ServiceProviderCard(
                                index: index,
                                isTopRated: e.isTopRated,
                                name: e.name,
                                providerId: e.id,
                                location: e.address ?? e.city ?? '',
                                rating: e.rating.toStringAsFixed(1),
                                reviews: e.reviewCount.toString(),
                                profileImage: e.imageUrl,
                                fallbackIcon: Icons.cleaning_services,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ServiceProviderDetailScreen(
                                        providerName: e.name,
                                        serviceType: 'Maid',
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Sticky Footer
      bottomNavigationBar: StickyFooter(
        selectedIndex: 1,
        onItemTapped: (index) {
          _handleFooterNavigation(index);
        },
      ),
    );
  }







  void _handleFooterNavigation(int index) {
    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Search (current page context)
        Navigator.pushReplacementNamed(context, '/all-services');
        break;
      case 2: // Scan
        debugPrint('Scan tapped');
        break;
      case 3: // Call
        debugPrint('Call tapped');
        break;
      case 4: // Profile
        debugPrint('Profile tapped');
        break;
    }
  }
}
