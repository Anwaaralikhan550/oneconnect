import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/location_service.dart';

class PartnerStep5Screen extends StatefulWidget {
  const PartnerStep5Screen({super.key});

  @override
  State<PartnerStep5Screen> createState() => _PartnerStep5ScreenState();
}

class _PartnerStep5ScreenState extends State<PartnerStep5Screen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final LocationService _locationService = LocationService();
  String _selectedArea = '';
  String _selectedCity = '';
  String _selectedCountry = '';
  bool _isLoadingLocations = false;
  List<String> _apiCityOptions = [];
  List<String> _apiCountryOptions = [];
  Map<String, List<String>> _apiAreaByCity = {};
  static const List<String> _cityOptions = [];
  static const List<String> _countryOptions = ['Pakistan'];
  static const Map<String, List<String>> _areaByCity = {};

  List<String> get _areaOptions {
    if (_selectedCity.isEmpty) return const [];
    if (_apiAreaByCity.isNotEmpty) {
      return _apiAreaByCity[_selectedCity] ?? const [];
    }
    return _areaByCity[_selectedCity] ?? const [];
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedCountry = 'Pakistan';
    _selectedCity = 'Islamabad';
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    if (!mounted) return;
    _safeSetState(() => _isLoadingLocations = true);
    try {
      final groups = await _locationService.getLocations();
      if (!mounted) return;

      final map = <String, List<String>>{};
      final countries = <String>{};
      for (final group in groups) {
        countries.add(group.country);
        map[group.city] = group.areas;
      }
      final cities = map.keys.toList()..sort();
      final countryOptions = countries.isEmpty ? <String>['Pakistan'] : countries.toList()..sort();

      _safeSetState(() {
        _apiAreaByCity = map;
        _apiCityOptions = cities;
        _apiCountryOptions = countryOptions;
        if (_selectedCity.isEmpty || !_apiCityOptions.contains(_selectedCity)) {
          _selectedCity = _apiCityOptions.isNotEmpty ? _apiCityOptions.first : _selectedCity;
          _selectedArea = '';
        }
        if (_selectedCountry.isEmpty || !_apiCountryOptions.contains(_selectedCountry)) {
          _selectedCountry = _apiCountryOptions.first;
        }
      });
    } catch (_) {
      if (!mounted) return;
      _safeSetState(() {
        _apiAreaByCity = {};
        _apiCityOptions = [];
        _apiCountryOptions = ['Pakistan'];
      });
    } finally {
      if (!mounted) return;
      _safeSetState(() => _isLoadingLocations = false);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Safe responsive padding
    final horizontalPadding = screenWidth * 0.05; // 5% of screen width
    final verticalPadding = screenHeight * 0.02; // 2% of screen height

    // Responsive font and spacing
    final titleFontSize = screenWidth * 0.065; // Responsive title size
    final labelFontSize = screenWidth * 0.04; // Responsive label size
    final buttonHeight = screenHeight * 0.06; // 6% of screen height
    final mapHeight = screenHeight * 0.25; // 25% of screen height
    final areaOptions = _areaOptions;
    final cityOptions = _apiCityOptions.isNotEmpty ? _apiCityOptions : _cityOptions;
    final countryOptions = _apiCountryOptions.isNotEmpty ? _apiCountryOptions : _countryOptions;
    final isLoadingLocations = _isLoadingLocations;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Section
                    Padding(
                      padding: EdgeInsets.only(bottom: verticalPadding),
                      child: Text(
                        'What is your business address',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: titleFontSize.clamp(24.0, 32.0),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF000000),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),

                    // Map Container - Responsive
                    Container(
                      width: double.infinity,
                      height: mapHeight.clamp(200.0, 300.0),
                      margin: EdgeInsets.only(bottom: verticalPadding),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFF5F5F5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            // Map background
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/map_background_step5.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFFE0E0E0),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.map_outlined,
                                            size: 60,
                                            color: Color(0xFF9E9E9E),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Map View',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              color: Color(0xFF9E9E9E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Fade overlay at bottom
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x00FFFFFF),
                                      Color(0xFFFFFFFF),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Address Field
                    Container(
                      margin: EdgeInsets.only(bottom: verticalPadding),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label with icon
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 20,
                                color: Color(0xFF666666),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Address',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: labelFontSize.clamp(14.0, 18.0),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF19213D),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Text Area
                          Container(
                            constraints: BoxConstraints(
                              minHeight: screenHeight * 0.12, // Responsive height
                              maxHeight: screenHeight * 0.2,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _addressController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              enableInteractiveSelection: false,
                              contextMenuBuilder: (context, state) => const SizedBox.shrink(),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: labelFontSize.clamp(14.0, 16.0),
                                color: const Color(0xFF000000),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Write your complete address here...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color(0xFF9E9E9E),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Character count
                          Align(
                            alignment: Alignment.centerRight,
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _addressController,
                              builder: (context, value, child) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Color(0xFF666666),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${value.text.length}/240',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Color(0xFF666666),
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

                    // Area/Sector Dropdown (Error state)
                    _buildSelectField(
                      label: 'Area/Sector',
                      value: _selectedArea,
                      hint: isLoadingLocations ? 'Loading areas...' : 'Select area',
                      isError: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedArea = value ?? '';
                        });
                      },
                      items: areaOptions,
                      fontSize: labelFontSize,
                      bottomMargin: verticalPadding,
                    ),

                    // City Dropdown (Focused state)
                    _buildSelectField(
                      label: 'City',
                      value: _selectedCity,
                      hint: isLoadingLocations ? 'Loading cities...' : 'Select city',
                      isFocused: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value ?? '';
                          _selectedArea = '';
                        });
                      },
                      items: cityOptions,
                      fontSize: labelFontSize,
                      bottomMargin: verticalPadding,
                    ),

                    // Country Dropdown (Default state)
                    _buildSelectField(
                      label: 'Country',
                      value: _selectedCountry,
                      hint: 'Select country',
                      showLeftIcons: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value ?? '';
                        });
                      },
                      items: countryOptions,
                      fontSize: labelFontSize,
                      bottomMargin: verticalPadding * 1.5,
                    ),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight.clamp(48.0, 60.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final previousData = (ModalRoute.of(context)?.settings.arguments
                                as Map<String, dynamic>?) ?? {};
                            final mergedData = {
                              ...previousData,
                              'address': _addressController.text.trim(),
                              'area': _selectedArea.isNotEmpty ? _selectedArea : null,
                              'city': _selectedCity.isNotEmpty ? _selectedCity : null,
                              'country': _selectedCountry.isNotEmpty ? _selectedCountry : 'Pakistan',
                            };
                            Navigator.pushNamed(context, '/partner-step6', arguments: mergedData);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3499AF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: labelFontSize.clamp(16.0, 18.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Bottom spacing for safe area
                    SizedBox(height: verticalPadding),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectField({
    required String label,
    required String value,
    required String hint,
    required ValueChanged<String?> onChanged,
    required List<String> items,
    required double fontSize,
    required double bottomMargin,
    bool isError = false,
    bool isFocused = false,
    bool showLeftIcons = false,
  }) {
    Color borderColor = const Color(0xFFE0E0E0);
    if (isError) borderColor = const Color(0xFFE53E3E);
    if (isFocused) borderColor = const Color(0xFF3499AF);

    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: fontSize.clamp(14.0, 18.0),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF19213D),
              ),
            ),
          ),

          // Dropdown Field
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              border: Border.all(
                color: borderColor,
                width: isFocused ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (showLeftIcons) ...[
                    // Country Flag - Real flag implementation
                    _buildCountryFlag(value),
                    const SizedBox(width: 8),
                    // Currency icon
                    _buildCurrencyIcon(value),
                    const SizedBox(width: 12),
                  ],

                  // Dropdown - Remove inner border for Area and City
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: value.isEmpty ? null : value,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: fontSize.clamp(14.0, 16.0),
                          color: const Color(0xFF9E9E9E),
                        ),
                        // Remove all borders for Area and City dropdowns
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: fontSize.clamp(14.0, 16.0),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF000000),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onChanged,
                      dropdownColor: const Color(0xFFFFFFFF),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryFlag(String countryValue) {
    // Map countries to their flag emojis
    const Map<String, String> countryFlags = {
      'Pakistan': '🇵🇰',
      'United States': '🇺🇸',
      'United Kingdom': '🇬🇧',
      'Canada': '🇨🇦',
    };

    String flagEmoji = countryFlags[countryValue] ?? '🏳️';

    return Container(
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          flagEmoji,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCurrencyIcon(String countryValue) {
    // Map countries to their currency symbols/colors
    const Map<String, Map<String, dynamic>> currencyData = {
      'Pakistan': {'symbol': '₨', 'color': Color(0xFF01AA4D)},
      'United States': {'symbol': '\$', 'color': Color(0xFF007AFF)},
      'United Kingdom': {'symbol': '£', 'color': Color(0xFFAF52DE)},
      'Canada': {'symbol': 'C\$', 'color': Color(0xFFFF3B30)},
    };

    Map<String, dynamic> currency = currencyData[countryValue] ??
        {'symbol': '¤', 'color': const Color(0xFFFFC107)};

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: currency['color'],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          currency['symbol'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

