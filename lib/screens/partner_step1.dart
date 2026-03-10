import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PartnerStep1Screen extends StatelessWidget {
  const PartnerStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive calculations based on Figma design (390x844)
    final designWidth = 390.0;
    final designHeight = 844.0;
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25 * scale),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Welcome title
                    Container(
                      width: 296 * scale,
                      margin: EdgeInsets.only(bottom: 30 * scale),
                      child: Text(
                        'Welcome to the partner On Boarding process',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.21,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Onboarding illustration
                    Container(
                      width: 357 * scale,
                      height: 200 * scale,
                      margin: EdgeInsets.only(bottom: 20 * scale),
                      child: Image.asset(
                        'assets/images/onboarding_illustration.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(8 * scale),
                            ),
                            child: Icon(
                              Icons.business,
                              color: const Color(0xFF3499AF),
                              size: 80 * scale,
                            ),
                          );
                        },
                      ),
                    ),

                    // "Grow your business with" text
                    Text(
                      'Grow your business with',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.21,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 10 * scale),

                    // OneConnect logo
                    Container(
                      width: 220 * scale,
                      height: 50 * scale,
                      margin: EdgeInsets.only(bottom: 20 * scale),
                      child: Image.asset(
                        'assets/images/oneconnect_text_graphic.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'OneConnect',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 28 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3499AF),
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),

                    // Description text
                    SizedBox(
                      width: 273 * scale,
                      child: Text(
                        'Join thousands of partners, reaching new customer everyday  ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.21,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom button section
              Container(
                width: 326 * scale,
                padding: EdgeInsets.only(bottom: 25 * scale),
                child: Column(
                  children: [
                    // Next button
                    Container(
                      width: double.infinity,
                      height: 48 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3499AF),
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/partner-step2');
                          },
                          borderRadius: BorderRadius.circular(8 * scale),
                          child: Center(
                            child: Text(
                              'Next',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 15 * scale),

                    // Already have an account text
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/partner-login');
                      },
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          height: 1.21,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}