import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../services/user_service.dart';
import 'service_provider_detail_screen.dart';
import 'grocery_store_screen.dart';
import 'cafe_detail_screen.dart';
import 'gym_detail_screen.dart';
import 'healthcare_detail_screen.dart';
import 'park_detail_screen.dart';
import 'pharmacy_detail_screen.dart';
import 'school_detail_screen.dart';
import 'mosque_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  late final TabController _tabController;

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _serviceFavorites = const [];
  List<Map<String, dynamic>> _businessFavorites = const [];
  List<Map<String, dynamic>> _amenityFavorites = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _userService.getFavorites();
      final items = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

      final services = <Map<String, dynamic>>[];
      final businesses = <Map<String, dynamic>>[];
      final amenities = <Map<String, dynamic>>[];

      for (final item in items) {
        final type = (item['targetType'] ?? '').toString().toUpperCase();
        if (type == 'SERVICE_PROVIDER') {
          services.add(item);
        } else if (type == 'BUSINESS') {
          businesses.add(item);
        } else if (type == 'AMENITY') {
          amenities.add(item);
        }
      }

      if (!mounted) return;
      setState(() {
        _serviceFavorites = services;
        _businessFavorites = businesses;
        _amenityFavorites = amenities;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favorites'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Services'),
            Tab(text: 'Businesses'),
            Tab(text: 'Amenities'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_serviceFavorites),
                      _buildList(_businessFavorites),
                      _buildList(_amenityFavorites),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load favorites'),
            const SizedBox(height: 8),
            Text(_error ?? '', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadFavorites, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      return const Center(child: Text('No favorites yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final row = rows[index];
        final type = (row['targetType'] ?? '').toString().toUpperCase();
        final entity = _entityFromFavorite(row, type);
        final entityId = (entity['id'] ?? '').toString();
        final title = (entity['name'] ?? entity['title'] ?? 'Untitled').toString();
        final subtitle = _subtitleFor(entity, type);

        return Consumer<FavoriteProvider>(
          builder: (context, favProvider, _) {
            final isPending = entityId.isNotEmpty && favProvider.isPending(entityId);
            return ListTile(
              tileColor: const Color(0xFFF7F9FB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(_iconFor(type), color: const Color(0xFF3195AB)),
              ),
              title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: isPending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () async {
                        await _toggleFavorite(type, entityId, favProvider);
                        await _loadFavorites();
                      },
                    ),
              onTap: () => _openDetail(type, entity),
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _entityFromFavorite(Map<String, dynamic> row, String type) {
    if (type == 'SERVICE_PROVIDER') {
      final v = row['serviceProvider'];
      if (v is Map) return Map<String, dynamic>.from(v);
    }
    if (type == 'BUSINESS') {
      final v = row['business'];
      if (v is Map) return Map<String, dynamic>.from(v);
    }
    if (type == 'AMENITY') {
      final v = row['amenity'];
      if (v is Map) return Map<String, dynamic>.from(v);
    }
    return <String, dynamic>{};
  }

  String _subtitleFor(Map<String, dynamic> entity, String type) {
    if (type == 'SERVICE_PROVIDER') {
      return (entity['serviceType'] ?? 'Service Provider').toString();
    }
    if (type == 'BUSINESS') {
      return (entity['category'] ?? 'Business').toString();
    }
    return (entity['amenityType'] ?? 'Amenity').toString();
  }

  IconData _iconFor(String type) {
    if (type == 'SERVICE_PROVIDER') return Icons.build;
    if (type == 'BUSINESS') return Icons.store;
    return Icons.place;
  }

  Future<void> _toggleFavorite(
    String type,
    String id,
    FavoriteProvider favoriteProvider,
  ) async {
    if (id.isEmpty) return;
    if (type == 'SERVICE_PROVIDER') {
      await favoriteProvider.toggleServiceProviderFavorite(id);
      return;
    }
    if (type == 'BUSINESS') {
      await favoriteProvider.toggleBusinessFavorite(id);
      return;
    }
    if (type == 'AMENITY') {
      await favoriteProvider.toggleAmenityFavorite(id);
    }
  }

  void _openDetail(String type, Map<String, dynamic> entity) {
    final id = entity['id']?.toString();
    if (id == null || id.isEmpty) return;

    if (type == 'SERVICE_PROVIDER') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceProviderDetailScreen(
            providerId: id,
            providerName: entity['name']?.toString(),
            serviceType: entity['serviceType']?.toString(),
          ),
        ),
      );
      return;
    }

    if (type == 'BUSINESS') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroceryStoreScreen(
            storeData: {
              'id': id,
              'name': entity['name'],
              'category': entity['category'],
              'rating': entity['rating'],
              'image': entity['imageUrl'],
            },
          ),
        ),
      );
      return;
    }

    final typeLabel = entity['amenityType']?.toString();
    final data = {
      'id': id,
      'name': entity['name'],
      'rating': entity['rating'],
      'image': entity['imageUrl'],
    };

    Widget screen;
    switch (typeLabel) {
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

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
