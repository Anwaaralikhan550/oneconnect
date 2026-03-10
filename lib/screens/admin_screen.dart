import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/search_result_model.dart';
import '../models/amenity_model.dart';
import '../services/admin_office_service.dart';
import '../services/amenity_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile_image.dart';
import '../widgets/list_screen_header.dart';
import 'admin_detail_screen.dart';
import 'search_screen.dart';
import '../mixins/responsive_mixin.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with ResponsiveMixin {
  final AdminOfficeService _adminService = AdminOfficeService();
  final AmenityService _amenityService = AmenityService();
  List<_UnifiedAdminItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final userLat = user?.locationLat;
    final userLng = user?.locationLng;

    final officesFuture = _adminService.getAll()
        .then<List<AdminOfficeModel>?>((value) => value)
        .catchError((_) => null);
    final amenitiesFuture = _amenityService.getByType('ADMIN')
        .then<List<AmenityModel>?>((value) => value)
        .catchError((_) => null);

    final results = await Future.wait([officesFuture, amenitiesFuture]);
    final offices = results[0] as List<AdminOfficeModel>?;
    final amenities = results[1] as List<AmenityModel>?;

    final mergedById = <String, _UnifiedAdminItem>{};

    if (offices != null) {
      for (final office in offices) {
        final normalized = _UnifiedAdminItem.fromOffice(
          office,
          userLat: userLat,
          userLng: userLng,
        );
        mergedById[normalized.id] = normalized;
      }
    }

    if (amenities != null) {
      for (final amenity in amenities) {
        final normalized = _UnifiedAdminItem.fromAmenity(
          amenity,
          userLat: userLat,
          userLng: userLng,
        );
        final existing = mergedById[normalized.id];
        mergedById[normalized.id] = existing == null
            ? normalized
            : existing.mergeWith(normalized);
      }
    }

    if (!mounted) return;

    setState(() {
      _items = mergedById.values.toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
      _isLoading = false;
      _error = (offices == null && amenities == null)
          ? 'Unable to load admin data right now.'
          : null;
    });
  }

  // Figma base: 390 x 844 - responsive scaling

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Figma: #FFFFFF
      body: Column(
        children: [
          // Header - Figma: 390x118, bg #F2F2F2
          ListScreenHeader(
            title: 'Community\nAdministration',
            categoryIconAsset: 'assets/images/admin_icon_hub.svg',
            onSearch: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          // Scrollable content (data from backend)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_error != null && _items.isEmpty)
                    ? Center(child: Text(_error!))
                    : _items.isEmpty
                    ? const Center(child: Text('No admin offices found'))
                    : SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: rh(16)),
                            _buildAdministrationOfficeSection(),
                            SizedBox(height: rh(25)),
                            _buildEmergencyContactSection(),
                            SizedBox(height: rh(30)),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }


  Widget _buildAdministrationOfficeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header - Figma: building icon 25x23.44 #474747 + title
        Padding(
          padding: EdgeInsets.only(left: rw(20)),
          child: Row(
            children: [
              // Building icon - Figma: 25x23.44, #474747 (rgb 0.279)
              Image.asset(
                'assets/images/vaadin_office.png',
                width: rw(25),
                height: rw(25),
                color: const Color(0xFF474747),
              ),
              SizedBox(width: rw(10)),
              // Title - Figma: "Administration Office", #282828 (rgb 0.158), 18px
              Text(
                'Administration Office',
                style: GoogleFonts.inter(
                  fontSize: rfs(18),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF282828),
                  letterSpacing: 0.168,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rh(12)),
        // Horizontal scrollable cards - data from backend
        SizedBox(
          height: rh(210),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: rw(17.5), right: rw(10)),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: rw(15)),
                child: _buildAdministrationCard(_items[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdministrationCard(_UnifiedAdminItem office) {
    final officeMap = _toAdminDataMap(office);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDetailScreen(adminData: officeMap),
          ),
        );
      },
      child: Container(
        width: rw(355),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(25)),
        border: Border.all(
          color: Colors.black.withOpacity(0.15),
          width: 1,
        ),
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
          // Image - Figma: 343x135, padding 6
          Padding(
            padding: EdgeInsets.all(rw(6)),
            child: SizedBox(
              width: rw(343),
              height: rh(135),
              child: Stack(
                children: [
                  // Main image - Figma: border-radius 20
                  ClipRRect(
                    borderRadius: BorderRadius.circular(rw(20)),
                    child: SizedBox(
                      width: rw(343),
                      height: rh(135),
                      child: buildProfileImage(
                        office.imageUrl,
                        fallbackIcon: Icons.apartment,
                        iconSize: rw(50),
                      ),
                    ),
                  ),
                  // Rating badge - Figma: top-left, white bg
                  Positioned(
                    top: rh(6),
                    left: rw(5),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(8),
                        vertical: rh(5),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rw(14)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Star - Figma: #FFCD29
                          Icon(
                            Icons.star,
                            size: rw(12.53),
                            color: const Color(0xFFFFCD29),
                          ),
                          SizedBox(width: rw(3)),
                          // Rating
                          Text(
                            office.rating.toStringAsFixed(1),
                            style: GoogleFonts.roboto(
                              fontSize: rfs(11),
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: rw(2)),
                          // Reviews
                          Text(
                            '',
                            style: GoogleFonts.inter(
                              fontSize: rfs(9),
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Heart icon - Figma: #FF5050
                  Positioned(
                    bottom: rh(8),
                    right: rw(10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        size: rw(18.67),
                        color: const Color(0xFFFF5050),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info row - name, distance, Open, Map
          Padding(
            padding: EdgeInsets.fromLTRB(rw(12), 0, rw(12), rh(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Name + Distance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name - Oswald 16px
                      Text(
                        office.name,
                        style: GoogleFonts.oswald(
                          fontSize: rfs(16),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: rh(2)),
                      // Distance - red location icon
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: rw(11.84),
                            color: const Color(0xFFFF0000),
                          ),
                          SizedBox(width: rw(2)),
                          Text(
                            office.distanceLabel ?? office.address ?? 'Nearby',
                            style: GoogleFonts.oswald(
                              fontSize: rfs(11),
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right: Open + Map
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Open row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.door_front_door_outlined,
                          size: rw(16),
                          color: const Color(0xFF474747),
                        ),
                        SizedBox(width: rw(2)),
                        Text(
                          office.isOpen ? 'Open' : 'Closed',
                          style: GoogleFonts.oswald(
                            fontSize: rfs(11),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF073A6A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rh(4)),
                    // Map row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: rw(18),
                          color: const Color(0xFF6A6A6A),
                        ),
                        SizedBox(width: rw(2)),
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

  Widget _buildEmergencyContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header - Figma: contact icon 25x25 #474747 + title
        Padding(
          padding: EdgeInsets.only(left: rw(20)),
          child: Row(
            children: [
              // Contact icon - Figma: 25x18.75, #474747 (rgb 0.279)
              Image.asset(
                'assets/images/material-symbols_contact-phone.png',
                width: rw(25),
                height: rw(25),
                color: const Color(0xFF474747),
              ),
              SizedBox(width: rw(10)),
              // Title - Figma: "Anchorage Emergency Contact", #282828 (rgb 0.158), 18px
              Expanded(
                child: Text(
                  'Anchorage Emergency Contact',
                  style: GoogleFonts.inter(
                    fontSize: rfs(18),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF282828),
                    letterSpacing: 0.168,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rh(15)),
        // Contact cards - data from backend
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rw(15)),
          child: Column(
            children: _items.map((office) {
              return Padding(
                padding: EdgeInsets.only(bottom: rh(20)),
                child: _buildContactCard(office),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(_UnifiedAdminItem contact) {
    final contactMap = _toAdminDataMap(contact);
    // Figma: 360x101, border-radius 25, shadow blur 5.3
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDetailScreen(adminData: contactMap),
          ),
        );
      },
      child: Container(
        width: rw(360),
        height: rh(101),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(25)),
        border: Border.all(
          color: Colors.black.withOpacity(0.15), // Figma: rgba(0,0,0,0.15)
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10), // Figma: rgba(0,0,0,0.25)
            blurRadius: 14, // Figma: blur 5.3
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(rw(10)),
      child: Row(
        children: [
          // Circular thumbnail - Figma: 81x81
          ClipOval(
            child: SizedBox(
              width: rw(81),
              height: rw(81),
              child: buildProfileImage(
                contact.imageUrl,
                fallbackIcon: Icons.contact_phone,
                iconSize: rw(30),
              ),
            ),
          ),
          SizedBox(width: rw(12)),
          // Info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name - Figma: Inter SemiBold 15px, #000000
                Text(
                  contact.name,
                  style: GoogleFonts.inter(
                    fontSize: rfs(15),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: rh(4)),
                // Distance - Figma: red location 11.84x14.38 + Oswald 11px
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: rw(11.84),
                      color: const Color(0xFFFF0000), // Figma: #FF0000
                    ),
                    SizedBox(width: rw(2)),
                    Text(
                      contact.distanceLabel ?? contact.address ?? 'Nearby',
                      style: GoogleFonts.oswald(
                        fontSize: rfs(11),
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: rh(4)),
                // Phone - Figma: phone icon 11.25x11.25 #000000 + Inter 12px
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: rw(11.25),
                      color: Colors.black, // Figma: #000000
                    ),
                    SizedBox(width: rw(6)),
                    Text(
                      contact.phone ?? '',
                      style: GoogleFonts.inter(
                        fontSize: rfs(11),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF353535), // Figma: rgb(0.208)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Map button - Figma: 18x18 #6A6A6A + "Map" #6A6A6A
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: rw(18),
                    color: const Color(0xFF6A6A6A),
                  ),
                  SizedBox(width: rw(2)),
                  Text(
                    'Map',
                    style: GoogleFonts.oswald(
                      fontSize: rfs(11),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6A6A6A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Map<String, dynamic> _toAdminDataMap(_UnifiedAdminItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'rating': item.rating.toStringAsFixed(1),
      'phone': item.phone ?? '',
      'address': item.address ?? '',
      'location': item.address ?? '',
      'image': item.imageUrl,
      'isOpen': item.isOpen,
      'openingTime': item.openingTime,
      'closingTime': item.closingTime,
      'operatingDays': item.operatingDays,
      'distance': item.distanceLabel,
      'itemTypeHint': 'ADMIN',
    };
  }
}

class _UnifiedAdminItem {
  final String id;
  final String name;
  final double rating;
  final String? phone;
  final bool isOpen;
  final String? address;
  final String? imageUrl;
  final String? openingTime;
  final String? closingTime;
  final List<String> operatingDays;
  final double? distanceKm;

  const _UnifiedAdminItem({
    required this.id,
    required this.name,
    required this.rating,
    required this.phone,
    required this.isOpen,
    required this.address,
    required this.imageUrl,
    required this.openingTime,
    required this.closingTime,
    required this.operatingDays,
    required this.distanceKm,
  });

  String? get distanceLabel =>
      distanceKm == null ? null : '${distanceKm!.toStringAsFixed(1)} Km away';

  factory _UnifiedAdminItem.fromOffice(
    AdminOfficeModel office, {
    double? userLat,
    double? userLng,
  }) {
    final parsed = _parseLatLngFromText(office.address);
    final km = _computeDistanceKm(
      userLat: userLat,
      userLng: userLng,
      entityLat: parsed?.$1,
      entityLng: parsed?.$2,
      fallbackKm: null,
    );

    return _UnifiedAdminItem(
      id: office.id,
      name: office.name,
      rating: office.rating,
      phone: office.phone,
      isOpen: office.isOpen,
      address: office.address,
      imageUrl: office.imageUrl,
      openingTime: null,
      closingTime: null,
      operatingDays: const <String>[],
      distanceKm: km,
    );
  }

  factory _UnifiedAdminItem.fromAmenity(
    AmenityModel amenity, {
    double? userLat,
    double? userLng,
  }) {
    final km = _computeDistanceKm(
      userLat: userLat,
      userLng: userLng,
      entityLat: amenity.latitude,
      entityLng: amenity.longitude,
      fallbackKm: amenity.distanceKm,
    );

    return _UnifiedAdminItem(
      id: amenity.id,
      name: amenity.name,
      rating: amenity.rating,
      phone: amenity.phone,
      isOpen: amenity.isOpen,
      address: amenity.location,
      imageUrl: amenity.imageUrl,
      openingTime: amenity.openingTime,
      closingTime: amenity.closingTime,
      operatingDays: amenity.operatingDays,
      distanceKm: km,
    );
  }

  _UnifiedAdminItem mergeWith(_UnifiedAdminItem other) {
    return _UnifiedAdminItem(
      id: id,
      name: name.isNotEmpty ? name : other.name,
      rating: rating > 0 ? rating : other.rating,
      phone: (phone ?? '').isNotEmpty ? phone : other.phone,
      isOpen: isOpen,
      address: (address ?? '').isNotEmpty ? address : other.address,
      imageUrl: (imageUrl ?? '').isNotEmpty ? imageUrl : other.imageUrl,
      openingTime: (openingTime ?? '').isNotEmpty ? openingTime : other.openingTime,
      closingTime: (closingTime ?? '').isNotEmpty ? closingTime : other.closingTime,
      operatingDays: operatingDays.isNotEmpty ? operatingDays : other.operatingDays,
      distanceKm: distanceKm ?? other.distanceKm,
    );
  }

  static (double, double)? _parseLatLngFromText(String? text) {
    final raw = (text ?? '').trim();
    if (raw.isEmpty) return null;

    final match = RegExp(r'(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)').firstMatch(raw);
    if (match == null) return null;

    final lat = double.tryParse(match.group(1)!);
    final lng = double.tryParse(match.group(2)!);
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  static double? _computeDistanceKm({
    required double? userLat,
    required double? userLng,
    required double? entityLat,
    required double? entityLng,
    required double? fallbackKm,
  }) {
    if (userLat == null || userLng == null || entityLat == null || entityLng == null) {
      return fallbackKm;
    }

    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(entityLat - userLat);
    final dLng = _degToRad(entityLng - userLng);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degToRad(userLat)) *
            cos(_degToRad(entityLat)) *
            (sin(dLng / 2) * sin(dLng / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * (3.141592653589793 / 180.0);
}


