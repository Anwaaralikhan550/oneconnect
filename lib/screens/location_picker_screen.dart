import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationPickResult {
  final double latitude;
  final double longitude;
  final String label;

  const LocationPickResult({
    required this.latitude,
    required this.longitude,
    required this.label,
  });
}

class LocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialLabel;

  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialLabel,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const LatLng _fallbackCenter = LatLng(31.5204, 74.3587);
  final MapController _mapController = MapController();
  LatLng? _selectedPoint;
  String _selectedLabel = 'Selected Location';
  bool _resolving = false;
  bool _locatingCurrent = false;

  LatLng get _initialCenter {
    final lat = widget.initialLatitude;
    final lng = widget.initialLongitude;
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return _fallbackCenter;
  }

  @override
  void initState() {
    super.initState();
    _selectedPoint = _initialCenter;
    final initialLabel = (widget.initialLabel ?? '').trim();
    if (initialLabel.isNotEmpty && initialLabel.toLowerCase() != 'current location') {
      _selectedLabel = initialLabel;
    } else {
      _selectedLabel = _latLngLabel(_selectedPoint!);
    }
    _resolveAddress(_selectedPoint!);
  }

  String _latLngLabel(LatLng value) {
    return '${value.latitude.toStringAsFixed(5)}, ${value.longitude.toStringAsFixed(5)}';
  }

  Future<void> _resolveAddress(LatLng point) async {
    setState(() => _resolving = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}&accept-language=en',
      );
      final res = await http.get(
        url,
        headers: const {
          'User-Agent': 'oneconnect-location-picker',
          'Accept-Language': 'en',
        },
      ).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body is Map<String, dynamic>) {
          final displayName = (body['display_name'] ?? '').toString().trim();
          if (displayName.isNotEmpty && mounted) {
            setState(() {
              _selectedLabel = displayName;
            });
          }
        }
      }
    } catch (_) {
      // Keep coordinate fallback when reverse geocoding is unavailable.
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_locatingCurrent) return;
    setState(() => _locatingCurrent = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final point = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;

      _mapController.move(point, 15);
      setState(() {
        _selectedPoint = point;
        _selectedLabel = _latLngLabel(point);
      });
      await _resolveAddress(point);
    } catch (_) {
      // Keep picker stable if current location is unavailable.
    } finally {
      if (mounted) setState(() => _locatingCurrent = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final point = _selectedPoint ?? _initialCenter;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0xFFEFF3F6),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: 13,
                  onTap: (_, latLng) {
                    setState(() {
                      _selectedPoint = latLng;
                      _selectedLabel = _latLngLabel(latLng);
                    });
                    _resolveAddress(latLng);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.oneconnect.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 42,
                        height: 42,
                        child: const Icon(
                          Icons.location_pin,
                          size: 42,
                          color: Color(0xFFD7263D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 116,
            child: SafeArea(
              child: FloatingActionButton(
                heroTag: 'current_location_fab',
                mini: true,
                onPressed: _locatingCurrent ? null : _goToCurrentLocation,
                child: _locatingCurrent
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _resolving
                            ? null
                            : () {
                                final selected = _selectedPoint ?? _initialCenter;
                                Navigator.pop(
                                  context,
                                  LocationPickResult(
                                    latitude: selected.latitude,
                                    longitude: selected.longitude,
                                    label: _selectedLabel,
                                  ),
                                );
                              },
                        child: Text(_resolving ? 'Resolving...' : 'Use This Location'),
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
}
