import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isRequestingPermission = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Top margin — welcome screen visible behind here
          SizedBox(height: height * 0.15),

          // Main card with rounded top corners
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle indicator
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Scrollable content area
                  Expanded(
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          _buildHeader(context, height * 0.92, width),

                          Padding(
                            padding: EdgeInsets.only(
                              top: height * 0.92 * 0.13,
                              left: width * 0.05,
                              right: width * 0.05,
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: height * 0.02),
                                Image.asset(
                                  'assets/images/location_pin_step3.png',
                                  width: width * 0.75,
                                ),

                                SizedBox(height: height * 0.03),
                                _buildTitleText(width),

                                SizedBox(height: height * 0.04),

                                _buildFeatureItem(
                                  context,
                                  'assets/images/map_search_icon.svg',
                                  'Searching the best amenities, services and SMEs near you',
                                  width,
                                ),

                                SizedBox(height: height * 0.03),

                                _buildFeatureItem(
                                  context,
                                  'assets/images/notification_icon.svg',
                                  'Receive more accurate and faster results',
                                  width,
                                ),

                                SizedBox(height: height * 0.03),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Fixed button at bottom
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                        vertical: height * 0.02,
                      ),
                      child: _buildContinueButton(context, width, height),
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

  Widget _buildHeader(BuildContext context, double height, double width) {
    return Container(
      height: height * 0.22,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xffF2F2F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(75),
          bottomRight: Radius.circular(75),
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/images/oneconnect_logo.svg',
        ),
      ),
    );
  }

  Widget _buildTitleText(double width) {
    return Text(
      'Allow location access on the next screen for:',
      style: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: width * 0.06, // Responsive font size
        height: 1.3,
        letterSpacing: -0.28,
        color: const Color(0xFF000000),
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildFeatureItem(BuildContext context, String iconPath, String text, double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: width * 0.12,
          height: width * 0.12,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              width: width * 0.06,
              height: width * 0.06,
              colorFilter: const ColorFilter.mode(
                Color(0xFF000000),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(width: width * 0.04),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: width * 0.035,
              height: 1.3,
              letterSpacing: -0.28,
              color: const Color(0xFF000000),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context, double width, double height) {
    // Responsive button height with min/max constraints
    final buttonHeight = (height * 0.06).clamp(48.0, 60.0);
    // Responsive font size with min/max constraints
    final fontSize = (width * 0.045).clamp(14.0, 18.0);

    return GestureDetector(
      onTap: _isRequestingPermission ? null : () => _requestLocationPermission(context),
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF3499AF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: _isRequestingPermission
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(
            'Continue',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              height: 1.26,
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    setState(() {
      _isRequestingPermission = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) _showLocationServiceDialog(context);
        setState(() => _isRequestingPermission = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) _showPermissionDeniedDialog(context);
        setState(() => _isRequestingPermission = false);
        return;
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        if (context.mounted) Navigator.pushReplacementNamed(context, '/signup');
      } else {
        if (context.mounted) _showPermissionDeniedDialog(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting location permission: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRequestingPermission = false;
      });
    }
  }

  void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Location services are disabled. Please enable them in your device settings to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'Location permission is required to provide you with the best nearby services. Please grant permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }
}
