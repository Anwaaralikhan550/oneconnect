import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PartnerStep3Screen extends StatelessWidget {
  const PartnerStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive calculations based on Figma design (352x744 component size)
    final designWidth = 352.0;
    final designHeight = 744.0;
    final scaleWidth = screenWidth / designWidth;
    final scaleHeight = screenHeight / designHeight;
    final scale = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Pure white background
      body: SafeArea(
        child: Center(
          child: Container(
            width: 352 * scale,
            height: 744 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(
                color: const Color(0x26000000), // rgba(0, 0, 0, 0.15)
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24 * scale,
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30 * scale),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Title - exactly as in Figma with center alignment
                            Container(
                              width: 326 * scale,
                              margin: EdgeInsets.only(bottom: 30 * scale),
                              child: Text(
                                'Guide us to your location',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 28 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF000000),
                                  height: 1.2, // Figma line height
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            // Location pin illustration - 260x260 without shadow
                            Container(
                              width: 260 * scale,
                              height: 260 * scale,
                              margin: EdgeInsets.only(bottom: 30 * scale),
                              child: Image.asset(
                                'assets/images/location_pin_step3.png',
                                width: 260 * scale,
                                height: 260 * scale,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 260 * scale,
                                    height: 260 * scale,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(8 * scale),
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: const Color(0xFF3499AF),
                                      size: 120 * scale,
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Description text - exact Figma styling
                            SizedBox(
                              width: 300 * scale,
                              child: Text(
                                'Allow location access on the next screen',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 25 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF000000),
                                  height: 1.22,
                                  letterSpacing: -0.28,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom button - Frame 240 with exact positioning
                Container(
                  padding: EdgeInsets.only(bottom: 50 * scale),
                  child: Container(
                    width: 324 * scale,
                    height: 48 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3499AF), // Blue color as per Figma
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final args = ModalRoute.of(context)?.settings.arguments;
                          Navigator.pushNamed(context, '/partner-step4', arguments: args);
                        },
                        borderRadius: BorderRadius.circular(8 * scale),
                        child: Center(
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFFFFF),
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
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
}